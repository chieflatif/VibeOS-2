#!/usr/bin/env bash
# VibeOS-2 — wo_exit Fallback Compatibility Fixture
# Verifies gate-runner.sh can resolve `wo_exit` through specialized wo_exit_* phases.
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
cp "$REPO_ROOT/scripts/validate-no-secrets.sh" "$TMP_DIR/scripts/validate-no-secrets.sh"
cp "$REPO_ROOT/scripts/validate-work-order.sh" "$TMP_DIR/scripts/validate-work-order.sh"

cat > "$TMP_DIR/quality-gate-manifest.json" <<'EOF'
{
  "version": "1.0.0",
  "project": {
    "name": "fallback-fixture",
    "slug": "fallback-fixture",
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
    "pre_commit": {
      "gates": [
        {
          "name": "no-secrets",
          "script": "scripts/validate-no-secrets.sh",
          "tier": 0
        }
      ]
    },
    "wo_exit_backend": {
      "includes": ["pre_commit"],
      "gates": []
    },
    "wo_exit_governance": {
      "gates": [
        {
          "name": "work-order-validation",
          "script": "scripts/validate-work-order.sh",
          "tier": 1,
          "env": {
            "WO_DIR": "docs/planning"
          }
        }
      ]
    }
  },
  "known_baselines": {}
}
EOF

cat > "$TMP_DIR/docs/planning/WO-001.md" <<'EOF'
# WO-001: Fixture

## Status: Draft

## Objective

Verify wo_exit fallback works.

## Acceptance Criteria

- [ ] Fallback runner path passes

## Tasks

- [ ] Execute fallback phase
EOF

output="$(cd "$TMP_DIR" && bash scripts/gate-runner.sh wo_exit --wo 001 2>&1)"
printf '%s\n' "$output"

if ! printf '%s\n' "$output" | grep -q "Manifest: $TMP_DIR/quality-gate-manifest.json"; then
  echo "[check-wo-exit-fallback-fixture] FAIL: runner did not use fixture manifest" >&2
  exit 1
fi

if ! printf '%s\n' "$output" | grep -q "\[no-secrets\]"; then
  echo "[check-wo-exit-fallback-fixture] FAIL: runner did not include backend fallback gates" >&2
  exit 1
fi

if ! printf '%s\n' "$output" | grep -q "\[work-order-validation\]"; then
  echo "[check-wo-exit-fallback-fixture] FAIL: runner did not include governance fallback gates" >&2
  exit 1
fi

echo "[check-wo-exit-fallback-fixture] PASS: wo_exit fallback covers specialized phases"
