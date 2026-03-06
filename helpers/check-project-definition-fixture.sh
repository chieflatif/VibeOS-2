#!/usr/bin/env bash
# VibeOS-2 — Project Definition Fixture
# Verifies a canonical PROJECT-IDEA.md can be converted into a valid project-definition.json.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/docs/product"
cat > "$TMP_DIR/docs/product/PROJECT-IDEA.md" <<'EOF'
# TrainerFlow

## Summary
A mobile SaaS for personal trainers to manage clients, workouts, messaging, and subscriptions.

## Primary User
Independent personal trainer

## Problem
Personal trainers need one place to manage programming, client communication, and subscription billing.

## Core Workflows
- Create workout programs
- Track client progress

## V1 Features
- Client management
- Workout plans
- Messaging

## Platforms
- mobile
- web

## Integrations
- Stripe

## Sensitive Data
- pii
- health
EOF

python3 "$REPO_ROOT/helpers/build-project-definition.py" \
  --idea-file "$TMP_DIR/docs/product/PROJECT-IDEA.md" \
  --output "$TMP_DIR/project-definition.json"

python3 "$REPO_ROOT/helpers/validate-project-definition.py" \
  "$TMP_DIR/project-definition.json"

if [[ "$(jq -r '.idea.name.value' "$TMP_DIR/project-definition.json")" != "TrainerFlow" ]]; then
  echo "[check-project-definition-fixture] FAIL: project name was not preserved" >&2
  exit 1
fi

if [[ "$(jq -r '.technical_recommendation.language.value' "$TMP_DIR/project-definition.json")" != "typescript" ]]; then
  echo "[check-project-definition-fixture] FAIL: expected inferred language to be typescript" >&2
  exit 1
fi

if [[ "$(jq -r '.technical_recommendation.database.value' "$TMP_DIR/project-definition.json")" != "postgresql" ]]; then
  echo "[check-project-definition-fixture] FAIL: expected inferred database to be postgresql" >&2
  exit 1
fi

echo "[check-project-definition-fixture] PASS: PROJECT-IDEA discovery flow works"
