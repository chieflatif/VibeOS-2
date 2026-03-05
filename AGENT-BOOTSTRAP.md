# VibeOS-2 — Agent Bootstrap Playbook

## PURPOSE

You are setting up enterprise-grade development governance for a project. This playbook tells you exactly what to do, step by step. Follow every phase in order. Do not skip phases. Verify before proceeding.

## FRAMEWORK VERSION

```
VIBEOS_VERSION="1.0.0"
```

## PREREQUISITES

Before starting, verify these tools are available:

```
REQUIRED: bash 3.2+, git, jq
REQUIRED IF language == python: python 3.7+ (for detect-stubs-placeholders.py)
RECOMMENDED BY LANGUAGE:
  python:     ruff (linting), pytest (testing), pre-commit
  typescript: eslint (linting), vitest/jest (testing), pre-commit
  javascript: eslint (linting), jest (testing), pre-commit
  go:         golangci-lint (linting), go test (built-in)
  rust:       clippy (linting), cargo test (built-in)
  java:       checkstyle (linting), junit (testing)
```

Run `helpers/verify-prerequisites.sh` from the VibeOS-2 directory to check.

---

## PHASE 1: ORIENTATION

### INPUT
- This file (AGENT-BOOTSTRAP.md)
- The VibeOS-2 repo directory structure

### ACTION

1. Confirm you are reading this file from the VibeOS-2 framework directory
2. Identify your agent type:
   - IF you are Claude Code → agent_type = "claude-code"
   - IF you are Cursor/Composer → agent_type = "cursor"
   - IF you are Codex CLI → agent_type = "codex"
3. Scan the `scripts/` directory — list all available gate scripts
4. Scan the `reference/` directory — list all reference files for your agent type
5. Identify the target project directory (the user's project, NOT this framework repo)

### STORE
```json
{
  "agent_type": "<claude-code|cursor|codex>",
  "framework_dir": "<path to this VibeOS-2 repo>",
  "target_project_dir": "<path to user's project>",
  "framework_version": "1.0.0",
  "available_scripts": ["<list of .sh and .py files in scripts/>"],
  "available_references": ["<list of .ref files for this agent type>"]
}
```

### VERIFY
- [ ] agent_type is set
- [ ] framework_dir exists and contains this file
- [ ] target_project_dir exists and is a git repo (or will be initialized)
- [ ] You can list at least 15 scripts in scripts/
- [ ] You can list reference files for your agent type

### ON FAILURE
IF target_project_dir does not exist → ask user for the correct path.
IF scripts/ has fewer than 15 files → framework may be incomplete. Warn user.

---

## PHASE 2: PROJECT INTAKE

### INPUT
- `PROJECT-INTAKE.md` (from this framework repo)
- User's answers to questions

### ACTION

Read `PROJECT-INTAKE.md` and ask the user all questions across 4 rounds. Do NOT skip rounds. Do NOT assume answers — ask every required question.

**Round 1 — Project Identity** (4 questions)
Ask: project name, slug, description, repo URL

**Round 2 — Technical Stack** (6 questions)
Ask: language, framework, source dirs, test dir, package manager, database

**Round 3 — Governance Profile** (5 questions)
Ask: team size, compliance targets, WO dir, frozen files, production URLs

**Round 4 — Agent Preferences** (3 questions)
Ask: cloud provider, CI/CD platform, MCP servers

### STORE
```json
{
  "project": {
    "name": "<from Q1>",
    "slug": "<from Q2>",
    "description": "<from Q3>",
    "repo_url": "<from Q4>"
  },
  "stack": {
    "language": "<from Q5>",
    "framework": "<from Q6>",
    "source_dirs": ["<from Q7>"],
    "test_dir": "<from Q8>",
    "package_manager": "<from Q9>",
    "database": "<from Q10>"
  },
  "governance": {
    "team_size": "<from Q11>",
    "compliance_targets": ["<from Q12>"],
    "wo_dir": "<from Q13>",
    "frozen_files": ["<from Q14>"],
    "production_urls": ["<from Q15>"]
  },
  "agent": {
    "cloud_provider": "<from Q16>",
    "ci_cd_platform": "<from Q17>",
    "mcp_servers": ["<from Q18>"]
  }
}
```

### VERIFY
- [ ] project.name is set (not empty)
- [ ] project.slug is set (lowercase, hyphens, no spaces)
- [ ] stack.language is a supported value (python, typescript, javascript, go, rust, java)
- [ ] stack.source_dirs — every directory exists OR user confirms they will be created
- [ ] governance.team_size is set (solo, small, enterprise)
- [ ] governance.compliance_targets is a list (can be empty/["none"])

### ON FAILURE
IF user skips a required question → explain why it's needed and ask again.
IF source_dirs don't exist → ask: "Should I create these directories?"

---

## PHASE 3: DECISION ENGINE

### INPUT
- Project config from Phase 2
- Decision trees in `decision-engine/` directory

### ACTION

Read each decision tree file and make selections:

#### 3A: Select Gate Scripts
Read `decision-engine/gate-selection.md`. Apply rules:

```
ALWAYS ENABLED (4 pre-commit gates):
  - validate-no-secrets.sh
  - validate-security-patterns.sh
  - detect-stubs-placeholders.py
  - validate-code-quality.sh

ALWAYS ENABLED (2 core gates):
  - validate-work-order.sh
  - enforce-architecture.sh

CONDITIONAL:
  IF compliance includes "SOC 2":
    ENABLE: validate-evidence-bundle.sh, validate-audit-completeness.sh, validate-pii-handling.sh
  IF compliance includes "OWASP":
    ENABLE: validate-owasp-alignment.sh
  IF compliance includes "GDPR":
    ENABLE: validate-pii-handling.sh, validate-tenant-isolation.sh
  IF database is "postgresql" OR "mysql" OR "sqlite":
    ENABLE: validate-tenant-isolation.sh
  IF production_urls is not empty:
    ENABLE: smoke-test.sh, health-check.sh

ALWAYS ENABLED (infrastructure):
  - validate-infrastructure-manifest.sh
  - validate-dependency-versions.sh
  - validate-session-start.sh
  - validate-logging-patterns.sh
  - validate-documentation-completeness.sh
  - validate-test-integrity.sh
  - validate-dependencies.sh
```

#### 3B: Select Gate Phases
Read `decision-engine/phase-selection.md`. Apply rules:

```
IF team_size == "solo":
  PHASES: session_start, pre_commit, wo_exit, full_audit

IF team_size == "small":
  PHASES: session_start, wo_entry, pre_commit, wo_exit_backend, wo_exit_governance, full_audit, session_end

IF team_size == "enterprise":
  PHASES: session_start, wo_entry, pre_commit, wo_exit_backend, wo_exit_frontend, wo_exit_crosscutting, wo_exit_governance, post_deploy, full_audit, session_end
```

#### 3C: Select Hooks
Read `decision-engine/hook-selection.md`. Apply rules:

```
IF agent_type == "claude-code":
  ALWAYS: secrets-scan, frozen-files, session-start, session-resume, capture-failure
  IF production_urls is not empty: staging-target
  IF compliance is not ["none"]: governance-guard
  IF using subagents: validate-audit-result

IF agent_type == "cursor":
  HOOKS: none (embed governance in .cursorrules instead)

IF agent_type == "codex":
  HOOKS: none (embed governance in AGENTS.md instead)
```

#### 3D: Select Architecture Rules
Read `decision-engine/architecture-rules.md`. Apply rules:

```
IF framework == "fastapi":
  RULES: api_purity, router_isolation, dependency_injection, no_raw_sql
IF framework == "django":
  RULES: app_isolation, orm_enforcement, view_separation, no_raw_sql
IF framework == "express" OR framework == "nestjs":
  RULES: middleware_isolation, async_patterns, controller_separation
IF framework == "flask":
  RULES: blueprint_isolation, no_raw_sql, factory_pattern
IF framework is other:
  RULES: no_raw_sql (minimum), ask user for module boundaries
```

#### 3E: Map Compliance Requirements
Read `decision-engine/compliance-mapping.md`. Apply rules:

```
IF compliance includes "SOC 2":
  REQUIRE: evidence bundles on every WO, audit trail, access logging
  GATES: validate-evidence-bundle (tier 1), validate-audit-completeness (tier 1)
IF compliance includes "GDPR":
  REQUIRE: PII handling docs, consent tracking, erasure support
  GATES: validate-pii-handling (tier 1), validate-tenant-isolation (tier 1)
IF compliance includes "OWASP":
  REQUIRE: injection prevention, auth checks, XSS prevention
  GATES: validate-owasp-alignment (tier 1), validate-security-patterns (strict)
IF compliance is ["none"]:
  All compliance gates set to tier 3 (advisory only)
```

### STORE
```json
{
  "selected_gates": ["<list of enabled gate script filenames>"],
  "selected_phases": ["<list of enabled phase names>"],
  "selected_hooks": ["<list of enabled hook names>"],
  "architecture_rules": ["<list of rule types>"],
  "compliance_gates": {
    "<gate_name>": { "tier": 1, "blocking": true },
    ...
  },
  "tier_overrides": {}
}
```

### VERIFY — Present Summary to User

Print a summary and ask for confirmation:

```
=== VibeOS-2 Setup Summary ===

Project: {project.name} ({project.slug})
Language: {stack.language} / {stack.framework}
Agent: {agent_type}
Team: {governance.team_size}

Gates enabled: {count} of 20
  Pre-commit: {list}
  WO-exit: {list}
  Full-audit: {list}
  Post-deploy: {list}

Phases: {selected_phases}

Hooks: {selected_hooks or "none (embedded in agent config)"}

Architecture rules: {architecture_rules}

Compliance: {compliance_targets}
  SOC 2 gates: {list or "N/A"}
  GDPR gates: {list or "N/A"}
  OWASP gates: {list or "N/A"}

Proceed with this configuration? [Y/n]
```

### ON FAILURE
IF user says no → ask what to change, update selections, re-present summary.

---

## PHASE 4: MECHANICAL SETUP

### INPUT
- Selected configuration from Phase 3
- Target project directory

### ACTION

Execute these steps in order:

#### 4A: Verify Prerequisites
```bash
bash {framework_dir}/helpers/verify-prerequisites.sh
```
IF any REQUIRED tool is missing → stop and tell user what to install.

#### 4B: Create Directory Structure
In the target project, create:
```
{target_project_dir}/
├── scripts/                    ← Gate scripts
├── docs/
│   └── planning/               ← Work orders, ADRs
├── .claude/                    ← (Claude Code only)
│   ├── rules/
│   │   └── always/
│   ├── hooks/
│   │   ├── pre-tool/
│   │   ├── post-tool/
│   │   ├── user-prompt/
│   │   ├── subagent/
│   │   └── session/
│   └── skills/
```
For Cursor: no .claude/ directory. For Codex: no .claude/ directory.

#### 4C: Copy Gate Scripts
Copy each selected gate script from `{framework_dir}/scripts/` to `{target_project_dir}/scripts/`.
Also always copy `gate-runner.sh` (the orchestrator).

#### 4D: Generate Quality Gate Manifest
Create `{target_project_dir}/.claude/quality-gate-manifest.json` (Claude Code) or
`{target_project_dir}/quality-gate-manifest.json` (Cursor/Codex).

Use `{framework_dir}/reference/manifests/quality-gate-manifest.json.ref` as the pattern.
Populate with:
- Selected phases from Phase 3
- Selected gates assigned to correct phases
- Tier definitions (always include all 4 tiers)
- Empty known_baselines (populated in Phase 6)

#### 4E: Generate Architecture Rules
Create `{target_project_dir}/scripts/architecture-rules.json`.
Use `{framework_dir}/scripts/architecture-rules.example.json` as the pattern.
Populate with rules selected in Phase 3D, customized to the project's source_dirs.

#### 4F: Set Up Pre-Commit
Create `{target_project_dir}/.pre-commit-config.yaml`.
Use `{framework_dir}/reference/manifests/pre-commit-config.yaml.ref` as the pattern.
Include hooks for each pre-commit gate.

### STORE
```json
{
  "created_files": ["<list of all files created>"],
  "copied_scripts": ["<list of scripts copied>"],
  "manifest_path": "<path to quality-gate-manifest.json>",
  "architecture_rules_path": "<path to architecture-rules.json>"
}
```

### VERIFY
```bash
# All copied scripts are syntactically valid
for f in {target_project_dir}/scripts/*.sh; do bash -n "$f" 2>&1; done

# Manifest is valid JSON
jq . {manifest_path} > /dev/null

# Architecture rules are valid JSON
jq . {architecture_rules_path} > /dev/null

# Gate runner can enumerate gates
bash {target_project_dir}/scripts/gate-runner.sh pre_commit --dry-run
```

### ON FAILURE
IF script copy fails → check permissions, check framework_dir path.
IF JSON validation fails → re-generate the file.
IF gate-runner fails → check manifest structure matches gate-runner expectations.

---

## PHASE 5: INTELLIGENT CUSTOMIZATION

### INPUT
- Reference files from `{framework_dir}/reference/`
- Project config from Phase 2
- Agent type from Phase 1

### ACTION

#### 5A: Generate Agent Configuration

**IF agent_type == "claude-code":**

1. Read `{framework_dir}/reference/claude/CLAUDE.md.ref`
2. GENERATE a project-specific CLAUDE.md at `{target_project_dir}/CLAUDE.md` containing:
   - Project name, description, architecture overview
   - Technology stack from intake
   - Module structure based on source_dirs
   - Architecture rules (human-readable summary)
   - Quality gate commands
   - Development workflow commands
   - Work Order protocol
   - Compliance targets (if any)
   Sections marked `<!-- REQUIRED -->` in the .ref file MUST appear.
   Sections marked `<!-- ADAPT -->` MUST be customized to the project.
   Sections marked `<!-- OPTIONAL: condition -->` included only if condition is true.

3. Read each file in `{framework_dir}/reference/claude/rules/`
4. GENERATE rule files at `{target_project_dir}/.claude/rules/always/`:
   - governance-cascade.md — REQUIRED (customize authority hierarchy)
   - evidence-first.md — REQUIRED (customize staging target)
   - no-stubs-placeholders.md — REQUIRED (no customization needed)
   - architecture-rules.md — REQUIRED (customize with project's module boundaries)
   - mandatory-audit.md — REQUIRED (customize gate phases)
   - security.md — REQUIRED (customize compliance targets)
   - wo-protocol.md — REQUIRED (customize WO dir path)
   - version-validation.md — REQUIRED (customize package manager)

5. Read `{framework_dir}/reference/claude/settings.json.ref`
6. GENERATE `{target_project_dir}/.claude/settings.json` with:
   - Hook wiring for all selected hooks
   - Permission deny list (production URLs, frozen files)
   - Environment variables (target env = staging)

**IF agent_type == "cursor":**

1. Read `{framework_dir}/reference/cursor/cursorrules.ref`
2. GENERATE `{target_project_dir}/.cursorrules` containing all governance rules, gate commands, architecture rules, and compliance requirements in a single file.

**IF agent_type == "codex":**

1. Read `{framework_dir}/reference/codex/AGENTS.md.ref`
2. GENERATE `{target_project_dir}/AGENTS.md` containing all governance rules, gate commands, architecture rules, and compliance requirements.

#### 5B: Generate Hook Scripts (Claude Code only)

For each selected hook:
1. Read the corresponding .ref file from `{framework_dir}/reference/hooks/`
2. GENERATE the hook script at `{target_project_dir}/.claude/hooks/{event_type}/{hook_name}.sh`
3. Customize each hook by setting variables at the top of the generated script:

   **secrets-scan.sh** — set SCAN_PATTERNS array:
   ```bash
   SCAN_PATTERNS=(
     'AKIA[0-9A-Z]{16}'           # AWS access key (always)
     'ghp_[a-zA-Z0-9]{36}'        # GitHub PAT (always)
     'sk-[a-zA-Z0-9]{48}'         # OpenAI API key (always)
     'eyJ[a-zA-Z0-9_-]*\.eyJ'     # JWT token (always)
     '-----BEGIN.*PRIVATE KEY'     # Private key (always)
   )
   # Add cloud-specific patterns:
   # IF cloud_provider == "azure": add Azure connection strings, SAS tokens
   # IF cloud_provider == "aws": add AWS secret keys, session tokens
   # IF cloud_provider == "gcp": add GCP service account JSON patterns
   ```

   **frozen-files.sh** — set FROZEN_FILES array from intake Q14:
   ```bash
   FROZEN_FILES=(
     # Populate from governance.frozen_files
     # Example: "src/legacy/main.py" "config/production.json"
   )
   ```

   **staging-target.sh** — set PRODUCTION_URLS array from intake Q15:
   ```bash
   PRODUCTION_URLS=(
     # Populate from governance.production_urls
     # Matching: exact domain match (strips protocol and path)
     # Example: "api.myapp.com" matches "https://api.myapp.com/anything"
   )
   ```

   **governance-guard.sh** — set BLOCKED_PATTERNS:
   ```bash
   BLOCKED_PATTERNS=(
     'skip.*gate'       # Always blocked
     'ignore.*test'     # Always blocked
     'disable.*hook'    # Always blocked
     'bypass.*check'    # Always blocked
   )
   # IF compliance != ["none"], add:
   #   'skip.*audit' 'no.*evidence' 'force.*deploy'
   ```

   **session-start.sh** — set REQUIRED_DOCS and HEALTH_URL:
   ```bash
   REQUIRED_DOCS=("CLAUDE.md" "docs/planning/WO-INDEX.md")  # or .cursorrules/AGENTS.md
   HEALTH_URL=""  # Set to first production_url + "/health" if available, else empty
   ```

   **capture-failure.sh** — set EVIDENCE_DIR:
   ```bash
   EVIDENCE_DIR=".claude/evidence"  # Claude Code default
   ```

   **session-resume.sh** — no project-specific customization needed.
   **validate-audit-result.sh** — no project-specific customization needed.

#### 5C: Generate Governance Documents

Read reference files from `{framework_dir}/reference/governance/` and GENERATE:

1. `{target_project_dir}/docs/planning/WO-INDEX.md` — with project name, empty WO table
2. `{target_project_dir}/docs/planning/WO-TEMPLATE.md` — standard WO template
3. `{target_project_dir}/docs/ADR-TEMPLATE.md` — ADR template
4. `{target_project_dir}/docs/ARCHITECTURE.md` — with project's module structure, architecture rules
5. `{target_project_dir}/docs/INFRASTRUCTURE-MANIFEST.md` — with sections for the project's cloud provider, database, env vars

#### 5D: Generate Skill Definitions (Claude Code only)

Read reference files from `{framework_dir}/reference/skills/` and GENERATE:

1. `{target_project_dir}/.claude/skills/quality-gate-check.md`
2. `{target_project_dir}/.claude/skills/wo-complete.md`
3. `{target_project_dir}/.claude/skills/post-phase-audit.md`
4. `{target_project_dir}/.claude/skills/wo-research.md`

Customize paths and gate names to match the project's manifest.

### STORE
```json
{
  "agent_config_path": "<path to CLAUDE.md / .cursorrules / AGENTS.md>",
  "rule_files": ["<list of generated rule files>"],
  "hook_files": ["<list of generated hook scripts>"],
  "governance_docs": ["<list of generated governance docs>"],
  "skill_files": ["<list of generated skill definitions>"],
  "settings_path": "<path to settings.json (Claude Code only)>"
}
```

### VERIFY
- [ ] Agent config file exists and has no `<!-- REQUIRED -->` markers remaining
- [ ] All rule files exist (8 for Claude Code)
- [ ] settings.json is valid JSON (Claude Code only)
- [ ] All hook scripts are executable and pass `bash -n` syntax check
- [ ] WO-INDEX.md exists with project name
- [ ] INFRASTRUCTURE-MANIFEST.md exists with correct cloud provider sections
- [ ] No `{{PLACEHOLDER}}` or `<!-- ADAPT -->` markers remain in any generated file

### ON FAILURE
IF a reference file is missing → warn user, skip that file, note in setup summary.
IF JSON validation fails → re-generate.

---

## PHASE 6: EXISTING PROJECT INGESTION

### CONDITION
IF the target project has existing source code (source_dirs contain .py/.ts/.js/.go/.rs/.java files), execute this phase.
IF the target project is empty/greenfield, SKIP to Phase 7.

### INPUT
- Target project source directories
- Selected gates and architecture rules

### ACTION

#### 6A: Scan Codebase Structure
```
1. Count files by type in each source_dir
2. Identify module/package boundaries:
   IF python: directories with __init__.py
   IF typescript/javascript: directories with package.json or index.ts/index.js
   IF go: directories with go.mod or *.go files
   IF rust: directories with Cargo.toml or mod.rs
   IF java: directories following package hierarchy (com/org/...)
3. Map import graph — for each module, list which other modules it imports
4. Measure test coverage structure — count test files, check if they mirror source files
```

#### 6B: Adapt Architecture Rules
```
1. Compare detected module boundaries against selected architecture rules
2. FOR EACH rule, run the rule against the codebase and count violations
3. Apply this decision tree:

   IF violation_count == 0:
     KEEP rule as-is (project already follows this pattern)

   IF violation_count >= 1 AND violation_count <= 5:
     KEEP rule as-is
     Violations become baselines in Phase 6C
     REASON: Small number of violations suggests these are fixable issues

   IF violation_count > 5 AND violation_count <= 20:
     ASK USER: "{rule.name} has {count} existing violations. Options:
       a) Keep rule — violations become baselines (fix over time)
       b) Adapt rule — add exceptions for current patterns
       c) Remove rule — not applicable to this project"
     IF user chooses (a): keep rule, violations become baselines
     IF user chooses (b): add exclusion patterns for violating files
     IF user chooses (c): remove rule from architecture-rules.json

   IF violation_count > 20:
     WARN: "{rule.name} has {count} violations — this rule likely doesn't match your architecture"
     DEFAULT: Remove rule
     ASK USER: "Remove this rule? [Y/n]"

4. Update architecture-rules.json with adapted rules
```

#### 6C: Establish Baselines
```
1. Run ALL selected gates against the existing codebase:
   bash {target_project_dir}/scripts/gate-runner.sh full_audit --continue-on-failure 2>&1
2. Parse output — count failures per gate
3. FOR EACH gate with failures:
   CREATE a baseline entry:
   {
     "gate": "<gate name>",
     "max_allowed_failures": <failure count>,
     "fail_count_pattern": "<regex to extract count from gate output>",
     "known_failing_files": ["<list of files with violations>"],
     "reason": "Pre-existing at VibeOS-2 adoption ({date})",
     "since": "<today's date>",
     "last_verified": "<today's date>"
   }
4. Add all baselines to quality-gate-manifest.json → known_baselines.entries
```

#### 6D: Detect Existing Tooling
```
PYTHON PROJECTS:
  IF .ruff.toml or pyproject.toml [tool.ruff] exists:
    NOTE: "Existing ruff config — validate-code-quality.sh will use it"
  IF mypy.ini or pyproject.toml [tool.mypy] exists:
    NOTE: "Existing mypy config — no override needed"
  IF pytest.ini or pyproject.toml [tool.pytest] or conftest.py exists:
    NOTE: "Existing pytest config — no override needed"

TYPESCRIPT/JAVASCRIPT PROJECTS:
  IF .eslintrc* or eslint.config.* exists:
    NOTE: "Existing eslint config — validate-code-quality.sh will use it"
  IF tsconfig.json exists:
    NOTE: "Existing TypeScript config — no override needed"
  IF vitest.config.* or jest.config.* exists:
    NOTE: "Existing test config — no override needed"

GO PROJECTS:
  IF .golangci.yml or .golangci.yaml exists:
    NOTE: "Existing golangci-lint config — validate-code-quality.sh will use it"
  IF go.mod exists:
    NOTE: "Go modules detected"

RUST PROJECTS:
  IF Cargo.toml exists:
    NOTE: "Cargo project detected"
  IF clippy.toml or .clippy.toml exists:
    NOTE: "Existing clippy config — validate-code-quality.sh will use it"

JAVA PROJECTS:
  IF pom.xml or build.gradle exists:
    NOTE: "Build system detected"
  IF checkstyle.xml exists:
    NOTE: "Existing checkstyle config — validate-code-quality.sh will use it"

ALL PROJECTS:
  IF .env exists:
    EXTRACT variable names (grep lines matching ^[A-Z_]+=)
    POPULATE INFRASTRUCTURE-MANIFEST.md env vars table with:
      | Variable | Purpose | Source | Required? |
      For each extracted var, set Purpose="(auto-detected)", Source=".env", Required="TBD"
  IF .pre-commit-config.yaml exists:
    MERGE new hooks with existing hooks (don't override, append only)
  IF .gitignore exists:
    MERGE framework patterns with existing patterns
```

### STORE
```json
{
  "codebase_stats": {
    "total_files": 0,
    "files_by_type": {},
    "modules_detected": [],
    "test_coverage_structure": {}
  },
  "adapted_rules": ["<list of rules that were adapted>"],
  "baselines": ["<list of baseline entries>"],
  "existing_tooling": ["<list of detected tools>"],
  "merge_notes": ["<list of integration notes>"]
}
```

### VERIFY
```bash
# Full audit must pass with baselines applied
bash {target_project_dir}/scripts/gate-runner.sh full_audit --continue-on-failure

# Every failure must be within a baseline
# (gate-runner.sh handles this automatically if baselines are in manifest)
```

### ON FAILURE
IF gate-runner crashes → fix the script or manifest, re-run.
IF failures exceed baselines → the scan miscounted. Re-scan and update baselines.

---

## PHASE 7: VERIFICATION + HANDOFF

### INPUT
- Everything from Phases 1-6
- Target project with all governance files installed

### ACTION

#### 7A: Run Comprehensive Verification
```bash
# 1. All scripts syntactically valid
for f in {target_project_dir}/scripts/*.sh; do bash -n "$f" 2>&1; done

# 2. All JSON valid
for f in $(find {target_project_dir} -name "*.json" -not -path '*/.git/*' -not -path '*/node_modules/*'); do
  jq . "$f" > /dev/null 2>&1 || echo "INVALID JSON: $f"
done

# 3. Gate runner works
bash {target_project_dir}/scripts/gate-runner.sh pre_commit --continue-on-failure

# 4. Full audit works (with baselines)
bash {target_project_dir}/scripts/gate-runner.sh full_audit --continue-on-failure

# 5. No placeholder remnants
grep -rn '{{.*}}' {target_project_dir}/scripts/ {target_project_dir}/docs/ || echo "No placeholders"
grep -rn '<!-- REQUIRED -->\|<!-- ADAPT' {target_project_dir}/ --include='*.md' || echo "No markers"
```

#### 7B: Test Hooks (Claude Code only)
```
1. Write a test file containing "AKIA1234567890EXAMPLE" (fake AWS key)
2. Verify secrets-scan hook fires and blocks the write
3. Delete the test file
4. Attempt to edit a frozen file
5. Verify frozen-files hook blocks the edit
```

#### 7C: Generate Setup Summary
Print to user:

```
=== VibeOS-2 Setup Complete ===

Project: {project.name}
Framework Version: {VIBEOS_VERSION}

Files Created:
  Scripts: {count} gate scripts in scripts/
  Agent Config: {agent_config_path}
  Rules: {count} rule files
  Hooks: {count} hook scripts
  Governance Docs: {count} documents
  Skills: {count} skill definitions

Gate Phases Active: {selected_phases}

Quality Gates:
  Pre-commit: {list with tier}
  WO-exit: {list with tier}
  Full-audit: {list with tier}
  Post-deploy: {list with tier}

Known Baselines: {count} (pre-existing violations documented)
  {list each baseline: gate name, failure count, reason}

Compliance Coverage:
  SOC 2: {covered/not targeted}
  GDPR: {covered/not targeted}
  OWASP: {covered/not targeted}

Next Steps:
  1. Run: bash scripts/gate-runner.sh pre_commit --continue-on-failure
  2. Create your first Work Order in docs/planning/WO-INDEX.md
  3. Read CLAUDE.md (or .cursorrules / AGENTS.md) for governance rules
  4. Fill in docs/INFRASTRUCTURE-MANIFEST.md with your infrastructure details

To update VibeOS-2 later:
  Re-run this bootstrap — it will preserve your config and update scripts.
```

#### 7D: Commit (if user approves)
```
git add -A
git commit -m "feat: enterprise governance framework via VibeOS-2 v{VIBEOS_VERSION}

- {count} quality gate scripts
- {count} gate phases configured
- {count} hooks installed
- {count} governance documents
- {baselines_count} known baselines documented

Auto-configured by VibeOS-2 Agent Bootstrap"
```

### VERIFY
- [ ] All verification commands in 7A passed
- [ ] Hook tests passed (Claude Code only)
- [ ] Setup summary printed
- [ ] User confirmed commit (or chose to defer)

### OUTPUT
Setup is complete. The project now has enterprise-grade governance. Every session, every commit, every Work Order is governed.

---

## TROUBLESHOOTING

### "gate-runner.sh: command not found"
The scripts need to be run from the project root: `bash scripts/gate-runner.sh`

### "jq: command not found"
Install jq: `brew install jq` (macOS) or `apt-get install jq` (Ubuntu)

### "Permission denied on hook scripts"
Run: `chmod +x {target_project_dir}/.claude/hooks/**/*.sh`

### "Gate fails but it's a pre-existing issue"
Add a baseline entry to quality-gate-manifest.json → known_baselines. See Phase 6C for format.

### "I want to add/remove gates later"
Edit quality-gate-manifest.json — add/remove gate entries from the appropriate phase. The gate-runner reads this file dynamically.

### "I want to change compliance targets"
Re-run the bootstrap. It will detect existing config and ask what to update.

---

## FRAMEWORK FILES REFERENCE

| Directory | Contains | Agent Reads | Agent Copies |
|---|---|---|---|
| `scripts/` | 20 gate scripts + gate-runner | No | Yes — to target project |
| `reference/` | Annotated examples (.ref files) | Yes — for patterns | No — generates from these |
| `decision-engine/` | Decision trees | Yes — for setup logic | No |
| `helpers/` | Utility scripts | No — calls directly | No |
| `docs/` | Philosophy, guides | Optional reading | No |

---

## APPENDIX A: EVIDENCE BUNDLE FORMAT

Evidence bundles are required for SOC 2 compliance. Each Work Order produces one bundle.

### Directory Structure
```
docs/evidence/{WO_NUMBER}/
├── summary.md          ← Human-readable: what was done, why, by whom
├── metadata.json       ← Machine-parseable metadata
└── gate-results/       ← Gate runner output for each phase
    ├── pre_commit.txt
    ├── wo_exit.txt
    └── full_audit.txt
```

### metadata.json Schema
```json
{
  "wo_number": "WO-001",
  "title": "Work order title",
  "status": "completed",
  "created_date": "2026-01-15",
  "completed_date": "2026-01-16",
  "author": "developer name or agent",
  "commit_sha": "abc123...",
  "gates_run": {
    "pre_commit": { "pass": 4, "fail": 0, "skip": 0 },
    "wo_exit": { "pass": 8, "fail": 0, "skip": 1 },
    "full_audit": { "pass": 15, "fail": 0, "skip": 3 }
  },
  "baselines_applied": 0,
  "files_changed": ["list of files"],
  "compliance_targets": ["SOC 2"]
}
```

### summary.md Template
```markdown
# Evidence: {WO_NUMBER} — {title}

## What Was Done
(Description of changes)

## Why
(Business justification / finding that prompted this)

## Testing
(How it was verified — test results, manual checks)

## Gate Results
(Summary of gate runner output)

## Sign-Off
- Author: {name}
- Date: {date}
- Commit: {sha}
```

---

## APPENDIX B: SETTINGS.JSON HOOK WIRING (Claude Code)

Complete settings.json structure for hook wiring:

```json
{
  "permissions": {
    "deny": [
      "Bash(npm publish*)",
      "Bash(*--force*)",
      "Bash(*rm -rf*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool/secrets-scan.sh $TOOL_INPUT"
          },
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool/frozen-files.sh $TOOL_INPUT"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-tool/staging-target.sh $TOOL_INPUT"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/post-tool/capture-failure.sh $TOOL_EXIT_CODE $TOOL_OUTPUT"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/user-prompt/governance-guard.sh $USER_PROMPT"
          }
        ]
      }
    ],
    "SubagentComplete": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/subagent/validate-audit-result.sh $SUBAGENT_OUTPUT"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session/session-start.sh"
          }
        ]
      }
    ],
    "SessionResume": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/session/session-resume.sh"
          }
        ]
      }
    ]
  },
  "env": {
    "TARGET_ENV": "staging"
  }
}
```

### Hook Exit Codes
- `0` — allow (tool proceeds)
- `1` — block (tool is prevented, message shown to user)
- `2` — warn (tool proceeds but warning is logged)

### Adding Production URLs to Permission Deny List
For each URL in `governance.production_urls`, add to `permissions.deny`:
```json
"Bash(*{domain}*)"
```
Example: if production_url is "https://api.myapp.com", add `"Bash(*api.myapp.com*)"`.

### Adding Frozen Files to Permission Deny List
For each file in `governance.frozen_files`, add to `permissions.deny`:
```json
"Write({file_path})",
"Edit({file_path})"
```

---

## APPENDIX C: QUALITY GATE MANIFEST SCHEMA

The manifest is the central configuration for all gates. Located at `.claude/quality-gate-manifest.json` (Claude Code) or `quality-gate-manifest.json` (project root).

```json
{
  "$schema": "VibeOS-2 Quality Gate Manifest v1.0.0",
  "version": "1.0.0",
  "project": {
    "name": "Project Name",
    "slug": "project-slug",
    "source_dirs": ["src/"]
  },
  "tier_definitions": {
    "0": "Session lifecycle — always runs automatically",
    "1": "CRITICAL — must pass for WO completion, blocks commit/deploy",
    "2": "IMPORTANT — should pass, blocks WO audit but allows individual commits",
    "3": "ADVISORY — reported but never blocks"
  },
  "phases": {
    "phase_name": {
      "description": "What this phase does",
      "gates": [
        {
          "name": "Human-readable gate name",
          "script": "scripts/gate-script.sh",
          "tier": 1,
          "blocking": true,
          "args": ["optional", "arguments"],
          "env": { "SCAN_DIRS": "src/" },
          "notes": "Optional notes about this gate"
        }
      ],
      "includes": ["other_phase_name"]
    }
  },
  "known_baselines": {
    "description": "Pre-existing failures that should NOT block work",
    "entries": [
      {
        "gate": "Gate Name",
        "max_allowed_failures": 0,
        "fail_count_pattern": "([0-9]+) failed",
        "known_failing_files": [],
        "reason": "Why these failures are accepted",
        "since": "2026-01-01",
        "last_verified": "2026-01-01"
      }
    ]
  }
}
```

### Gate Runner Reads This Manifest
The `gate-runner.sh` script:
1. Reads the manifest
2. Finds the requested phase
3. Resolves `includes` (inherits gates from other phases)
4. Runs each gate script in order
5. Compares failures against `known_baselines`
6. Reports: PASS (no failures), BASELINE (failures within baseline), REGRESSION (new failures)
