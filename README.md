# VibeOS-2

**Self-deploying enterprise governance for AI-assisted development.**

An AI agent reads this repo, asks your project questions, makes decisions, and builds a complete enterprise governance system — customized to your stack, your team, your compliance needs.

## What This Is

A downloadable framework that any AI agent (Claude Code, Cursor, Codex) can read and use to autonomously set up enterprise-grade quality gates, security hooks, architecture enforcement, and governance workflows for your project.

**This is NOT a template repo with a bash bootstrap.** The agent IS the bootstrap engine. It reads structured playbooks, asks you questions, makes decisions, and builds everything.

## 60-Second Demo

```bash
# 1. Clone this repo
git clone https://github.com/chieflatif/VibeOS-2.git

# 2. Open your project in Claude Code
cd your-project/

# 3. Tell the agent to set up governance
# "Set up enterprise governance using /path/to/VibeOS-2"

# 4. Answer 18 questions across 4 rounds
# 5. Agent builds everything automatically
# 6. You have enterprise governance running
```

## What You Get

| Component | Count | Description |
|-----------|-------|-------------|
| Gate Scripts | 21 | Security, quality, architecture, compliance checks |
| Gate Phases | Up to 10 | session_start through session_end |
| Hook Templates | 8 | Real-time guardrails (secrets, frozen files, staging safety) |
| Agent Configs | 3 | Claude Code, Cursor, Codex |
| Governance Templates | 6 | Work orders, ADRs, design docs, architecture, infrastructure |
| Decision Trees | 5 | Gate, phase, hook, architecture rule, compliance selection |
| Project Configs | 3 | FastAPI, Django, Express examples |

## How It Works

```
1. Agent reads AGENT-BOOTSTRAP.md (master playbook)
2. Agent asks 18 questions (PROJECT-INTAKE.md)
3. Agent selects gates, phases, hooks, rules (decision-engine/)
4. Agent copies scripts, generates configs, wires hooks
5. Agent scans existing code, creates architecture rules
6. Agent captures pre-existing issues as known baselines
7. Agent verifies everything, commits, hands off to you
```

## Architecture

```
AGENT-BOOTSTRAP.md          ← Agent reads this first (7-phase playbook)
PROJECT-INTAKE.md            ← 18 structured questions
decision-engine/             ← Decision trees for setup choices
reference/                   ← Annotated examples (agent reads + adapts)
scripts/                     ← 21 working gate scripts (agent copies)
helpers/                     ← Mechanical utilities
docs/                        ← Documentation + guides
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
- [PROJECT-INTAKE.md](PROJECT-INTAKE.md) — Structured questionnaire
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
