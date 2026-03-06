#!/usr/bin/env bash
# VibeOS-2 — Root Manifest Compatibility Fixture
# Verifies gate-runner.sh can discover a project-root quality-gate-manifest.json.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/scripts"
cp "$REPO_ROOT/scripts/gate-runner.sh" "$TMP_DIR/scripts/gate-runner.sh"
cp "$REPO_ROOT/scripts/validate-work-order.sh" "$TMP_DIR/scripts/validate-work-order.sh"

cat > "$TMP_DIR/quality-gate-manifest.json" <<'EOF'
{
  "version": "1.0.0",
  "project": {
    "name": "fixture",
    "slug": "fixture",
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
    "wo_exit": {
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

mkdir -p "$TMP_DIR/docs/planning"
cat > "$TMP_DIR/docs/planning/WO-001.md" <<'EOF'
# WO-001: Fixture

## Status: Draft

## Objective

Root manifest compatibility check.

## Acceptance Criteria

- [ ] Fixture passes

## Tasks

- [ ] Run the gate
EOF

output="$(cd "$TMP_DIR" && bash scripts/gate-runner.sh wo_exit --wo 001 2>&1)"
printf '%s\n' "$output"

if ! printf '%s\n' "$output" | grep -q "Manifest: $TMP_DIR/quality-gate-manifest.json"; then
  echo "[check-root-manifest-fixture] FAIL: runner did not discover root manifest" >&2
  exit 1
fi

if ! printf '%s\n' "$output" | grep -q "work-order-validation"; then
  echo "[check-root-manifest-fixture] FAIL: runner did not execute WO gate" >&2
  exit 1
fi

echo "[check-root-manifest-fixture] PASS: root manifest discovery works"
