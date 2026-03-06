#!/usr/bin/env bash
# VibeOS-2 — Framework Validation
# Runs a focused validation suite for the framework repo itself.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "================================"
echo "VibeOS-2 Framework Validation"
echo "================================"

echo ""
echo "[1/7] Syntax checks"
for f in \
  "$REPO_ROOT/scripts/"*.sh \
  "$REPO_ROOT/helpers/"*.sh
do
  [[ -f "$f" ]] || continue
  bash -n "$f"
done
python3 -m py_compile "$REPO_ROOT/helpers/check-contract-consistency.py"

echo ""
echo "[2/7] JSON validation"
for f in \
  "$REPO_ROOT/.claude/quality-gate-manifest.json" \
  "$REPO_ROOT/docs/canonical-contract.json" \
  "$REPO_ROOT/reference/manifests/quality-gate-manifest.json.ref" \
  "$REPO_ROOT/reference/project-configs/"*.json
do
  [[ -f "$f" ]] || continue
  jq empty "$f"
done

echo ""
echo "[3/7] Contract consistency"
python3 "$REPO_ROOT/helpers/check-contract-consistency.py"

echo ""
echo "[4/7] Root manifest compatibility"
bash "$REPO_ROOT/helpers/check-root-manifest-fixture.sh"

echo ""
echo "[5/7] wo_exit fallback compatibility"
bash "$REPO_ROOT/helpers/check-wo-exit-fallback-fixture.sh"

echo ""
echo "[6/7] Setup verifier"
bash "$REPO_ROOT/helpers/verify-setup.sh" "$REPO_ROOT"

echo ""
echo "[7/7] Dependency version fixtures"
ONLINE_LOOKUP=false bash "$REPO_ROOT/helpers/check-dependency-version-fixtures.sh"

echo ""
echo "[validate-framework] PASS: framework checks completed"
