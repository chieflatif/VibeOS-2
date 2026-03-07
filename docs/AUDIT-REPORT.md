# VibeOS-2 — Full Project Audit Report

**Date:** 2026-03-05  
**Scope:** Workflow, technical, schema, and cross-reference consistency across the entire framework.

---

## Executive Summary

The framework is coherent and well-structured. The main issues are **documentation drift** (counts, question lists, STORE schemas), **missing integration** of `validate-production-readiness.sh` into the decision engine, **missing reference template** for ASSUMPTIONS-AND-RISKS, and **schema vs validator divergence**. No critical workflow breakages were found; fixes are mostly additive or corrective.

---

## 1. Workflow Inconsistencies

### 1.1 Round 3 Question Count Mismatch

| Location | States | Actual |
|----------|--------|--------|
| AGENT-BOOTSTRAP.md Phase 2 | "Round 3 — Governance Profile (5 questions)" | 6 questions: Q11, Q12, Q12b, Q13, Q14, Q15 |
| PROJECT-INTAKE.md | Round 3 has Q12b (Deployment Context) | Correct |

**Impact:** Agent may under-count or mislabel. Low severity.

**Fix:** Update AGENT-BOOTSTRAP to "6 questions" and list: team size, compliance targets, **deployment context**, WO dir, frozen files, production URLs.

---

### 1.2 Phase 2 STORE Missing deployment_context

| Location | governance section |
|----------|--------------------|
| AGENT-BOOTSTRAP Phase 2 STORE | `team_size`, `compliance_targets`, `wo_dir`, `frozen_files`, `production_urls` |
| PROJECT-INTAKE ANSWER SCHEMA | Includes `deployment_context` |
| build-project-definition output | Includes `deployment_context` in governance_profile |

**Impact:** Agent may not persist Q12b into the project config when merging intake answers. Medium severity.

**Fix:** Add `"deployment_context": "<from Q12b>"` to the governance section of Phase 2 STORE in AGENT-BOOTSTRAP.

---

### 1.3 Phase 3 Gate Selection Missing deployment_context and Production Readiness

| Location | Content |
|----------|---------|
| decision-engine/gate-selection.md | INPUTS: language, database, compliance_targets, production_urls — **no deployment_context** |
| decision-engine/gate-selection.md | No rule for `validate-production-readiness.sh` |
| reference/manifests/quality-gate-manifest.json.ref | Has validate-production-readiness in wo_exit and full_audit |
| scripts/validate-production-readiness.sh | Exists and works |

**Impact:** Agent generating a manifest from gate-selection will not know to include production-readiness or pass deployment_context. The manifest ref has it, but the decision tree does not. Medium severity.

**Fix:** Add to gate-selection.md:
- INPUTS: `governance_profile.deployment_context` (or `governance.deployment_context`)
- New conditional block:
  ```
  IF deployment_context IN ["production", "customer-facing", "scale"]:
    ENABLE: validate-production-readiness.sh  tier=1  blocking=true
    ENV: PROJECT_DEFINITION=project-definition.json (or path from project)
  IF deployment_context == "prototype":
    SKIP: validate-production-readiness.sh
  ```

---

### 1.4 Phase 4C Script Copy List Incomplete

| Location | States |
|----------|--------|
| AGENT-BOOTSTRAP Phase 4C | "Always copy: gate-runner.sh, validate-development-plan-alignment.sh, validate-tests-required.sh, validate-tests-pass.sh" |
| Missing | validate-production-readiness.sh |

**Impact:** Production-readiness gate may not be copied to target project. The manifest references it; if the script is missing, gate-runner will fail. Medium severity.

**Fix:** Add `validate-production-readiness.sh` to the "Always copy" list in Phase 4C, with a note: "Include when deployment_context is production or above (or copy always — gate skips when prototype)."

---

### 1.5 development-plan-generation Input Incomplete

| Location | Input list |
|----------|------------|
| decision-engine/development-plan-generation.md | PRD, project-definition (scope), ARCHITECTURE, WO-INDEX |
| Missing | `governance_profile.deployment_context` from project-definition |

**Impact:** Agent may not know to read deployment_context when generating the plan. Low severity (the doc describes it in the phase logic, but Input section doesn't list it).

**Fix:** Add to Input: `project-definition.json` (scope.core_workflows, scope.v1_features, **governance_profile.deployment_context**).

---

## 2. Technical Inconsistencies

### 2.1 Script Count Drift

| Location | States | Actual |
|----------|--------|--------|
| docs/PLAN.md | "21 scripts (20 gates + gate-runner)" | Outdated |
| AGENT-BOOTSTRAP Phase 1 VERIFY | "at least 15 scripts" | OK |
| AGENT-BOOTSTRAP Appendix | "21 scripts (20 gates + gate-runner)" | Outdated |
| gate-selection.md | "20 gate scripts" | Undercount |
| Actual scripts/ | 24 gate scripts + gate-runner + architecture-rules.example.json | Current |

**New gates since original count:** validate-tests-required, validate-tests-pass, validate-production-readiness, validate-development-plan-alignment (and possibly others).

**Fix:** Update PLAN.md, AGENT-BOOTSTRAP Appendix, and gate-selection header to reflect actual count (e.g. "24 gate scripts" or "20+ gate scripts").

---

### 2.2 Phase 3 Summary Template Says "of 20"

| Location | Text |
|----------|------|
| AGENT-BOOTSTRAP Phase 3 VERIFY | "Gates enabled: {count} of 20" |

**Fix:** Change to "of 24" or "of {total}" to avoid hardcoding.

---

### 2.3 Schema vs Validator Divergence

| Component | Role |
|-----------|------|
| docs/project-definition.schema.json | JSON Schema for project-definition structure |
| helpers/validate-project-definition.py | Custom Python validation (evidence format, required fields, enum checks) |

**Observation:** The Python validator does not use the JSON Schema. It implements its own rules. The schema is used for documentation and possibly tooling (e.g. IDE validation).

**Risks:**
- Schema and validator can drift (e.g. new field in schema but not in validator, or vice versa).
- deployment_context is in schema and validator; both are aligned.

**Recommendation:** Either (a) wire a JSON Schema validator (e.g. jsonschema) into validate-project-definition.py, or (b) document explicitly that the schema is for tooling/docs only and the Python validator is the source of truth.

---

### 2.4 project-definition.schema.json: deployment_context Not Required

| Location | governance_profile.required |
|----------|----------------------------|
| docs/project-definition.schema.json | `["team_size", "risk_level"]` |
| deployment_context | Optional in schema |
| PROJECT-INTAKE ANSWER SCHEMA | deployment_context required |
| build-project-definition ensure_defaults | Always adds deployment_context if missing |

**Impact:** Legacy project-definitions without deployment_context validate against schema. Validator only checks deployment_context when present. Consistent behavior.

**Recommendation:** Consider adding deployment_context to schema required for new projects, or document that it is optional for backward compatibility.

---

## 3. Missing Pieces

### 3.1 ASSUMPTIONS-AND-RISKS.md.ref

| Location | Expectation |
|----------|-------------|
| PRODUCT-DISCOVERY Step 5 | Output: `docs/product/ASSUMPTIONS-AND-RISKS.md` |
| AGENT-BOOTSTRAP Phase 0 | product_outputs includes ASSUMPTIONS-AND-RISKS.md |
| reference/product/ | No ASSUMPTIONS-AND-RISKS.md.ref |

**Impact:** Agent has no reference template for structure/format. May generate ad hoc or inconsistent output.

**Fix:** Add `reference/product/ASSUMPTIONS-AND-RISKS.md.ref` with REQUIRED/ADAPT sections (e.g. Unresolved Questions, Delivery Risks, Compliance/Data Concerns).

---

### 3.2 docs/PLAN.md Round 3 Description

| Location | Content |
|----------|---------|
| docs/PLAN.md | "Round 3 (Governance): team size, compliance targets, WO dir, frozen files, production URLs" |
| Missing | deployment_context |

**Fix:** Add "deployment context (prototype | production | customer-facing | scale)" to the Round 3 description.

---

## 4. Cross-Reference Verification

### 4.1 Bootstrap → Decision Engine

| Phase | References | Status |
|-------|------------|--------|
| Phase 3A | gate-selection.md | OK — but gate-selection lacks production-readiness |
| Phase 3B | phase-selection.md | OK |
| Phase 3C | hook-selection.md | OK |
| Phase 3D | architecture-rules.md | OK |
| Phase 3E | compliance-mapping.md | OK |
| Phase 5C | development-plan-generation.md | OK |

### 4.2 Bootstrap → Helpers

| Helper | Referenced | Status |
|--------|------------|--------|
| verify-prerequisites.sh | Phase 4A | OK |
| verify-environment.sh | Phase 1.5 | OK |
| verify-setup.sh | Phase 7 | OK |
| build-project-definition.py | Phase 0 | OK |
| validate-project-definition.py | Phase 0 | OK |

### 4.3 Gate Runner → Manifest

| Contract | canonical-contract.json | gate-runner behavior |
|----------|-------------------------|------------------------|
| Pass exit code | 0 | Matches |
| Skip exit code | 0 | Matches |
| Policy failure | 1 | Matches |
| Config error | 2 | Matches |
| wo_exit fallback | wo_exit_* phases | Documented |

---

## 5. Edge Cases and Gaps

### 5.1 validate-production-readiness When Plan Missing

**Behavior:** Gate SKIPs when DEVELOPMENT-PLAN.md is not found.

**Scenario:** New production project before first plan generation. Gate would skip.

**Assessment:** Acceptable. Plan is created in Phase 5C. If bootstrap completes, plan exists. For manual runs before bootstrap, skip is reasonable.

---

### 5.2 project-definition.json Location

**Default:** `project-definition.json` in project root.

**Gate support:** `PROJECT_DEFINITION` env var overrides path.

**Observation:** AGENT-BOOTSTRAP and PRODUCT-DISCOVERY assume root. Some projects may use `docs/project-definition.json`. Document the env var in gate script header (already present) and in bootstrap/docs.

---

### 5.3 wo_exit Phase Count for Solo

| team_size | Phases |
|-----------|--------|
| solo | session_start, wo_entry, pre_commit, wo_exit, full_audit |
| small | Adds wo_exit_backend, wo_exit_governance, session_end |
| enterprise | Adds wo_exit_frontend, wo_exit_crosscutting, post_deploy |

**Observation:** phase-selection says solo gets `wo_exit` directly. canonical-contract aliases wo_exit to wo_exit_* fallbacks. For solo, there may be no wo_exit_* phases — only the base wo_exit. The manifest ref has wo_exit with its own gates. Consistent.

---

## 6. Summary of Recommended Fixes

| Priority | Issue | Fix |
|----------|-------|-----|
| **High** | gate-selection lacks production-readiness | Add deployment_context input and conditional rule for validate-production-readiness.sh |
| **High** | Phase 4C doesn't list production-readiness script | Add to "Always copy" (or conditional copy) |
| **Medium** | Phase 2 STORE missing deployment_context | Add to governance in AGENT-BOOTSTRAP |
| **Medium** | Round 3 question count wrong | Update to 6 questions, list Q12b |
| **Medium** | No ASSUMPTIONS-AND-RISKS.md.ref | Create reference template |
| **Low** | development-plan-generation Input | Add governance_profile.deployment_context |
| **Low** | Script count drift | Update PLAN.md, Appendix, gate-selection to 24 |
| **Low** | "Gates enabled: of 20" | Change to dynamic or 24 |
| **Low** | docs/PLAN.md Round 3 | Add deployment context |

---

## 7. Validation Commands Run

```bash
# All scripts syntactically valid
for f in scripts/*.sh; do bash -n "$f"; done  # PASS

# build-project-definition produces valid output
python3 helpers/build-project-definition.py --idea-file reference/product/PROJECT-IDEA.md.ref --output /tmp/pd.json  # PASS

# validate-project-definition accepts valid, rejects invalid deployment_context
python3 helpers/validate-project-definition.py /tmp/pd.json  # PASS
# (with deployment_context.value="enterprise")  # FAIL as expected

# check-project-definition-fixture
bash helpers/check-project-definition-fixture.sh  # PASS

# validate-production-readiness
DEPLOYMENT_CONTEXT=prototype bash scripts/validate-production-readiness.sh  # SKIP
DEPLOYMENT_CONTEXT=production bash scripts/validate-production-readiness.sh  # SKIP (no plan)
```

---

## 8. Conclusion

The framework is structurally sound. The audit found no critical workflow breakages. The main improvements are:

1. **Integrate** validate-production-readiness into the decision engine (gate-selection, Phase 4C).
2. **Align** AGENT-BOOTSTRAP Phase 2 STORE and Round 3 description with PROJECT-INTAKE (deployment_context, question count).
3. **Add** ASSUMPTIONS-AND-RISKS.md.ref.
4. **Update** script counts and summary templates to match current implementation.
5. **Clarify** schema vs validator relationship in documentation.

Implementing these will reduce agent confusion and ensure consistent behavior across discovery, intake, plan generation, and gate execution.
