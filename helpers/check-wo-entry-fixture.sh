#!/usr/bin/env bash
# VibeOS-2 — WO Entry Audit Fixture
# Verifies wo_entry blocks implementation until required audits are complete.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/scripts" "$TMP_DIR/docs/planning"
cp "$REPO_ROOT/scripts/gate-runner.sh" "$TMP_DIR/scripts/gate-runner.sh"
cp "$REPO_ROOT/scripts/validate-work-order.sh" "$TMP_DIR/scripts/validate-work-order.sh"

cat > "$TMP_DIR/quality-gate-manifest.json" <<'EOF'
{
  "version": "1.0.0",
  "project": {
    "name": "wo-entry-fixture",
    "slug": "wo-entry-fixture",
    "language": "bash",
    "framework": "none"
  },
  "tiers": {
    "0": { "label": "critical", "blocking": true },
    "1": { "label": "important", "blocking": true },
    "2": { "label": "advisory", "blocking": false },
    "3": { "label": "informational", "blocking": false }
  },
  "phases": {
    "wo_entry": {
      "gates": [
        {
          "name": "work-order-entry-readiness",
          "script": "scripts/validate-work-order.sh",
          "tier": 1,
          "env": {
            "WO_DIR": "docs/planning",
            "WO_NUMBER": "$WO_NUMBER",
            "WO_VALIDATION_MODE": "entry"
          }
        }
      ]
    },
    "wo_exit": {
      "gates": [
        {
          "name": "work-order-validation",
          "script": "scripts/validate-work-order.sh",
          "tier": 1,
          "env": {
            "WO_DIR": "docs/planning",
            "WO_NUMBER": "$WO_NUMBER",
            "WO_VALIDATION_MODE": "completion"
          }
        }
      ]
    }
  },
  "known_baselines": {}
}
EOF

cat > "$TMP_DIR/docs/planning/WO-001.md" <<'EOF'
# WO-001: Entry Audit Fixture

## Status: Draft

## Objective

Verify the entry gate blocks implementation until audits are complete.

## Acceptance Criteria

- [ ] Entry gate blocks missing audits

## Audit Loop

### Planning Self-Audit (Required Before Approval)
- Audit Status: not-started
- Findings:
  - Pending

### Pre-Implementation Deep Audit (Required Before Coding Starts)
- Audit Status: not-started
- Findings:
  - Pending

### Pre-Commit Audit (Required Before Commit)
- Audit Status: not-started
- Findings:
  - Pending

## Implementation

### Phase 0: Research
- [ ] Planning self-audit completed
- [ ] Pre-implementation deep audit completed
EOF

entry_fail_output="$(cd "$TMP_DIR" && bash scripts/gate-runner.sh wo_entry --wo 001 2>&1 || true)"
printf '%s\n' "$entry_fail_output"

if ! printf '%s\n' "$entry_fail_output" | grep -q "FAIL"; then
  echo "[check-wo-entry-fixture] FAIL: wo_entry should fail when required audits are incomplete" >&2
  exit 1
fi

cat > "$TMP_DIR/docs/planning/WO-001.md" <<'EOF'
# WO-001: Entry Audit Fixture

## Status: Accepted - Awaiting Entry Audit

## Objective

Verify the entry gate blocks implementation until audits are complete.

## Acceptance Criteria

- [x] Entry gate blocks missing audits

## Audit Loop

### Planning Self-Audit (Required Before Approval)
- Audit Status: complete
- Findings:
  - Updated sequencing and dependencies

### Pre-Implementation Deep Audit (Required Before Coding Starts)
- Audit Status: complete
- Findings:
  - Entry criteria validated

### Pre-Commit Audit (Required Before Commit)
- Audit Status: complete
- Findings:
  - Ready for later completion gate

## Implementation

### Phase 0: Research
- [x] Planning self-audit completed
- [x] Pre-implementation deep audit completed
EOF

entry_pass_output="$(cd "$TMP_DIR" && bash scripts/gate-runner.sh wo_entry --wo 001 2>&1)"
printf '%s\n' "$entry_pass_output"

if ! printf '%s\n' "$entry_pass_output" | grep -q "Result: PASS"; then
  echo "[check-wo-entry-fixture] FAIL: wo_entry should pass when required audits are complete" >&2
  exit 1
fi

completion_pass_output="$(cd "$TMP_DIR" && bash scripts/gate-runner.sh wo_exit --wo 001 2>&1)"
printf '%s\n' "$completion_pass_output"

if ! printf '%s\n' "$completion_pass_output" | grep -q "Result: PASS"; then
  echo "[check-wo-entry-fixture] FAIL: wo_exit completion validation should pass with required audits complete" >&2
  exit 1
fi

echo "[check-wo-entry-fixture] PASS: wo_entry and completion audit enforcement work"
