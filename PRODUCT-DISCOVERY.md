# VibeOS-2 — Product Discovery Playbook

## PURPOSE

Turn a rough product idea into a validated `project-definition.json`, a product brief, a PRD, and a technical starting point before governance setup begins.

This phase exists for greenfield and vibe-coded projects where the user knows the outcome they want but does not yet have implementation details.

When interacting with the user during discovery:

- explain the purpose of each step in plain English
- translate technical suggestions into product or workflow outcomes
- avoid asking the user to choose technologies before they understand the business difference
- summarize what was learned after each meaningful discovery step

## INPUT

- Freeform user description of the product idea
- Optional references: competitor links, screenshots, notes, transcripts, sketches
- Optional repository scan data when a target project already exists

## OUTPUT

- `docs/product/PROJECT-IDEA.md`
- `project-definition.json`
- `docs/product/PRODUCT-BRIEF.md`
- `docs/product/PRD.md`
- `docs/TECHNICAL-SPEC.md`
- `docs/ARCHITECTURE.md` or `docs/product/ARCHITECTURE-OUTLINE.md`
- `docs/product/ASSUMPTIONS-AND-RISKS.md`

## DISCOVERY MODEL

### Step 1: Capture Intent

Collect the user's own words first. Ask for:

- What they want to build
- Who it is for
- The main problem it solves
- The most important workflow
- Desired platforms: web, mobile, API, internal tool, or mixed
- Any hard constraints: timeline, integrations, budget, compliance, cloud, team

Do not ask stack or framework questions first unless the user already volunteered them.

Write the raw, user-facing idea to the canonical input path:

- `docs/product/PROJECT-IDEA.md`

Use `reference/product/PROJECT-IDEA.md.ref` as the structure. This is the handoff file between freeform user intent and machine-readable definition building.

### Step 2: Draft Product Shape

Infer a first-pass product definition:

- product type
- target personas
- jobs to be done
- v1 workflows
- likely monetization model
- likely sensitive data categories
- likely integration classes
- likely delivery shape: mobile app, web SaaS, API, internal tool, marketplace

### Step 3: Ask Adaptive Follow-Ups

Only ask questions when both are true:

1. Confidence is low
2. Impact is high

Use these metadata values on inferred fields:

- `source`: `user-confirmed` | `inferred` | `scanned` | `default`
- `confidence`: `high` | `medium` | `low`
- `impact`: `high` | `medium` | `low`

High-value follow-up questions usually include:

- Who is the primary user?
- What must exist in v1?
- What is explicitly out of scope?
- Does the product process payments, health data, financial data, PII, or company secrets?
- Is the product mobile-first, web-first, or API-first?
- Are there non-negotiable integrations?

### Step 4: Build Canonical Definition

Write `project-definition.json` using `docs/project-definition.schema.json`.

Run:

```bash
python3 helpers/build-project-definition.py \
  --idea-file docs/product/PROJECT-IDEA.md \
  --output project-definition.json
```

This file is the handoff contract between discovery and governance. It should be detailed enough for:

- technical recommendation
- architecture drafting
- work order planning
- compliance posture selection
- governance intensity selection

### Step 5: Generate Product Artifacts

Generate the product artifacts from the canonical definition:

- `PRODUCT-BRIEF.md`: one-page summary
- `PRD.md`: scope, requirements, user stories, acceptance criteria
- `TECHNICAL-SPEC.md`: implementation recommendation, service boundaries, dependencies
- `ARCHITECTURE-OUTLINE.md`: systems and data flow
- `ASSUMPTIONS-AND-RISKS.md`: unresolved questions, delivery risks, compliance/data concerns

### Step 6: Gate Readiness For Governance

Do not proceed to the governance bootstrap until these are true:

- product summary exists
- primary persona is defined
- at least one core workflow is defined
- v1 scope is defined
- sensitive data posture is defined
- technical recommendation exists or the user explicitly requested manual selection later

## STORE

```json
{
  "idea": {
    "name": {},
    "summary": {},
    "product_type": {}
  },
  "users": {
    "primary_persona": {},
    "secondary_personas": []
  },
  "scope": {
    "core_workflows": [],
    "v1_features": [],
    "non_goals": []
  },
  "constraints": {
    "platforms": [],
    "integrations": [],
    "sensitive_data": [],
    "compliance_targets": []
  },
  "technical_recommendation": {
    "language": {},
    "framework": {},
    "database": {},
    "deployment_shape": {}
  },
  "governance_profile": {
    "team_size": {},
    "risk_level": {}
  }
}
```

## VERIFY

- [ ] The product idea is captured in the user's own language
- [ ] At least one target persona is identified
- [ ] At least one core workflow is identified
- [ ] v1 scope and non-goals are separated
- [ ] Sensitive-data and compliance posture are stated
- [ ] Technical recommendation includes rationale or confidence metadata
- [ ] `project-definition.json` passes `helpers/validate-project-definition.py`

## ON FAILURE

IF the user stays vague after the first pass:
- reduce the question set to the single user, single workflow, and single platform that matter most

IF the product is still ambiguous:
- generate assumptions explicitly in `ASSUMPTIONS-AND-RISKS.md`
- mark unresolved fields with `confidence = "low"`
- ask for confirmation before governance setup

IF the user wants to choose the stack manually:
- preserve discovery outputs
- mark technical recommendation as `user-confirmed` when supplied later
