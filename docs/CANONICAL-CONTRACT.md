# VibeOS-2 Canonical Contract

This document is the Release A source of truth for the framework contract. Its machine-readable companion is `docs/canonical-contract.json`.

## Purpose

Use this contract to keep the runtime, templates, and docs aligned while VibeOS-2 stabilizes.

## Core Decisions

### Manifest Paths

- Claude Code projects store the manifest at `.claude/quality-gate-manifest.json`.
- Cursor and Codex projects store the manifest at `quality-gate-manifest.json` in the project root.
- `scripts/gate-runner.sh` must auto-discover both paths in that order for compatibility.

### Phase Model

- `wo_entry` is the blocking phase between plan acceptance and implementation.
- `wo_exit` is the universal user-facing phase name.
- Specialized WO phases such as `wo_exit_backend` and `wo_exit_governance` are optional extensions.
- If a manifest does not define `wo_exit` directly, the runner may resolve it through the specialized `wo_exit_*` phases for backward compatibility.

### Claude Hook Contract

- Use current Claude Code hook event names:
  - `PreToolUse`
  - `PostToolUseFailure`
  - `UserPromptSubmit`
  - `SessionStart`
  - `SubagentStop`
- Command hooks receive JSON on stdin.
- Hooks return decisions via exit codes and stdout/stderr, following current Claude Code docs.

### Gate Result Contract

- `PASS`:
  - exit code `0`
  - output includes `PASS:` when the script reports a positive result
- `SKIP`:
  - exit code `0`
  - output includes `SKIP:`
- Policy failures use exit code `1`.
- Config or invalid-usage failures use exit code `2`.
- The runner must preserve real gate exit codes and must not count `SKIP:` output as `PASS`.

### Tier Model

- `tiers` are the blocking source of truth.
- Per-gate `blocking` overrides are not part of the Release A contract.

### Compliance Naming

- Internal names:
  - `soc2`
  - `gdpr`
  - `owasp`
  - `none`
- Human-facing docs may still render `SOC 2`, `GDPR`, and `OWASP`.

## Dependency Intelligence MVP Boundaries

Release B focuses on:

- JavaScript application repos
- TypeScript application repos
- Python application repos

Release B does not attempt to be:

- a universal dependency compatibility solver
- a deep Go/Rust/Java intelligence layer
- an auto-upgrade engine that guesses through uncertainty

## Compatibility Policy

- Prefer runtime compatibility shims before breaking generated projects.
- When a breaking change is unavoidable, document a migration path and version the affected contract.
