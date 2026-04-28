# HIPAA And PHI Test Data Strategy

This role is marked high risk because it may expose the tester to PHI-sensitive data. That changes how testing should be planned, executed, documented, and shared.

## Core Principle

Use the minimum necessary data for the testing purpose. Prefer synthetic data. Do not move PHI into screenshots, documents, chat, tickets, or public repositories.

## Data Handling Model

```mermaid
flowchart TD
    NEED["Testing need identified"] --> SYN{"Can synthetic data prove the behavior?"}
    SYN -- "Yes" --> USESYN["Use synthetic member, provider, and claim data"]
    SYN -- "No" --> APPROVAL["Request approved controlled access"]
    APPROVAL --> MIN["Use minimum necessary real data"]
    MIN --> REDACT["Redact evidence before ticket attachment"]
    USESYN --> EVIDENCE["Attach safe evidence"]
    REDACT --> EVIDENCE
    EVIDENCE --> REVIEW["Review ticket for PHI leakage"]
    REVIEW --> STORE["Store evidence in approved system only"]

    classDef safe fill:#ECFDF5,stroke:#2F855A,color:#102A43;
    classDef risk fill:#FFF7ED,stroke:#C05621,color:#102A43;
    classDef control fill:#E8F1FF,stroke:#2D5B9A,color:#102A43;
    class USESYN,EVIDENCE,REVIEW,STORE safe;
    class APPROVAL,MIN,REDACT risk;
    class NEED,SYN control;
```

## Public Portfolio Rules Used Here

- No real names.
- No real member IDs.
- No real claim IDs.
- No real provider data.
- No real diagnosis tied to a real person.
- No employer-confidential workflows.
- No screenshots from real systems.
- No protected production data.

## On-The-Job Evidence Rules

| Evidence type | Safe handling |
|---|---|
| Screenshot | Use synthetic data or redact PHI before attaching |
| SQL result | Limit columns to what proves the result |
| Logs | Remove tokens, credentials, identifiers, and PHI |
| XML request/response | Use synthetic identifiers or mask restricted fields |
| Jira defect | Include enough detail to reproduce without unnecessary exposure |
| Test summary | Aggregate results, not patient-level details |

## HIPAA-Aware QA Behaviors

- Validate role-based access and masking.
- Avoid downloading data unless required and approved.
- Do not store PHI locally.
- Do not paste PHI into external tools.
- Confirm test accounts have appropriate role permissions.
- Keep evidence in approved systems.
- Use synthetic data for reusable regression scenarios.

