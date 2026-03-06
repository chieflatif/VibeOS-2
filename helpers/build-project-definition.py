#!/usr/bin/env python3
"""Build a normalized VibeOS project-definition.json file."""

from __future__ import annotations

import argparse
import json
import re
import sys
from copy import deepcopy
from pathlib import Path
from typing import Any


VERSION = "1.0.0"
SOURCES = {"user-confirmed", "inferred", "scanned", "default"}
CONFIDENCE = {"high", "medium", "low"}
IMPACT = {"high", "medium", "low"}
HEADING_RE = re.compile(r"^(#{1,6})\s+(.*)$")


def load_json(path: Path | None) -> dict[str, Any]:
    if path is None:
        return {}
    with path.open() as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return data


def load_text(path: Path | None) -> str:
    if path is None:
        return ""
    return path.read_text().strip()


def deep_merge(base: dict[str, Any], incoming: dict[str, Any]) -> dict[str, Any]:
    result = deepcopy(base)
    for key, value in incoming.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = deep_merge(result[key], value)
        else:
            result[key] = deepcopy(value)
    return result


def slugify(value: str) -> str:
    lowered = value.strip().lower()
    lowered = re.sub(r"[^a-z0-9]+", "-", lowered)
    lowered = re.sub(r"-+", "-", lowered).strip("-")
    return lowered or "project"


def title_case_words(text: str) -> str:
    words = [word for word in re.split(r"[^A-Za-z0-9]+", text) if word]
    if not words:
        return "Untitled Project"
    return " ".join(word.capitalize() for word in words[:5])


DEFAULT_IMPACT = {
    "name": "high",
    "summary": "high",
    "product_type": "high",
    "problem_statement": "high",
    "primary_persona": "high",
    "secondary_personas": "medium",
    "core_workflows": "high",
    "v1_features": "high",
    "non_goals": "medium",
    "success_metrics": "medium",
    "platforms": "high",
    "integrations": "medium",
    "sensitive_data": "high",
    "compliance_targets": "high",
    "language": "high",
    "framework": "high",
    "database": "high",
    "deployment_shape": "high",
    "notes": "medium",
    "team_size": "medium",
    "risk_level": "high",
    "slug": "medium",
    "repo_url": "low",
}


def evidence(value: Any, source: str = "default", confidence: str = "medium", impact: str = "medium") -> dict[str, Any]:
    return {
        "value": value,
        "source": source,
        "confidence": confidence,
        "impact": impact,
    }


def evidence_for_field(
    field_name: str,
    value: Any,
    source: str = "inferred",
    confidence: str = "low",
) -> dict[str, Any]:
    return evidence(
        value,
        source=source,
        confidence=confidence,
        impact=DEFAULT_IMPACT.get(field_name, "medium"),
    )


def unbox(value: Any) -> Any:
    if isinstance(value, dict) and {"value", "source", "confidence", "impact"} <= set(value.keys()):
        return value["value"]
    return value


def unbox_list(values: Any) -> list[str]:
    if not isinstance(values, list):
        values = [values]
    return [str(unbox(item)) for item in values if unbox(item) not in (None, "")]


def parse_markdown_sections(text: str) -> tuple[str | None, dict[str, str]]:
    title: str | None = None
    sections: dict[str, list[str]] = {}
    current = "_body"

    for raw_line in text.splitlines():
        line = raw_line.rstrip()
        heading_match = HEADING_RE.match(line.strip())
        if heading_match:
            level = len(heading_match.group(1))
            heading_text = heading_match.group(2).strip()
            if title is None and level == 1:
                title = heading_text
            current = heading_text.lower()
            sections.setdefault(current, [])
            continue
        sections.setdefault(current, []).append(line)

    flattened = {
        key: "\n".join(value).strip()
        for key, value in sections.items()
        if "\n".join(value).strip()
    }
    return title, flattened


def section_text(sections: dict[str, str], *names: str) -> str:
    for name in names:
        value = sections.get(name.lower())
        if value:
            return value
    return ""


def parse_bullets_or_csv(value: str) -> list[str]:
    if not value:
        return []
    items: list[str] = []
    for line in value.splitlines():
        candidate = line.strip()
        if not candidate:
            continue
        if candidate.startswith(("- ", "* ")):
            candidate = candidate[2:].strip()
            if candidate:
                items.append(candidate)
        elif candidate.startswith(tuple(f"{n}. " for n in range(1, 10))):
            items.append(candidate.split(". ", 1)[1].strip())
        elif "," in candidate and len(value.splitlines()) == 1:
            items.extend(part.strip() for part in candidate.split(",") if part.strip())
        else:
            items.append(candidate)
    return items


def infer_name(title: str | None, sections: dict[str, str], text: str) -> str:
    explicit = section_text(sections, "project name", "name")
    if explicit:
        return explicit.splitlines()[0].strip()
    if title:
        return title
    summary = infer_summary(sections, text)
    return title_case_words(summary)


def infer_summary(sections: dict[str, str], text: str) -> str:
    explicit = section_text(sections, "summary", "idea", "product summary", "description")
    if explicit:
        return explicit.splitlines()[0].strip()
    body = sections.get("_body", text).strip()
    if not body:
        return "A new software product defined from a freeform idea."
    lines = [line.strip() for line in body.splitlines() if line.strip()]
    return lines[0]


def infer_primary_persona(sections: dict[str, str], text: str) -> str:
    explicit = section_text(sections, "primary user", "user", "persona", "persona(s)")
    if explicit:
        return parse_bullets_or_csv(explicit)[0]
    match = re.search(r"\bfor\s+([A-Za-z0-9 ,/&-]{3,80})", text, re.IGNORECASE)
    if match:
        return match.group(1).strip(" .,:;")
    return "Primary end user"


def infer_problem_statement(sections: dict[str, str], summary: str) -> str:
    explicit = section_text(sections, "problem", "problem statement")
    if explicit:
        return explicit.splitlines()[0].strip()
    return summary


def infer_list_with_fallback(
    sections: dict[str, str],
    text: str,
    field_name: str,
    *section_names: str,
) -> list[dict[str, Any]]:
    explicit = section_text(sections, *section_names)
    items = parse_bullets_or_csv(explicit)
    if items:
        return [evidence_for_field(field_name, item, source="user-confirmed", confidence="high") for item in items]

    fallback_text = text.strip().splitlines()[0] if text.strip() else field_name.replace("_", " ")
    if field_name == "core_workflows":
        fallback_text = f"Deliver the primary workflow described in the product idea: {fallback_text}"
    elif field_name == "v1_features":
        fallback_text = f"Implement the minimum viable feature set needed for: {fallback_text}"
    elif field_name == "non_goals":
        fallback_text = "Anything outside the first validated release scope"

    return [evidence_for_field(field_name, fallback_text, source="inferred", confidence="low")]


def infer_platforms(summary: str, text: str, sections: dict[str, str]) -> list[dict[str, Any]]:
    explicit = parse_bullets_or_csv(section_text(sections, "platforms", "platform"))
    if explicit:
        return [evidence_for_field("platforms", item.lower(), source="user-confirmed", confidence="high") for item in explicit]

    lowered = f"{summary}\n{text}".lower()
    inferred: list[str] = []
    if any(token in lowered for token in ("mobile", "ios", "android", "app store", "play store")):
        inferred.append("mobile")
    if any(token in lowered for token in ("web", "browser", "dashboard", "portal", "saas")):
        inferred.append("web")
    if "api" in lowered or "integration" in lowered or "backend" in lowered:
        inferred.append("api")
    if "internal" in lowered or "back office" in lowered:
        inferred.append("internal")
    if not inferred:
        inferred.append("web")
    return [evidence_for_field("platforms", item, source="inferred", confidence="medium") for item in dict.fromkeys(inferred)]


def infer_sensitive_data(summary: str, text: str, sections: dict[str, str]) -> list[dict[str, Any]]:
    explicit = parse_bullets_or_csv(section_text(sections, "sensitive data", "data sensitivity"))
    if explicit:
        return [evidence_for_field("sensitive_data", item.lower(), source="user-confirmed", confidence="high") for item in explicit]

    lowered = f"{summary}\n{text}".lower()
    inferred: list[str] = []
    if any(token in lowered for token in ("email", "name", "customer", "client", "profile", "user account")):
        inferred.append("pii")
    if any(token in lowered for token in ("payment", "billing", "subscription", "stripe", "invoice")):
        inferred.append("payments")
    if any(token in lowered for token in ("health", "workout", "medical", "biometric", "wellness")):
        inferred.append("health")
    if any(token in lowered for token in ("finance", "financial", "bank", "payroll")):
        inferred.append("financial")
    return [evidence_for_field("sensitive_data", item, source="inferred", confidence="medium") for item in dict.fromkeys(inferred)]


def infer_compliance_targets(sensitive_data: list[dict[str, Any]], text: str, sections: dict[str, str]) -> list[dict[str, Any]]:
    explicit = parse_bullets_or_csv(section_text(sections, "compliance", "compliance targets"))
    if explicit:
        return [evidence_for_field("compliance_targets", item.lower(), source="user-confirmed", confidence="high") for item in explicit]

    lowered = text.lower()
    inferred: list[str] = []
    sensitive_values = {unbox(item) for item in sensitive_data}
    if "pii" in sensitive_values or "gdpr" in lowered:
        inferred.append("gdpr")
    if "owasp" in lowered or any(token in lowered for token in ("web", "api", "auth", "public")):
        inferred.append("owasp")
    if "soc2" in lowered or any(token in lowered for token in ("enterprise", "audit trail", "b2b")):
        inferred.append("soc2")
    return [evidence_for_field("compliance_targets", item, source="inferred", confidence="low") for item in dict.fromkeys(inferred)]


def infer_integrations(sections: dict[str, str]) -> list[dict[str, Any]]:
    explicit = parse_bullets_or_csv(section_text(sections, "integrations", "integration"))
    return [evidence_for_field("integrations", item, source="user-confirmed", confidence="high") for item in explicit]


def parse_idea_markdown(path: Path) -> dict[str, Any]:
    text = load_text(path)
    if not text:
        raise ValueError(f"{path} is empty")

    title, sections = parse_markdown_sections(text)
    summary = infer_summary(sections, text)
    name = infer_name(title, sections, text)
    primary_persona = infer_primary_persona(sections, text)
    problem_statement = infer_problem_statement(sections, summary)
    platforms = infer_platforms(summary, text, sections)
    sensitive_data = infer_sensitive_data(summary, text, sections)
    compliance_targets = infer_compliance_targets(sensitive_data, text, sections)
    integrations = infer_integrations(sections)

    return {
        "project": {
            "slug": evidence_for_field("slug", slugify(name), source="inferred", confidence="medium"),
        },
        "idea": {
            "name": evidence_for_field("name", name, source="user-confirmed" if title else "inferred", confidence="high" if title else "medium"),
            "summary": evidence_for_field("summary", summary, source="user-confirmed", confidence="high"),
            "problem_statement": evidence_for_field(
                "problem_statement",
                problem_statement,
                source="user-confirmed" if section_text(sections, "problem", "problem statement") else "inferred",
                confidence="high" if section_text(sections, "problem", "problem statement") else "medium",
            ),
        },
        "users": {
            "primary_persona": evidence_for_field(
                "primary_persona",
                primary_persona,
                source="user-confirmed" if section_text(sections, "primary user", "user", "persona", "persona(s)") else "inferred",
                confidence="high" if section_text(sections, "primary user", "user", "persona", "persona(s)") else "low",
            ),
            "secondary_personas": [],
        },
        "scope": {
            "core_workflows": infer_list_with_fallback(sections, summary, "core_workflows", "core workflows", "workflow", "workflows"),
            "v1_features": infer_list_with_fallback(sections, summary, "v1_features", "v1 features", "features", "scope"),
            "non_goals": infer_list_with_fallback(sections, summary, "non_goals", "non-goals", "non goals"),
        },
        "constraints": {
            "platforms": platforms,
            "integrations": integrations,
            "sensitive_data": sensitive_data,
            "compliance_targets": compliance_targets,
        },
    }


def normalize_evidence(value: Any, field_name: str, source: str) -> dict[str, Any]:
    if isinstance(value, dict) and {"value", "source", "confidence", "impact"} <= set(value.keys()):
        normalized = {
            "value": value["value"],
            "source": value["source"],
            "confidence": value["confidence"],
            "impact": value["impact"],
        }
    else:
        confidence = "high" if source == "user-confirmed" else "medium"
        normalized = evidence(value, source=source, confidence=confidence, impact=DEFAULT_IMPACT.get(field_name, "medium"))

    if normalized["source"] not in SOURCES:
        raise ValueError(f"{field_name} has invalid source: {normalized['source']}")
    if normalized["confidence"] not in CONFIDENCE:
        raise ValueError(f"{field_name} has invalid confidence: {normalized['confidence']}")
    if normalized["impact"] not in IMPACT:
        raise ValueError(f"{field_name} has invalid impact: {normalized['impact']}")
    return normalized


SECTION_SOURCES = {
    "idea": "user-confirmed",
    "users": "user-confirmed",
    "scope": "user-confirmed",
    "constraints": "user-confirmed",
    "technical_recommendation": "inferred",
    "governance_profile": "inferred",
    "project": "default",
}


LIST_FIELDS = {
    "secondary_personas",
    "core_workflows",
    "v1_features",
    "non_goals",
    "success_metrics",
    "platforms",
    "integrations",
    "sensitive_data",
    "compliance_targets",
    "notes",
}


def normalize_section(name: str, value: dict[str, Any]) -> dict[str, Any]:
    source = SECTION_SOURCES.get(name, "default")
    normalized: dict[str, Any] = {}
    for key, raw_value in value.items():
        if key in LIST_FIELDS:
            items = raw_value if isinstance(raw_value, list) else [raw_value]
            normalized[key] = [normalize_evidence(item, key, source) for item in items if item not in (None, "")]
        else:
            normalized[key] = normalize_evidence(raw_value, key, source)
    return normalized


def infer_product_type(summary: str, platforms: list[str]) -> str:
    text = summary.lower()
    if "marketplace" in text:
        return "marketplace"
    if "internal" in text or "back office" in text:
        return "internal-tool"
    if "mobile" in text or "ios" in text or "android" in text or "mobile" in platforms:
        return "mobile-app"
    if "api" in text and "web" not in platforms:
        return "api-platform"
    if "saas" in text or "dashboard" in text or "portal" in text:
        return "web-saas"
    return "other"


def infer_language(product_type: str, platforms: list[str]) -> str:
    if "mobile" in platforms or product_type in {"mobile-app", "web-saas", "internal-tool", "api-platform"}:
        return "typescript"
    return "python"


def infer_framework(language: str, product_type: str, platforms: list[str]) -> str:
    if "mobile" in platforms:
        return "expo"
    if language == "python" and "api" in platforms:
        return "fastapi"
    if product_type == "web-saas" or "web" in platforms:
        return "nextjs"
    if "api" in platforms:
        return "express" if language == "typescript" else "fastapi"
    return "none"


def infer_database(product_type: str, platforms: list[str], sensitive_data: list[str]) -> str:
    if sensitive_data or product_type in {"web-saas", "marketplace", "internal-tool"} or "api" in platforms:
        return "postgresql"
    return "sqlite"


def infer_deployment_shape(risk_level: str, platforms: list[str]) -> str:
    if risk_level == "high" and "api" in platforms:
        return "modular-monolith-with-explicit-boundaries"
    return "monolith-first"


def infer_risk_level(sensitive_data: list[str], compliance_targets: list[str]) -> str:
    high_risk = {"health", "financial", "payments"}
    if any(item in high_risk for item in sensitive_data) or "soc2" in compliance_targets:
        return "high"
    if sensitive_data or any(item in {"gdpr", "owasp"} for item in compliance_targets):
        return "medium"
    return "low"


def extract_values(items: list[dict[str, Any]]) -> list[str]:
    return [str(item["value"]) for item in items]


def ensure_defaults(merged: dict[str, Any]) -> dict[str, Any]:
    idea = merged.setdefault("idea", {})
    users = merged.setdefault("users", {})
    scope = merged.setdefault("scope", {})
    constraints = merged.setdefault("constraints", {})
    technical = merged.setdefault("technical_recommendation", {})
    governance = merged.setdefault("governance_profile", {})
    project = merged.setdefault("project", {})

    name = unbox(idea.get("name", ""))
    summary = unbox(idea.get("summary", ""))

    if name and "slug" not in project:
        project["slug"] = slugify(str(name))

    platforms = constraints.setdefault("platforms", [])
    sensitive_data = constraints.setdefault("sensitive_data", [])
    compliance = constraints.setdefault("compliance_targets", [])
    scope.setdefault("core_workflows", [])
    scope.setdefault("v1_features", [])
    scope.setdefault("non_goals", [])
    users.setdefault("secondary_personas", [])
    constraints.setdefault("integrations", [])

    platform_values = unbox_list(platforms)
    sensitive_values = unbox_list(sensitive_data)
    compliance_values = unbox_list(compliance)

    if "product_type" not in idea:
        idea["product_type"] = infer_product_type(str(summary), platform_values)

    product_type = str(unbox(idea.get("product_type", "other")))

    if "language" not in technical:
        technical["language"] = infer_language(product_type, platform_values)
    if "framework" not in technical:
        technical["framework"] = infer_framework(str(unbox(technical["language"])), product_type, platform_values)
    if "database" not in technical:
        technical["database"] = infer_database(product_type, platform_values, sensitive_values)

    risk_level = infer_risk_level(sensitive_values, compliance_values)
    governance.setdefault("team_size", "solo")
    governance.setdefault("risk_level", risk_level)

    if "deployment_shape" not in technical:
        technical["deployment_shape"] = infer_deployment_shape(str(unbox(governance["risk_level"])), platform_values)

    technical.setdefault("notes", [])
    return merged


def normalize_structure(raw: dict[str, Any]) -> dict[str, Any]:
    data = ensure_defaults(raw)
    normalized = {
        "version": data.get("version", VERSION),
        "idea": normalize_section("idea", data["idea"]),
        "users": normalize_section("users", data["users"]),
        "scope": normalize_section("scope", data["scope"]),
        "constraints": normalize_section("constraints", data["constraints"]),
        "technical_recommendation": normalize_section("technical_recommendation", data["technical_recommendation"]),
        "governance_profile": normalize_section("governance_profile", data["governance_profile"]),
    }
    if data.get("project"):
        normalized["project"] = normalize_section("project", data["project"])
    return normalized


def main() -> int:
    parser = argparse.ArgumentParser(description="Build project-definition.json for VibeOS-2")
    parser.add_argument("--idea-file", type=Path, help="Canonical freeform PROJECT-IDEA.md input")
    parser.add_argument("--idea", type=Path, help="Primary discovery JSON input")
    parser.add_argument("--existing", type=Path, help="Existing project-definition.json to merge")
    parser.add_argument("--intake", type=Path, help="Governance or intake answers as JSON")
    parser.add_argument("--scan", type=Path, help="Repository scan findings as JSON")
    parser.add_argument("--output", type=Path, required=True, help="Destination file")
    args = parser.parse_args()

    merged: dict[str, Any] = {}
    if args.idea_file is not None:
        merged = deep_merge(merged, parse_idea_markdown(args.idea_file))
    for path in (args.existing, args.idea, args.intake, args.scan):
        merged = deep_merge(merged, load_json(path))

    try:
        normalized = normalize_structure(merged)
    except ValueError as exc:
        print(f"[build-project-definition] FAIL: {exc}", file=sys.stderr)
        return 1

    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("w") as handle:
        json.dump(normalized, handle, indent=2)
        handle.write("\n")

    workflows = extract_values(normalized["scope"]["core_workflows"])
    print(
        f"[build-project-definition] PASS: wrote {args.output} "
        f"with {len(workflows)} core workflow(s)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
