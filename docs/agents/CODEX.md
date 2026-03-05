# Codex Integration

## Overview

Codex integration uses `AGENTS.md` — a single file that provides agent instructions. Codex does not support hooks or custom settings, so all governance is instruction-based.

## AGENTS.md

The agent generates `AGENTS.md` from `reference/codex/AGENTS.md.ref`. This file contains:

- Governance rules (Three Laws, Work Order protocol)
- Security rules
- Architecture rules
- Quality gate commands
- Development workflow

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
- [ ] `scripts/` has all gate scripts
- [ ] `gate-runner.sh pre_commit` runs without crashes
