# Core Principles

## Why Enterprise Governance for AI-Assisted Development?

AI agents write code fast. Without guardrails, they also write code that:
- Contains hardcoded secrets
- Violates module boundaries
- Creates stubs and placeholders
- Logs PII
- Ignores test coverage
- Drifts from architecture

Enterprise governance prevents these problems automatically, at the speed of AI development.

## The Governance Cascade

Every project using this framework follows a strict cascade:

```
Behavioral Rules (CLAUDE.md / .cursorrules / AGENTS.md)
        ↓
Investigation & Evidence
        ↓
Work Orders
        ↓
Implementation
        ↓
Quality Gates
        ↓
Commit
```

### Three Laws

1. **No remediation without a Work Order** — Don't fix things without tracking them.
2. **No Work Order without an evidence-backed finding** — Don't create work without proof of a problem.
3. **No finding without investigation** — Don't assume problems exist. Verify first.

## Agent-First Design

This framework is designed for AI agents to consume, not humans. Every document follows 7 rules:

1. **Action verb headers** — "Copy these scripts" not "Scripts Overview"
2. **Decision trees, not prose** — IF/THEN/ELSE, not paragraphs
3. **STORE/INPUT/OUTPUT annotations** — Every phase declares dependencies
4. **Verification at every boundary** — Agent confirms success before proceeding
5. **Concrete examples** — Not "customize to your project" but "IF FastAPI THEN add these rules"
6. **TYPE/REQUIRED/DEFAULT annotations** — Every field is typed
7. **No ambiguous language** — "MUST" and "IF condition THEN", never "should" or "consider"

## Quality Gate Philosophy

### Tiers

Gates are organized into 4 tiers:

| Tier | Label | Behavior |
|------|-------|----------|
| 0 | Critical | Always blocking. Security gates. No exceptions. |
| 1 | Important | Blocking by default. Architecture and quality. |
| 2 | Advisory | Non-blocking. Best practices. Warns but doesn't stop. |
| 3 | Informational | Never blocks. Metrics and reporting only. |

### Phases

Gates run at different lifecycle points:

| Phase | When | Purpose |
|-------|------|---------|
| session_start | Session opens | Verify environment ready |
| pre_commit | Before commit | Catch security/quality issues |
| wo_exit | After WO complete | Verify architecture and docs |
| full_audit | Periodic | Deep compliance scan |
| post_deploy | After deploy | Verify deployment health |

### Known Baselines

When adopting governance on an existing project, pre-existing issues are captured as **known baselines** — not punished. The system distinguishes:
- **Regressions** — New failures that didn't exist before. These block.
- **Pre-existing** — Failures that existed before governance adoption. These are tracked and ratcheted down over time.

## Hook Philosophy

Hooks provide real-time guardrails that fire during agent operations:

| Hook Type | When | Purpose |
|-----------|------|---------|
| PreToolUse | Before Edit/Write/Bash | Block dangerous operations |
| PostToolUseFailure | After tool failure | Capture evidence |
| UserPromptSubmit | On user prompt | Block governance bypass |
| SessionStart | Session open/resume | Initialize context |
| SubagentStop | Subagent completes | Validate audit results |

### Real-Time vs Batch

- **Hooks** = real-time (fires on every operation)
- **Gates** = batch (runs on command at lifecycle checkpoints)

Both are necessary. Hooks catch problems as they happen. Gates catch problems that slip through hooks.

## Evidence-First

The framework prioritizes evidence collection:

1. **Session evidence** — Every session has an evidence directory
2. **Failure capture** — Tool failures are automatically logged
3. **Gate results** — Quality gate output is machine-parseable
4. **Audit trails** — Work orders track investigation → evidence → implementation → verification

For SOC 2 compliance, evidence bundles include:
- `summary.md` — Human-readable summary
- `metadata.json` — Machine-parseable metadata
- `gate-results/` — Gate output files

## Zero-Stub Policy

AI agents frequently generate placeholder code. This framework enforces zero tolerance:

- No `NotImplementedError`
- No `pass`-only functions
- No `# TODO` in production code
- No empty test bodies
- No vacuous assertions (`assert True`)

If something can't be fully implemented, it must be flagged as a blocker in the Work Order — not hidden behind a stub.

## Staging is the Engineering Target

All development and testing targets staging environments. Production changes require explicit human approval. This is enforced by:
- Hook: staging-target.sh (blocks production URLs in commands)
- Hook: governance-guard.sh (blocks production deployment prompts)
- Permission: deny rules for production URLs

## Progressive Adoption

The framework is designed for incremental adoption:

1. **Start with pre-commit gates** — Secrets + security. Takes 5 minutes.
2. **Add WO-exit gates** — Architecture + quality. Takes 15 minutes.
3. **Add full governance** — Hooks + sessions + evidence. Takes 30 minutes.

No project is required to adopt everything. The decision engine selects what's appropriate based on team size, compliance targets, and maturity level.
