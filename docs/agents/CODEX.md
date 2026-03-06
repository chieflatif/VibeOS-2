# Codex Integration

## Overview

Codex integration uses `AGENTS.md` — a single file that provides agent instructions. Codex does not support hooks or custom settings, so all governance is instruction-based.

## AGENTS.md

The agent generates `AGENTS.md` from `reference/codex/AGENTS.md.ref`. This file contains:

- Governance rules (Three Laws, Work Order protocol)
- Work Order audit-loop instructions
- Security rules
- Architecture rules
- Quality gate commands
- Development workflow

Generated Codex projects should also inherit the business-first communication behavior defined in `docs/USER-COMMUNICATION-CONTRACT.md`.

For Codex projects, the quality gate manifest lives at `quality-gate-manifest.json` in the project root. `gate-runner.sh` auto-discovers this path.

## What Works

| Feature | Support |
|---------|---------|
| Gate scripts | Full — run via CLI |
| Gate runner | Full — run via CLI |
| Architecture enforcement | Full — run via CLI |
| Governance rules | Text instructions only |
| Security rules | Text instructions only |

## What Doesn't Work

Codex cannot:
- Run hooks on tool usage
- Block operations in real-time
- Track session state
- Capture failure evidence automatically
- Use custom slash commands (skills)

## Setup Checklist

After the agent runs AGENT-BOOTSTRAP.md:

- [ ] `AGENTS.md` exists with project-specific content
- [ ] `quality-gate-manifest.json` exists at the project root
- [ ] `scripts/` has all gate scripts
- [ ] `docs/planning/WO-AUDIT-FRAMEWORK.md` exists
- [ ] `gate-runner.sh wo_entry --dry-run` runs without crashes
- [ ] `gate-runner.sh pre_commit` runs without crashes
