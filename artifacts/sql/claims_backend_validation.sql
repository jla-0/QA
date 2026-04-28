-- Healthcare claims backend validation checks.
-- These queries are written in mostly portable SQL. Minor date or concatenation syntax may need adjustment for Oracle or SQL Server.
-- Data is synthetic and safe for portfolio use.

-- SQL-001: Paid claim header and line status should agree.
SELECT
    c.claim_id,
    c.claim_status,
    cl.claim_line_id,
    cl.line_status
FROM claims c
JOIN claim_lines cl
    ON c.claim_id = cl.claim_id
WHERE c.claim_status = 'PAID'
  AND cl.line_status <> 'PAID';

-- Expected result: zero rows.

-- SQL-002: Claims for inactive members on the service date should not pay.
SELECT
    c.claim_id,
    c.member_id,
    c.service_date,
    m.effective_date,
    m.termination_date,
    c.claim_status,
    c.paid_amount
FROM claims c
JOIN members m
    ON c.member_id = m.member_id
WHERE (
        c.service_date < m.effective_date
        OR (m.termination_date IS NOT NULL AND c.service_date > m.termination_date)
      )
  AND c.paid_amount > 0;

-- Expected result: zero rows.
-- QA note: In SQL Server and Oracle, the explicit parentheses prevent operator-precedence mistakes.

-- SQL-003: Duplicate claim candidates should not be paid automatically.
WITH duplicate_candidates AS (
    SELECT
        member_id,
        provider_id,
        service_date,
        billed_amount,
        COUNT(*) AS claim_count
    FROM claims
    GROUP BY member_id, provider_id, service_date, billed_amount
    HAVING COUNT(*) > 1
)
SELECT
    c.claim_id,
    c.member_id,
    c.provider_id,
    c.service_date,
    c.claim_status,
    c.paid_amount,
    c.duplicate_flag
FROM claims c
JOIN duplicate_candidates d
    ON c.member_id = d.member_id
   AND c.provider_id = d.provider_id
   AND c.service_date = d.service_date
   AND c.billed_amount = d.billed_amount
WHERE c.claim_status = 'PAID'
  AND c.duplicate_flag <> 'N';

-- Expected result: zero rows.

-- SQL-004: Claim status used by UI or SOAP should match latest status history.
WITH latest_status AS (
    SELECT
        claim_id,
        MAX(status_timestamp) AS latest_status_timestamp
    FROM claim_status_history
    GROUP BY claim_id
)
SELECT
    c.claim_id,
    c.claim_status AS claim_header_status,
    h.status_value AS latest_history_status,
    h.status_timestamp
FROM claims c
JOIN latest_status ls
    ON c.claim_id = ls.claim_id
JOIN claim_status_history h
    ON h.claim_id = ls.claim_id
   AND h.status_timestamp = ls.latest_status_timestamp
WHERE c.claim_status <> h.status_value;

-- Expected result: zero rows.

-- SQL-005: Paid claims should have payment and remittance records.
SELECT
    c.claim_id,
    c.claim_status,
    c.paid_amount,
    p.payment_id,
    p.payment_amount,
    p.remittance_id
FROM claims c
LEFT JOIN payments p
    ON c.claim_id = p.claim_id
WHERE c.claim_status = 'PAID'
  AND (p.payment_id IS NULL OR p.remittance_id IS NULL);

-- Expected result: zero rows.

-- SQL-006: Denied claim lines should have denial reason codes.
SELECT
    c.claim_id,
    cl.claim_line_id,
    cl.line_status,
    cl.denial_reason_code
FROM claims c
JOIN claim_lines cl
    ON c.claim_id = cl.claim_id
WHERE cl.line_status = 'DENIED'
  AND (cl.denial_reason_code IS NULL OR cl.denial_reason_code = '');

-- Expected result: zero rows.

-- SQL-007: Paid amount should never exceed allowed amount.
SELECT
    c.claim_id,
    c.allowed_amount,
    c.paid_amount
FROM claims c
WHERE c.paid_amount > c.allowed_amount
UNION ALL
SELECT
    cl.claim_id,
    cl.allowed_amount,
    cl.paid_amount
FROM claim_lines cl
WHERE cl.paid_amount > cl.allowed_amount;

-- Expected result: zero rows.

-- SQL-008: Claims for inactive provider contracts should not pay automatically.
SELECT
    c.claim_id,
    c.provider_id,
    c.service_date,
    p.contract_start,
    p.contract_end,
    c.claim_status,
    c.paid_amount
FROM claims c
JOIN providers p
    ON c.provider_id = p.provider_id
WHERE (
        c.service_date < p.contract_start
        OR (p.contract_end IS NOT NULL AND c.service_date > p.contract_end)
      )
  AND c.paid_amount > 0;

-- Expected result: zero rows.

-- SQL-009: Claim line totals should reconcile to claim header totals.
SELECT
    c.claim_id,
    c.billed_amount AS header_billed,
    line_totals.line_billed,
    c.allowed_amount AS header_allowed,
    line_totals.line_allowed,
    c.paid_amount AS header_paid,
    line_totals.line_paid
FROM claims c
JOIN (
    SELECT
        claim_id,
        SUM(billed_amount) AS line_billed,
        SUM(allowed_amount) AS line_allowed,
        SUM(paid_amount) AS line_paid
    FROM claim_lines
    GROUP BY claim_id
) line_totals
    ON c.claim_id = line_totals.claim_id
WHERE c.billed_amount <> line_totals.line_billed
   OR c.allowed_amount <> line_totals.line_allowed
   OR c.paid_amount <> line_totals.line_paid;

-- Expected result: zero rows.

-- SQL-010: Orphan claim lines should not exist.
SELECT
    cl.claim_line_id,
    cl.claim_id
FROM claim_lines cl
LEFT JOIN claims c
    ON cl.claim_id = c.claim_id
WHERE c.claim_id IS NULL;

-- Expected result: zero rows.
