-- SPROC_PROBE_FAULT -- parity self-test probe. Never deployed.
-- Used by scripts/parity_check.py --self-test to inject faults.
CREATE OR REPLACE PROCEDURE DEV_G2M_AI.STAGING.SPROC_PROBE_FAULT()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
    RETURN 'probe';
END;
$$;
