# Plan: VibeOS-2 — Self-Deploying Agent Platform

## Pre-Implementation: Repo Setup

```bash
# Create private GitHub repo
gh repo create VibeOS-2 --private --description "Self-deploying enterprise governance for AI-assisted development"

# Clone to local projects directory
cd "/Users/latifhorst/cursor projects"
gh repo clone VibeOS-2

# Copy plan file into the new repo
cp ~/.claude/plans/misty-herding-ocean.md "/Users/latifhorst/cursor projects/VibeOS-2/docs/PLAN.md"
```

Then open `/Users/latifhorst/cursor projects/VibeOS-2/` in a new Claude Code session and start Session 1.

## Context

**Problem:** Vibe coders build fast but ship fragile. They don't know how to set up enterprise-grade governance, and they shouldn't have to. The AI agent should do it for them.

**Solution:** A downloadable GitHub repo that any AI agent (Claude Code, Cursor, Codex) can read, ingest, and use to autonomously build out a complete enterprise governance system — then ingest the user's project and customize everything on the fly.

**This is NOT a template repo with a bash bootstrap.** The agent IS the bootstrap engine. It reads structured playbooks, asks the user questions, makes decisions, and builds everything. The bash scripts are mechanical tools the agent calls — not the entry point.

**Source material:** Extracted from governance systems built across two production projects:
- SalesSidekick — 86 scripts, 10 gate phases, 11 hooks, 8 rule files (8.6x more mature)
- Signal Intelligence Platform — 10 scripts, 3 gate phases, focused architecture enforcement

## How It Works (User Journey)

```
1. User clones the repo
2. User opens their project in Claude Code / Cursor / Codex
3. User says: "Set up enterprise governance using /path/to/enterprise-dev-framework"
4. Agent reads AGENT-BOOTSTRAP.md (the master playbook)
5. Agent asks 18 structured questions across 4 rounds (PROJECT-INTAKE.md)
6. Agent makes decisions: which gates, which hooks, which rules, which phases
7. Agent copies scripts, renders templates, wires hooks, creates manifests
8. Agent scans existing codebase → adapts architecture rules → documents baselines
9. Agent verifies everything works → hands off to user
10. User has enterprise-grade governance running. Every session, every commit, every WO.
```

## Value Analysis: What's In vs Out

### INCLUDED (universal, customizable, prevents real problems)

| Pattern | Source | Why |
|---|---|---|
| 20 gate scripts (all working) | SIP + SS + new | Complete quality gate coverage |
| 8 hook templates | SalesSidekick | Real-time governance (secrets, frozen files, staging safety, session lifecycle) |
| settings.json template | SalesSidekick | Hook wiring — without this, hooks don't fire |
| 7 gate phases | SalesSidekick | session_start → wo_entry → pre_commit → wo_exit → post_deploy → full_audit → session_end |
| Known baselines system | SalesSidekick | Adoptable by existing projects — violations become ratchet-down baselines |
| Evidence bundle validation | SalesSidekick | SOC 2 compliance — structured, machine-parseable proof |
| 4-tier gate definitions | SalesSidekick | Session lifecycle / critical / important / advisory |
| 3 agent config sets | Both | Claude (multi-file + hooks), Cursor (.cursorrules), Codex (AGENTS.md) |
| Infrastructure manifest | SS + SIP | "Where is everything" — prevents drift every session |
| Version validation | New | Forces real-time version checks — agents build on stale training data |
| Agent bootstrap playbook | New | The agent reads this and drives the entire setup autonomously |
| Project intake questionnaire | New | Structured questions so agent customizes correctly |

### EXCLUDED (project-specific or v2.0)

| Pattern | Why |
|---|---|
| Canonical tracker parity (432 LOC) | SS-specific (4 trackers). Most projects have 1. |
| 22 advanced Python validators | Language-specific. Extension pack for v2.0. |
| Frontend-backend contracts (220 LOC) | SS-specific (7 React component contracts) |
| enforce-architecture-enhanced.sh (339 LOC) | SS Strangler Fig. Generic engine covers the pattern. |
| GitHub Actions CI/CD | Cloud-specific. Gate-runner works locally. v1.1. |
| Multi-agent team config | Premature. Document the pattern, don't require it. |

## Repository Structure

```
enterprise-dev-framework/
│
│── # THE ENTRY POINTS (agent reads these first)
├── AGENT-BOOTSTRAP.md              ← Master playbook: 7-phase agent-driven setup
├── PROJECT-INTAKE.md               ← 18-question intake across 4 rounds
├── README.md                       ← Human-readable overview + "how to use"
├── LICENSE (MIT)
├── CHANGELOG.md
│
├── docs/
│   ├── CORE-PRINCIPLES.md          ← Philosophy (not a template — agents and humans read this)
│   ├── PREREQUISITES.md            ← Tool installation per OS
│   ├── PROGRESSIVE-ADOPTION.md     ← Pick-and-choose tiers (not all-or-nothing)
│   └── agents/
│       ├── CLAUDE-CODE.md           ← Deep dive: CLAUDE.md, .claude/rules/, hooks, skills, settings.json
│       ├── CURSOR.md                ← Deep dive: .cursorrules, composer patterns
│       └── CODEX.md                 ← Deep dive: AGENTS.md, CLI patterns
│
├── decision-engine/                ← Agent reads these to make setup decisions
│   ├── gate-selection.md           ← Decision tree: which gates for which project type
│   ├── phase-selection.md          ← Decision tree: which phases based on team size + maturity
│   ├── hook-selection.md           ← Decision tree: which hooks for which agent + compliance
│   ├── architecture-rules.md       ← Decision tree: rule types by framework (FastAPI, Django, Express, etc.)
│   └── compliance-mapping.md       ← SOC 2 / GDPR / OWASP → which gates + evidence requirements
│
├── reference/                      ← Annotated examples (agent reads, adapts, does NOT copy verbatim)
│   ├── claude/
│   │   ├── CLAUDE.md.ref           ← Annotated with ADAPT/CUSTOMIZE/REQUIRED markers
│   │   ├── settings.json.ref       ← Annotated hook wiring reference
│   │   └── rules/
│   │       ├── governance-cascade.md.ref
│   │       ├── evidence-first.md.ref
│   │       ├── no-stubs-placeholders.md.ref
│   │       ├── architecture-rules.md.ref
│   │       ├── mandatory-audit.md.ref
│   │       ├── security.md.ref
│   │       ├── wo-protocol.md.ref
│   │       └── version-validation.md.ref
│   ├── cursor/
│   │   └── cursorrules.ref
│   ├── codex/
│   │   └── AGENTS.md.ref
│   ├── manifests/
│   │   ├── quality-gate-manifest.json.ref   ← All phases, tiers, baselines — annotated
│   │   └── pre-commit-config.yaml.ref
│   ├── hooks/
│   │   ├── pre-tool/
│   │   │   ├── secrets-scan.sh.ref
│   │   │   ├── frozen-files.sh.ref
│   │   │   └── staging-target.sh.ref
│   │   ├── post-tool/
│   │   │   └── capture-failure.sh.ref
│   │   ├── user-prompt/
│   │   │   └── governance-guard.sh.ref
│   │   ├── subagent/
│   │   │   └── validate-audit-result.sh.ref
│   │   └── session/
│   │       ├── session-start.sh.ref
│   │       └── session-resume.sh.ref
│   ├── governance/
│   │   ├── WO-INDEX.md.ref
│   │   ├── WO-TEMPLATE.md.ref
│   │   ├── ADR-TEMPLATE.md.ref
│   │   ├── DESIGN-DOC-TEMPLATE.md.ref
│   │   ├── ARCHITECTURE.md.ref
│   │   └── INFRASTRUCTURE-MANIFEST.md.ref
│   ├── skills/
│   │   ├── quality-gate-check.md.ref
│   │   ├── wo-complete.md.ref
│   │   ├── post-phase-audit.md.ref
│   │   └── wo-research.md.ref
│   └── project-configs/
│       ├── python-fastapi.json
│       ├── python-django.json
│       └── typescript-node.json
│
├── scripts/                        ← 20 working gate scripts (agent copies these)
│   ├── gate-runner.sh              ← Orchestrator: reads manifest, runs gates, handles baselines
│   │
│   ├── # Pre-commit (4)
│   ├── validate-no-secrets.sh
│   ├── validate-security-patterns.sh
│   ├── detect-stubs-placeholders.py
│   ├── validate-code-quality.sh
│   │
│   ├── # WO-exit (4)
│   ├── enforce-architecture.sh      ← Config-driven rule engine (JSON rules)
│   ├── validate-work-order.sh
│   ├── validate-logging-patterns.sh
│   ├── validate-documentation-completeness.sh
│   │
│   ├── # Full-audit (6)
│   ├── validate-owasp-alignment.sh
│   ├── validate-pii-handling.sh
│   ├── validate-tenant-isolation.sh
│   ├── validate-test-integrity.sh
│   ├── validate-dependencies.sh
│   ├── validate-audit-completeness.sh
│   │
│   ├── # Session + evidence (2)
│   ├── validate-session-start.sh
│   ├── validate-evidence-bundle.sh
│   │
│   ├── # Infrastructure + version (2)
│   ├── validate-infrastructure-manifest.sh
│   ├── validate-dependency-versions.sh
│   │
│   ├── # Post-deploy (2)
│   ├── smoke-test.sh
│   ├── health-check.sh
│   │
│   └── architecture-rules.example.json
│
└── helpers/                        ← Mechanical utilities the agent calls
    ├── render-template.sh          ← jq for JSON, sed for markdown
    ├── verify-prerequisites.sh     ← Checks bash 4+, python 3.7+, git, jq
    └── verify-setup.sh             ← Post-setup validation (all gates run, no crashes)
```

## AGENT-BOOTSTRAP.md — The Master Playbook

The core innovation. This is what the agent reads first. Written in agent-executable format: action verb headers, decision trees (not prose), INPUT/OUTPUT/STORE annotations, verification at every phase boundary.

### 7 Phases

**Phase 1: Orientation**
- INPUT: This repo's file structure
- ACTION: Read AGENT-BOOTSTRAP.md, scan repo structure, identify agent type (Claude/Cursor/Codex)
- STORE: Agent type, framework version, available scripts list
- VERIFY: Agent can list all 20 gate scripts and identify its own config format

**Phase 2: Project Intake**
- INPUT: PROJECT-INTAKE.md questionnaire
- ACTION: Ask user 18 questions across 4 rounds:
  - Round 1 (Identity): project name, slug, description, repo URL
  - Round 2 (Stack): language, framework, source dirs, test dir, package manager, database, cloud provider
  - Round 3 (Governance): team size, compliance targets (SOC 2/GDPR/OWASP/none), WO dir, frozen files, production URLs
  - Round 4 (Agent): preferred agent, multi-agent team?, CI/CD platform, MCP servers
- STORE: Project config (structured JSON)
- VERIFY: All required fields populated, source dirs exist

**Phase 3: Decision Engine**
- INPUT: Project config from Phase 2 + decision trees in `decision-engine/`
- ACTION: Select gates, phases, hooks, rules, architecture config based on answers
- DECISIONS:
  - Gates: All 20 always available. Pre-commit (4) always on. WO-exit gates selected by stack. Full-audit gates selected by compliance targets.
  - Phases: Solo dev → 4 phases (pre_commit, wo_exit, full_audit, session_start). Team → 7 phases (add wo_entry, component exits, session_end). Enterprise → 10 phases (add post_deploy, wo_exit_governance).
  - Hooks: Claude Code → all 8. Cursor → secrets-scan + frozen-files (via .cursorrules). Codex → none (no hook support).
  - Architecture rules: FastAPI → API purity + router isolation. Django → app isolation + ORM enforcement. Express → middleware isolation + async patterns.
- STORE: Selected configuration
- VERIFY: Print summary, get user confirmation before proceeding

**Phase 4: Mechanical Setup**
- INPUT: Selected configuration
- ACTION:
  1. Run `helpers/verify-prerequisites.sh` — check bash 4+, python 3.7+, git, jq
  2. Create directory structure: `scripts/`, `docs/planning/`, `.claude/` (or equivalent)
  3. Copy selected gate scripts to project's `scripts/`
  4. Generate quality-gate-manifest.json from selected phases + gates + tiers
  5. Generate architecture-rules.json from framework-specific rules
  6. Set up pre-commit hooks (`.pre-commit-config.yaml`)
- STORE: Paths of all created files
- VERIFY: `bash scripts/gate-runner.sh pre_commit --continue-on-failure` runs without crashes

**Phase 5: Intelligent Customization**
- INPUT: Reference files from `reference/`, project config
- ACTION:
  1. Generate agent config (CLAUDE.md / .cursorrules / AGENTS.md) — not copy, GENERATE from reference + project context
  2. Generate rule files customized to project (architecture rules, security, stubs policy)
  3. Generate settings.json with hook wiring (Claude Code only)
  4. Copy and customize hook scripts (Claude Code only)
  5. Generate governance templates (WO-INDEX, WO-TEMPLATE, etc.) with project name/slug
  6. Generate INFRASTRUCTURE-MANIFEST.md with sections for the project's cloud provider
  7. Generate skill definitions (Claude Code only)
- STORE: All generated file paths
- VERIFY: All JSON valid, no placeholder remnants, hooks fire on test event

**Phase 6: Existing Project Ingestion** (if project has existing code)
- INPUT: Project source directories
- ACTION:
  1. Scan codebase structure — modules, imports, test coverage
  2. Analyze import graph — identify module boundaries that already exist
  3. Generate architecture rules that MATCH existing structure (non-punitive)
  4. Run all selected gates → capture failures as known baselines
  5. Document baselines in manifest with reasons: "Pre-existing at framework adoption"
  6. Detect existing tooling (ruff config, mypy config, pytest config) → integrate, don't override
  7. Scan for existing .env → populate infrastructure manifest env vars section
- STORE: Baselines, detected architecture, existing tooling config
- VERIFY: `gate-runner.sh full_audit` passes (all failures within baselines)

**Phase 7: Verification + Handoff**
- INPUT: Everything from Phases 1-6
- ACTION:
  1. Run `helpers/verify-setup.sh` — all gates execute, no crashes
  2. Run full_audit → verify baseline handling
  3. Test hooks (Claude Code): write a test secret → verify secrets-scan catches it
  4. Generate setup summary for user: what was installed, what gates are active, what baselines exist
  5. First commit: "feat: enterprise governance framework (auto-configured)"
- OUTPUT: Setup complete message with next steps

## PROJECT-INTAKE.md — Structured Questionnaire

Written so ANY agent can parse it. Each question has:
- `QUESTION:` — what to ask
- `TYPE:` — text / choice / multi-choice / path
- `DEFAULT:` — sensible default
- `REQUIRED:` — yes/no
- `USED_BY:` — which Phase 3 decisions depend on this answer

Example:
```
### Q5: Primary Language
QUESTION: What is the primary programming language?
TYPE: choice
OPTIONS: python | typescript | javascript | go | rust | java | other
DEFAULT: python
REQUIRED: yes
USED_BY: architecture-rules, code-quality-gate, stub-detection, dependency-validation
```

## Decision Engine

Located in `decision-engine/`. Each file is a decision tree the agent follows.

### gate-selection.md
```
IF compliance includes "SOC 2":
  ENABLE: validate-evidence-bundle, validate-audit-completeness, validate-pii-handling
IF compliance includes "OWASP":
  ENABLE: validate-owasp-alignment, validate-security-patterns (strict mode)
IF compliance includes "GDPR":
  ENABLE: validate-pii-handling (strict mode), validate-tenant-isolation
IF database == "postgresql" OR database == "mysql":
  ENABLE: validate-tenant-isolation
IF language == "python":
  ENABLE: detect-stubs-placeholders.py, validate-code-quality.sh (ruff mode)
IF language == "typescript" OR language == "javascript":
  ENABLE: detect-stubs-placeholders.py (JS mode), validate-code-quality.sh (eslint mode)
ALWAYS ENABLE: validate-no-secrets, validate-security-patterns, validate-work-order
```

### phase-selection.md
```
IF team_size == "solo":
  PHASES: session_start, pre_commit, wo_exit, full_audit
IF team_size == "small" (2-5):
  PHASES: session_start, wo_entry, pre_commit, wo_exit_backend, wo_exit_governance, full_audit, session_end
IF team_size == "enterprise" (5+):
  PHASES: ALL (session_start, wo_entry, pre_commit, wo_exit_backend, wo_exit_frontend, wo_exit_crosscutting, wo_exit_governance, post_deploy, full_audit, session_end)
```

### hook-selection.md
```
IF agent == "claude-code":
  ALWAYS: secrets-scan, frozen-files, session-start, session-resume, capture-failure
  IF has_production_urls: staging-target
  IF has_subagents: validate-audit-result
  IF compliance != "none": governance-guard
IF agent == "cursor":
  EMBED in .cursorrules: secrets-scan patterns, frozen-file warnings
  NO hooks (Cursor doesn't support hook scripts)
IF agent == "codex":
  EMBED in AGENTS.md: governance rules as text instructions
  NO hooks (Codex doesn't support hook scripts)
```

## Agent-Readable Document Principles

All framework documents follow these 7 rules:

1. **Action verb headers** — "Copy these scripts" not "Scripts Overview"
2. **Decision trees, not prose** — IF/THEN/ELSE, not paragraphs explaining trade-offs
3. **STORE/INPUT/OUTPUT annotations** — every phase declares what it needs and produces
4. **Verification at every phase boundary** — agent confirms success before proceeding
5. **Concrete examples** — not "customize to your project" but "IF FastAPI THEN add these 3 rules"
6. **TYPE/REQUIRED/DEFAULT annotations** — every question and config field is typed
7. **No ambiguous language** — "should" and "consider" replaced with "MUST" and "IF condition THEN"

## Reference Files (.ref) vs Templates (.tmpl)

**Key design change from v4:** Files in `reference/` are annotated references, NOT fill-in-the-blank templates. The agent reads them, understands the patterns, and GENERATES project-specific versions. This is critical because:

1. Templates produce generic output. Agent-generated output is customized.
2. Templates break on edge cases. Agents adapt.
3. Templates can't merge with existing config. Agents can.

Each `.ref` file contains:
- `<!-- REQUIRED -->` — sections that must appear in generated output
- `<!-- ADAPT: explanation -->` — sections the agent customizes based on project config
- `<!-- OPTIONAL: condition -->` — sections included only if condition is true
- `<!-- EXAMPLE -->` — concrete examples the agent uses as patterns

## Scripts (20 working gate scripts)

All scripts are parameterized via environment variables. The agent sets these in the manifest.

| # | Script | LOC | Source | Parameterized By |
|---|---|---|---|---|
| 1 | gate-runner.sh | ~300 | SIP (rewrite) | MANIFEST_PATH, PROJECT_ROOT |
| 2 | validate-no-secrets.sh | ~160 | SIP (verbatim) | SCAN_DIRS |
| 3 | validate-security-patterns.sh | ~160 | SIP (verbatim) | SCAN_DIRS |
| 4 | detect-stubs-placeholders.py | ~400 | SIP (parameterize) | --scan-dirs, --language |
| 5 | validate-code-quality.sh | ~80 | SIP (parameterize) | SOURCE_DIR, LINTER |
| 6 | enforce-architecture.sh | ~300 | New (config-driven) | RULES_FILE |
| 7 | validate-work-order.sh | ~90 | SIP (parameterize) | WO_DIR |
| 8 | validate-logging-patterns.sh | ~70 | SIP (parameterize) | SCAN_DIR |
| 9 | validate-documentation-completeness.sh | ~90 | SIP (parameterize) | SOURCE_DIR, DOC_DIR |
| 10 | validate-owasp-alignment.sh | ~150 | New | SCAN_DIRS, LANGUAGE |
| 11 | validate-pii-handling.sh | ~120 | New | SCAN_DIRS, PII_PATTERNS |
| 12 | validate-tenant-isolation.sh | ~130 | SS (adapt) | SCAN_DIRS, TENANT_FIELD |
| 13 | validate-test-integrity.sh | ~120 | New | TEST_DIR, SOURCE_DIR |
| 14 | validate-dependencies.sh | ~100 | New | PACKAGE_FILE |
| 15 | validate-audit-completeness.sh | ~80 | New | WO_DIR, ADR_DIR |
| 16 | validate-session-start.sh | ~70 | SS (reduce) | REQUIRED_DOCS, HEALTH_URL |
| 17 | validate-evidence-bundle.sh | ~100 | SS (adapt) | EVIDENCE_DIR |
| 18 | validate-infrastructure-manifest.sh | ~80 | New | MANIFEST_PATH |
| 19 | validate-dependency-versions.sh | ~120 | New | PACKAGE_FILE, REGISTRY |
| 20 | smoke-test.sh + health-check.sh | ~160 | New | HEALTH_URL, SMOKE_ENDPOINTS |

## Implementation (8 Sessions)

### Session 1: Core Playbooks + Bootstrap Infrastructure
**Goal:** AGENT-BOOTSTRAP.md and PROJECT-INTAKE.md are complete and agent-executable. Helper scripts work.

- Write `AGENT-BOOTSTRAP.md` (~400 LOC) — 7-phase master playbook with decision trees, INPUT/OUTPUT/STORE, verification steps
- Write `PROJECT-INTAKE.md` (~200 LOC) — 18 questions, 4 rounds, typed fields with defaults
- Write `decision-engine/gate-selection.md` (~80 LOC)
- Write `decision-engine/phase-selection.md` (~60 LOC)
- Write `decision-engine/hook-selection.md` (~60 LOC)
- Write `decision-engine/architecture-rules.md` (~100 LOC) — rules by framework
- Write `decision-engine/compliance-mapping.md` (~60 LOC)
- Write `helpers/verify-prerequisites.sh` (~60 LOC)
- Write `helpers/render-template.sh` (~120 LOC) — jq for JSON, sed for markdown
- Write `helpers/verify-setup.sh` (~80 LOC)

**Verify:** An agent (Claude Code) can read AGENT-BOOTSTRAP.md and execute Phases 1-3 on a test project.

### Session 2: Gate Scripts — Pre-Commit + WO-Exit (8 scripts)
**Goal:** All 8 core gate scripts working.

- Copy + parameterize from SIP: validate-no-secrets.sh, validate-security-patterns.sh, detect-stubs-placeholders.py, validate-code-quality.sh
- Copy + parameterize from SIP: validate-work-order.sh, validate-logging-patterns.sh, validate-documentation-completeness.sh
- Write from scratch: enforce-architecture.sh (config-driven, ~300 LOC)
- Write architecture-rules.example.json (FastAPI, Django, Express examples)

**Verify:** All 8 gates run on empty project — pass or fail gracefully, no crashes.

### Session 3: Gate Scripts — Audit + Infrastructure + Version (10 scripts)
**Goal:** All remaining gate scripts working.

- Write: validate-owasp-alignment.sh, validate-pii-handling.sh, validate-tenant-isolation.sh, validate-test-integrity.sh, validate-dependencies.sh, validate-audit-completeness.sh
- Write: validate-session-start.sh, validate-evidence-bundle.sh
- Write: validate-infrastructure-manifest.sh, validate-dependency-versions.sh

**Verify:** All 18 gates + gate-runner.sh run via `gate-runner.sh full_audit --continue-on-failure`.

### Session 4: Gate Runner + Manifest System
**Goal:** Gate runner orchestrates all gates with phase support, baselines, tiers.

- Rewrite gate-runner.sh (~300 LOC) — phase inheritance (includes), baseline comparison, tier enforcement, component-specific exits, parallel execution option
- Write gate-runner for post-deploy: smoke-test.sh, health-check.sh
- Write quality-gate-manifest.json.ref — annotated reference with all 10 phases

**Verify:** gate-runner handles all phases correctly. Baselines distinguish regression from pre-existing. Graceful degradation.

### Session 5: Hooks + Settings + Session Lifecycle
**Goal:** Complete hook infrastructure (Claude Code).

- Write 8 hook reference files (adapted from SalesSidekick, annotated):
  - secrets-scan.sh.ref, frozen-files.sh.ref, staging-target.sh.ref
  - governance-guard.sh.ref, validate-audit-result.sh.ref
  - session-start.sh.ref, session-resume.sh.ref, capture-failure.sh.ref
- Write settings.json.ref (~100 LOC) — annotated hook wiring reference
- Test hooks end-to-end in a test Claude Code project

**Verify:** Hooks fire on correct events. Secrets-scan catches test secret. Frozen-files blocks edit. Session-start runs on session open.

### Session 6: Agent Config References + Governance Templates
**Goal:** All reference files for agent configs and governance docs.

- Write Claude references: CLAUDE.md.ref + 8 rule files (governance-cascade, evidence-first, no-stubs, architecture, mandatory-audit, security, wo-protocol, version-validation)
- Write Cursor reference: cursorrules.ref
- Write Codex reference: AGENTS.md.ref
- Write governance references: WO-INDEX.md.ref, WO-TEMPLATE.md.ref, ADR-TEMPLATE.md.ref, DESIGN-DOC-TEMPLATE.md.ref, ARCHITECTURE.md.ref, INFRASTRUCTURE-MANIFEST.md.ref
- Write skill references: quality-gate-check.md.ref, wo-complete.md.ref, post-phase-audit.md.ref, wo-research.md.ref
- Write shared references: pre-commit-config.yaml.ref

**Verify:** Full agent bootstrap renders all references into customized output. No placeholder remnants. All JSON valid.

### Session 7: Documentation + CORE-PRINCIPLES
**Goal:** All documentation written.

- Clean CORE-PRINCIPLES.md — remove SIP/SS refs, add hooks/sessions/evidence/baselines sections, make agent-agnostic
- Write README.md — the "landing page": what this is, 60-second demo, architecture diagram
- Write PROGRESSIVE-ADOPTION.md — pick tiers: Tier 1 only (pre-commit), Tier 1+2 (wo-exit), Full (all phases)
- Write PREREQUISITES.md — tool installation per OS (macOS, Ubuntu, Windows/WSL)
- Write agent guides: CLAUDE-CODE.md, CURSOR.md, CODEX.md

**Verify:** Docs internally consistent, no broken references, no project-specific content. A developer can read README → AGENT-BOOTSTRAP.md and understand the full flow.

### Session 8: End-to-End Testing + Polish
**Goal:** Ship-ready repo.

- Write 3 project config examples: python-fastapi, python-django, typescript-node
- End-to-end test: bootstrap each example with Claude Code, run all gates, run all hooks
- Verify existing project ingestion: bootstrap against SIP codebase, verify baselines
- LICENSE (MIT), CHANGELOG.md (v1.0.0)
- Version markers in scripts (`FRAMEWORK_VERSION="1.0.0"`)

**Verify:**
1. All 3 example configs produce working governance setups
2. All 20 gates execute (pass or fail gracefully — no crashes)
3. All 8 hooks fire correctly (Claude Code)
4. Existing project ingestion produces correct baselines
5. No `{{PLACEHOLDER}}` remnants in any generated files
6. All JSON valid (`jq . file.json` succeeds)
7. Known baselines correctly distinguish regression from pre-existing failures

## Source File Mapping

### From SIP (extract + parameterize)
| Source | Target | Action |
|---|---|---|
| `scripts/validate-no-secrets.sh` | `scripts/validate-no-secrets.sh` | Copy, add SCAN_DIRS param |
| `scripts/validate-security-patterns.sh` | `scripts/validate-security-patterns.sh` | Copy, add SCAN_DIRS param |
| `scripts/gate-runner.sh` | `scripts/gate-runner.sh` | Rewrite: baselines, component phases, tiers |
| `scripts/detect-stubs-placeholders.py` | `scripts/detect-stubs-placeholders.py` | Add --scan-dirs, --language |
| `scripts/validate-code-quality.sh` | `scripts/validate-code-quality.sh` | Add SOURCE_DIR, LINTER params |
| `scripts/validate-work-order.sh` | `scripts/validate-work-order.sh` | Add WO_DIR param |
| `scripts/validate-logging-patterns.sh` | `scripts/validate-logging-patterns.sh` | Add SCAN_DIR param |
| `scripts/validate-documentation-completeness.sh` | `scripts/validate-documentation-completeness.sh` | Add SOURCE_DIR, DOC_DIR params |
| `~/.claude/CORE-PRINCIPLES.md` | `docs/CORE-PRINCIPLES.md` | Clean, generalize, add sections |
| `CLAUDE.md` | `reference/claude/CLAUDE.md.ref` | Annotate with ADAPT/REQUIRED markers |
| `.claude/rules/always/*.md` | `reference/claude/rules/*.md.ref` | Annotate |
| `.claude/quality-gate-manifest.json` | `reference/manifests/quality-gate-manifest.json.ref` | Expand + annotate |

### From SalesSidekick (adapt + annotate)
| Source | Target | Action |
|---|---|---|
| `.claude/hooks/pre-tool/*.sh` | `reference/hooks/pre-tool/*.sh.ref` | Parameterize + annotate |
| `.claude/hooks/post-tool/capture-failure.sh` | `reference/hooks/post-tool/capture-failure.sh.ref` | Annotate |
| `.claude/hooks/user-prompt/governance-guard.sh` | `reference/hooks/user-prompt/governance-guard.sh.ref` | Annotate |
| `.claude/hooks/subagent/validate-audit-result.sh` | `reference/hooks/subagent/validate-audit-result.sh.ref` | Annotate |
| `.claude/hooks/session/*.sh` | `reference/hooks/session/*.sh.ref` | Parameterize + annotate |
| `.claude/settings.json` | `reference/claude/settings.json.ref` | Annotate hook wiring |
| `scripts/validate-tenant-isolation.sh` | `scripts/validate-tenant-isolation.sh` | Parameterize TENANT_FIELD |
| `scripts/validate-evidence-bundle.sh` | `scripts/validate-evidence-bundle.sh` | Remove SS-specific strict mode |
| `scripts/validate-session-start.sh` | `scripts/validate-session-start.sh` | Reduce 212→70 LOC |
| `.claude/rules/backend/security.md` | `reference/claude/rules/security.md.ref` | Annotate |
| `.claude/rules/work-orders/protocol.md` | `reference/claude/rules/wo-protocol.md.ref` | Annotate |
| `.cursorrules` | `reference/cursor/cursorrules.ref` | Adapt structure |
| `AGENTS.md` | `reference/codex/AGENTS.md.ref` | Adapt structure |

### New (write from scratch)
| Target | Description |
|---|---|
| `AGENT-BOOTSTRAP.md` | Master playbook — the entry point |
| `PROJECT-INTAKE.md` | 18-question intake questionnaire |
| `decision-engine/*.md` (5 files) | Decision trees for setup choices |
| `helpers/*.sh` (3 files) | Mechanical utilities |
| `scripts/enforce-architecture.sh` | Config-driven architecture engine |
| `scripts/validate-owasp-alignment.sh` | OWASP Top 10 alignment checks |
| `scripts/validate-pii-handling.sh` | PII detection in code + logs |
| `scripts/validate-test-integrity.sh` | Vacuous assertions, mirror structure |
| `scripts/validate-dependencies.sh` | pip-audit / npm audit wrapper |
| `scripts/validate-audit-completeness.sh` | WO audit trail validation |
| `scripts/validate-infrastructure-manifest.sh` | Infra doc completeness |
| `scripts/validate-dependency-versions.sh` | Real-time version checking |
| `scripts/smoke-test.sh` | Post-deploy smoke test |
| `scripts/health-check.sh` | Post-deploy health check |
| `reference/governance/*.md.ref` (6 files) | Governance doc references |

## v1.1 Roadmap (documented, not implemented)

- GitHub Actions CI/CD template (gate-runner in CI)
- Extension packs: security gates, reliability gates, scalability gates
- Cascade router for Cursor (.cursorrules dynamic loading)
- Multi-agent team configuration
- Canonical tracker parity validation
- Web UI for intake questionnaire (alternative to agent-driven Q&A)
