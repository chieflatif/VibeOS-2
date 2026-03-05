#!/usr/bin/env bash
# VibeOS-2 — Work Order Validation Gate
# Checks that a WO file has essential sections (Objective, Acceptance Criteria, Tasks, Status).
#
# Usage:
#   bash scripts/validate-work-order.sh <WO_NUMBER>
#   bash scripts/validate-work-order.sh 001
#
# Environment:
#   WO_DIR — directory containing work order files (default: docs/planning)
#
# Exit codes:
#   0 = All required sections present (or no WO number provided)
#   1 = Missing required sections
#   2 = WO file not found or invalid arguments
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
GATE_NAME="validate-work-order"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    echo "Usage: bash scripts/validate-work-order.sh <WO_NUMBER>"
    echo ""
    echo "Environment:"
    echo "  WO_DIR  Directory containing WO files (default: docs/planning)"
    echo ""
    echo "Validates that a WO file has required sections:"
    echo "  - Objective or Scope"
    echo "  - Acceptance Criteria or Definition of Done"
    echo "  - Tasks or Phase"
    echo "  - Status field"
    exit 0
fi

# Graceful skip if no WO number provided
if [[ $# -lt 1 || -z "${1:-}" || "${1:-}" == '$WO_NUMBER' ]]; then
    echo "[$GATE_NAME] SKIP: No WO number provided — skipping WO validation"
    exit 0
fi

WO_NUMBER="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Resolve WO directory
WO_DIR="${WO_DIR:-docs/planning}"
WO_BASE="$PROJECT_ROOT/$WO_DIR"

if [[ ! -d "$WO_BASE" ]]; then
    echo "[$GATE_NAME] WARN: WO directory not found: $WO_BASE"
    echo "[$GATE_NAME] SKIP: Set WO_DIR to your work order directory"
    exit 0
fi

# Find the WO file (try common patterns)
WO_FILE=""
for candidate in \
    "$WO_BASE/WO-${WO_NUMBER}.md" \
    "$WO_BASE"/WO-"${WO_NUMBER}"*.md \
    "$WO_BASE"/WO-*-"${WO_NUMBER}"*.md; do
    if [[ -f "$candidate" ]]; then
        WO_FILE="$candidate"
        break
    fi
done

if [[ -z "$WO_FILE" ]]; then
    echo "[$GATE_NAME] FAIL: No WO file found for WO-${WO_NUMBER} in $WO_BASE"
    exit 2
fi

echo "[$GATE_NAME] Validating: $WO_FILE"

content=$(cat "$WO_FILE")
errors=()

# Check 1: Objective or Scope section
if ! echo "$content" | grep -qiE '^#{1,3}\s+(Objective|Scope|Goal)'; then
    errors+=("Missing 'Objective', 'Scope', or 'Goal' section")
fi

# Check 2: Acceptance Criteria or Definition of Done
if ! echo "$content" | grep -qiE '^#{1,3}\s+(Acceptance Criteria|Definition of Done|DoD|Success Criteria)'; then
    errors+=("Missing 'Acceptance Criteria' or 'Definition of Done' section")
fi

# Check 3: Tasks or Phase section
if ! echo "$content" | grep -qiE '^#{1,3}\s+(Tasks|Phase|Implementation|Deliverables)'; then
    errors+=("Missing 'Tasks', 'Phase', or 'Implementation' section")
fi

# Check 4: Status field (in YAML frontmatter or as a heading/field)
if ! echo "$content" | grep -qiE '(^status:|^#{1,3}\s+Status|Status:\s+)'; then
    errors+=("Missing 'status' field")
fi

if [[ ${#errors[@]} -gt 0 ]]; then
    echo "[$GATE_NAME] FAIL: WO-${WO_NUMBER} validation failed (${#errors[@]} issue(s)):"
    for err in "${errors[@]}"; do
        echo "  - $err"
    done
    exit 1
fi

echo "[$GATE_NAME] PASS: WO-${WO_NUMBER} has all required sections"
exit 0
