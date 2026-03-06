# VibeOS-2 — Project Intake Questionnaire

## PURPOSE

Refine and confirm the project definition after `PRODUCT-DISCOVERY.md` has produced a first-pass brief, PRD, and `project-definition.json`.

Questions remain organized in 4 rounds, but the agent should not force the user through every question manually if a high-confidence answer already exists.

## INTAKE OPERATING MODE

- Read `project-definition.json` first if it exists.
- Pre-fill answers from discovery outputs whenever confidence is medium or high.
- Ask follow-up questions only when the answer is missing, confidence is low, or the impact is high enough to justify confirmation.
- Present inferred defaults explicitly: "I inferred X from your product definition. Keep or change?"
- Do not lead with implementation-detail questions if the product definition is still incomplete.
- If a question uses technical language, explain the term briefly before asking it.
- Frame choices in outcome language first, then introduce technology names as the implementation mapping.

## OUTPUT FORMAT

Store answers as a JSON object matching the schema in `AGENT-BOOTSTRAP.md` Phase 2. Treat this as the governance/bootstrap refinement layer, not the first source of truth for product intent.

---

## ROUND 1: PROJECT IDENTITY

### Q1: Project Name
```
QUESTION: What is the name of your project?
TYPE: text
DEFAULT: none
REQUIRED: yes
EXAMPLE: "Signal Intelligence Platform"
USED_BY: CLAUDE.md title, WO-INDEX header, commit messages
```

### Q2: Project Slug
```
QUESTION: What slug should I use for file prefixes and config? (lowercase, hyphens only)
TYPE: text
DEFAULT: derived from Q1 (lowercase, spaces→hyphens, strip special chars)
REQUIRED: yes
EXAMPLE: "signal-intelligence-platform"
USED_BY: config file names, environment variable prefixes, gate-runner lock files
VALIDATION: must match ^[a-z][a-z0-9-]*$
```

### Q3: Project Description
```
QUESTION: One-line description of what this project does?
TYPE: text
DEFAULT: none
REQUIRED: yes
EXAMPLE: "Backend intelligence service that aggregates enterprise context and delivers signal intelligence"
USED_BY: CLAUDE.md header, README, agent config
```

### Q4: Repository URL
```
QUESTION: What is the GitHub/GitLab repository URL? (leave blank if not yet created)
TYPE: text
DEFAULT: ""
REQUIRED: no
EXAMPLE: "https://github.com/org/project"
USED_BY: CLAUDE.md, documentation links
```

---

## ROUND 2: TECHNICAL STACK

### Q5: Primary Language
```
QUESTION: What is the primary programming language?
TYPE: choice
AUTO_DERIVE_FIRST: yes
OPTIONS:
  - python
  - typescript
  - javascript
  - go
  - rust
  - java
DEFAULT: python
REQUIRED: yes
USED_BY: architecture-rules selection, code-quality gate config, stub detection mode, dependency validation
```

### Q6: Framework
```
QUESTION: What framework are you using?
TYPE: choice (filtered by Q5)
AUTO_DERIVE_FIRST: yes
OPTIONS:
  IF python: fastapi | django | flask | none
  IF typescript: express | nestjs | nextjs | none
  IF javascript: express | nextjs | react-only | none
  IF go: gin | echo | chi | none
  IF rust: actix | axum | rocket | none
  IF java: spring-boot | quarkus | none
DEFAULT: none
REQUIRED: yes
USED_BY: architecture-rules selection (framework-specific boundaries), architecture doc template
```

### Q7: Source Directories
```
QUESTION: Where is your source code? (comma-separated paths relative to project root)
TYPE: path-list
AUTO_DERIVE_FIRST: yes
DEFAULT:
  IF python: "src/" or "{slug}/"
  IF typescript/javascript: "src/"
  IF go: "cmd/, internal/, pkg/"
  IF rust: "src/"
  IF java: "src/main/java/"
REQUIRED: yes
EXAMPLE: "sip/, tests/" or "src/, lib/"
USED_BY: gate script SCAN_DIRS, architecture enforcement, stub detection, security scanning
VALIDATION: paths should be relative to project root
```

### Q8: Test Directory
```
QUESTION: Where are your tests?
TYPE: path
AUTO_DERIVE_FIRST: yes
DEFAULT:
  IF python: "tests/"
  IF typescript/javascript: "tests/" or "__tests__/" or "src/**/*.test.*"
  IF go: same as source (Go convention)
  IF rust: same as source (Rust convention) + "tests/"
  IF java: "src/test/java/"
REQUIRED: yes
USED_BY: test-integrity gate, documentation-completeness gate (mirror structure check)
```

### Q9: Package Manager
```
QUESTION: What package manager do you use?
TYPE: choice (filtered by Q5)
AUTO_DERIVE_FIRST: yes
OPTIONS:
  IF python: pip | poetry | uv | pdm
  IF typescript/javascript: npm | yarn | pnpm | bun
  IF go: go-modules
  IF rust: cargo
  IF java: maven | gradle
DEFAULT:
  IF python: pip
  IF typescript/javascript: npm
REQUIRED: yes
USED_BY: dependency validation gate, dependency-versions gate (registry queries), pre-commit config
```

### Q10: Database
```
QUESTION: What database does your project use? (select "none" if no database)
TYPE: choice
AUTO_DERIVE_FIRST: yes
OPTIONS:
  - postgresql
  - mysql
  - sqlite
  - mongodb
  - redis-only
  - none
DEFAULT: none
REQUIRED: yes
USED_BY: tenant-isolation gate (SQL scanning), architecture rules (no-raw-sql), infrastructure manifest template
```

---

## ROUND 3: GOVERNANCE PROFILE

### Q11: Team Size
```
QUESTION: How many developers work on this project?
TYPE: choice
AUTO_DERIVE_FIRST: yes
OPTIONS:
  - solo (just me)
  - small (2-5 developers)
  - enterprise (5+ developers)
DEFAULT: solo
REQUIRED: yes
USED_BY: phase selection (solo=5 phases, small=7, enterprise=10), hook selection, governance doc templates
IMPACT:
  solo: lighter governance — 5 gate phases including blocking wo_entry, minimal hooks
  small: moderate governance — 7 gate phases, session lifecycle
  enterprise: full governance — all 10 phases, all hooks, evidence bundles
```

### Q12: Compliance Targets
```
QUESTION: Which compliance standards does this project target? (select all that apply, or "none")
TYPE: multi-choice
AUTO_DERIVE_FIRST: yes
OPTIONS:
  - SOC 2 (audit logging, evidence bundles, access controls)
  - GDPR (PII handling, consent management, data erasure)
  - OWASP Top 10 (injection prevention, auth, XSS, etc.)
  - none
DEFAULT: ["none"]
REQUIRED: yes
USED_BY: gate selection (compliance-specific gates), tier assignments, evidence requirements, gate-runner strictness
STORE_AS: soc2 | gdpr | owasp | none
IMPACT:
  SOC 2: enables evidence-bundle and audit-completeness gates at tier 1
  GDPR: enables pii-handling and tenant-isolation gates at tier 1
  OWASP: enables owasp-alignment gate at tier 1, security-patterns in strict mode
  none: all compliance gates set to tier 3 (advisory only)
```

### Q13: Work Order Directory
```
QUESTION: Where should Work Order documents be stored?
TYPE: path
DEFAULT: "docs/planning/"
REQUIRED: yes
USED_BY: validate-work-order gate (WO_DIR), WO-INDEX location, WO-TEMPLATE location
```

### Q14: Frozen Files
```
QUESTION: Are there any files that should NEVER be edited by the AI agent? (comma-separated paths, or "none")
TYPE: path-list
DEFAULT: ["none"]
REQUIRED: no
EXAMPLE: "src/legacy/main.py, config/production.json"
USED_BY: frozen-files hook (blocks edits), settings.json permission deny list
```

### Q15: Production URLs
```
QUESTION: What are your production URLs? (so the agent never targets them — comma-separated, or "none")
TYPE: text-list
DEFAULT: ["none"]
REQUIRED: no
EXAMPLE: "https://api.myapp.com, https://myapp.com"
USED_BY: staging-target hook (blocks production commands), settings.json permission deny list
```

---

## ROUND 4: AGENT PREFERENCES

### Q16: Cloud Provider
```
QUESTION: What cloud provider does this project use? (or "none" for local-only)
TYPE: choice
AUTO_DERIVE_FIRST: yes
OPTIONS:
  - azure
  - aws
  - gcp
  - vercel
  - none
DEFAULT: none
REQUIRED: yes
USED_BY: infrastructure-manifest template (provider-specific sections), smoke-test config, session-start health checks
```

### Q17: CI/CD Platform
```
QUESTION: What CI/CD platform do you use? (or "none" — gates run locally via gate-runner)
TYPE: choice
AUTO_DERIVE_FIRST: yes
OPTIONS:
  - github-actions
  - gitlab-ci
  - azure-devops
  - none
DEFAULT: none
REQUIRED: yes
USED_BY: documentation only (v1.0 — CI/CD templates are v1.1 roadmap)
NOTE: Gates always run locally via gate-runner.sh regardless of CI/CD. This answer is for future CI integration.
```

### Q18: MCP Servers
```
QUESTION: Does your project use any MCP servers? (comma-separated names, or "none")
TYPE: text-list
AUTO_DERIVE_FIRST: yes
DEFAULT: ["none"]
REQUIRED: no
EXAMPLE: "notion, playwright, postgres"
USED_BY: infrastructure-manifest (MCP config section), session-start (MCP health checks)
```

---

## POST-INTAKE VALIDATION

After collecting all answers, validate:

```
CHECKS:
  1. project.name is not empty
  2. project.slug matches ^[a-z][a-z0-9-]*$
  3. stack.language is in [python, typescript, javascript, go, rust, java]
  4. stack.source_dirs — warn if directories don't exist yet
  5. governance.team_size is in [solo, small, enterprise]
  6. governance.compliance_targets is a non-empty list
  7. IF compliance includes any standard AND team_size == "solo":
     WARN: "Compliance governance with a solo team adds overhead. Recommended: set compliance gates to tier 2 (advisory) until team grows."

IF any required field is missing:
  Ask the specific question again.

IF all valid:
  Print summary of all answers.
  Also print which fields were:
    - user-confirmed
    - inferred from discovery
    - defaulted by the framework
  Ask: "Does this look correct? [Y/n]"
  IF no: ask what to change, update, re-validate.
```

---

## ANSWER SCHEMA

```json
{
  "$schema": "VibeOS-2 Project Config v1.0.0",
  "project": {
    "name": "string (required)",
    "slug": "string (required, ^[a-z][a-z0-9-]*$)",
    "description": "string (required)",
    "repo_url": "string (optional)"
  },
  "stack": {
    "language": "enum: python|typescript|javascript|go|rust|java (required)",
    "framework": "enum: varies by language (required)",
    "source_dirs": ["string[] (required, relative paths)"],
    "test_dir": "string (required, relative path)",
    "package_manager": "enum: varies by language (required)",
    "database": "enum: postgresql|mysql|sqlite|mongodb|redis-only|none (required)"
  },
  "governance": {
    "team_size": "enum: solo|small|enterprise (required)",
    "compliance_targets": ["enum[]: soc2|gdpr|owasp|none (required)"],
    "wo_dir": "string (required, relative path)",
    "frozen_files": ["string[] (optional)"],
    "production_urls": ["string[] (optional)"]
  },
  "agent": {
    "cloud_provider": "enum: azure|aws|gcp|vercel|none (required)",
    "ci_cd_platform": "enum: github-actions|gitlab-ci|azure-devops|none (required)",
    "mcp_servers": ["string[] (optional)"]
  }
}
```
