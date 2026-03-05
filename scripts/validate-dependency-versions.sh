#!/usr/bin/env bash
# VibeOS-2 — Dependency Version Validation Gate
# Checks for outdated dependencies and version pinning.
#
# Usage:
#   bash scripts/validate-dependency-versions.sh
#
# Environment:
#   LANGUAGE      — python|typescript|javascript|go|rust|java (default: auto-detect)
#   PACKAGE_FILE  — path to package manifest (default: auto-detect)
#
# Exit codes:
#   0 = Dependencies up to date (or checks not available)
#   1 = Critical outdated dependencies
#   2 = Configuration error
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
GATE_NAME="validate-dependency-versions"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/validate-dependency-versions.sh

Environment:
  LANGUAGE      python|typescript|javascript|go|rust|java (default: auto-detect)
  PACKAGE_FILE  Path to package manifest (default: auto-detect)

Checks:
  - Dependencies are version-pinned (not floating)
  - No wildcard version specifiers
  - Outdated package check (when tools available)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

echo "[$GATE_NAME] Dependency Version Validation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Auto-detect language
detect_language() {
  if [[ -f "$repo_root/pyproject.toml" ]] || [[ -f "$repo_root/setup.py" ]] || [[ -f "$repo_root/requirements.txt" ]]; then
    echo "python"
  elif [[ -f "$repo_root/tsconfig.json" ]]; then
    echo "typescript"
  elif [[ -f "$repo_root/package.json" ]]; then
    echo "javascript"
  elif [[ -f "$repo_root/go.mod" ]]; then
    echo "go"
  elif [[ -f "$repo_root/Cargo.toml" ]]; then
    echo "rust"
  elif [[ -f "$repo_root/pom.xml" ]] || [[ -f "$repo_root/build.gradle" ]]; then
    echo "java"
  else
    echo "unknown"
  fi
}

LANGUAGE="${LANGUAGE:-$(detect_language)}"
echo "Language: $LANGUAGE"

warnings=0
errors=0

case "$LANGUAGE" in
  python)
    # Check requirements.txt for unpinned versions
    req_file="${PACKAGE_FILE:-$repo_root/requirements.txt}"
    if [[ -f "$req_file" ]]; then
      echo "=== Checking $req_file for version pinning ==="
      # Find lines with >= or no version specifier (unpinned)
      unpinned=$(grep -nE '^[a-zA-Z]' "$req_file" | grep -vE '==|~=' | grep -vE '^\s*#' || true)
      if [[ -n "$unpinned" ]]; then
        unpinned_count=$(echo "$unpinned" | wc -l | tr -d ' ')
        echo "[$GATE_NAME] WARN: $unpinned_count unpinned dependencies in $req_file"
        echo "$unpinned" | head -10 | sed 's/^/  /'
        warnings=$((warnings + 1))
      else
        echo "[$GATE_NAME] PASS: All dependencies in $req_file are pinned"
      fi
    fi

    # Check pyproject.toml for wildcard versions
    pyproject="$repo_root/pyproject.toml"
    if [[ -f "$pyproject" ]]; then
      wildcards=$(grep -nE '"\*"|>=.*,<|>=' "$pyproject" | grep -iE 'dependencies' || true)
      if [[ -n "$wildcards" ]]; then
        echo "[$GATE_NAME] INFO: Some pyproject.toml dependencies use ranges (acceptable for libraries)"
      fi
    fi

    # Run pip list --outdated if available
    if command -v pip >/dev/null 2>&1; then
      echo ""
      echo "=== Checking for outdated packages ==="
      outdated=$(pip list --outdated --format=columns 2>/dev/null | tail -n +3 || true)
      if [[ -n "$outdated" ]]; then
        outdated_count=$(echo "$outdated" | wc -l | tr -d ' ')
        echo "[$GATE_NAME] INFO: $outdated_count outdated package(s) (review recommended)"
        echo "$outdated" | head -10 | sed 's/^/  /'
      else
        echo "[$GATE_NAME] PASS: All installed packages are up to date"
      fi
    fi
    ;;

  typescript|javascript)
    pkg_file="${PACKAGE_FILE:-$repo_root/package.json}"
    if [[ -f "$pkg_file" ]]; then
      echo "=== Checking $pkg_file for version pinning ==="
      # Check for wildcard (*) or latest versions
      wildcards=$(grep -nE '"(\*|latest|next)"' "$pkg_file" || true)
      if [[ -n "$wildcards" ]]; then
        wildcard_count=$(echo "$wildcards" | wc -l | tr -d ' ')
        echo "[$GATE_NAME] WARN: $wildcard_count wildcard version(s) in package.json"
        echo "$wildcards" | head -5 | sed 's/^/  /'
        warnings=$((warnings + 1))
      else
        echo "[$GATE_NAME] PASS: No wildcard versions in package.json"
      fi

      # Check for lock file
      if [[ -f "$repo_root/package-lock.json" ]] || [[ -f "$repo_root/yarn.lock" ]] || [[ -f "$repo_root/pnpm-lock.yaml" ]]; then
        echo "[$GATE_NAME] PASS: Lock file exists"
      else
        echo "[$GATE_NAME] WARN: No lock file found (package-lock.json, yarn.lock, or pnpm-lock.yaml)"
        warnings=$((warnings + 1))
      fi

      # npm outdated check
      if command -v npm >/dev/null 2>&1 && [[ -f "$repo_root/package-lock.json" ]]; then
        echo ""
        echo "=== Checking for outdated packages ==="
        outdated=$(cd "$repo_root" && npm outdated --parseable 2>/dev/null | head -15 || true)
        if [[ -n "$outdated" ]]; then
          outdated_count=$(echo "$outdated" | wc -l | tr -d ' ')
          echo "[$GATE_NAME] INFO: $outdated_count outdated package(s)"
          echo "$outdated" | head -10 | sed 's/^/  /'
        else
          echo "[$GATE_NAME] PASS: All packages are up to date"
        fi
      fi
    else
      echo "[$GATE_NAME] WARN: package.json not found"
      warnings=$((warnings + 1))
    fi
    ;;

  go)
    if [[ -f "$repo_root/go.sum" ]]; then
      echo "[$GATE_NAME] PASS: go.sum exists (dependencies tracked)"
    else
      echo "[$GATE_NAME] WARN: go.sum not found"
      warnings=$((warnings + 1))
    fi
    ;;

  rust)
    if [[ -f "$repo_root/Cargo.lock" ]]; then
      echo "[$GATE_NAME] PASS: Cargo.lock exists (dependencies pinned)"
    else
      echo "[$GATE_NAME] WARN: Cargo.lock not found (run cargo generate-lockfile)"
      warnings=$((warnings + 1))
    fi
    ;;

  *)
    echo "[$GATE_NAME] WARN: Version checking not supported for language '$LANGUAGE'"
    echo "[$GATE_NAME] SKIP: Set LANGUAGE to enable version checks"
    exit 0
    ;;
esac

# Summary
echo ""
if [[ $errors -gt 0 ]]; then
  echo "[$GATE_NAME] FAIL: $errors error(s), $warnings warning(s)"
  exit 1
elif [[ $warnings -gt 0 ]]; then
  echo "[$GATE_NAME] PASS (with $warnings warning(s))"
  exit 0
else
  echo "[$GATE_NAME] PASS: Dependency version validation complete"
  exit 0
fi
