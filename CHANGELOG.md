# Changelog

## Unreleased

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
