# VibeOS-2 — Agent Boot

## What Is VibeOS-2

A **self-deploying enterprise governance framework** for AI-assisted development. Any AI agent (Claude Code, Cursor, Codex) reads the playbooks, asks questions, and autonomously builds a complete governance system customized to the user's project.

## Architecture

```
AGENT-BOOTSTRAP.md          ← Master playbook (agent entry point)
PROJECT-INTAKE.md            ← 18-question structured intake
decision-engine/             ← Decision trees for setup choices
        ↓ (agent reads, decides, executes)
scripts/                     ← 22 scripts: 21 gates + gate-runner (copied to target project)
reference/                   ← Annotated examples (agent reads + adapts)
helpers/                     ← Mechanical utilities (agent calls)
```

## Key Concepts

- **DEVELOPMENT-PLAN.md** — Phased roadmap with ordered Work Orders. Agent determines "what's next" from this. Plan, WO-INDEX, and WO files must stay aligned (`validate-development-plan-alignment` gate enforces).
- **Midstream embedding** — When target has existing code: audit first, identify issues, create WOs, then implement and audit again.

## Implementation Plan

Full plan: `docs/PLAN.md`

## Key Rules

1. **All scripts must be working implementations** — no stubs, no placeholders, no TODOs
2. **Scripts are parameterized** — env vars and CLI args, not hardcoded paths
3. **Reference files use annotations** — `<!-- REQUIRED -->`, `<!-- ADAPT -->`, `<!-- OPTIONAL -->`, `<!-- EXAMPLE -->`
4. **Decision engine uses decision trees** — IF/THEN/ELSE, not prose
5. **Playbooks use INPUT/OUTPUT/STORE** — every phase declares data flow
6. **Graceful degradation** — optional tools skip with WARNING, never crash
7. **Language-agnostic** — every feature must work for Python, TypeScript, JavaScript, Go, Rust, Java

## Quality Gates

```bash
# Validate all scripts are syntactically valid
for f in scripts/*.sh; do bash -n "$f"; done

# Validate all JSON
for f in $(find . -name "*.json" -not -path './.git/*'); do jq . "$f" > /dev/null; done

# Validate no placeholders remain
grep -rn '{{.*}}' scripts/ helpers/ decision-engine/ || echo "No placeholders found"

# Test gate-runner
bash scripts/gate-runner.sh pre_commit --continue-on-failure
```

## Technology

| Tool | Purpose |
|---|---|
| Bash 3.2+ | Gate scripts, helpers (macOS compatible) |
| Python 3.7+ | Stub detection script (only dependency needing Python) |
| jq | JSON manifest parsing |
| git | Version control |

## Conventions

- Shell scripts: `#!/usr/bin/env bash`, `set -euo pipefail`
- Exit codes: 0 = pass, 1 = fail, 2 = skip (graceful degradation)
- Logging: `echo "[GATE_NAME] PASS|FAIL|WARN|SKIP: message"`
- Version: `FRAMEWORK_VERSION="1.0.0"` in every script
