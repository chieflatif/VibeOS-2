# VibeOS-2

**Specification-first governance for non-technical vibe coders.**

An AI agent reads this repo, helps you describe what you want to build, explains choices in plain English, turns that into a brief and PRD, and then builds a complete governance system around the project.

## What This Is

A downloadable framework that any AI agent (Claude Code, Cursor, Codex) can read and use to:

- shape a vague product idea into a clearer plan
- explain technical choices in a more user-friendly way
- guide the user step by step while work is happening
- set up quality gates, security hooks, architecture enforcement, and governance workflows for the project

**This is NOT a template repo with a bash bootstrap.** The agent IS the bootstrap engine. It reads structured playbooks, asks you questions, makes decisions, and builds everything.

## 60-Second Demo

```bash
# 1. Clone this repo
git clone https://github.com/chieflatif/VibeOS-2.git

# 2. Open your project in Claude Code
cd your-project/

# 3. Tell the agent what you want to build
# "Use /path/to/VibeOS-2 to turn my idea into a PRD and governed build setup"

# 4. Agent drafts a product brief + PRD + technical starting point
# 5. Answer only the high-impact follow-up questions
# 6. Agent builds governance automatically
```

## Built For Vibe Coders

VibeOS is designed for people who know what they want to build, but do not necessarily know the technical stack yet.

That means the agent should:

- explain what it is doing in plain English
- explain technical words the first time they matter
- give business-level meaning before technical detail
- tell you what happens next and why
- present choices in outcome language first, technology language second

This behavior is part of the framework, not a nice-to-have reminder.

## What You Get

| Component | Count | Description |
|-----------|-------|-------------|
| Gate Scripts | 21 | Security, quality, architecture, compliance checks |
| Gate Phases | Up to 10 | session_start through session_end |
| Discovery Playbooks | 2 | Product discovery + governance bootstrap |
| Hook Templates | 8 | Real-time guardrails (secrets, frozen files, staging safety) |
| Agent Configs | 3 | Claude Code, Cursor, Codex |
| Product Templates | 5 | Idea capture, product brief, PRD, technical spec, architecture outline |
| Governance Templates | 7 | Work orders, audit framework, ADRs, design docs, architecture, infrastructure |
| Decision Trees | 7 | Product shaping, technical recommendation, gates, phases, hooks, architecture, compliance |
| Project Configs | 3 | FastAPI, Django, Express examples |

## How It Works

```
1. Agent reads AGENT-BOOTSTRAP.md (master playbook)
2. Agent runs PRODUCT-DISCOVERY.md to shape the product
3. Agent writes `docs/product/PROJECT-IDEA.md` and builds a canonical project-definition.json
4. Agent asks adaptive follow-up questions (PROJECT-INTAKE.md)
5. Agent selects stack, gates, phases, hooks, rules (decision-engine/)
6. Agent installs a blocking `wo_entry` audit gate plus the WO audit loop
7. Agent copies scripts, generates configs, wires hooks
8. Agent scans existing code, creates architecture rules and baselines
9. Agent verifies everything, commits, hands off to you
```

## What The Agent Should Sound Like

Good VibeOS behavior is:

- "We just made your plan safer by checking it for missing dependencies, weak assumptions, and rollout risks."
- "Under the hood, I ran the entry audit gate. That is the blocking check between accepting a plan and starting implementation."
- "Next, we should confirm the product scope because that will affect the implementation path and the testing plan."

Bad VibeOS behavior is:

- unexplained technology names
- dense terminal-style summaries
- silent work with no guidance
- asking the user to choose tools they do not understand without explanation

## Architecture

```
AGENT-BOOTSTRAP.md              ← Agent reads this first (Phase 0-7 playbook)
PRODUCT-DISCOVERY.md            ← Discovery playbook for idea → definition
PROJECT-INTAKE.md               ← Adaptive refinement questionnaire
decision-engine/                ← Product + governance decision trees
reference/                      ← Annotated examples (agent reads + adapts)
scripts/                        ← 21 working gate scripts (agent copies)
helpers/                        ← Mechanical utilities + definition builders
docs/product/PROJECT-IDEA.md    ← Canonical freeform idea input in generated projects
docs/project-definition.schema.json ← Canonical discovery contract
docs/                           ← Documentation + guides
```

## Gate Scripts (21)

### Pre-Commit (4) — Run before every commit
- **validate-no-secrets.sh** — AWS keys, API tokens, JWTs, PEM keys
- **validate-security-patterns.sh** — eval, exec, pickle, shell=True, verify=False
- **detect-stubs-placeholders.py** — NotImplementedError, TODO, empty functions
- **validate-code-quality.sh** — Language-aware linting (ruff, eslint, go vet, clippy)

### WO-Exit (4) — Run after completing a Work Order
- **enforce-architecture.sh** — Config-driven module boundary enforcement
- **validate-work-order.sh** — Required WO sections
- **validate-logging-patterns.sh** — Structured logging, correlation IDs
- **validate-documentation-completeness.sh** — Docstring coverage

### Full Audit (6) — Comprehensive compliance checks
- **validate-owasp-alignment.sh** — OWASP Top 10 pattern checks
- **validate-pii-handling.sh** — PII in code/logs, GDPR strict mode
- **validate-tenant-isolation.sh** — Multi-tenant query filtering
- **validate-test-integrity.sh** — Vacuous assertions, empty tests
- **validate-dependencies.sh** — Known vulnerability scanning
- **validate-audit-completeness.sh** — WO audit trail validation

### Infrastructure + Version (2)
- **validate-infrastructure-manifest.sh** — Infra doc completeness
- **validate-dependency-versions.sh** — Version pinning, outdated packages

### Session + Evidence (2)
- **validate-session-start.sh** — Required docs, git state, health checks
- **validate-evidence-bundle.sh** — SOC 2 evidence bundle validation

### Post-Deploy (2)
- **smoke-test.sh** — Endpoint availability
- **health-check.sh** — Health endpoint JSON validation

### Orchestrator (1)
- **gate-runner.sh** — Phase inheritance, baselines, tiers, JSON output

## Multi-Language Support

All gate scripts auto-detect and support:
- **Python** (ruff, flake8, mypy, pip-audit)
- **TypeScript/JavaScript** (tsc, eslint, biome, npm audit)
- **Go** (go build, go vet, golangci-lint, govulncheck)
- **Rust** (cargo check, clippy, cargo audit)
- **Java** (gradle, maven)

## Progressive Adoption

You don't have to adopt everything at once:

| Tier | What You Get | Effort |
|------|-------------|--------|
| **Tier 1** | Pre-commit gates (secrets + security) | 5 minutes |
| **Tier 2** | + WO-exit gates (architecture + quality) | 15 minutes |
| **Tier 3** | + Full audit + hooks + session lifecycle | 30 minutes |

See [docs/PROGRESSIVE-ADOPTION.md](docs/PROGRESSIVE-ADOPTION.md) for details.

## Documentation

- [AGENT-BOOTSTRAP.md](AGENT-BOOTSTRAP.md) — Master playbook (start here for agents)
- [PRODUCT-DISCOVERY.md](PRODUCT-DISCOVERY.md) — Discovery playbook for idea → PRD → spec
- [PROJECT-INTAKE.md](PROJECT-INTAKE.md) — Adaptive refinement questionnaire
- [docs/project-definition.schema.json](docs/project-definition.schema.json) — Canonical product-definition schema
- [docs/USER-COMMUNICATION-CONTRACT.md](docs/USER-COMMUNICATION-CONTRACT.md) — Business-first communication rules for agents
- [docs/CANONICAL-CONTRACT.md](docs/CANONICAL-CONTRACT.md) — Release A contract source of truth
- [docs/MIGRATION.md](docs/MIGRATION.md) — Upgrade guidance for generated projects
- [docs/CORE-PRINCIPLES.md](docs/CORE-PRINCIPLES.md) — Philosophy and design principles
- [docs/PREREQUISITES.md](docs/PREREQUISITES.md) — Tool installation per OS
- [docs/PROGRESSIVE-ADOPTION.md](docs/PROGRESSIVE-ADOPTION.md) — Pick-and-choose tiers
- [docs/agents/CLAUDE-CODE.md](docs/agents/CLAUDE-CODE.md) — Claude Code deep dive
- [docs/agents/CURSOR.md](docs/agents/CURSOR.md) — Cursor deep dive
- [docs/agents/CODEX.md](docs/agents/CODEX.md) — Codex deep dive

## Requirements

- Bash 3.2+ (macOS default works)
- Python 3.7+
- Git
- jq

See [docs/PREREQUISITES.md](docs/PREREQUISITES.md) for full installation guide.

## License

MIT
