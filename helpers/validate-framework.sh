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
echo "[1/11] Syntax checks"
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
echo "[2/11] JSON validation"
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
echo "[3/11] Contract consistency"
python3 "$REPO_ROOT/helpers/check-contract-consistency.py"

echo ""
echo "[4/11] Communication contract consistency"
python3 "$REPO_ROOT/helpers/check-communication-contract.py"

echo ""
echo "[5/11] Project-definition discovery fixture"
bash "$REPO_ROOT/helpers/check-project-definition-fixture.sh"

echo ""
echo "[6/11] WO entry audit fixture"
bash "$REPO_ROOT/helpers/check-wo-entry-fixture.sh"

echo ""
echo "[7/11] Root manifest compatibility"
bash "$REPO_ROOT/helpers/check-root-manifest-fixture.sh"

echo ""
echo "[8/11] wo_exit fallback compatibility"
bash "$REPO_ROOT/helpers/check-wo-exit-fallback-fixture.sh"

echo ""
echo "[9/11] Environment discovery (valid JSON output)"
bash "$REPO_ROOT/helpers/verify-environment.sh" "$REPO_ROOT" | jq -e '.git and .version' >/dev/null

echo ""
echo "[10/11] Setup verifier"
bash "$REPO_ROOT/helpers/verify-setup.sh" "$REPO_ROOT"

echo ""
echo "[11/11] Dependency version fixtures"
ONLINE_LOOKUP=false bash "$REPO_ROOT/helpers/check-dependency-version-fixtures.sh"

echo ""
echo "[validate-framework] PASS: framework checks completed"
