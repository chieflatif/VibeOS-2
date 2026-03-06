# Migration Guide

This guide covers Release A compatibility changes for projects generated before the VibeOS-2 contract stabilization pass.

## What Changed

### Manifest Discovery

`scripts/gate-runner.sh` now discovers manifests in this order:

1. `.claude/quality-gate-manifest.json`
2. `quality-gate-manifest.json`

This keeps existing Claude projects working while also supporting Cursor and Codex projects that store the manifest at the project root.

### Universal `wo_exit`

`wo_exit` remains the universal user-facing audit command.

If your manifest already defines `wo_exit`, nothing changes.

If your manifest only defines specialized `wo_exit_*` phases, the runner now attempts a compatibility fallback when you run:

```bash
bash scripts/gate-runner.sh wo_exit --continue-on-failure
```

### Claude Hook Events

Claude hook documentation and references now follow the current hook contract:

- stdin JSON input
- current event names such as `PostToolUseFailure` and `SubagentStop`

If you generated older hook wiring from a stale appendix, regenerate `.claude/settings.json` and hook scripts from the updated references.

## Recommended Upgrade Steps

### Claude Code Projects

1. Regenerate `.claude/settings.json` from the updated reference.
2. Regenerate hook scripts from `reference/hooks/`.
3. Confirm the manifest still lives at `.claude/quality-gate-manifest.json`.
4. Run:

```bash
bash scripts/gate-runner.sh pre_commit --continue-on-failure
bash scripts/gate-runner.sh wo_exit --continue-on-failure --wo 001
```

### Cursor and Codex Projects

1. Keep or move the manifest to `quality-gate-manifest.json` at the project root.
2. Regenerate `.cursorrules` or `AGENTS.md` from the updated references if they were created from older docs.
3. Run:

```bash
bash scripts/gate-runner.sh pre_commit --continue-on-failure
bash scripts/gate-runner.sh wo_exit --continue-on-failure --wo 001
```

## Compatibility Notes

- Release A favors compatibility shims over hard breaks.
- Generated projects that already use `.claude/quality-gate-manifest.json` remain supported.
- Generated projects that use root `quality-gate-manifest.json` are now supported directly by the runner.
- The next tightening step should add explicit manifest versioning if the schema changes materially.
