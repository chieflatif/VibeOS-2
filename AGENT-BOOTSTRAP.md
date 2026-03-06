# VibeOS-2 — Agent Bootstrap Playbook

## PURPOSE

You are turning a rough project idea into a product definition, technical foundation, and enterprise-grade development governance setup. This playbook tells you exactly what to do, step by step. Follow every phase in order. Do not skip phases. Verify before proceeding.

## INVOCATION (Do This First)

**The bootstrap runs FROM the user's project folder, not from VibeOS-2.**

Correct flow: (1) User creates empty project folder (or opens existing project), (2) opens it in Claude Code/Cursor/Codex, (3) says "Set up VibeOS" and gives path to VibeOS-2, (4) governance installs into current folder.

1. **target_project_dir = current workspace** — The folder the user has open. All outputs go here.
2. **framework_dir = path user provides** — Ask if needed: "Where is your VibeOS-2 folder? (e.g. ~/VibeOS-2)"
3. **Verify:** framework_dir must contain AGENT-BOOTSTRAP.md, scripts/, reference/
4. **Detect project mode:** Scan target for source files in common dirs (src/, lib/, app/, packages/, or project root). If any `.py`, `.ts`, `.js`, `.go`, `.rs`, `.java` files exist → **existing_project = true** (midstream embedding). Else → **existing_project = false** (greenfield).

### STORE
```json
{
  "framework_dir": "<path to VibeOS-2>",
  "target_project_dir": "<current workspace>",
  "existing_project": true | false
}
```

### MIDSTREAM EMBEDDING (Existing Projects)

When **existing_project = true**, explain this to the user before proceeding:

"I'm embedding VibeOS governance into your existing project. Here's how it works:

1. **Install** — I'll set up the governance framework (gates, scripts, rules) tailored to your codebase.
2. **Audit** — I'll run architecture, dependency, version, and security audits to understand what you have.
3. **Identify issues** — From those audits, we'll see what needs attention.
4. **Create Work Orders** — We turn high-priority findings into Work Orders (planned fixes).
5. **Audit the plan** — Before implementing, we audit each WO to ensure the plan is sound.
6. **Implement** — We make the changes.
7. **Audit again** — We verify the fix and check we didn't introduce regressions.

I'll run the audits, talk you through what we find, and help you prioritize remediation. You can run audits anytime; I'll explain how the system works as we go."

---

## USER COMMUNICATION CONTRACT

Read `{framework_dir}/docs/USER-COMMUNICATION-CONTRACT.md` before interacting with the user.

Apply these rules throughout every phase:

1. **Explain in easy terms** — Every technical term gets a brief, plain-English explanation the first time it appears.
2. **Before acting** — Tell the user what you're about to do and why it matters.
3. **After acting** — Start with business meaning, then explain what happened, what changed, and why it matters.
4. **Choices require reasoning** — When presenting options: explain each in outcome language first, state pros/cons, make a recommendation based on evidence, and explain your rationale.
5. **Never go silent** — Keep the user updated while work is in progress; do not return only with terminal-style output.

Required response pattern for major milestones:

1. What we just achieved
2. What changed under the hood
3. Why it matters
4. Recommended next step and why it comes next

If the user appears non-technical or asks broad product questions:

- prefer plain English over jargon
- explain assumptions clearly
- translate technical choices into product, speed, risk, and maintainability implications
- never ask the user to choose between raw technologies without first explaining the business difference
- always make a recommendation when choices exist, and explain why you recommend it

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

Run `{framework_dir}/helpers/verify-prerequisites.sh` to check.

---

## PHASE 0: PRODUCT DISCOVERY

**For existing projects:** Infer product shape from the codebase where possible (language, framework, structure). Discovery can be shorter; Phase 6 will run a full audit and identify issues. Confirm inferred answers with the user.

### INPUT
- `{framework_dir}/PRODUCT-DISCOVERY.md`
- User's freeform product description
- Optional supporting material: links, screenshots, notes, existing repo scan

### ACTION

1. Read `{framework_dir}/PRODUCT-DISCOVERY.md`
2. Capture the user's product idea in their own language before asking implementation questions
3. Explain Phase 0 in plain English before you begin: tell the user you are turning their rough idea into a clearer product definition and plan
4. Write the canonical freeform intent file at:
   - `{target_project_dir}/docs/product/PROJECT-IDEA.md`
   Use `{framework_dir}/reference/product/PROJECT-IDEA.md.ref` as the pattern.
5. Infer a first-pass product shape using:
   - `{framework_dir}/decision-engine/product-shaping.md`
   - `{framework_dir}/decision-engine/technical-recommendation.md`
6. Build a canonical `project-definition.json`
7. Generate discovery outputs:
   - `docs/product/PRODUCT-BRIEF.md`
   - `docs/product/PRD.md`
   - `docs/TECHNICAL-SPEC.md`
   - `docs/ARCHITECTURE.md` or `docs/product/ARCHITECTURE-OUTLINE.md`
   - `docs/product/ASSUMPTIONS-AND-RISKS.md`
8. Run (from target project dir or with explicit paths):
   - `python3 {framework_dir}/helpers/build-project-definition.py --idea-file {target_project_dir}/docs/product/PROJECT-IDEA.md --output {target_project_dir}/project-definition.json`
   - `python3 {framework_dir}/helpers/validate-project-definition.py {target_project_dir}/project-definition.json`
9. Ask adaptive follow-up questions only for missing or low-confidence/high-impact fields
10. When asking follow-up questions, explain why the answer matters and describe options in outcome language before naming technologies

### STORE
```json
{
  "project_idea_path": "<target_project_dir>/docs/product/PROJECT-IDEA.md",
  "project_definition_path": "<target_project_dir>/project-definition.json",
  "product_outputs": [
    "docs/product/PRODUCT-BRIEF.md",
    "docs/product/PRD.md",
    "docs/TECHNICAL-SPEC.md",
    "docs/ARCHITECTURE.md",
    "docs/product/ASSUMPTIONS-AND-RISKS.md"
  ],
  "discovery_confidence_gaps": ["<list of unresolved high-impact fields>"]
}
```

### VERIFY
- [ ] `project-definition.json` exists
- [ ] The project definition passes `helpers/validate-project-definition.py`
- [ ] The primary persona is defined
- [ ] At least one core workflow is defined
- [ ] v1 scope is defined
- [ ] Sensitive data and compliance posture are stated

### ON FAILURE
IF the product definition is still too vague → ask the user for one target user, one core workflow, and one desired platform before continuing.

---

## PHASE 1: ORIENTATION

### INPUT
- framework_dir and target_project_dir from INVOCATION
- `{framework_dir}/AGENT-BOOTSTRAP.md`

### ACTION

1. Confirm framework_dir and target_project_dir are set (from INVOCATION). You are running from the target project; you read playbooks from the framework.
2. Identify your agent type:
   - IF you are Claude Code → agent_type = "claude-code"
   - IF you are Cursor/Composer → agent_type = "cursor"
   - IF you are Codex CLI → agent_type = "codex"
3. Scan `{framework_dir}/scripts/` — list all available gate scripts
4. Scan `{framework_dir}/reference/` — list all reference files for your agent type
5. target_project_dir is already set (current workspace) — all governance installs here

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
- [ ] framework_dir exists and contains AGENT-BOOTSTRAP.md, scripts/, reference/
- [ ] target_project_dir is the current workspace (user's project folder)
- [ ] You can list at least 15 scripts in {framework_dir}/scripts/
- [ ] You can list reference files for your agent type

### ON FAILURE
IF framework_dir is wrong or missing → ask user for the correct path to their VibeOS-2 folder.
IF target_project_dir is not the current workspace → the user may have the wrong folder open. Ask them to open their project folder.
IF scripts/ has fewer than 15 files → framework may be incomplete. Warn user.

---

## PHASE 1.5: ENVIRONMENT DISCOVERY

### PURPOSE

Discover what tools, hosting, and Git access the agent has in the target project. Use this to tailor setup, avoid asking the user to run commands, and offer guided configuration when something is missing.

### INPUT
- target_project_dir from Phase 1

### ACTION

1. Run:
   ```bash
   bash {framework_dir}/helpers/verify-environment.sh {target_project_dir}
   ```
2. Parse the JSON output. You now have:
   - `git.is_repo`, `git.remote_url`, `git.remote_host` (github | gitlab | other | none)
   - `github_cli` (authenticated | not_authenticated | not_installed)
   - `hosting_detected` (array: railway, vercel, supabase, aws, gcp, docker, or empty)
   - `tools_available` (array: npm, node, python3, docker, gh, railway, vercel, supabase, etc.)

3. Present a brief, business-first summary to the user:
   - "I checked your environment. Here's what I found:"
   - Tools: list what's available in plain English
   - Git/GitHub: "Your project is linked to GitHub" OR "No remote yet" OR "GitHub CLI is installed but not signed in"
   - Hosting: "I detected Railway/Vercel/Supabase config" OR "No hosting configured yet"

4. IF tools, Git, or hosting are configured:
   - Ask: "Which of these do you want to use for this project?" (only where there are options)
5. IF something is missing and matters for the project:
   - Offer to walk through setup: "I can guide you through getting GitHub connected" / "I can help you add Railway/Vercel credentials to your infrastructure manifest when you're ready"

6. Do NOT tell the user to run scripts. You run them. Do NOT tell the user to "open this project in X" — the project is already the current workspace.

### STORE
```json
{
  "env_discovery": {
    "git_repo": true,
    "git_host": "github",
    "github_cli": "authenticated",
    "hosting_detected": ["railway"],
    "tools_available": ["npm", "node", "gh"]
  },
  "user_confirmed_hosting": "railway",
  "user_confirmed_ci": "github-actions"
}
```

### VERIFY
- [ ] Environment discovery ran successfully
- [ ] User received a plain-English summary
- [ ] Missing or optional config was addressed (either confirmed for later or walked through)

### NO-CODE RULE

The agent performs all script execution and environment checks. Never instruct the user to "run" a script. Say instead: "I'll run that now and report back" — then run it and report the result.

---

## PHASE 2: PROJECT INTAKE

### INPUT
- `{target_project_dir}/project-definition.json` (if created in Phase 0)
- `{framework_dir}/PROJECT-INTAKE.md`
- User's answers to questions

### ACTION

Read `{framework_dir}/PROJECT-INTAKE.md` and refine the generated project definition across 4 rounds.

Do not treat this as a blank questionnaire if `project-definition.json` already exists. Pre-fill and confirm inferred answers first, then ask only the unresolved or high-impact questions.

When a question is technical, explain it briefly before asking. For example, explain what a framework or package manager is in one sentence if the user has not shown that they already know.

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
- Product definition from Phase 0
- Project config from Phase 2
- Decision trees in `{framework_dir}/decision-engine/`

### ACTION

Read each decision tree file and make selections. Keep the technical recommendation and governance settings aligned with the discovery outputs.

#### 3A: Select Gate Scripts
Read `{framework_dir}/decision-engine/gate-selection.md`. Apply rules:

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
  IF compliance includes "soc2":
    ENABLE: validate-evidence-bundle.sh, validate-audit-completeness.sh, validate-pii-handling.sh
  IF compliance includes "owasp":
    ENABLE: validate-owasp-alignment.sh
  IF compliance includes "gdpr":
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
Read `{framework_dir}/decision-engine/phase-selection.md`. Apply rules:

```
IF team_size == "solo":
  PHASES: session_start, wo_entry, pre_commit, wo_exit, full_audit

IF team_size == "small":
  PHASES: session_start, wo_entry, pre_commit, wo_exit_backend, wo_exit_governance, full_audit, session_end

IF team_size == "enterprise":
  PHASES: session_start, wo_entry, pre_commit, wo_exit_backend, wo_exit_frontend, wo_exit_crosscutting, wo_exit_governance, post_deploy, full_audit, session_end
```

`wo_exit` remains the universal user-facing audit command. If a generated manifest uses specialized `wo_exit_*` phases, `gate-runner.sh wo_exit` must still work via an explicit `wo_exit` phase or compatibility fallback.

#### 3C: Select Hooks
Read `{framework_dir}/decision-engine/hook-selection.md`. Apply rules:

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
Read `{framework_dir}/decision-engine/architecture-rules.md`. Apply rules:

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
Read `{framework_dir}/decision-engine/compliance-mapping.md`. Apply rules:

```
IF compliance includes "soc2":
  REQUIRE: evidence bundles on every WO, audit trail, access logging
  GATES: validate-evidence-bundle (tier 1), validate-audit-completeness (tier 1)
IF compliance includes "gdpr":
  REQUIRE: PII handling docs, consent tracking, erasure support
  GATES: validate-pii-handling (tier 1), validate-tenant-isolation (tier 1)
IF compliance includes "owasp":
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

When presenting this summary, explain the user-facing effect of the chosen setup before listing technical details.

### ON FAILURE
IF user says no → ask what to change, update selections, re-present summary.

---

## PHASE 4: MECHANICAL SETUP

### INPUT
- Product definition and discovery outputs from Phase 0
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
│   ├── planning/               ← Work orders, ADRs
│   └── product/                ← Idea capture, brief, PRD
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
Always copy: `gate-runner.sh` (orchestrator), `validate-development-plan-alignment.sh` (enforces plan ↔ WO-INDEX alignment).

#### 4D: Generate Quality Gate Manifest
Create `{target_project_dir}/.claude/quality-gate-manifest.json` (Claude Code) or
`{target_project_dir}/quality-gate-manifest.json` (Cursor/Codex).

`gate-runner.sh` must auto-discover manifests in this order:
1. `.claude/quality-gate-manifest.json`
2. `quality-gate-manifest.json`

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
   REQUIRED_DOCS=("CLAUDE.md" "docs/planning/DEVELOPMENT-PLAN.md" "docs/planning/WO-INDEX.md")  # or .cursorrules/AGENTS.md
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
3. `{target_project_dir}/docs/planning/DEVELOPMENT-PLAN.md` — **REQUIRED**: phased roadmap derived from PRD and architecture. Read `{framework_dir}/decision-engine/development-plan-generation.md` and `{framework_dir}/reference/governance/DEVELOPMENT-PLAN.md.ref`. Generate phases (Foundation, then one per core workflow, then v1 features) with ordered WOs. Set **Next Work Order** to the first pending WO. Keep plan, WO-INDEX, and WO files aligned — `validate-development-plan-alignment.sh` enforces this at wo_exit and full_audit.
4. `{target_project_dir}/docs/ADR-TEMPLATE.md` — ADR template
5. `{target_project_dir}/docs/DESIGN-DOC-TEMPLATE.md` — design document template
6. `{target_project_dir}/docs/ARCHITECTURE.md` — with project's module structure, architecture rules
7. `{target_project_dir}/docs/INFRASTRUCTURE-MANIFEST.md` — with sections for the project's cloud provider, database, env vars, MCP servers, and data privacy requirements (when applicable)
8. `{target_project_dir}/docs/planning/WO-AUDIT-FRAMEWORK.md` — standard multi-pass audit questions for planning, pre-implementation, pre-commit, and staging

Preserve and update the discovery outputs generated in Phase 0 so they remain consistent with the final technical and governance decisions.

#### 5D: Generate Skill Definitions (Claude Code only)

Read reference files from `{framework_dir}/reference/skills/` and GENERATE:

1. `{target_project_dir}/.claude/skills/quality-gate-check.md`
2. `{target_project_dir}/.claude/skills/wo-complete.md`
3. `{target_project_dir}/.claude/skills/post-phase-audit.md`
4. `{target_project_dir}/.claude/skills/wo-research.md`
5. `{target_project_dir}/.claude/skills/wo-audit.md`

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
- [ ] DEVELOPMENT-PLAN.md exists with phases and Next Work Order set
- [ ] WO-AUDIT-FRAMEWORK.md exists and is referenced by the WO template or agent instructions
- [ ] INFRASTRUCTURE-MANIFEST.md exists with correct cloud provider sections
- [ ] MCP server section is present when `agent.mcp_servers` is not `["none"]`
- [ ] Data Privacy section is present when compliance includes `gdpr` or the project stores PII
- [ ] No `{{PLACEHOLDER}}` or `<!-- ADAPT -->` markers remain in any generated file

### ON FAILURE
IF a reference file is missing → warn user, skip that file, note in setup summary.
IF JSON validation fails → re-generate.

---

## PHASE 6: EXISTING PROJECT INGESTION (Midstream Embedding)

### CONDITION
IF the target project has existing source code (source_dirs contain .py/.ts/.js/.go/.rs/.java files), execute this phase.
IF the target project is empty/greenfield, SKIP to Phase 7.

### PURPOSE

For midstream embedding: configure governance from what exists, run audits to understand the project, identify issues, and set up the audit→issues→WOs→implement→audit loop. The agent explains findings in plain English and guides remediation.

### INPUT
- Target project source directories
- Selected gates and architecture rules
- Quality gate manifest (from Phase 4)

### ACTION

#### 6A: Run Full Audit Suite (Explain Before and After)

Tell the user: "I'm running the audit suite to understand your project — architecture, dependencies, versions, and security. I'll report what I find and walk you through it."

Run these gates (or equivalents from the manifest) and capture output:

```bash
# Architecture — module boundaries, rule violations
bash {target_project_dir}/scripts/gate-runner.sh full_audit --continue-on-failure 2>&1
# Or run individual gates: enforce-architecture, validate-dependencies, validate-dependency-versions,
# validate-no-secrets, validate-security-patterns, validate-owasp-alignment (if enabled)
```

Parse results. Present to the user in plain English:

- **Architecture** — What modules exist, what boundaries we see, any rule violations. "Your project has X modules. We found Y boundary violations — these mean [plain-English explanation]."
- **Dependencies** — Known vulnerabilities, outdated packages. "We found N packages with known issues. The highest risk is [package] because [reason]."
- **Versions** — Pinning, lockfile status. "Your dependencies are [pinned/floating]. I recommend [change] because [reason]."
- **Security** — Secrets, patterns, OWASP. "We checked for hardcoded secrets and risky patterns. [Findings in plain English]."

Recommend prioritization: "Here's what I suggest we tackle first: [list with rationale]. I can create Work Orders for these so we can plan and implement fixes."

IF the user agrees → create Work Orders for high-priority findings. Use `/wo-research` or the WO template. Each WO addresses one category of finding (e.g. "WO-001: Remediate dependency vulnerabilities", "WO-002: Fix architecture boundary violations in api/"). Explain: "I've created WOs for the top issues. We'll audit each plan before implementing, then implement and audit again."

#### 6B: Scan Codebase Structure
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

#### 6C: Adapt Architecture Rules
```
1. Compare detected module boundaries against selected architecture rules
2. FOR EACH rule, run the rule against the codebase and count violations
3. Apply this decision tree:

   IF violation_count == 0:
     KEEP rule as-is (project already follows this pattern)

   IF violation_count >= 1 AND violation_count <= 5:
     KEEP rule as-is
     Violations become baselines in 6D
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

#### 6D: Establish Baselines
```
1. Run ALL selected gates against the existing codebase:
   bash {target_project_dir}/scripts/gate-runner.sh full_audit --continue-on-failure 2>&1
2. Parse output — count failures per gate
3. FOR EACH gate with failures:
   CREATE a baseline entry keyed by gate name:
   "<gate name>": {
     "max_allowed_failures": <failure count>,
     "fail_count_pattern": "<regex to extract count from gate output>",
     "known_failing_files": ["<list of files with violations>"],
     "reason": "Pre-existing at VibeOS-2 adoption ({date})",
     "since": "<today's date>",
     "last_verified": "<today's date>"
   }
4. Add all baselines to quality-gate-manifest.json → known_baselines (keyed by gate name)
```

#### 6E: Detect Existing Tooling
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
  "audit_findings": { "architecture": [], "dependencies": [], "versions": [], "security": [] },
  "wos_created_from_findings": ["WO-001", "WO-002"],
  "codebase_stats": { "total_files": 0, "files_by_type": {}, "modules_detected": [] },
  "adapted_rules": [],
  "baselines": [],
  "existing_tooling": [],
  "merge_notes": []
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
- Everything from Phases 0-6
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

# 4. wo_entry phase enumerates correctly
bash {target_project_dir}/scripts/gate-runner.sh wo_entry --dry-run

# 5. Full audit works (with baselines)
bash {target_project_dir}/scripts/gate-runner.sh full_audit --continue-on-failure

# 6. No placeholder remnants
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

**CRITICAL: The project is already in this workspace.** Do not tell the user to "open" the project in Claude Code, Cursor, or any other tool. They are already here.

**CRITICAL: You run all validation scripts.** Never instruct the user to "run" a command. You run `gate-runner.sh pre_commit` as part of 7A — report the result in the summary, not as a user task.

Print to user:

```
=== VibeOS-2 Setup Complete ===

What we just built: A complete product definition and enterprise governance foundation for {project.name}, ready for development to start.

Your project is ready. Governance is active in this workspace — hooks, rules, and gates are wired and will fire automatically.

Environment check: I ran the pre-commit validation as part of setup. Result: {PASS | BASELINE with N known issues | see details below}. No action needed from you.

What's in {target_project_dir}:
  Product Documents: {count} files in docs/product/
  Gate Scripts: {count} in scripts/
  Active Gate Phases: {selected_phases}
  Compliance: {compliance_targets}
  Hooks: {count} — fire automatically
  Governance: CLAUDE.md (or .cursorrules / AGENTS.md), {count} rule files, {count} skills

Known Baselines: {count} (pre-existing violations documented)
  {brief list or "None"}

Next Work Order: {Read from docs/planning/DEVELOPMENT-PLAN.md → "Next:" section}
  • I'll start WO-XXX ({title}) from the development plan. Shall I begin?
  • (Never ask "what do you want to build?" — the development plan defines the roadmap.)

Other (your choice):
  • Add API keys to docs/INFRASTRUCTURE-MANIFEST.md when ready
  • Review docs/product/PRD.md and docs/planning/DEVELOPMENT-PLAN.md
```

The setup summary must follow the communication contract:

- business-level summary first
- technical explanation second
- next steps as choices or agent-offered actions — never as "run this command"

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
| `PRODUCT-DISCOVERY.md` | Discovery playbook | Yes | No |
| `scripts/` | 21 scripts (20 gates + gate-runner) | No | Yes — to target project |
| `reference/` | Annotated examples (.ref files) | Yes — for patterns | No — generates from these |
| `decision-engine/` | Product + governance decision trees | Yes — for setup logic | No |
| `helpers/` | Utility scripts and project-definition builders | No — calls directly | No |
| `docs/` | Philosophy, guides, schemas | Optional reading | No |

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
  "compliance_targets": ["soc2"]
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
            "command": ".claude/hooks/pre-tool/secrets-scan.sh"
          },
          {
            "type": "command",
            "command": ".claude/hooks/pre-tool/frozen-files.sh"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/pre-tool/staging-target.sh"
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-tool/capture-failure.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/user-prompt/governance-guard.sh"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/subagent/validate-audit-result.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/session/session-start.sh"
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

The manifest is the central configuration for all gates. Located at `.claude/quality-gate-manifest.json` (Claude Code) or `quality-gate-manifest.json` (project root). `gate-runner.sh` auto-discovers both in that order.

```json
{
  "$schema": "VibeOS-2 Quality Gate Manifest v1.0.0",
  "version": "1.0.0",
  "project": {
    "name": "Project Name",
    "slug": "project-slug",
    "source_dirs": ["src/"]
  },
  "tiers": {
    "0": { "label": "critical", "blocking": true, "description": "Session lifecycle — always runs automatically" },
    "1": { "label": "important", "blocking": true, "description": "Must pass for WO completion, blocks commit/deploy" },
    "2": { "label": "advisory", "blocking": false, "description": "Should pass, blocks WO audit but allows individual commits" },
    "3": { "label": "informational", "blocking": false, "description": "Reported but never blocks" }
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
    "Gate Name": {
      "max_allowed_failures": 0,
      "fail_count_pattern": "([0-9]+) failed",
      "known_failing_files": [],
      "reason": "Why these failures are accepted",
      "since": "2026-01-01",
      "last_verified": "2026-01-01"
    }
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
