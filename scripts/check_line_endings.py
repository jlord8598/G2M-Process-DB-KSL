#!/usr/bin/env python3
"""check_line_endings.py -- fail on CRLF line endings and non-ASCII .sql files.

Reads files only. Never connects to Snowflake (CLAUDE.md section 11).

Scans sql/, scripts/ and docs/ under the repo root:
  * any text file containing CRLF        -> fault
  * any .sql file containing a non-ASCII byte -> fault (breaks parity)

Usage:
  python scripts/check_line_endings.py [repo_root] [--fix]

  --fix rewrites CRLF files with LF in place. It never touches non-ASCII
  content; those must be rewritten by hand.

Exit codes:
  0  pass           no faults
  1  fault detected at least one CRLF file or non-ASCII .sql file
  2  check broken   repo root missing, no scan folder present, or no files found
"""
import os
import sys

EXIT_PASS, EXIT_FAULT, EXIT_BROKEN = 0, 1, 2
SCAN_DIRS = ("sql", "scripts", "docs")
TEXT_EXTS = {".sql", ".md", ".py", ".txt", ".csv", ".json", ".yml", ".yaml"}


def main(argv):
    fix = "--fix" in argv
    args = [a for a in argv if a != "--fix"]
    root = os.path.abspath(args[0] if args else ".")

    if not os.path.isdir(root):
        print("BROKEN: repo root not found: %s" % root)
        return EXIT_BROKEN

    present = [d for d in SCAN_DIRS if os.path.isdir(os.path.join(root, d))]
    if not present:
        print("BROKEN: none of %s found under %s" % (", ".join(SCAN_DIRS), root))
        return EXIT_BROKEN

    scanned, faults = 0, []
    for d in present:
        for dirpath, _, files in os.walk(os.path.join(root, d)):
            for name in sorted(files):
                ext = os.path.splitext(name)[1].lower()
                if ext not in TEXT_EXTS:
                    continue
                path = os.path.join(dirpath, name)
                rel = os.path.relpath(path, root)
                try:
                    with open(path, "rb") as fh:
                        data = fh.read()
                except (IOError, OSError) as exc:
                    print("BROKEN: cannot read %s: %s" % (rel, exc))
                    return EXIT_BROKEN
                scanned += 1

                if b"\r\n" in data:
                    if fix:
                        with open(path, "wb") as fh:
                            fh.write(data.replace(b"\r\n", b"\n"))
                        print("FIXED: %s converted CRLF -> LF" % rel)
                    else:
                        faults.append("FAULT: %s has CRLF line endings (%d)"
                                      % (rel, data.count(b"\r\n")))

                if ext == ".sql":
                    bad = [i for i, b in enumerate(data) if b > 127]
                    if bad:
                        line = data[:bad[0]].count(b"\n") + 1
                        faults.append("FAULT: %s has %d non-ASCII byte(s), first on line %d"
                                      % (rel, len(bad), line))

    if scanned == 0:
        print("BROKEN: no text files found under %s" % ", ".join(present))
        return EXIT_BROKEN

    for f in faults:
        print(f)
    if faults:
        print("%d fault(s) in %d file(s) scanned" % (len(faults), scanned))
        return EXIT_FAULT
    print("OK: %d file(s) scanned, all LF, all .sql ASCII" % scanned)
    return EXIT_PASS


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
