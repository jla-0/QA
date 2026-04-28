# Contributing

This is a portfolio repository, so contribution standards are written as if the project were maintained by a QA team.

## Standards

- Use synthetic data only.
- Do not commit PHI, credentials, access tokens, screenshots from real systems, or employer-confidential material.
- Keep test cases traceable to a requirement ID.
- Keep SQL checks tied to a named backend risk.
- Include human-readable context with every technical artifact.
- Prefer clear Markdown tables and Mermaid diagrams for reviewability.

## Review Checklist

Before opening a pull request:

- Run `python tools/smoke_check.py`.
- Confirm local Markdown links resolve.
- Confirm new examples contain no sensitive data.
- Update the README if the navigation changes.
- Update the traceability matrix if requirements or test cases change.

