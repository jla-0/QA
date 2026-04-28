from __future__ import annotations

import csv
import re
import sys
from pathlib import Path
from xml.etree import ElementTree


ROOT = Path(__file__).resolve().parents[1]


REQUIRED_FILES = [
    "README.md",
    "docs/00-job-walkthrough.md",
    "docs/02-qa-strategy.md",
    "docs/03-test-plan.md",
    "docs/04-requirements-traceability-matrix.md",
    "docs/06-sql-backend-testing.md",
    "docs/07-edi-and-soap-testing.md",
    "artifacts/test-cases/claims-test-cases.csv",
    "artifacts/traceability/requirements-traceability-matrix.csv",
    "artifacts/sql/claims_backend_validation.sql",
    "artifacts/soap/claim-status-request.xml",
    "artifacts/soap/claim-status-response.xml",
]


CSV_MIN_ROWS = {
    "artifacts/test-cases/claims-test-cases.csv": 10,
    "artifacts/traceability/requirements-traceability-matrix.csv": 10,
    "artifacts/data/synthetic_claims.csv": 5,
    "artifacts/data/synthetic_claim_lines.csv": 5,
}


def fail(message: str) -> None:
    print(f"FAIL: {message}")
    sys.exit(1)


def check_required_files() -> None:
    missing = [path for path in REQUIRED_FILES if not (ROOT / path).is_file()]
    if missing:
        fail("Missing required files: " + ", ".join(missing))


def check_csvs() -> None:
    for rel_path, minimum in CSV_MIN_ROWS.items():
        path = ROOT / rel_path
        with path.open(newline="", encoding="utf-8") as handle:
            rows = list(csv.DictReader(handle))
        if len(rows) < minimum:
            fail(f"{rel_path} has {len(rows)} rows; expected at least {minimum}")
        if not rows:
            fail(f"{rel_path} has no data rows")


def check_xml() -> None:
    for rel_path in [
        "artifacts/soap/claim-status-request.xml",
        "artifacts/soap/claim-status-response.xml",
    ]:
        try:
            ElementTree.parse(ROOT / rel_path)
        except ElementTree.ParseError as exc:
            fail(f"{rel_path} is not valid XML: {exc}")


def check_markdown_fences_and_links() -> None:
    local_link_pattern = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
    for path in ROOT.rglob("*.md"):
        text = path.read_text(encoding="utf-8")
        if text.count("```") % 2:
            fail(f"{path.relative_to(ROOT)} has unbalanced code fences")

        for match in local_link_pattern.finditer(text):
            target = match.group(1)
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            clean_target = target.split("#", 1)[0]
            if not clean_target:
                continue
            resolved = (path.parent / clean_target).resolve()
            if not resolved.exists():
                fail(
                    f"{path.relative_to(ROOT)} links to missing local target: {target}"
                )


def check_mermaid_presence() -> None:
    mermaid_count = 0
    for path in ROOT.rglob("*.md"):
        mermaid_count += path.read_text(encoding="utf-8").count("```mermaid")
    if mermaid_count < 10:
        fail(f"Expected at least 10 Mermaid diagrams, found {mermaid_count}")


def main() -> None:
    check_required_files()
    check_csvs()
    check_xml()
    check_markdown_fences_and_links()
    check_mermaid_presence()
    print("Portfolio smoke check passed.")


if __name__ == "__main__":
    main()

