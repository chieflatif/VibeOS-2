# VibeOS-2

> **v2.0.0 — Verification Integrity Upgrade (2026-03-16)**
>
> This release fixes 6 systemic failure modes found during production use across 24 phases and 156 work orders. During an 8-hour autonomous build session, the framework reported 6,175 passing tests and 0 critical findings — a post-session audit revealed 67% of findings were false positives from stale worktrees, every frontend page 404'd against the real backend, and 3 work orders were falsely marked Complete. Version 2.0 adds **4 verification integrity gates**, **5 convergence scripts**, **2 new decision trees**, and expands the gate count from 24 to 42. Baseline entries now expire after 2 phases. See [CHANGELOG.md](CHANGELOG.md) for full details.

**Governance that speaks your language.**

An AI agent reads this repo, helps you describe what you want to build, explains choices in plain English, turns that into a product brief and plan, and then sets up checks and workflows so your project stays safe and organized.

## What This Is

A downloadable framework that any AI agent (Claude Code, Cursor, Codex) can read and use to:

- turn a vague idea into a clearer plan
- explain technical choices in plain English
- guide you step by step while work is happening
- set up automatic checks (secrets, security, code quality, tests) and workflows so nothing slips through

**The agent does the setup.** It reads the playbooks, asks you questions, makes decisions, and builds everything. You don't run scripts yourself.

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
# Agent drafts product brief, PRD (product requirements doc), and technical spec
# Answer high-impact follow-up questions
# Agent installs governance into this folder
```

### Existing Project (Adding VibeOS to Something You Already Built)

```bash
cd my-existing-app
# Open this folder, say: "Set up VibeOS using ~/VibeOS-2"
# Agent installs governance, runs audits (architecture, dependencies, versions, security)
# Agent explains findings in plain English, creates Work Orders (WOs) from issues
# You run audits → identify issues → create WOs → audit the plan → implement → audit again
# Agent talks you through remediation and how the system works
```

VibeOS configures itself from your codebase. It runs architecture reviews, dependency audits, version audits, and security audits. From those audits it identifies issues, creates Work Orders (WOs — tasks with clear steps and evidence), and guides you through the audit→plan→implement→audit loop.

### Development Plan (What's Next — No Guesswork)

The agent never asks "what do you want to build?" It creates a roadmap from your product plan — a list of work items in order. That roadmap defines what's next. After each item is done, the agent marks it complete and moves to the next. A quality gate [check that runs at key moments] keeps the roadmap, work list, and work files in sync so nothing gets out of date.

## Built For Vibe Coders

VibeOS is designed for people who know what they want to build, but do not necessarily know the technical stack yet.

That means the agent should:

- explain what it is doing in plain English
- use the real technical term and explain it (e.g. "PRD (product requirements doc)", "quality gates [checks that run before you commit]") so you learn the vocabulary
- give business-level meaning before technical detail
- tell you what happens next and why
- present choices in outcome language first, technology language second

This behavior is part of the framework, not a nice-to-have reminder.

## What You Get

| Component | Count | Description |
|-----------|-------|-------------|
| Quality gates (check scripts) | 42 | Secrets, security, tests, code quality, architecture, roadmap alignment, verification integrity, observability, resilience, AI integration |
| Convergence scripts | 5 | State hashing, convergence detection, baseline expiry, finding lifecycle |
| Check Phases | Up to 10 | From session start to session end |
| Discovery Playbooks | 2 | Product discovery + setup |
| Guard Templates | 8 | Block bad edits (secrets, protected files, production safety) |
| Agent Configs | 3 | Claude Code, Cursor, Codex |
| Product Templates | 5 | Idea capture, brief, requirements, technical spec, architecture |
| Governance Templates | 8 | Work orders, roadmap, audit questions, design docs, infrastructure |
| Decision Trees | 10 | Product shape, tech stack, which checks to run, architecture rules, AI integration, observability |
| Project Configs | 3 | Python, Django, Node examples |

## How It Works

You open your project folder. You give the agent the path to VibeOS-2. The agent reads playbooks from VibeOS-2 and installs everything into your project.

```
1. You open your project folder; you say "Set up VibeOS" + path to VibeOS-2
2. Agent reads AGENT-BOOTSTRAP.md from the framework path
3. Agent runs PRODUCT-DISCOVERY to shape the product (writes into your project)
4. Agent asks adaptive follow-up questions (PROJECT-INTAKE)
5. Agent selects stack, quality gates (checks), phases, and hooks
6. Agent copies scripts, generates configs, wires hooks — all into your project
7. Agent scans existing code, creates architecture rules and baselines
8. Agent generates DEVELOPMENT-PLAN.md (phased roadmap with ordered WOs) — defines what's next
9. Agent verifies everything, commits, hands off — you never left your folder
```

## What The Agent Should Sound Like

Good VibeOS behavior is:

- "We just made your plan safer by checking it for missing dependencies, weak assumptions, and rollout risks."
- "Under the hood, I ran the entry audit gate (the check that runs before we start building — it makes sure the plan is solid)."
- "Next, we should confirm the product scope because that will affect the implementation path and the testing plan."

Bad VibeOS behavior is:

- unexplained technology names
- dense terminal-style summaries
- silent work with no guidance
- asking the user to choose tools they do not understand without explanation

## How the Repo Is Organized

```
AGENT-BOOTSTRAP.md              ← Agent reads this first (setup playbook)
PRODUCT-DISCOVERY.md             ← Turn your idea into a plan
PROJECT-INTAKE.md                ← Questions to refine the plan
decision-engine/                 ← Rules for which checks to run
reference/                       ← Templates the agent adapts
convergence/                     ← 5 loop control scripts (state hashing, convergence, baselines, findings)
scripts/                         ← 42 quality gates (check scripts; agent copies to your project)
helpers/                         ← Builders and utilities
docs/                            ← Guides and docs
```

## Quality Gates (42)

### Before Every Commit (6)
- **No secrets** — Catches API keys, tokens, passwords before they get committed
- **Security patterns** — Flags risky code (unsafe eval, disabled SSL checks)
- **No stubs** — Blocks TODO, empty functions, placeholder code
- **Code quality** — Runs your linter (ruff, eslint, etc.)
- **Tests required** — Blocks if you have no test files
- **Tests pass** — Runs your test command, blocks if tests fail

### After Each Work Item (5)
- **Architecture** — Enforces module boundaries (no cross-module mess)
- **Work order (WO)** — Checks work items have required sections
- **Roadmap alignment** — Keeps roadmap, work list, and files in sync
- **Logging** — Checks for structured logs
- **Documentation** — Checks docs match code

### Quality & Architecture (3)
- **Code complexity** — Function length, cyclomatic complexity, god objects
- **Dev environment** — README, lockfile, CI config, task runner
- **Test quality gate** — Mock density, TDD compliance

### Verification Integrity (4) — New in v2.0
- **Worktree freshness** — Blocks audit findings from stale worktrees (>1 commit behind HEAD)
- **Testing antipatterns** — Detects silent pass guards, vacuous assertions, mock-only integration
- **WO status integrity** — Prevents status inflation (blocks "Complete" when evidence is missing)
- **Cross-boundary contracts** — Validates frontend API calls match actual backend routes

### Full Audit (6) — Deeper checks when you're ready
- **Web security** — Common web vulnerabilities
- **Personal data (PII)** — How you handle user data, privacy-style checks
- **Multi-tenant** — When multiple customers share the same app — keeps their data separate
- **Test quality** — Catches fake or empty tests
- **Dependencies** — Known vulnerabilities in packages
- **Audit trail** — Work items have proper evidence

### VC Audit & Production (6) — Conditional on deployment context
- **Observability** — Health endpoints, structured logging, metrics, tracing
- **Resilience** — Circuit breakers, retry logic, timeout patterns
- **Data integrity** — Transaction boundaries, constraint enforcement
- **API contracts** — API spec compliance, versioning
- **Auth boundaries** — AuthN/AuthZ enforcement per endpoint
- **Production readiness** — Full production checklist

### AI Integration (1) — Conditional on AI usage
- **AI integration** — Cost controls, prompt injection defense, model fallbacks

### Additional (5)
- **Communication contract** — Agent communication pattern compliance
- **Devmode fallbacks** — Dev-mode-only code that shouldn't reach production
- **Env completeness** — Environment variable documentation vs usage
- **Infrastructure connectivity** — Service connectivity and dependency checks
- **Swallowed errors** — Empty catch blocks, bare except-pass, discarded error returns

### Infrastructure + Versions (2)
- **Infrastructure doc** — Where things run, env vars, etc.
- **Dependency versions** — Pinned versions, outdated packages

### Session + Evidence (2)
- **Session start** — Required docs, git state, health
- **Evidence bundle** — Proof for audits and compliance (SOC 2–style)

### Post-Deploy (2)
- **Smoke test** — Can we reach the app?
- **Health check** — Is the health endpoint OK?

### Runner + Setup (2)
- **gate-runner** — Runs all quality gates in the right order
- **setup-git-hooks** — Installs pre-commit hooks into your project

## Multi-Language Support

Checks auto-detect your language and use the right tools:
- **Python** — ruff, pytest, pip-audit
- **TypeScript/JavaScript** — eslint, npm audit
- **Go** — go vet, govulncheck
- **Rust** — clippy, cargo audit
- **Java** — gradle, maven

## Progressive Adoption

You don't have to turn everything on at once:

| Tier | What You Get | Effort |
|------|-------------|--------|
| **Tier 1** | Before-commit checks (secrets + security) | 5 minutes |
| **Tier 2** | + After-work-item checks (architecture + quality) | 15 minutes |
| **Tier 3** | + Full audit + guards + session checks | 30 minutes |

See [docs/PROGRESSIVE-ADOPTION.md](docs/PROGRESSIVE-ADOPTION.md) for details.

## Documentation

- [AGENT-BOOTSTRAP.md](AGENT-BOOTSTRAP.md) — Master playbook (start here for agents)
- [PRODUCT-DISCOVERY.md](PRODUCT-DISCOVERY.md) — Discovery playbook for idea → PRD (product requirements doc) → spec
- [PROJECT-INTAKE.md](PROJECT-INTAKE.md) — Adaptive refinement questionnaire
- [docs/project-definition.schema.json](docs/project-definition.schema.json) — project-definition schema (what the agent knows about your project)
- [docs/USER-COMMUNICATION-CONTRACT.md](docs/USER-COMMUNICATION-CONTRACT.md) — Business-first communication rules for agents
- [docs/CANONICAL-CONTRACT.md](docs/CANONICAL-CONTRACT.md) — What each release includes
- [docs/UPGRADE.md](docs/UPGRADE.md) — Upgrade existing projects to latest framework
- [docs/AGENT-UPGRADE-PROTOCOL.md](docs/AGENT-UPGRADE-PROTOCOL.md) — Voice-driven upgrade: agent instructions for "Upgrade VibeOS"
- [docs/MIGRATION.md](docs/MIGRATION.md) — Compatibility guidance for generated projects
- [docs/CORE-PRINCIPLES.md](docs/CORE-PRINCIPLES.md) — Philosophy and design principles
- [docs/PREREQUISITES.md](docs/PREREQUISITES.md) — Tool installation per OS
- [docs/PROGRESSIVE-ADOPTION.md](docs/PROGRESSIVE-ADOPTION.md) — Pick-and-choose tiers
- [reference/governance/DEVELOPMENT-PLAN.md.ref](reference/governance/DEVELOPMENT-PLAN.md.ref) — Development plan template
- [decision-engine/development-plan-generation.md](decision-engine/development-plan-generation.md) — Rules for generating phased roadmap from your product plan
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
