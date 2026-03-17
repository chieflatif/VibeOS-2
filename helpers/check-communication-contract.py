#!/usr/bin/env python3
"""Verify business-first communication guidance remains embedded in key surfaces."""

from __future__ import annotations

import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent


def require_contains(errors: list[str], path: Path, needles: list[str]) -> None:
    content = path.read_text()
    for needle in needles:
        if needle not in content:
            errors.append(f"{path.relative_to(REPO_ROOT)} missing expected text: {needle}")


def main() -> int:
    errors: list[str] = []

    contract_path = REPO_ROOT / "docs" / "USER-COMMUNICATION-CONTRACT.md"
    if not contract_path.exists():
        print("[check-communication-contract] FAIL: missing docs/USER-COMMUNICATION-CONTRACT.md")
        return 1

    require_contains(
        errors,
        contract_path,
        [
            "Business Meaning First",
            "Always Explain What Is Next",
            "Options Must Be Outcome-First",
            "What we just achieved",
            "No-Code Expectation",
            "The agent runs",
            "Project is embedded",
            "Choices Require Reasoning",
            "make a recommendation",
            "rationale",
            "Use the Technical Term and Explain It",
            "Midstream Embedding",
            "Development Plan Is the Roadmap",
            "never asks",
        ],
    )

    require_contains(
        errors,
        REPO_ROOT / "README.md",
        [
            "Built For Vibe Coders",
            "What The Agent Should Sound Like",
            "plain English",
        ],
    )

    require_contains(
        errors,
        REPO_ROOT / "AGENT-BOOTSTRAP.md",
        [
            "USER COMMUNICATION CONTRACT",
            "business meaning",
            "outcome language first",
            "What we just achieved",
        ],
    )

    require_contains(
        errors,
        REPO_ROOT / "reference" / "claude" / "CLAUDE.md.ref",
        [
            "### Communication Style",
            "executive or business summary",
            "Recommended next step and why",
        ],
    )

    require_contains(
        errors,
        REPO_ROOT / "reference" / "cursor" / "cursorrules.ref",
        [
            "### Communication Style",
            "business meaning",
            "Required Response Pattern",
        ],
    )

    require_contains(
        errors,
        REPO_ROOT / "reference" / "codex" / "AGENTS.md.ref",
        [
            "### Communication Style",
            "business meaning",
            "Required Response Pattern",
        ],
    )

    for skill_name in ("wo-research.md.ref", "wo-audit.md.ref", "wo-complete.md.ref", "post-phase-audit.md.ref"):
        require_contains(
            errors,
            REPO_ROOT / "reference" / "skills" / skill_name,
            [
                "Executive summary",
                "Recommended next step",
            ],
        )

    if errors:
        print("[check-communication-contract] FAIL:")
        for item in errors:
            print(f"  - {item}")
        return 1

    print("[check-communication-contract] PASS: communication contract is embedded in key surfaces")
    return 0


if __name__ == "__main__":
    sys.exit(main())
