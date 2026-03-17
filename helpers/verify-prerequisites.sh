#!/usr/bin/env bash
# VibeOS-2 — Prerequisite Verification
# Checks that all required and recommended tools are available.
# Exit codes: 0 = all required present, 1 = missing required tools, 2 = missing recommended only
set -euo pipefail

FRAMEWORK_VERSION="2.0.0"
SCRIPT_NAME="verify-prerequisites"

# Colors (if terminal supports them)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' NC=''
fi

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo "[INFO] $1"; }

MISSING_REQUIRED=0
MISSING_RECOMMENDED=0

# --- REQUIRED TOOLS ---

info "Checking required tools..."

# Bash 3.2+ (macOS ships 3.2, scripts are compatible)
if command -v bash &>/dev/null; then
    BASH_VERSION_NUM=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    BASH_MAJOR=$(echo "$BASH_VERSION_NUM" | cut -d. -f1)
    BASH_MINOR=$(echo "$BASH_VERSION_NUM" | cut -d. -f2)
    if [[ "$BASH_MAJOR" -ge 4 ]] || { [[ "$BASH_MAJOR" -eq 3 ]] && [[ "$BASH_MINOR" -ge 2 ]]; }; then
        pass "bash $BASH_VERSION_NUM (>= 3.2 required)"
    else
        fail "bash $BASH_VERSION_NUM — version 3.2+ required"
        MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
    fi
else
    fail "bash — not found"
    MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
fi

# Python 3.7+
if command -v python3 &>/dev/null; then
    PY_VERSION=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    PY_MAJOR=$(echo "$PY_VERSION" | cut -d. -f1)
    PY_MINOR=$(echo "$PY_VERSION" | cut -d. -f2)
    if [[ "$PY_MAJOR" -ge 3 ]] && [[ "$PY_MINOR" -ge 7 ]]; then
        pass "python3 $PY_VERSION (>= 3.7 required)"
    else
        fail "python3 $PY_VERSION — version 3.7+ required"
        MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
    fi
else
    fail "python3 — not found"
    MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
fi

# Git
if command -v git &>/dev/null; then
    GIT_VERSION=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    pass "git $GIT_VERSION"
else
    fail "git — not found"
    MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
fi

# jq
if command -v jq &>/dev/null; then
    JQ_VERSION=$(jq --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    pass "jq $JQ_VERSION"
else
    fail "jq — not found (install: brew install jq / apt-get install jq)"
    MISSING_REQUIRED=$((MISSING_REQUIRED + 1))
fi

echo ""

# --- RECOMMENDED TOOLS ---

info "Checking recommended tools..."

# ruff (Python linting)
if command -v ruff &>/dev/null; then
    RUFF_VERSION=$(ruff --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    pass "ruff $RUFF_VERSION"
else
    warn "ruff — not found (install: pip install ruff) — used by validate-code-quality.sh for Python"
    MISSING_RECOMMENDED=$((MISSING_RECOMMENDED + 1))
fi

# mypy (Python type checking)
if command -v mypy &>/dev/null; then
    MYPY_VERSION=$(mypy --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    pass "mypy $MYPY_VERSION"
else
    warn "mypy — not found (install: pip install mypy) — optional type checking"
    MISSING_RECOMMENDED=$((MISSING_RECOMMENDED + 1))
fi

# pytest (Python testing)
if command -v pytest &>/dev/null; then
    PYTEST_VERSION=$(pytest --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    pass "pytest $PYTEST_VERSION"
else
    warn "pytest — not found (install: pip install pytest) — used by test gate"
    MISSING_RECOMMENDED=$((MISSING_RECOMMENDED + 1))
fi

# pre-commit
if command -v pre-commit &>/dev/null; then
    PC_VERSION=$(pre-commit --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    pass "pre-commit $PC_VERSION"
else
    warn "pre-commit — not found (install: pip install pre-commit) — used for git hook management"
    MISSING_RECOMMENDED=$((MISSING_RECOMMENDED + 1))
fi

# pip-audit (dependency security)
if command -v pip-audit &>/dev/null; then
    pass "pip-audit (available)"
else
    warn "pip-audit — not found (install: pip install pip-audit) — used by validate-dependencies.sh"
    MISSING_RECOMMENDED=$((MISSING_RECOMMENDED + 1))
fi

echo ""

# --- SUMMARY ---

echo "================================"
echo "VibeOS-2 Prerequisites Check v${FRAMEWORK_VERSION}"
echo "================================"

if [[ "$MISSING_REQUIRED" -eq 0 ]]; then
    pass "All required tools present"
else
    fail "$MISSING_REQUIRED required tool(s) missing — install before proceeding"
fi

if [[ "$MISSING_RECOMMENDED" -gt 0 ]]; then
    warn "$MISSING_RECOMMENDED recommended tool(s) missing — gates will skip gracefully"
fi

echo ""

if [[ "$MISSING_REQUIRED" -gt 0 ]]; then
    echo "Installation help:"
    echo "  macOS:   brew install bash python3 git jq"
    echo "  Ubuntu:  apt-get install bash python3 git jq"
    echo "  Windows: Use WSL2 with Ubuntu"
    exit 1
fi

if [[ "$MISSING_RECOMMENDED" -gt 0 ]]; then
    exit 2
fi

exit 0
