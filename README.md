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

## Correct User Flow

You never work inside the VibeOS-2 repo. You work in your project folder the whole time.

1. Create an empty folder for your project (or open an existing one)
2. Open **that folder** in Claude Code, Cursor, or Codex
3. Say "Set up VibeOS" and give the path to where you cloned VibeOS-2 (e.g. `~/VibeOS-2`)
4. Governance installs **into your current folder**
5. You never leave this folder — everything happens in-place

### Greenfield (New Project)

```bash
mkdir my-new-app && cd my-new-app
# Open this folder, say: "Set up VibeOS using ~/VibeOS-2"
# Agent drafts product brief, PRD, technical spec
# Answer high-impact follow-up questions
# Agent installs governance into this folder
```

### Existing Project (Midstream Embedding)

```bash
cd my-existing-app
# Open this folder, say: "Set up VibeOS using ~/VibeOS-2"
# Agent installs governance, runs audits (architecture, dependencies, versions, security)
# Agent explains findings in plain English, creates Work Orders from issues
# You run audits → identify issues → create WOs → audit the plan → implement → audit again
# Agent talks you through remediation and how the system works
```

VibeOS configures itself from your codebase. It runs architecture reviews, dependency audits, version audits, and security audits. From those audits it identifies issues, creates Work Orders, and guides you through the audit→plan→implement→audit loop.

### Development Plan (What's Next — No Guesswork)

The agent never asks "what do you want to build?" It generates a **DEVELOPMENT-PLAN.md** from your PRD and architecture — phased roadmap with ordered Work Orders. That plan defines what's next. After each WO completes, the agent marks it done and sets the next one. **DEVELOPMENT-PLAN, WO-INDEX, and WO files stay aligned** — the `validate-development-plan-alignment` gate runs at wo_exit and full_audit and blocks if they drift.

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
| Gate Scripts | 24 | Security, quality, **TDD enforcement**, architecture, compliance, development plan alignment |
| Gate Phases | Up to 10 | session_start through session_end |
| Discovery Playbooks | 2 | Product discovery + governance bootstrap |
| Hook Templates | 8 | Real-time guardrails (secrets, frozen files, staging safety) |
| Agent Configs | 3 | Claude Code, Cursor, Codex |
| Product Templates | 5 | Idea capture, product brief, PRD, technical spec, architecture outline |
| Governance Templates | 8 | Work orders, **development plan**, audit framework, ADRs, design docs, architecture, infrastructure |
| Decision Trees | 8 | Product shaping, technical recommendation, gates, phases, hooks, architecture, compliance, **development plan generation** |
| Project Configs | 3 | FastAPI, Django, Express examples |

## How It Works

You open your project folder. You give the agent the path to VibeOS-2. The agent reads playbooks from VibeOS-2 and installs everything into your project.

```
1. You open your project folder; you say "Set up VibeOS" + path to VibeOS-2
2. Agent reads AGENT-BOOTSTRAP.md from the framework path
3. Agent runs PRODUCT-DISCOVERY to shape the product (writes into your project)
4. Agent asks adaptive follow-up questions (PROJECT-INTAKE)
5. Agent selects stack, gates, phases, hooks, rules
6. Agent copies scripts, generates configs, wires hooks — all into your project
7. Agent scans existing code, creates architecture rules and baselines
8. Agent generates DEVELOPMENT-PLAN.md (phased roadmap with ordered WOs) — defines what's next
9. Agent verifies everything, commits, hands off — you never left your folder
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
decision-engine/                ← Product + governance + development plan decision trees
reference/                      ← Annotated examples (agent reads + adapts)
scripts/                        ← 22 working gate scripts (agent copies)
helpers/                        ← Mechanical utilities + definition builders
docs/product/PROJECT-IDEA.md    ← Canonical freeform idea input in generated projects
docs/planning/DEVELOPMENT-PLAN.md ← Phased roadmap (generated); defines what's next
docs/project-definition.schema.json ← Canonical discovery contract
docs/                           ← Documentation + guides
```

## Gate Scripts (24)

### Pre-Commit (6) — Run before every commit
- **validate-no-secrets.sh** — AWS keys, API tokens, JWTs, PEM keys
- **validate-security-patterns.sh** — eval, exec, pickle, shell=True, verify=False
- **detect-stubs-placeholders.py** — NotImplementedError, TODO, empty functions
- **validate-code-quality.sh** — Language-aware linting (ruff, eslint, go vet, clippy)
- **validate-tests-required.sh** — TDD: blocks when no test files exist
- **validate-tests-pass.sh** — TDD: runs test command, blocks when tests fail

### WO-Exit (5) — Run after completing a Work Order
- **enforce-architecture.sh** — Config-driven module boundary enforcement
- **validate-work-order.sh** — Required WO sections
- **validate-development-plan-alignment.sh** — Plan ↔ WO-INDEX ↔ WO files aligned; blocks on drift
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
- [reference/governance/DEVELOPMENT-PLAN.md.ref](reference/governance/DEVELOPMENT-PLAN.md.ref) — Development plan template
- [decision-engine/development-plan-generation.md](decision-engine/development-plan-generation.md) — Rules for generating phased roadmap from PRD
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
