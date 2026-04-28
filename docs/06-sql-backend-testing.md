# SQL Backend Testing Guide

Backend testing verifies that the database state supports the front-end and integration behavior. In healthcare claims, the database is often the best source for finding hidden defects: orphan records, mismatched statuses, incorrect amounts, missing denial codes, and duplicate payments.

The SQL script is here: [claims_backend_validation.sql](../artifacts/sql/claims_backend_validation.sql)

## Synthetic Data Model

```mermaid
erDiagram
    MEMBER ||--o{ CLAIM : "has claims"
    PROVIDER ||--o{ CLAIM : "submits"
    CLAIM ||--|{ CLAIM_LINE : "contains"
    CLAIM ||--o{ PAYMENT : "may generate"
    CLAIM ||--o{ CLAIM_STATUS_HISTORY : "tracks"
    CLAIM_LINE }o--|| PROCEDURE_CODE : "uses"
    CLAIM_LINE }o--|| DIAGNOSIS_CODE : "references"

    MEMBER {
        string member_id PK
        string plan_id
        date effective_date
        date termination_date
        string status
    }

    PROVIDER {
        string provider_id PK
        string network_status
        date contract_start
        date contract_end
    }

    CLAIM {
        string claim_id PK
        string member_id FK
        string provider_id FK
        date service_date
        string claim_status
        decimal billed_amount
        decimal allowed_amount
        decimal paid_amount
        string duplicate_flag
    }

    CLAIM_LINE {
        string claim_line_id PK
        string claim_id FK
        string procedure_code
        string diagnosis_code
        decimal billed_amount
        decimal allowed_amount
        decimal paid_amount
        string line_status
        string denial_reason_code
    }

    PAYMENT {
        string payment_id PK
        string claim_id FK
        decimal payment_amount
        date payment_date
        string remittance_id
    }
```

## Backend Checks To Run

| Check | Defect it can reveal |
|---|---|
| Claim header status differs from line status | UI/service may report the wrong status |
| Paid claim has no payment record | Financial output is incomplete |
| Denied claim has no denial reason | Business users cannot explain outcome |
| Paid amount exceeds allowed amount | Payment calculation defect |
| Claim service date outside member eligibility | Eligibility rule defect |
| Provider contract inactive on service date | Provider validation defect |
| Duplicate claim candidate paid automatically | Duplicate payment risk |
| Orphan claim line without claim header | Data integrity defect |

## SQL Testing Workflow

```mermaid
sequenceDiagram
    participant QA as QA Tester
    participant UI as Claims UI
    participant DB as Claims Database
    participant SOAP as Claim Status Service
    participant Jira as Jira

    QA->>UI: Execute manual claim scenario
    UI-->>QA: Display claim status and amounts
    QA->>DB: Run SQL validation query
    DB-->>QA: Return persisted claim state
    QA->>SOAP: Submit claim status inquiry
    SOAP-->>QA: Return XML status response
    QA->>QA: Compare UI, DB, and service result
    alt Results match expected behavior
        QA->>QA: Record pass evidence
    else Mismatch found
        QA->>Jira: Log defect with UI, SQL, and XML evidence
    end
```

## Evidence Standard

When a SQL check supports a test result, the evidence should record:

- query name;
- environment;
- claim ID or synthetic data key;
- execution timestamp;
- expected row count or expected value;
- actual row count or actual value;
- pass/fail conclusion;
- defect ID if failed.
