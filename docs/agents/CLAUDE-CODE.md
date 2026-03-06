# Claude Code Integration

## Overview

Claude Code has the deepest integration with this framework:
- **CLAUDE.md** — Agent boot instructions (loaded on every session)
- **.claude/rules/** — Always-active behavioral rules
- **.claude/hooks/** — Real-time guardrails on tool usage
- **settings.json** — Hook wiring, permissions, environment
- **Skills** — Custom slash commands for governance workflows

## CLAUDE.md

The agent generates `CLAUDE.md` from `reference/claude/CLAUDE.md.ref`. This file contains:

- Project description and architecture
- Technology stack
- Module boundaries and architecture rules
- Quality gate phases and commands
- Development workflow
- Work order protocol
- Compliance targets

Claude Code loads CLAUDE.md automatically at the start of every session.

## Rule Files

Place in `.claude/rules/always/` — loaded on every interaction.

| Rule File | Purpose |
|-----------|---------|
| governance-cascade.md | Three Laws, authority hierarchy, cascade flow |
| evidence-first.md | Evidence requirements before any fix |
| no-stubs-placeholders.md | Zero-stub policy enforcement |
| architecture-rules.md | Module boundary documentation |
| mandatory-audit.md | Gate running requirements |
| security.md | Security rules and OWASP alignment |
| wo-protocol.md | Work order lifecycle |
| version-validation.md | Dependency version checking |

## Hooks

### Hook Types and Placement

| Hook Type | Directory | When It Fires |
|-----------|-----------|---------------|
| PreToolUse | `.claude/hooks/pre-tool/` | Before Edit, Write, or Bash |
| PostToolUseFailure | `.claude/hooks/post-tool/` | After a tool fails |
| UserPromptSubmit | `.claude/hooks/user-prompt/` | On every user prompt |
| SessionStart | `.claude/hooks/session/` | Session start or resume |
| SubagentStop | `.claude/hooks/subagent/` | After subagent completes |

### Hook Protocol

All hooks:
1. Read JSON from stdin (tool input, context)
2. Write JSON to stdout (decision, messages)
3. Must exit within their timeout

**PreToolUse response format:**
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow|deny",
    "permissionDecisionReason": "why (if deny)"
  }
}
```

**UserPromptSubmit/SubagentStop response format:**
```json
{
  "decision": "allow|block",
  "reason": "why (if block)"
}
```

## Settings.json

Located at `.claude/settings.json`. Generated from `reference/claude/settings.json.ref`.

Key sections:
- **hooks** — Maps hook types to scripts with matchers and timeouts
- **permissions.deny** — Blocks dangerous operations (frozen files, production URLs, force push)
- **env** — Project environment variables

## Skills

Claude Code skills are custom slash commands. Generated from `reference/skills/`.

Generated Claude projects should also inherit the business-first communication behavior defined in `docs/USER-COMMUNICATION-CONTRACT.md`.

| Skill | Command | Purpose |
|-------|---------|---------|
| quality-gate-check | /quality-gate-check | Run quality gates |
| wo-complete | /wo-complete | Complete a work order |
| post-phase-audit | /post-phase-audit | Run post-phase audit |
| wo-research | /wo-research | Start WO Phase 0 research |
| wo-audit | /wo-audit | Run the standard deep WO audit |

## Setup Checklist

After the agent runs AGENT-BOOTSTRAP.md:

- [ ] CLAUDE.md exists with project-specific content
- [ ] `.claude/rules/always/` has all 8 rule files
- [ ] `.claude/hooks/` has hook scripts in correct subdirectories
- [ ] `.claude/settings.json` has hook wiring
- [ ] `.claude/quality-gate-manifest.json` has phases and gates
- [ ] `scripts/` has all gate scripts
- [ ] `scripts/architecture-rules.json` has project-specific rules
- [ ] `docs/planning/WO-AUDIT-FRAMEWORK.md` exists
- [ ] `gate-runner.sh wo_entry --dry-run` runs without crashes
- [ ] `gate-runner.sh pre_commit` runs without crashes
