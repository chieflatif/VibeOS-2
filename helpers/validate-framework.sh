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
echo "[1/10] Syntax checks"
for f in \
  "$REPO_ROOT/scripts/"*.sh \
  "$REPO_ROOT/helpers/"*.sh
do
  [[ -f "$f" ]] || continue
  bash -n "$f"
done
python3 -m py_compile \
  "$REPO_ROOT/helpers/check-contract-consistency.py" \
  "$REPO_ROOT/helpers/check-communication-contract.py" \
  "$REPO_ROOT/helpers/build-project-definition.py" \
  "$REPO_ROOT/helpers/validate-project-definition.py"

echo ""
echo "[2/10] JSON validation"
for f in \
  "$REPO_ROOT/.claude/quality-gate-manifest.json" \
  "$REPO_ROOT/docs/canonical-contract.json" \
  "$REPO_ROOT/docs/project-definition.schema.json" \
  "$REPO_ROOT/reference/manifests/quality-gate-manifest.json.ref" \
  "$REPO_ROOT/reference/project-configs/"*.json
do
  [[ -f "$f" ]] || continue
  jq empty "$f"
done

echo ""
echo "[3/10] Contract consistency"
python3 "$REPO_ROOT/helpers/check-contract-consistency.py"

echo ""
echo "[4/10] Communication contract consistency"
python3 "$REPO_ROOT/helpers/check-communication-contract.py"

echo ""
echo "[5/10] Project-definition discovery fixture"
bash "$REPO_ROOT/helpers/check-project-definition-fixture.sh"

echo ""
echo "[6/10] WO entry audit fixture"
bash "$REPO_ROOT/helpers/check-wo-entry-fixture.sh"

echo ""
echo "[7/10] Root manifest compatibility"
bash "$REPO_ROOT/helpers/check-root-manifest-fixture.sh"

echo ""
echo "[8/10] wo_exit fallback compatibility"
bash "$REPO_ROOT/helpers/check-wo-exit-fallback-fixture.sh"

echo ""
echo "[9/10] Setup verifier"
bash "$REPO_ROOT/helpers/verify-setup.sh" "$REPO_ROOT"

echo ""
echo "[10/10] Dependency version fixtures"
ONLINE_LOOKUP=false bash "$REPO_ROOT/helpers/check-dependency-version-fixtures.sh"

echo ""
echo "[validate-framework] PASS: framework checks completed"
