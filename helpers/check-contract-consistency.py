#!/usr/bin/env python3
"""Minimal Release A contract consistency checker."""

from __future__ import annotations

import json
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent

CONTRACT_PATH = REPO_ROOT / "docs" / "canonical-contract.json"
BOOTSTRAP_PATH = REPO_ROOT / "AGENT-BOOTSTRAP.md"
PHASE_SELECTION_PATH = REPO_ROOT / "decision-engine" / "phase-selection.md"
HOOK_SELECTION_PATH = REPO_ROOT / "decision-engine" / "hook-selection.md"
MANIFEST_REF_PATH = REPO_ROOT / "reference" / "manifests" / "quality-gate-manifest.json.ref"
SETTINGS_REF_PATH = REPO_ROOT / "reference" / "claude" / "settings.json.ref"


def load_json(path: Path) -> dict:
    with path.open() as handle:
        return json.load(handle)


def require_contains(errors: list[str], content: str, path: Path, needle: str) -> None:
    if needle not in content:
        errors.append(f"{path.relative_to(REPO_ROOT)} missing expected text: {needle}")


def require_absent(errors: list[str], content: str, path: Path, needle: str) -> None:
    if needle in content:
        errors.append(f"{path.relative_to(REPO_ROOT)} contains stale text: {needle}")


def main() -> int:
    contract = load_json(CONTRACT_PATH)
    manifest_ref = load_json(MANIFEST_REF_PATH)
    settings_ref = load_json(SETTINGS_REF_PATH)

    bootstrap = BOOTSTRAP_PATH.read_text()
    phase_selection = PHASE_SELECTION_PATH.read_text()
    hook_selection = HOOK_SELECTION_PATH.read_text()

    errors: list[str] = []

    # Manifest expectations
    manifest_paths = contract["manifest"]["runner_lookup_order"]
    for manifest_path in manifest_paths:
        require_contains(errors, bootstrap, BOOTSTRAP_PATH, manifest_path)

    require_contains(errors, bootstrap, BOOTSTRAP_PATH, '"wo_exit"')
    require_contains(errors, phase_selection, PHASE_SELECTION_PATH, "wo_exit")

    # Hook events
    hook_events = contract["hooks"]["claude_events"]
    settings_hooks = settings_ref.get("hooks", {})
    for event_name in hook_events:
        if event_name not in settings_hooks:
            errors.append(
                f"{SETTINGS_REF_PATH.relative_to(REPO_ROOT)} missing hook event: {event_name}"
            )
        require_contains(errors, bootstrap, BOOTSTRAP_PATH, event_name)
        require_contains(errors, hook_selection, HOOK_SELECTION_PATH, event_name)

    for stale_name in ("PostToolUse\": [", "SubagentComplete", "$TOOL_INPUT", "$USER_PROMPT", "$SUBAGENT_OUTPUT"):
        require_absent(errors, bootstrap, BOOTSTRAP_PATH, stale_name)
        require_absent(errors, hook_selection, HOOK_SELECTION_PATH, stale_name)

    # Manifest schema basics
    for field in ("version", "project", "tiers", "phases", "known_baselines"):
        if field not in manifest_ref:
            errors.append(
                f"{MANIFEST_REF_PATH.relative_to(REPO_ROOT)} missing top-level field: {field}"
            )

    for phase_name in ("session_start", "pre_commit", "wo_exit", "full_audit"):
        if phase_name not in manifest_ref.get("phases", {}):
            errors.append(
                f"{MANIFEST_REF_PATH.relative_to(REPO_ROOT)} missing canonical phase: {phase_name}"
            )

    if errors:
        print("[check-contract-consistency] FAIL:")
        for issue in errors:
            print(f"  - {issue}")
        return 1

    print("[check-contract-consistency] PASS: core contract surfaces are aligned")
    return 0


if __name__ == "__main__":
    sys.exit(main())
