# Changelog

## [2.0.0] — 2026-03-16

### What's New (Plain English)

- **Verification integrity** — 4 new gates that catch the ways autonomous builds lie to themselves: stale audit data, imagined API shapes, passing tests that prove nothing, and work marked "done" without evidence.
- **Convergence control** — 5 new scripts that detect when the build is going in circles, track findings across sessions so the same issue isn't reported twice, and expire old baseline suppressions after 2 phases.
- **VC-grade audit gates** — 6 new conditional gates for production-bound projects: observability, resilience, data integrity, API contracts, auth boundaries, and AI integration.
- **Quality & architecture** — 3 new always-on gates for code complexity, dev environment hygiene, and test quality (mock density, TDD compliance).
- **Additional gates** — Communication contract compliance, devmode fallback detection, environment variable completeness, infrastructure connectivity.
- **Expanded references** — Quality Anchor template, engineering principles, deviations tracker, research registry, product anchor, prompt engineering bible, 12 Codex skill references.
- **Decision engine** — 2 new decision trees (AI integration patterns, observability patterns) and gate-selection updated from 24 → 42 gates.

### Added
- **Verification integrity gates (4)** — `validate-worktree-freshness.sh` (tier 0, blocks stale worktree findings), `detect-testing-antipatterns.py` (silent pass guards, vacuous assertions, mock-only integration), `validate-wo-status-integrity.sh` (status inflation prevention), `validate-cross-boundary-contracts.sh` (frontend-backend contract validation).
- **Convergence directory (5 scripts)** — `state-hash.sh` (codebase fingerprint for loop detection), `convergence-check.sh` (progress stall detection), `baseline-check.sh` (2-phase baseline expiry), `migrate-baseline.sh` (baseline format migration), `findings-lifecycle.sh` (finding dedup, regression detection, false positive suppression, pattern statistics).
- **VC audit gates (5)** — `validate-observability.sh`, `validate-resilience-patterns.sh`, `validate-data-integrity.sh`, `validate-api-contracts.sh`, `validate-auth-boundaries.sh`. Conditional on deployment context.
- **Quality gates (3)** — `validate-code-complexity.sh`, `validate-dev-environment.sh`, `test-quality-gate.sh`. Always on.
- **AI integration gate** — `validate-ai-integration.sh`. Conditional on AI/LLM usage.
- **Additional gates (4)** — `validate-communication-contract.sh`, `validate-devmode-fallbacks.sh`, `validate-env-completeness.sh`, `validate-infrastructure-connectivity.sh`.
- **Setup utility** — `setup-git-hooks.sh` installs pre-commit hooks into target project.
- **Decision engine (2)** — `ai-integration-patterns.md`, `observability-patterns.md`.
- **Reference files** — `QUALITY-ANCHOR-TEMPLATE.md` (frozen quality standard), `DEVIATIONS.md.ref`, `ENGINEERING-PRINCIPLES.md.ref`, `RESEARCH-REGISTRY.md.ref`, `PRODUCT-ANCHOR.md.ref`, `cli-vs-mcp.md`, 12 Codex skill SKILL.md files, prompt-engineering-bible (17 files).

### Changed
- **FRAMEWORK_VERSION** bumped from `1.0.0` to `2.0.0` across all scripts, helpers, and AGENT-BOOTSTRAP.md.
- **gate-selection.md** — Expanded from 24 to 42 gates. Added verification integrity (always-on), VC audit enhancement (conditional), AI integration (conditional), cross-boundary validation sections. Always-on count: 13 → 20.
- **Baseline entries now expire after 2 phases** — they can no longer suppress findings indefinitely.

### Fixed
- False positive rate from stale audit worktrees (worktree freshness gate)
- Frontend-backend contract drift (cross-boundary contracts gate)
- Silent pass guards and vacuous assertions (testing antipatterns detector)
- WO status inflation (status integrity gate)

## Unreleased

### What's New (Plain English)

- **"How serious is this project?"** — The agent now asks whether you're building a quick prototype, something for real users, or something that needs to scale. That shapes which checks and phases it sets up (e.g. production readiness, monitoring, security).
- **Risks and assumptions template** — A new template helps you capture open questions, delivery risks, and compliance concerns during discovery.
- **Project audit report** — A full audit of the framework is documented (workflow, technical consistency, schema alignment).
- **24 checks** — Three new checks added (including production readiness when you're beyond prototype).
- **Fixes and polish** — Various fixes to checks, manifest handling, and work-order validation.

### Added
- **Production readiness (deployment context)** — Q12b in PROJECT-INTAKE: deployment context (prototype | production | customer-facing | scale). Drives conditional phases in DEVELOPMENT-PLAN: Production Readiness for all non-prototype; Observability, Resilience, Security Hardening for customer-facing/scale. `validate-production-readiness.sh` gate; Production Definition of Done in wo-protocol and CLAUDE.ref.
- **ASSUMPTIONS-AND-RISKS.md.ref** — Reference template for discovery output (unresolved questions, delivery risks, compliance concerns).
- **docs/AUDIT-REPORT.md** — Full project audit (workflow, technical, schema consistency).

### Changed
- **gate-selection.md** — Added deployment_context input and conditional rule for validate-production-readiness.sh. Updated script count to 24.
- **AGENT-BOOTSTRAP** — Round 3 now 6 questions (deployment context); Phase 2 STORE includes deployment_context; Phase 4C copies validate-production-readiness.sh; Phase 3A includes production-readiness conditional; summary "Gates enabled: of 24".
- **development-plan-generation** — Input now lists governance_profile.deployment_context.
- **docs/PLAN.md** — Script count 24; Round 3 includes deployment context; 19 questions total.
- **Appendix** — scripts/ count updated to 24 gates + gate-runner.

### Added (prior)
- **Production readiness (deployment context)** — Q12b: Deployment Context (prototype | production | customer-facing | scale) in PROJECT-INTAKE. `validate-production-readiness.sh` gate checks for Production Readiness (and Observability/Resilience/Security for customer-facing/scale) phases in DEVELOPMENT-PLAN. Development plan generation adds conditional phases per deployment_context. See `docs/AUDIT-REPORT.md` and plan at `.cursor/plans/enterprise_readiness_gaps_*.plan.md`.
- **ASSUMPTIONS-AND-RISKS.md.ref** — Reference template for discovery output (Unresolved Questions, Delivery Risks, Compliance/Data Concerns).
- **TDD enforcement gates** — `validate-tests-required.sh` blocks when no test files exist; `validate-tests-pass.sh` runs the project's test command and blocks when it fails. Both run in pre_commit and wo_exit (Tier 1). Aligns automation with rules (CLAUDE.md, WO-TEMPLATE, stub-detection) that require tests.
- **Development plan** — `DEVELOPMENT-PLAN.md` phased roadmap derived from PRD and architecture. Agent never asks "what to build?" — uses the plan. See `decision-engine/development-plan-generation.md`.
- **validate-development-plan-alignment.sh** — Gate at wo_exit and full_audit. Ensures DEVELOPMENT-PLAN, WO-INDEX, and WO files stay aligned; blocks on drift.
- **Midstream embedding** — Bootstrap detects existing projects, runs audit-first flow, explains audit→issues→WOs→implement→audit loop, creates WOs from findings.
- **Environment discovery** — `helpers/verify-environment.sh` discovers tools, GitHub, hosting. Phase 1.5 presents findings, walks user through config when missing.
- **Target-project invocation** — Bootstrap runs FROM the user's project folder; user provides path to VibeOS-2. No context switching.
- **Upgrade flow** — `helpers/upgrade.sh` upgrades existing projects: copies new scripts, merges new gates into manifest, preserves baselines. Say "Upgrade VibeOS using ~/VibeOS-2" when in your project. See `docs/UPGRADE.md`.

### Changed
- Stabilized the framework contract with `docs/CANONICAL-CONTRACT.md` and `docs/canonical-contract.json`.
- Added `docs/MIGRATION.md` and compatibility support for both `.claude/quality-gate-manifest.json` and root `quality-gate-manifest.json`.
- Updated `scripts/gate-runner.sh` to distinguish `SKIP` from `PASS`, preserve real gate exit codes in baseline checks, and support `wo_exit` fallback through specialized `wo_exit_*` phases.
- Fixed `scripts/validate-work-order.sh` so `--wo`/`WO_NUMBER` reaches the gate reliably under orchestration.
- Fixed `scripts/validate-code-quality.sh` so TypeScript, JavaScript, Go, and Rust lint/type-check failures no longer report false PASS results.
- Reworked `scripts/validate-dependency-versions.sh` into a bounded JS/TS + Python MVP with app-oriented pinning policy, lockfile checks, and best-effort latest-version awareness.
- Fixed `scripts/validate-dependencies.sh` to skip gracefully when `npm` is unavailable.
- Updated `scripts/validate-session-start.sh` and agent docs for dual manifest-path discovery.
- Aligned `helpers/verify-setup.sh` and `helpers/verify-prerequisites.sh` with the current manifest schema and documented exit codes.
- Added framework validation helpers and compatibility fixtures for root-manifest discovery, `wo_exit` fallback, contract consistency, and dependency-version policy checks.
- Brought governance templates into line with compliance docs by adding evidence, cloud provider, MCP, and data-privacy sections.
- Session start REQUIRED_DOCS now includes DEVELOPMENT-PLAN.md and WO-INDEX.md.
- validate-audit-completeness.sh now checks for DEVELOPMENT-PLAN.md and "Next Work Order" section.
- **TDD in Work Orders** — Test Strategy is a required WO section (before implementation). validate-work-order.sh enforces: (1) Test Strategy exists with substantive content for entry/completion, (2) Evidence must reference tests for completion. WO-TEMPLATE, wo-protocol, and WO-AUDIT-FRAMEWORK updated so every WO is a governed document that cannot complete without tests.

## v1.0.0 (2026-03-05)

### Added
- AGENT-BOOTSTRAP.md — 7-phase master playbook for agent-driven setup
- PROJECT-INTAKE.md — 18-question structured intake across 4 rounds
- Decision engine — 5 decision trees (gates, phases, hooks, architecture rules, compliance)
- 21 gate scripts — pre-commit, WO-exit, full-audit, infrastructure, post-deploy
- Gate runner — orchestrator with phase inheritance, baselines, tiers, JSON output
- 8 hook reference files — secrets-scan, frozen-files, staging-target, capture-failure, governance-guard, validate-audit-result, session-start, session-resume
- settings.json.ref — Claude Code hook wiring reference
- CLAUDE.md.ref + 8 rule references — agent config for Claude Code
- .cursorrules.ref — agent config for Cursor
- AGENTS.md.ref — agent config for Codex
- 6 governance templates — WO-INDEX, WO-TEMPLATE, ADR, design doc, architecture, infrastructure manifest
- 4 skill references — quality-gate-check, wo-complete, post-phase-audit, wo-research
- 3 project config examples — Python FastAPI, Python Django, TypeScript Express
- quality-gate-manifest.json.ref — annotated manifest reference
- pre-commit-config.yaml.ref — pre-commit configuration reference
- 3 helper scripts — verify-prerequisites, render-template, verify-setup
- Documentation — README, CORE-PRINCIPLES, PROGRESSIVE-ADOPTION, PREREQUISITES, agent guides
- Multi-language support — Python, TypeScript/JavaScript, Go, Rust, Java
