#!/usr/bin/env bash
# VibeOS-2 — Fetch from URL and Upgrade (Voice-Driven)
# One command: clone/pull from repo URL, then run upgrade. For voice-driven "Upgrade VibeOS from [URL]".
#
# Usage:
#   bash helpers/fetch-and-upgrade.sh <target_project_dir> [vibeos_url]
#   bash helpers/fetch-and-upgrade.sh . https://github.com/chieflatif/VibeOS-2
#
# Environment:
#   VIBEOS_URL       — repo URL (default: https://github.com/chieflatif/VibeOS-2)
#   VIBEOS_CACHE      — cache dir for clone (default: ~/.vibeos-cache/VibeOS-2)
#   TARGET_DIR        — target project (default: first arg)
#
# Exit codes:
#   0 = Success
#   1 = Upgrade failed
#   2 = Invalid args / git not available
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
SCRIPT_NAME="fetch-and-upgrade"
DEFAULT_URL="https://github.com/chieflatif/VibeOS-2"
CACHE_DIR="${VIBEOS_CACHE:-$HOME/.vibeos-cache/VibeOS-2}"

usage() {
  cat <<'EOF'
Usage:
  bash helpers/fetch-and-upgrade.sh <target_project_dir> [vibeos_url]

  Voice-driven: "Upgrade VibeOS from https://github.com/chieflatif/VibeOS-2"
  The agent runs this with your project dir and the URL you give.

Examples:
  bash helpers/fetch-and-upgrade.sh .
  bash helpers/fetch-and-upgrade.sh /path/to/my-project https://github.com/chieflatif/VibeOS-2
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  echo "[$SCRIPT_NAME] Usage: fetch-and-upgrade.sh <target_dir> [url]"
  exit 2
fi

TARGET_DIR="$1"
VIBEOS_URL="${2:-${VIBEOS_URL:-$DEFAULT_URL}}"
# Shorthand: chieflatif/VibeOS-2 -> https://github.com/chieflatif/VibeOS-2
if [[ "$VIBEOS_URL" == *"/"* ]] && [[ "$VIBEOS_URL" != *"://"* ]]; then
  VIBEOS_URL="https://github.com/$VIBEOS_URL"
fi

# Resolve script location — we might be running from a cached clone or local path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USE_URL=true
if [[ -n "${FRAMEWORK_DIR:-}" ]] && [[ -d "$FRAMEWORK_DIR" ]] && [[ -f "$FRAMEWORK_DIR/helpers/upgrade.sh" ]]; then
  # FRAMEWORK_DIR explicitly set (e.g. user gave path) — use it
  USE_URL=false
elif [[ -f "$SCRIPT_DIR/upgrade.sh" ]] && [[ -f "$SCRIPT_DIR/../AGENT-BOOTSTRAP.md" ]]; then
  # Running from a VibeOS-2 clone — use directly (no fetch)
  FRAMEWORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
  USE_URL=false
  echo "[$SCRIPT_NAME] Using local framework: $FRAMEWORK_DIR"
fi

if [[ "$USE_URL" == "true" ]]; then
  # We're in a project or elsewhere — fetch from URL
  if ! command -v git &>/dev/null; then
    echo "[$SCRIPT_NAME] ERROR: git required to fetch from URL"
    exit 2
  fi

  mkdir -p "$(dirname "$CACHE_DIR")"
  if [[ -d "$CACHE_DIR/.git" ]]; then
    echo "[$SCRIPT_NAME] Pulling latest from $VIBEOS_URL..."
    (cd "$CACHE_DIR" && git pull --rebase 2>/dev/null || git pull 2>/dev/null) || true
  else
    echo "[$SCRIPT_NAME] Cloning $VIBEOS_URL to $CACHE_DIR..."
    git clone --depth 1 "$VIBEOS_URL" "$CACHE_DIR" 2>/dev/null || git clone "$VIBEOS_URL" "$CACHE_DIR"
  fi

  FRAMEWORK_DIR="$CACHE_DIR"
fi

if [[ ! -f "$FRAMEWORK_DIR/helpers/upgrade.sh" ]]; then
  echo "[$SCRIPT_NAME] ERROR: Framework missing helpers/upgrade.sh at $FRAMEWORK_DIR"
  exit 2
fi

export FRAMEWORK_DIR
bash "$FRAMEWORK_DIR/helpers/upgrade.sh" "$TARGET_DIR"
