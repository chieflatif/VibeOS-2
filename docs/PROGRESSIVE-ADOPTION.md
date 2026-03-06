# Progressive Adoption

You don't have to adopt everything at once. Pick the tier that matches your current needs and grow from there.

## Tier 1: Pre-Commit Gates (5 minutes)

**What you get:** Security scanning on every commit.

**Setup:**
1. Copy `scripts/validate-no-secrets.sh` and `scripts/validate-security-patterns.sh` to your project
2. Add to `.pre-commit-config.yaml` or run manually before commits

**Gates active:**
- Secrets detection (tier 0, blocking)
- Security pattern checks (tier 0, blocking)

**What it catches:**
- Hardcoded API keys, tokens, passwords
- eval/exec, shell=True, verify=False, innerHTML

## Tier 2: WO-Exit Gates (15 minutes)

**What you get:** Architecture enforcement and quality checks on Work Order completion.

**Prerequisites:** Tier 1

**Additional setup:**
1. Copy all gate scripts from `scripts/` to your project
2. Copy `scripts/gate-runner.sh` (orchestrator)
3. Create the manifest using the reference:
   - Claude Code: `.claude/quality-gate-manifest.json`
   - Cursor/Codex: `quality-gate-manifest.json`
4. Create `scripts/architecture-rules.json` for your project

**Additional gates:**
- Stub/placeholder detection (tier 1, blocking)
- Code quality linting (tier 1, blocking)
- Architecture enforcement (tier 1, blocking)
- Work order validation (tier 1, blocking)
- Logging patterns (tier 2, advisory)
- Documentation completeness (tier 2, advisory)

**Workflow:**
```bash
# Before every commit
bash scripts/gate-runner.sh pre_commit

# After completing a WO
bash scripts/gate-runner.sh wo_exit --continue-on-failure
```

## Tier 3: Full Governance (30 minutes)

**What you get:** Complete governance with hooks, session lifecycle, compliance gates, and evidence collection.

**Prerequisites:** Tier 2

**Additional setup:**
1. Install hook scripts in `.claude/hooks/`
2. Configure `settings.json` with hook wiring
3. Set up governance templates (WO-INDEX.md, WO-TEMPLATE.md)
4. Configure compliance-specific gates in manifest

**Additional gates (selected by compliance targets):**
- OWASP alignment (if OWASP target)
- PII handling (if GDPR/SOC 2 target)
- Tenant isolation (if multi-tenant)
- Test integrity
- Dependency security
- Infrastructure manifest
- Evidence bundle validation (if SOC 2 target)

**Hooks active (Claude Code only):**
- secrets-scan (blocks hardcoded secrets in real-time)
- frozen-files (blocks edits to locked files)
- staging-target (blocks production commands)
- governance-guard (blocks governance bypass)
- session-start/resume (initializes session context)
- capture-failure (logs tool failures)

## Choosing Your Tier

| Factor | Tier 1 | Tier 2 | Tier 3 |
|--------|--------|--------|--------|
| Team size | Any | Any | Small+ |
| Compliance needs | None | None | SOC 2, GDPR, OWASP |
| Agent | Any | Claude Code, Cursor | Claude Code |
| Setup time | 5 min | 15 min | 30 min |
| Maintenance | None | Low | Low |

## Upgrading Between Tiers

Each tier is additive — you keep everything from the previous tier and add more. The agent can upgrade your setup at any time by re-running with a higher tier selection.
