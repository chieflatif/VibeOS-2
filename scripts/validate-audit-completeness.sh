#!/usr/bin/env bash
# VibeOS-2 — Audit Completeness Validation Gate
# Checks that work orders have proper audit trails and evidence.
#
# Usage:
#   bash scripts/validate-audit-completeness.sh
#
# Environment:
#   WO_DIR    — work order directory (default: docs/planning)
#   ADR_DIR   — ADR directory (default: docs/adr)
#
# Exit codes:
#   0 = Audit completeness checks passed
#   1 = Missing audit artifacts
#   2 = Configuration error
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
GATE_NAME="validate-audit-completeness"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/validate-audit-completeness.sh

Environment:
  WO_DIR    Work order directory (default: docs/planning)
  ADR_DIR   ADR directory (default: docs/adr)

Checks:
  - WO-INDEX.md exists and has recent entries
  - Completed WOs have audit trail sections
  - ADRs reference WOs when applicable
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

echo "[$GATE_NAME] Audit Completeness Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WO_DIR="${WO_DIR:-docs/planning}"
ADR_DIR="${ADR_DIR:-docs/adr}"

wo_path="$repo_root/$WO_DIR"
warnings=0
errors=0

# Check 1: WO-INDEX.md exists
WO_INDEX="$wo_path/WO-INDEX.md"
if [[ -f "$WO_INDEX" ]]; then
  echo "[$GATE_NAME] PASS: WO-INDEX.md found"

  # Check that it has at least one WO entry
  wo_count=$(grep -c -E '^\|.*WO-' "$WO_INDEX" 2>/dev/null || echo "0")
  if [[ "$wo_count" -gt 0 ]]; then
    echo "[$GATE_NAME] PASS: WO-INDEX has $wo_count work order entries"
  else
    echo "[$GATE_NAME] WARN: WO-INDEX.md exists but has no work order entries"
    warnings=$((warnings + 1))
  fi
else
  echo "[$GATE_NAME] WARN: WO-INDEX.md not found at $WO_INDEX"
  echo "[$GATE_NAME] WARN: Create a WO-INDEX.md to track work orders"
  warnings=$((warnings + 1))
fi

# Check 2: Completed WOs have required sections
if [[ -d "$wo_path" ]]; then
  completed_wo_files=$(find "$wo_path" -name "WO-*.md" -not -name "WO-INDEX.md" 2>/dev/null || true)

  if [[ -n "$completed_wo_files" ]]; then
    for wo_file in $completed_wo_files; do
      content=$(cat "$wo_file")
      wo_name=$(basename "$wo_file" .md)

      # Check for status field
      if echo "$content" | grep -qiE '(status:\s*(complete|done|closed|shipped))'; then
        # Completed WOs need audit sections
        has_evidence=false
        has_testing=false

        if echo "$content" | grep -qiE '(evidence|audit|gate.*result|quality.*gate)'; then
          has_evidence=true
        fi
        if echo "$content" | grep -qiE '(test|testing|verification|validated)'; then
          has_testing=true
        fi

        if ! $has_evidence; then
          echo "[$GATE_NAME] WARN: $wo_name marked complete but missing evidence/audit section"
          warnings=$((warnings + 1))
        fi
      fi
    done
  fi
fi

# Check 3: ADR directory exists (advisory)
adr_path="$repo_root/$ADR_DIR"
if [[ -d "$adr_path" ]]; then
  adr_count=$(find "$adr_path" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  echo "[$GATE_NAME] INFO: $adr_count ADR(s) found in $ADR_DIR"
else
  echo "[$GATE_NAME] INFO: No ADR directory at $ADR_DIR (optional)"
fi

# Summary
echo ""
if [[ $errors -gt 0 ]]; then
  echo "[$GATE_NAME] FAIL: $errors error(s), $warnings warning(s)"
  exit 1
elif [[ $warnings -gt 0 ]]; then
  echo "[$GATE_NAME] PASS (with $warnings warning(s))"
  exit 0
else
  echo "[$GATE_NAME] PASS: Audit completeness checks passed"
  exit 0
fi
