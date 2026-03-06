# Cursor Integration

## Overview

Cursor integration uses `.cursorrules` — a single file that embeds governance rules as text instructions. Cursor does not support hooks, so all guardrails are instruction-based.

## .cursorrules

The agent generates `.cursorrules` from `reference/cursor/cursorrules.ref`. This file contains:

- Governance rules (Three Laws, Work Order protocol)
- Work Order audit-loop instructions
- Security rules (secrets, SQL injection, production URLs)
- Architecture rules (module boundaries)
- Quality gate commands
- Evidence-first protocol

Generated Cursor projects should also inherit the business-first communication behavior defined in `docs/USER-COMMUNICATION-CONTRACT.md`.

For Cursor projects, the quality gate manifest lives at `quality-gate-manifest.json` in the project root. `gate-runner.sh` auto-discovers this path.

## What Works

| Feature | Support |
|---------|---------|
| Gate scripts | Full — run via terminal |
| Gate runner | Full — run via terminal |
| Architecture enforcement | Full — run via terminal |
| Governance rules | Text instructions only |
| Security rules | Text instructions only |
| Frozen files | Text instructions (no enforcement) |
| Secrets scanning | Text instructions (no enforcement) |
| Session lifecycle | Not supported |
| Hooks | Not supported |

## What Doesn't Work

Cursor cannot:
- Run hooks on tool usage (no PreToolUse hooks)
- Block operations in real-time (no permission system)
- Track session state (no SessionStart hooks)
- Capture failure evidence automatically

## Mitigation

For features Cursor can't enforce via hooks:
1. **Secrets**: .cursorrules instructs "never hardcode secrets" — but gate scripts catch them on commit
2. **Frozen files**: .cursorrules lists frozen files — but no enforcement mechanism
3. **Production targeting**: .cursorrules says "target staging" — but no blocking

## Setup Checklist

After the agent runs AGENT-BOOTSTRAP.md:

- [ ] `.cursorrules` exists with project-specific content
- [ ] `quality-gate-manifest.json` exists at the project root
- [ ] `scripts/` has all gate scripts
- [ ] `docs/planning/WO-AUDIT-FRAMEWORK.md` exists
- [ ] `.pre-commit-config.yaml` has pre-commit hooks (compensates for no real-time hooks)
- [ ] `gate-runner.sh wo_entry --dry-run` runs without crashes
- [ ] `gate-runner.sh pre_commit` runs without crashes
