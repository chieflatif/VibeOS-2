# Upgrade Guide

When VibeOS-2 gets new gates, templates, or fixes, you can upgrade your project without re-running the full bootstrap.

## Quick Upgrade

1. **Pull latest VibeOS-2**
   ```bash
   cd ~/VibeOS-2   # or wherever you cloned it
   git pull
   ```

2. **Run the upgrade** (from your project folder, or with an agent):
   ```bash
   bash ~/VibeOS-2/helpers/upgrade.sh /path/to/your-project
   ```

   Or say to your agent: **"Upgrade VibeOS using ~/VibeOS-2"** — it will run the upgrade script for you.

3. **Verify**
   ```bash
   cd /path/to/your-project
   bash scripts/gate-runner.sh pre_commit --continue-on-failure
   ```

## What Gets Updated

| Component | Behavior |
|-----------|----------|
| **Scripts** | All gate scripts and `gate-runner.sh` are overwritten from the framework. They are framework-managed; don't edit them. |
| **Manifest** | New gates from the reference are *added* to your phases. Existing gates, tiers, env, and `known_baselines` are preserved. |

## What Is Preserved

- `known_baselines` — Your tracked pre-existing failures stay as-is
- Gate env vars — Your `SCAN_DIRS`, `SOURCE_DIR`, `TEST_DIR`, etc. are not touched
- Project config — `architecture-rules.json`, governance docs, WO-INDEX, DEVELOPMENT-PLAN
- Hooks — `.claude/hooks/` and `settings.json` are not modified

## Dry Run

To see what would change without applying:

```bash
DRY_RUN=true bash ~/VibeOS-2/helpers/upgrade.sh /path/to/your-project
```

## After Upgrade

1. Check [CHANGELOG.md](../CHANGELOG.md) for new gates and behavior changes
2. If new gates were added (e.g. `tests-required`, `tests-pass`), configure env vars in your manifest if needed
3. For existing projects with no tests: add `tests-required` and `tests-pass` to `known_baselines` until you add tests, or use the doc-only waiver in Work Orders

## Troubleshooting

- **"No project manifest found"** — Your project doesn't have `.claude/quality-gate-manifest.json` or `quality-gate-manifest.json`. Run the full bootstrap first, or create a manifest from the reference.
- **New gates fail** — New gates (e.g. TDD gates) may fail if your project doesn't meet the new requirements yet. Add to `known_baselines` during adoption, or fix the underlying issue.
- **Manifest merge skipped** — Python 3 is required for manifest merge. If unavailable, compare your manifest with `reference/manifests/quality-gate-manifest.json.ref` and add new gates manually.
