#!/usr/bin/env python3
"""parity_check.py - check 4

Compares the MD5 of each $$ body in sql/ against deployed PROCEDURE_DEFINITION.
Does not connect to Snowflake. Takes the deployed side as an argument.

Usage:
    python parity_check.py <sql_dir> <deployed_csv>
    python parity_check.py --self-test <sql_dir> <deployed_csv> <probes_dir>

deployed_csv format (no header):
    PROCEDURE_SCHEMA,PROCEDURE_NAME,DEPLOYED_MD5

The CSV must be regenerated from INFORMATION_SCHEMA.PROCEDURES immediately
before every run. It is a point-in-time snapshot that goes stale on the next
deploy. Delete it after each parity run.

Exit codes:
    0  pass
    1  fault detected
    2  check broken
"""
import sys
import os
import hashlib
import csv
import shutil
import tempfile

EXIT_PASS = 0
EXIT_FAULT = 1
EXIT_BROKEN = 2

FOLDER_TO_SCHEMA = {
    'staging': 'STAGING',
    'xref_snapshot': 'XREF_SNAPSHOT',
    'transformation': 'TRANSFORMATION',
    'semantic': 'SEMANTIC',
}

SCHEMA_TO_FOLDER = {v: k for k, v in FOLDER_TO_SCHEMA.items()}


def extract_body(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    idx1 = content.find('$$')
    if idx1 < 0:
        return None
    idx2 = content.find('$$', idx1 + 2)
    if idx2 < 0:
        return None
    return content[idx1 + 2:idx2]


def md5_of(text):
    return hashlib.md5(text.encode('utf-8')).hexdigest()


def walk_sql(sql_dir):
    """Return dict of (schema, proc_name) -> (file_md5, file_path, folder_name)
    and a boolean indicating whether any .sql files were found."""
    files = {}
    found_any = False
    for folder_name, schema in sorted(FOLDER_TO_SCHEMA.items()):
        folder_path = os.path.join(sql_dir, folder_name)
        if not os.path.isdir(folder_path):
            continue
        for fname in sorted(os.listdir(folder_path)):
            if not fname.upper().endswith('.SQL'):
                continue
            found_any = True
            fpath = os.path.join(folder_path, fname)
            proc_name = os.path.splitext(fname)[0].upper()
            body = extract_body(fpath)
            if body is None:
                files[(schema, proc_name)] = (None, fpath, folder_name)
            else:
                files[(schema, proc_name)] = (md5_of(body), fpath, folder_name)
    return files, found_any


def parse_deployed(deployed_path):
    """Return dict of (schema, proc_name) -> deployed_md5."""
    deployed = {}
    with open(deployed_path, 'r', encoding='utf-8') as f:
        reader = csv.reader(f)
        for row in reader:
            if len(row) >= 3:
                schema = row[0].strip()
                name = row[1].strip()
                dep_md5 = row[2].strip()
                deployed[(schema, name)] = dep_md5
    return deployed


def run_check(sql_dir, deployed_path):
    """Run the parity check. Returns (exit_code, list_of_messages)."""
    messages = []
    faults = []

    files, found_any = walk_sql(sql_dir)

    if not found_any:
        return EXIT_BROKEN, ['BROKEN: no .sql files found under ' + sql_dir]

    try:
        deployed = parse_deployed(deployed_path)
    except (IOError, OSError) as e:
        return EXIT_BROKEN, ['BROKEN: cannot read deployed CSV: %s' % e]
    except (UnicodeDecodeError, csv.Error) as e:
        return EXIT_BROKEN, ['BROKEN: malformed deployed CSV: %s' % e]

    for (schema, proc_name), (file_md5, fpath, folder) in sorted(files.items()):
        if (schema, proc_name) in deployed:
            dep_md5 = deployed[(schema, proc_name)]
            if file_md5 is None:
                faults.append('FAULT: %s has no $$ delimiters' % fpath)
            elif file_md5 != dep_md5:
                faults.append(
                    'FAULT: hash mismatch on %s.%s (file=%s, deployed=%s)'
                    % (schema, proc_name, file_md5, dep_md5))
            else:
                messages.append('OK: %s.%s' % (schema, proc_name))
        else:
            found_elsewhere = None
            for (ds, dn) in deployed:
                if dn == proc_name and ds != schema:
                    found_elsewhere = ds
                    break
            if found_elsewhere:
                faults.append(
                    'FAULT: %s is in folder %s/ (schema %s) '
                    'but deployed in %s'
                    % (fpath, folder, schema, found_elsewhere))
            else:
                faults.append('FAULT: stray file %s - deployed nowhere' % fpath)

    for (schema, proc_name) in sorted(deployed.keys()):
        if (schema, proc_name) not in files:
            found_wrong_folder = False
            for (fs, fn) in files:
                if fn == proc_name and fs != schema:
                    found_wrong_folder = True
                    break
            if not found_wrong_folder:
                faults.append(
                    'FAULT: %s.%s is deployed but has no file'
                    % (schema, proc_name))

    if faults:
        return EXIT_FAULT, messages + faults
    return EXIT_PASS, messages


def self_test(sql_dir, deployed_path, probes_dir):
    """Run all six fault scenarios. Returns (pass_count, fail_count, messages)."""
    probe_file = None
    for fname in os.listdir(probes_dir):
        if fname.upper().endswith('.SQL'):
            probe_file = os.path.join(probes_dir, fname)
            break
    if probe_file is None:
        return 0, 0, ['BROKEN: no probe .sql file found in ' + probes_dir]

    probe_name = os.path.splitext(os.path.basename(probe_file))[0].upper()
    probe_body = extract_body(probe_file)
    if probe_body is None:
        return 0, 0, ['BROKEN: probe file has no $$ delimiters']
    probe_md5 = md5_of(probe_body)

    try:
        parse_deployed(deployed_path)
    except (IOError, OSError, UnicodeDecodeError, csv.Error) as e:
        return 0, 0, ['BROKEN: cannot read deployed CSV: %s' % e]

    injected_files = []
    injected_csvs = []
    passed = 0
    failed = 0
    results = []

    try:
        # -- fault 1: clean baseline -> EXIT_PASS
        code, msgs = run_check(sql_dir, deployed_path)
        if code == EXIT_PASS:
            passed += 1
            results.append('FAULT 1 (clean baseline): PASS')
        else:
            failed += 1
            results.append('FAULT 1 (clean baseline): FAIL - expected pass, got %d' % code)
            for m in msgs:
                results.append('  ' + m)

        # -- fault 2: wrong hash -> EXIT_FAULT with "hash mismatch"
        target = os.path.join(sql_dir, 'staging', os.path.basename(probe_file))
        shutil.copy2(probe_file, target)
        injected_files.append(target)
        tmp_csv = tempfile.NamedTemporaryFile(
            mode='w', suffix='.csv', delete=False, encoding='utf-8')
        injected_csvs.append(tmp_csv.name)
        writer = csv.writer(tmp_csv)
        with open(deployed_path, 'r', encoding='utf-8') as f:
            for row in csv.reader(f):
                writer.writerow(row)
        writer.writerow(['STAGING', probe_name, 'deadbeef00000000deadbeef00000000'])
        tmp_csv.close()
        code, msgs = run_check(sql_dir, tmp_csv.name)
        has_mismatch = any('hash mismatch' in m and probe_name in m for m in msgs)
        if code == EXIT_FAULT and has_mismatch:
            passed += 1
            results.append('FAULT 2 (wrong hash): PASS')
        else:
            failed += 1
            results.append('FAULT 2 (wrong hash): FAIL - code=%d, mismatch_found=%s' % (code, has_mismatch))
        os.remove(target)
        injected_files.remove(target)

        # -- fault 3: stray file deployed nowhere -> EXIT_FAULT with "stray"
        target = os.path.join(sql_dir, 'staging', os.path.basename(probe_file))
        shutil.copy2(probe_file, target)
        injected_files.append(target)
        code, msgs = run_check(sql_dir, deployed_path)
        has_stray = any('stray' in m.lower() and probe_name in m for m in msgs)
        if code == EXIT_FAULT and has_stray:
            passed += 1
            results.append('FAULT 3 (stray file): PASS')
        else:
            failed += 1
            results.append('FAULT 3 (stray file): FAIL - code=%d, stray_found=%s' % (code, has_stray))
        os.remove(target)
        injected_files.remove(target)

        # -- fault 4: deployed object with no file -> EXIT_FAULT with "no file"
        tmp_csv2 = tempfile.NamedTemporaryFile(
            mode='w', suffix='.csv', delete=False, encoding='utf-8')
        injected_csvs.append(tmp_csv2.name)
        writer2 = csv.writer(tmp_csv2)
        with open(deployed_path, 'r', encoding='utf-8') as f:
            for row in csv.reader(f):
                writer2.writerow(row)
        writer2.writerow(['STAGING', 'SPROC_PHANTOM_PROC', probe_md5])
        tmp_csv2.close()
        code, msgs = run_check(sql_dir, tmp_csv2.name)
        has_nofile = any('no file' in m.lower() and 'SPROC_PHANTOM_PROC' in m for m in msgs)
        if code == EXIT_FAULT and has_nofile:
            passed += 1
            results.append('FAULT 4 (deployed, no file): PASS')
        else:
            failed += 1
            results.append('FAULT 4 (deployed, no file): FAIL - code=%d, nofile_found=%s' % (code, has_nofile))

        # -- fault 5: file in wrong layer folder -> fails on folder, not hash
        target = os.path.join(sql_dir, 'staging', os.path.basename(probe_file))
        shutil.copy2(probe_file, target)
        injected_files.append(target)
        tmp_csv3 = tempfile.NamedTemporaryFile(
            mode='w', suffix='.csv', delete=False, encoding='utf-8')
        injected_csvs.append(tmp_csv3.name)
        writer3 = csv.writer(tmp_csv3)
        with open(deployed_path, 'r', encoding='utf-8') as f:
            for row in csv.reader(f):
                writer3.writerow(row)
        writer3.writerow(['XREF_SNAPSHOT', probe_name, probe_md5])
        tmp_csv3.close()
        code, msgs = run_check(sql_dir, tmp_csv3.name)
        has_folder_fault = any(
            ('wrong' in m.lower() or 'but deployed in' in m.lower())
            and probe_name in m
            for m in msgs)
        has_hash_fault = any('hash mismatch' in m and probe_name in m for m in msgs)
        if code == EXIT_FAULT and has_folder_fault and not has_hash_fault:
            passed += 1
            results.append('FAULT 5 (wrong folder): PASS')
        else:
            failed += 1
            results.append(
                'FAULT 5 (wrong folder): FAIL - code=%d, folder_fault=%s, hash_fault=%s'
                % (code, has_folder_fault, has_hash_fault))
        os.remove(target)
        injected_files.remove(target)

        # -- fault 6: recursion finds nothing -> EXIT_BROKEN
        empty_dir = tempfile.mkdtemp()
        for folder_name in FOLDER_TO_SCHEMA:
            os.makedirs(os.path.join(empty_dir, folder_name), exist_ok=True)
        code, msgs = run_check(empty_dir, deployed_path)
        shutil.rmtree(empty_dir)
        if code == EXIT_BROKEN:
            passed += 1
            results.append('FAULT 6 (empty tree): PASS')
        else:
            failed += 1
            results.append('FAULT 6 (empty tree): FAIL - expected BROKEN(2), got %d' % code)

    finally:
        for f in injected_files:
            if os.path.exists(f):
                os.remove(f)
        for f in injected_csvs:
            if os.path.exists(f):
                os.remove(f)

        # assert the tree is clean after probe removal
        current_files, _ = walk_sql(sql_dir)
        file_keys = set(current_files.keys())
        probe_keys = {k for k in file_keys
                      if probe_name in k[1] or 'PHANTOM' in k[1]}
        if probe_keys:
            failed += 1
            results.append(
                'CLEANUP FAILURE: probe files remain: %s'
                % ', '.join('%s.%s' % k for k in probe_keys))

    return passed, failed, results


def main():
    if len(sys.argv) < 3:
        print('usage: parity_check.py [--self-test] <sql_dir> <deployed_csv> [probes_dir]',
              file=sys.stderr)
        sys.exit(EXIT_BROKEN)

    if sys.argv[1] == '--self-test':
        if len(sys.argv) < 5:
            print('usage: parity_check.py --self-test <sql_dir> <deployed_csv> <probes_dir>',
                  file=sys.stderr)
            sys.exit(EXIT_BROKEN)
        sql_dir = sys.argv[2]
        deployed_path = sys.argv[3]
        probes_dir = sys.argv[4]
        passed, failed, results = self_test(sql_dir, deployed_path, probes_dir)
        for r in results:
            print(r)
        print()
        print('%d passed, %d failed' % (passed, failed))
        # a self-test that ran nothing is broken, never a pass
        if any(r.startswith('BROKEN') for r in results) or passed + failed == 0:
            sys.exit(EXIT_BROKEN)
        if failed > 0:
            sys.exit(EXIT_FAULT)
        sys.exit(EXIT_PASS)
    else:
        sql_dir = sys.argv[1]
        deployed_path = sys.argv[2]
        code, msgs = run_check(sql_dir, deployed_path)
        for m in msgs:
            print(m)
        sys.exit(code)


if __name__ == '__main__':
    main()
