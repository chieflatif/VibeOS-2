#!/usr/bin/env bash
# VibeOS-2 — Post-Setup Verification
# Validates that a VibeOS-2 governance setup is correctly installed in a target project.
# Usage: bash verify-setup.sh <target_project_dir>
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
SCRIPT_NAME="verify-setup"

# Colors
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' NC=''
fi

pass() { echo -e "${GREEN}[PASS]${NC} $1"; PASS_COUNT=$((PASS_COUNT + 1)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; WARN_COUNT=$((WARN_COUNT + 1)); }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

# --- ARGUMENT PARSING ---

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <target_project_dir>"
    echo "Verifies VibeOS-2 governance setup in the target project."
    exit 2
fi

TARGET_DIR="$1"

if [[ ! -d "$TARGET_DIR" ]]; then
    fail "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

echo "================================"
echo "VibeOS-2 Setup Verification v${FRAMEWORK_VERSION}"
echo "Target: $TARGET_DIR"
echo "================================"
echo ""

# --- CHECK 1: Scripts Directory ---

info "Checking scripts..."

if [[ -d "$TARGET_DIR/scripts" ]]; then
    SCRIPT_COUNT=$(find "$TARGET_DIR/scripts" -name "*.sh" -o -name "*.py" | wc -l | tr -d ' ')
    if [[ "$SCRIPT_COUNT" -gt 0 ]]; then
        pass "scripts/ directory exists with $SCRIPT_COUNT scripts"
    else
        fail "scripts/ directory exists but contains no scripts"
    fi
else
    fail "scripts/ directory not found"
fi

# Check gate-runner specifically
if [[ -f "$TARGET_DIR/scripts/gate-runner.sh" ]]; then
    pass "gate-runner.sh present"
else
    fail "gate-runner.sh not found — this is the orchestrator, it's required"
fi

# Syntax check all shell scripts
if [[ -d "$TARGET_DIR/scripts" ]]; then
    SYNTAX_ERRORS=0
    for f in "$TARGET_DIR/scripts"/*.sh; do
        [[ -f "$f" ]] || continue
        if ! bash -n "$f" 2>/dev/null; then
            fail "Syntax error in $(basename "$f")"
            SYNTAX_ERRORS=$((SYNTAX_ERRORS + 1))
        fi
    done
    if [[ "$SYNTAX_ERRORS" -eq 0 ]]; then
        pass "All shell scripts pass syntax check"
    fi
fi

echo ""

# --- CHECK 2: Quality Gate Manifest ---

info "Checking quality gate manifest..."

MANIFEST_FOUND=false
for MANIFEST_PATH in "$TARGET_DIR/.claude/quality-gate-manifest.json" "$TARGET_DIR/quality-gate-manifest.json"; do
    if [[ -f "$MANIFEST_PATH" ]]; then
        MANIFEST_FOUND=true
        if jq empty "$MANIFEST_PATH" 2>/dev/null; then
            pass "Quality gate manifest is valid JSON: $(basename "$MANIFEST_PATH")"

            # Check required sections
            if jq -e '.phases' "$MANIFEST_PATH" >/dev/null 2>&1; then
                PHASE_COUNT=$(jq '.phases | keys | length' "$MANIFEST_PATH")
                pass "Manifest has $PHASE_COUNT phases defined"
            else
                fail "Manifest missing 'phases' section"
            fi

            if jq -e '.tier_definitions' "$MANIFEST_PATH" >/dev/null 2>&1; then
                pass "Manifest has tier definitions"
            else
                warn "Manifest missing 'tier_definitions' section"
            fi

            if jq -e '.known_baselines' "$MANIFEST_PATH" >/dev/null 2>&1; then
                BASELINE_COUNT=$(jq '.known_baselines.entries | length' "$MANIFEST_PATH" 2>/dev/null || echo 0)
                pass "Manifest has known_baselines ($BASELINE_COUNT entries)"
            else
                warn "Manifest missing 'known_baselines' section"
            fi
        else
            fail "Quality gate manifest is invalid JSON"
        fi
        break
    fi
done

if ! $MANIFEST_FOUND; then
    fail "Quality gate manifest not found (checked .claude/ and project root)"
fi

echo ""

# --- CHECK 3: Agent Configuration ---

info "Checking agent configuration..."

if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
    pass "CLAUDE.md found (Claude Code config)"
elif [[ -f "$TARGET_DIR/.cursorrules" ]]; then
    pass ".cursorrules found (Cursor config)"
elif [[ -f "$TARGET_DIR/AGENTS.md" ]]; then
    pass "AGENTS.md found (Codex config)"
else
    fail "No agent configuration found (expected CLAUDE.md, .cursorrules, or AGENTS.md)"
fi

echo ""

# --- CHECK 4: Architecture Rules ---

info "Checking architecture rules..."

if [[ -f "$TARGET_DIR/scripts/architecture-rules.json" ]]; then
    if jq empty "$TARGET_DIR/scripts/architecture-rules.json" 2>/dev/null; then
        RULE_COUNT=$(jq '.rules | length' "$TARGET_DIR/scripts/architecture-rules.json" 2>/dev/null || echo 0)
        pass "Architecture rules valid JSON ($RULE_COUNT rules)"
    else
        fail "Architecture rules file is invalid JSON"
    fi
else
    warn "No architecture-rules.json found (enforce-architecture.sh will skip)"
fi

echo ""

# --- CHECK 5: JSON Validation (all JSON files) ---

info "Checking all JSON files..."

JSON_ERRORS=0
while IFS= read -r -d '' json_file; do
    if ! jq empty "$json_file" 2>/dev/null; then
        fail "Invalid JSON: $json_file"
        JSON_ERRORS=$((JSON_ERRORS + 1))
    fi
done < <(find "$TARGET_DIR" -name "*.json" -not -path "*/.git/*" -not -path "*/node_modules/*" -print0 2>/dev/null)

if [[ "$JSON_ERRORS" -eq 0 ]]; then
    pass "All JSON files are valid"
fi

echo ""

# --- CHECK 6: Placeholder Remnants ---

info "Checking for placeholder remnants..."

PLACEHOLDER_COUNT=0
while IFS= read -r line; do
    PLACEHOLDER_COUNT=$((PLACEHOLDER_COUNT + 1))
    if [[ "$PLACEHOLDER_COUNT" -le 5 ]]; then
        warn "Placeholder found: $line"
    fi
done < <(grep -rn '{{[A-Z_]*}}' "$TARGET_DIR/scripts/" "$TARGET_DIR/docs/" 2>/dev/null || true)

if [[ "$PLACEHOLDER_COUNT" -eq 0 ]]; then
    pass "No placeholder remnants found"
elif [[ "$PLACEHOLDER_COUNT" -gt 5 ]]; then
    warn "... and $((PLACEHOLDER_COUNT - 5)) more placeholder(s)"
fi

# Check for .ref markers that shouldn't be in generated files
MARKER_COUNT=$(grep -rn '<!-- REQUIRED -->\|<!-- ADAPT' "$TARGET_DIR/" --include='*.md' 2>/dev/null | grep -v 'node_modules' | wc -l | tr -d ' ')
if [[ "$MARKER_COUNT" -eq 0 ]]; then
    pass "No reference markers remaining in generated files"
else
    warn "$MARKER_COUNT reference marker(s) found in generated files (should have been removed during generation)"
fi

echo ""

# --- CHECK 7: Governance Documents ---

info "Checking governance documents..."

WO_DIR="docs/planning"
if [[ -f "$TARGET_DIR/$WO_DIR/WO-INDEX.md" ]]; then
    pass "WO-INDEX.md found"
else
    warn "WO-INDEX.md not found at $WO_DIR/"
fi

if [[ -f "$TARGET_DIR/docs/INFRASTRUCTURE-MANIFEST.md" ]]; then
    pass "INFRASTRUCTURE-MANIFEST.md found"
else
    warn "INFRASTRUCTURE-MANIFEST.md not found"
fi

if [[ -f "$TARGET_DIR/docs/ARCHITECTURE.md" ]]; then
    pass "ARCHITECTURE.md found"
else
    warn "ARCHITECTURE.md not found"
fi

echo ""

# --- CHECK 8: Hooks (Claude Code only) ---

if [[ -d "$TARGET_DIR/.claude/hooks" ]]; then
    info "Checking hooks..."

    HOOK_COUNT=$(find "$TARGET_DIR/.claude/hooks" -name "*.sh" | wc -l | tr -d ' ')
    if [[ "$HOOK_COUNT" -gt 0 ]]; then
        pass "$HOOK_COUNT hook script(s) found"

        # Syntax check hooks
        HOOK_ERRORS=0
        for f in $(find "$TARGET_DIR/.claude/hooks" -name "*.sh"); do
            if ! bash -n "$f" 2>/dev/null; then
                fail "Syntax error in hook: $f"
                HOOK_ERRORS=$((HOOK_ERRORS + 1))
            fi
        done
        if [[ "$HOOK_ERRORS" -eq 0 ]]; then
            pass "All hook scripts pass syntax check"
        fi
    else
        warn "hooks/ directory exists but no scripts found"
    fi

    # Check settings.json
    if [[ -f "$TARGET_DIR/.claude/settings.json" ]]; then
        if jq empty "$TARGET_DIR/.claude/settings.json" 2>/dev/null; then
            pass "settings.json is valid JSON"
        else
            fail "settings.json is invalid JSON"
        fi
    else
        warn "settings.json not found (hooks won't fire without it)"
    fi
fi

echo ""

# --- CHECK 9: Gate Runner Smoke Test ---

info "Running gate-runner smoke test..."

if [[ -f "$TARGET_DIR/scripts/gate-runner.sh" ]] && $MANIFEST_FOUND; then
    # Dry run — just check that gate-runner can parse the manifest
    GATE_RUNNER_OUTPUT=$(cd "$TARGET_DIR" && bash scripts/gate-runner.sh pre_commit --dry-run 2>&1 || true)
    if echo "$GATE_RUNNER_OUTPUT" | grep -qi "error\|fatal\|cannot"; then
        warn "gate-runner.sh dry run produced errors (may need manifest adjustments)"
    else
        pass "gate-runner.sh dry run completed"
    fi
else
    warn "Skipping gate-runner smoke test (missing gate-runner.sh or manifest)"
fi

echo ""

# --- SUMMARY ---

echo "================================"
echo "VibeOS-2 Setup Verification Summary"
echo "================================"
echo -e "${GREEN}PASS: $PASS_COUNT${NC}"
echo -e "${RED}FAIL: $FAIL_COUNT${NC}"
echo -e "${YELLOW}WARN: $WARN_COUNT${NC}"
echo ""

if [[ "$FAIL_COUNT" -eq 0 ]]; then
    echo -e "${GREEN}Setup verification PASSED${NC}"
    if [[ "$WARN_COUNT" -gt 0 ]]; then
        echo "  Warnings are non-blocking but should be reviewed."
    fi
    exit 0
else
    echo -e "${RED}Setup verification FAILED ($FAIL_COUNT issue(s) must be fixed)${NC}"
    exit 1
fi
