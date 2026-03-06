#!/usr/bin/env bash
# VibeOS-2 — Environment Discovery
# Discovers tools, GitHub access, and hosting config in the target project.
# Output: JSON for agent consumption. Agent uses this to tailor setup and next steps.
# Usage: bash verify-environment.sh [target_project_dir]
# Exit codes: 0 = success, 1 = invalid args
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
TARGET_DIR="${1:-.}"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo '{"error": "target_dir_not_found", "path": "'"$TARGET_DIR"'"}' >&2
    exit 1
fi

cd "$TARGET_DIR"

# --- GIT & REMOTE ---
GIT_REPO="false"
GIT_REMOTE_URL=""
GIT_REMOTE_HOST="none"
if git rev-parse --is-inside-work-tree &>/dev/null; then
    GIT_REPO="true"
    GIT_REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null || echo "")
    if [[ -n "$GIT_REMOTE_URL" ]]; then
        if [[ "$GIT_REMOTE_URL" == *"github.com"* ]]; then
            GIT_REMOTE_HOST="github"
        elif [[ "$GIT_REMOTE_URL" == *"gitlab.com"* ]]; then
            GIT_REMOTE_HOST="gitlab"
        else
            GIT_REMOTE_HOST="other"
        fi
    fi
fi

# --- GITHUB CLI ---
GITHUB_CLI="not_installed"
if command -v gh &>/dev/null; then
    if gh auth status &>/dev/null 2>&1; then
        GITHUB_CLI="authenticated"
    else
        GITHUB_CLI="not_authenticated"
    fi
fi

# --- HOSTING DETECTION ---
HOSTING_ARR=()
[[ -f "railway.json" ]] || [[ -f "railway.toml" ]] && HOSTING_ARR+=("railway")
[[ -f "vercel.json" ]] && HOSTING_ARR+=("vercel")
[[ -d "supabase" ]] && HOSTING_ARR+=("supabase")
[[ -f ".platform/app.yaml" ]] || [[ -d ".elasticbeanstalk" ]] && HOSTING_ARR+=("aws")
[[ -f "app.yaml" ]] && HOSTING_ARR+=("gcp")
[[ -f "Dockerfile" ]] && HOSTING_ARR+=("docker")
if [[ -f ".env" ]]; then
    ENV_KEYS=$(grep -E '^[A-Z_]+=' .env 2>/dev/null | cut -d= -f1 | tr '\n' ' ') || true
    echo " $ENV_KEYS " | grep -q " RAILWAY " && HOSTING_ARR+=("railway")
    echo " $ENV_KEYS " | grep -q " VERCEL " && HOSTING_ARR+=("vercel")
    echo " $ENV_KEYS " | grep -q " SUPABASE " && HOSTING_ARR+=("supabase")
fi
# Build JSON arrays (handle empty)
if [[ ${#HOSTING_ARR[@]} -eq 0 ]]; then HOSTING_JSON="[]"; else
  HOSTING_JSON=$(printf '%s\n' "${HOSTING_ARR[@]}" | sort -u | jq -R . | jq -s .); fi

# --- TOOLS ---
TOOLS_ARR=()
command -v npm &>/dev/null && TOOLS_ARR+=("npm")
command -v node &>/dev/null && TOOLS_ARR+=("node")
command -v python3 &>/dev/null && TOOLS_ARR+=("python3")
command -v pip &>/dev/null && TOOLS_ARR+=("pip")
command -v docker &>/dev/null && TOOLS_ARR+=("docker")
command -v gh &>/dev/null && TOOLS_ARR+=("gh")
command -v railway &>/dev/null && TOOLS_ARR+=("railway")
command -v vercel &>/dev/null && TOOLS_ARR+=("vercel")
command -v supabase &>/dev/null && TOOLS_ARR+=("supabase")
if [[ ${#TOOLS_ARR[@]} -eq 0 ]]; then TOOLS_JSON="[]"; else
  TOOLS_JSON=$(printf '%s\n' "${TOOLS_ARR[@]}" | sort -u | jq -R . | jq -s .); fi

jq -n \
    --argjson git_repo "$([ "$GIT_REPO" = "true" ] && echo true || echo false)" \
    --arg git_remote "$GIT_REMOTE_URL" \
    --arg git_host "$GIT_REMOTE_HOST" \
    --arg gh_cli "$GITHUB_CLI" \
    --arg target "$(cd "$TARGET_DIR" && pwd)" \
    --arg version "$FRAMEWORK_VERSION" \
    --argjson hosting "$HOSTING_JSON" \
    --argjson tools "$TOOLS_JSON" \
    '{
      git: { is_repo: $git_repo, remote_url: $git_remote, remote_host: $git_host },
      github_cli: $gh_cli,
      hosting_detected: $hosting,
      tools_available: $tools,
      target_dir: $target,
      version: $version
    }'
