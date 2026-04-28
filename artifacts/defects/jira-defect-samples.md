# Sample Jira Defects

These are portfolio-ready examples of how I would document defects for a healthcare claims QA role. All data is synthetic.

## DEFECT-001: Paid Claim Missing Payment Record

| Field | Value |
|---|---|
| Severity | Critical |
| Priority | P1 |
| Environment | QA |
| Requirement | BR-005 |
| Test Case | TC-006 |
| Synthetic Claim | CLM-5001 |

### Summary

Claim detail screen displays Paid status for CLM-5001, but backend validation shows no payment or remittance record.

### Steps To Reproduce

1. Log in as Claims QA user.
2. Search for claim CLM-5001.
3. Open claim detail.
4. Confirm claim status displays Paid.
5. Run SQL-005 payment/remittance validation query.

### Expected Result

Paid claim has a payment row and remittance ID.

### Actual Result

The claim displays as Paid, but payment_id and remittance_id are null in the backend query result.

### Impact

Financial and operational risk. Provider-facing payment/remittance output may be incomplete even though the claim appears paid.

### Retest Criteria

After fix deployment, CLM-5001 or an equivalent synthetic paid claim must display Paid status and return a payment row with a populated remittance ID.

## DEFECT-002: Denied Claim Line Missing Denial Reason

| Field | Value |
|---|---|
| Severity | High |
| Priority | P2 |
| Environment | QA |
| Requirement | BR-006 |
| Test Case | TC-007 |
| Synthetic Claim | CLM-5002 |

### Summary

Denied claim line does not display or store a denial reason code for inactive member scenario.

### Steps To Reproduce

1. Submit claim CLM-5002 for inactive member M-1002.
2. Open claim detail.
3. Review line-level denial reason.
4. Run SQL-006 denied-line validation query.

### Expected Result

Denied line includes denial reason code MEMBER_INACTIVE and user-visible denial explanation for authorized roles.

### Actual Result

Claim status is Denied, but line-level denial reason is blank.

### Impact

Business users cannot explain the denial. This can create provider/member service issues and rework.

### Retest Criteria

Denied inactive-member claims must store and display denial reason code MEMBER_INACTIVE.

## DEFECT-003: SOAP Claim Status Response Does Not Match Database

| Field | Value |
|---|---|
| Severity | High |
| Priority | P2 |
| Environment | Integration |
| Requirement | BR-004 |
| Test Case | TC-005 |
| Synthetic Claim | CLM-5003 |

### Summary

SOAP claim status inquiry returns Paid for a duplicate claim candidate that is stored as Suspended in the database.

### Steps To Reproduce

1. Submit SOAP claim status request for CLM-5003.
2. Confirm SOAP response returns ClaimStatus = PAID.
3. Run SQL-004 status validation query for CLM-5003.
4. Confirm claim header and latest status history show SUSPENDED.

### Expected Result

SOAP response status matches latest database claim status.

### Actual Result

SOAP returns Paid while the database stores Suspended.

### Impact

External or service users may receive incorrect claim status, creating operational confusion and potential payment inquiry errors.

### Retest Criteria

SOAP response for CLM-5003 must return Suspended or the correct current status from the source of truth.

