#!/usr/bin/env bash
# VibeOS-2 — Upgrade Existing Project
# Copies new/updated scripts and merges new gates into the project manifest.
# Use when you've pulled latest VibeOS-2 and want to upgrade a project that already has governance.
#
# Usage:
#   bash helpers/upgrade.sh <target_project_dir>
#   FRAMEWORK_DIR=~/VibeOS-2 bash helpers/upgrade.sh /path/to/my-project
#
# Environment:
#   FRAMEWORK_DIR  — path to VibeOS-2 (default: parent of helpers/)
#   DRY_RUN        — if set, show what would be done without making changes
#
# Exit codes:
#   0 = Upgrade completed (or dry-run)
#   1 = Upgrade failed
#   2 = Invalid arguments
set -euo pipefail

FRAMEWORK_VERSION="1.0.0"
SCRIPT_NAME="upgrade"

usage() {
  cat <<'EOF'
Usage:
  bash helpers/upgrade.sh <target_project_dir>

  From your project: say "Upgrade VibeOS using ~/VibeOS-2" — the agent runs this.

Environment:
  FRAMEWORK_DIR  Path to VibeOS-2 (default: parent of helpers/)
  DRY_RUN       If set, show planned changes without applying

What gets updated:
  - Scripts: All gate scripts and gate-runner.sh (overwritten — they are framework-managed)
  - Manifest: New gates added to your phases; your baselines and env preserved

What is preserved:
  - known_baselines
  - Your project-specific env vars in gate configs
  - WO-INDEX, DEVELOPMENT-PLAN, governance docs (not overwritten)
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  echo "[$SCRIPT_NAME] Usage: bash helpers/upgrade.sh <target_project_dir>"
  echo "[$SCRIPT_NAME] Example: bash helpers/upgrade.sh /path/to/my-project"
  exit 2
fi

HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="${FRAMEWORK_DIR:-$(cd "$HELPERS_DIR/.." && pwd)}"
TARGET_DIR="$1"
DRY_RUN="${DRY_RUN:-false}"

if [[ ! -d "$FRAMEWORK_DIR" ]]; then
  echo "[$SCRIPT_NAME] ERROR: Framework dir not found: $FRAMEWORK_DIR"
  exit 2
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "[$SCRIPT_NAME] ERROR: Target project dir not found: $TARGET_DIR"
  exit 2
fi

# Skip if target is the framework repo itself
TARGET_ABS="$(cd "$TARGET_DIR" && pwd)"
FRAMEWORK_ABS="$(cd "$FRAMEWORK_DIR" && pwd)"
if [[ "$TARGET_ABS" == "$FRAMEWORK_ABS" ]]; then
  echo "[$SCRIPT_NAME] SKIP: Target is the framework repo — upgrade applies to projects that use it"
  exit 0
fi

# Verify framework structure
if [[ ! -f "$FRAMEWORK_DIR/AGENT-BOOTSTRAP.md" ]] || [[ ! -d "$FRAMEWORK_DIR/scripts" ]]; then
  echo "[$SCRIPT_NAME] ERROR: $FRAMEWORK_DIR does not look like VibeOS-2 (missing AGENT-BOOTSTRAP.md or scripts/)"
  exit 2
fi

echo "[$SCRIPT_NAME] VibeOS-2 Upgrade v${FRAMEWORK_VERSION}"
echo "[$SCRIPT_NAME] Framework: $FRAMEWORK_DIR"
echo "[$SCRIPT_NAME] Target:    $TARGET_DIR"
[[ "$DRY_RUN" == "true" ]] && echo "[$SCRIPT_NAME] DRY RUN — no changes will be made"
echo ""

# --- 1. Copy scripts ---
mkdir -p "$TARGET_DIR/scripts"
COPIED=0
for f in "$FRAMEWORK_DIR"/scripts/*.sh "$FRAMEWORK_DIR"/scripts/*.py; do
  [[ -f "$f" ]] || continue
  name=$(basename "$f")
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "[$SCRIPT_NAME] Would copy: scripts/$name"
  else
    cp "$f" "$TARGET_DIR/scripts/$name"
    echo "[$SCRIPT_NAME] Copied: scripts/$name"
  fi
  COPIED=$((COPIED + 1))
done

echo "[$SCRIPT_NAME] Scripts: $COPIED file(s) updated"
echo ""

# --- 2. Merge manifest (add new gates) ---
PROJECT_MANIFEST=""
for candidate in "$TARGET_DIR/.claude/quality-gate-manifest.json" "$TARGET_DIR/quality-gate-manifest.json"; do
  if [[ -f "$candidate" ]]; then
    PROJECT_MANIFEST="$candidate"
    break
  fi
done

REF_MANIFEST="$FRAMEWORK_DIR/reference/manifests/quality-gate-manifest.json.ref"

if [[ -n "$PROJECT_MANIFEST" ]] && [[ -f "$REF_MANIFEST" ]] && command -v jq &>/dev/null; then
  # Use Python for reliable JSON merge (jq struggles with _comment keys and nested merge)
  python3 - "$PROJECT_MANIFEST" "$REF_MANIFEST" "$DRY_RUN" <<'PY' || true
import json
import sys

proj_path = sys.argv[1]
ref_path = sys.argv[2]
dry_run = sys.argv[3] == "true"

try:
    with open(proj_path) as f:
        proj = json.load(f)
except Exception as e:
    print(f"[upgrade] WARN: Could not read project manifest: {e}")
    sys.exit(0)

try:
    with open(ref_path) as f:
        ref = json.load(f)
except Exception as e:
    print(f"[upgrade] WARN: Could not read reference manifest: {e}")
    sys.exit(0)

def gate_name(g):
    return g.get("name") or g.get("script", "")

def add_missing_gates(proj_phase, ref_phase):
    if not ref_phase or "gates" not in ref_phase:
        return []
    proj_gate_names = {gate_name(g) for g in proj_phase.get("gates", [])}
    added = []
    for rg in ref_phase.get("gates", []):
        if not isinstance(rg, dict):
            continue
        if gate_name(rg) in proj_gate_names:
            continue
        # Skip ref-only keys
        gate_copy = {k: v for k, v in rg.items() if not k.startswith("_")}
        if gate_copy:
            proj_phase.setdefault("gates", []).append(gate_copy)
            added.append(gate_copy.get("name", gate_copy.get("script", "?")))
    return added

added_any = False
for phase_name, ref_phase in ref.get("phases", {}).items():
    if not isinstance(ref_phase, dict):
        continue
    proj_phase = proj.get("phases", {}).get(phase_name)
    if not proj_phase:
        continue
    added = add_missing_gates(proj_phase, ref_phase)
    if added:
        added_any = True
        print(f"[upgrade] Manifest: added to {phase_name}: {', '.join(added)}")

if added_any and not dry_run:
    with open(proj_path, "w") as f:
        json.dump(proj, f, indent=2)
    print("[upgrade] Manifest updated — new gates added; baselines and env preserved")
elif added_any and dry_run:
    print("[upgrade] Would update manifest with new gates")
else:
    print("[upgrade] Manifest: no new gates to add")
PY
else
  if [[ -z "$PROJECT_MANIFEST" ]]; then
    echo "[$SCRIPT_NAME] No project manifest found — skipping manifest merge"
  elif [[ ! -f "$REF_MANIFEST" ]]; then
    echo "[$SCRIPT_NAME] Reference manifest not found — skipping merge"
  else
    echo "[$SCRIPT_NAME] jq or Python required for manifest merge — compare with reference manually"
  fi
fi

echo ""
echo "[$SCRIPT_NAME] Upgrade complete. Run: bash scripts/gate-runner.sh pre_commit --continue-on-failure"
echo "[$SCRIPT_NAME] See docs/UPGRADE.md and CHANGELOG.md for release notes."
