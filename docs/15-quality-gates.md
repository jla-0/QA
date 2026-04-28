# Quality Gates

Quality gates define what must be true before this portfolio or a real QA package is considered ready.

## Portfolio Gates

| Gate | Status |
|---|---|
| README explains the target role and value clearly | Complete |
| Mermaid diagrams render as Markdown code blocks | Complete |
| Test cases map to requirements | Complete |
| SQL checks map to backend risks | Complete |
| SOAP XML parses successfully | Complete |
| CSV artifacts import successfully | Complete |
| Markdown links resolve locally | Complete |
| Public files contain synthetic data only | Complete |
| GitHub Actions smoke check exists | Complete |

## Real Project Gates

```mermaid
flowchart TD
    A["Requirements approved"] --> B["Traceability complete"]
    B --> C["Test data approved"]
    C --> D["Functional tests executed"]
    D --> E["SQL checks executed"]
    E --> F["Integration checks executed"]
    F --> G["Defects triaged"]
    G --> H{"Critical or high defects open?"}
    H -- "Yes" --> I["Do not release without accepted risk"]
    H -- "No" --> J["Regression complete"]
    J --> K["Release recommendation"]

    classDef ready fill:#ECFDF5,stroke:#2F855A,color:#102A43;
    classDef risk fill:#FFF7ED,stroke:#C05621,color:#102A43;
    classDef decision fill:#E8F1FF,stroke:#2D5B9A,color:#102A43;
    class A,B,C,D,E,F,G,J,K ready;
    class I risk;
    class H decision;
```

## Smoke Check

The repository includes [tools/smoke_check.py](../tools/smoke_check.py), which validates:

- required files exist;
- CSV artifacts contain expected rows;
- SOAP XML files parse;
- Markdown code fences are balanced;
- local Markdown links resolve;
- the repository includes substantial Mermaid coverage.

