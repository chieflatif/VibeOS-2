#!/usr/bin/env bash
# VibeOS-2 — Dependency Version MVP Fixtures
# Exercises the bounded JS/TS and Python dependency version checks.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

js_dir="$TMP_DIR/js-app"
mkdir -p "$js_dir"
cat > "$js_dir/package.json" <<'EOF'
{
  "name": "fixture-js-app",
  "private": true,
  "dependencies": {
    "react": "^18.3.1"
  },
  "devDependencies": {
    "typescript": "5.4.5"
  }
}
EOF
cat > "$js_dir/package-lock.json" <<'EOF'
{ "name": "fixture-js-app", "lockfileVersion": 3 }
EOF

js_output="$(cd "$js_dir" && PROJECT_ROOT="$js_dir" ONLINE_LOOKUP=false bash "$REPO_ROOT/scripts/validate-dependency-versions.sh" 2>&1 || true)"
printf '%s\n' "$js_output"
if ! printf '%s\n' "$js_output" | grep -q "ERROR:dependencies:react uses floating specifier '\^18.3.1'"; then
  echo "[check-dependency-version-fixtures] FAIL: JS fixture did not flag floating semver range" >&2
  exit 1
fi

py_dir="$TMP_DIR/python-app"
mkdir -p "$py_dir"
cat > "$py_dir/requirements.txt" <<'EOF'
fastapi>=0.115.0
uvicorn==0.30.0
EOF

py_output="$(cd "$py_dir" && PROJECT_ROOT="$py_dir" ONLINE_LOOKUP=false bash "$REPO_ROOT/scripts/validate-dependency-versions.sh" 2>&1 || true)"
printf '%s\n' "$py_output"
if ! printf '%s\n' "$py_output" | grep -q "ERROR:requirements.txt:fastapi uses floating specifier '>=0.115.0'"; then
  echo "[check-dependency-version-fixtures] FAIL: Python fixture did not flag floating requirement" >&2
  exit 1
fi

echo "[check-dependency-version-fixtures] PASS: JS/TS and Python MVP fixtures behaved as expected"
