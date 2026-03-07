#!/usr/bin/env python3
"""Validate a VibeOS project-definition.json file without external dependencies."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


SOURCES = {"user-confirmed", "inferred", "scanned", "default"}
CONFIDENCE = {"high", "medium", "low"}
IMPACT = {"high", "medium", "low"}


def load_json(path: Path) -> dict[str, Any]:
    with path.open() as handle:
        data = json.load(handle)
    if not isinstance(data, dict):
        raise ValueError("project definition must be a JSON object")
    return data


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def is_evidence_object(value: Any) -> bool:
    return isinstance(value, dict) and {"value", "source", "confidence", "impact"} <= set(value.keys())


def validate_evidence(value: Any, path: str, errors: list[str]) -> None:
    require(is_evidence_object(value), f"{path} must be an evidence object", errors)
    if not is_evidence_object(value):
        return
    require(value["value"] not in ("", None, []), f"{path}.value must not be empty", errors)
    require(value["source"] in SOURCES, f"{path}.source must be one of {sorted(SOURCES)}", errors)
    require(value["confidence"] in CONFIDENCE, f"{path}.confidence must be one of {sorted(CONFIDENCE)}", errors)
    require(value["impact"] in IMPACT, f"{path}.impact must be one of {sorted(IMPACT)}", errors)


def validate_list(section: dict[str, Any], key: str, errors: list[str]) -> None:
    value = section.get(key)
    require(isinstance(value, list), f"{key} must be a list", errors)
    if not isinstance(value, list):
        return
    require(len(value) > 0, f"{key} must not be empty", errors)
    for index, item in enumerate(value):
        validate_evidence(item, f"{key}[{index}]", errors)


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate VibeOS project-definition.json")
    parser.add_argument("path", type=Path, help="Path to project-definition.json")
    args = parser.parse_args()

    try:
        data = load_json(args.path)
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"[validate-project-definition] FAIL: {exc}", file=sys.stderr)
        return 1

    errors: list[str] = []
    for key in ("idea", "users", "scope", "constraints", "technical_recommendation", "governance_profile"):
        require(isinstance(data.get(key), dict), f"missing object section: {key}", errors)

    if errors:
        print("[validate-project-definition] FAIL:")
        for item in errors:
            print(f"  - {item}")
        return 1

    idea = data["idea"]
    users = data["users"]
    scope = data["scope"]
    constraints = data["constraints"]
    technical = data["technical_recommendation"]
    governance = data["governance_profile"]

    for field in ("name", "summary", "product_type"):
        validate_evidence(idea.get(field), f"idea.{field}", errors)
    validate_evidence(users.get("primary_persona"), "users.primary_persona", errors)
    for field in ("language", "framework", "database", "deployment_shape"):
        validate_evidence(technical.get(field), f"technical_recommendation.{field}", errors)
    for field in ("team_size", "risk_level"):
        validate_evidence(governance.get(field), f"governance_profile.{field}", errors)
    if governance.get("deployment_context") is not None:
        dep_ctx = governance["deployment_context"]
        validate_evidence(dep_ctx, "governance_profile.deployment_context", errors)
        if is_evidence_object(dep_ctx):
            val = dep_ctx.get("value")
            if val not in ("prototype", "production", "customer-facing", "scale"):
                errors.append(
                    "governance_profile.deployment_context.value must be one of: prototype, production, customer-facing, scale"
                )

    validate_list(scope, "core_workflows", errors)
    validate_list(scope, "v1_features", errors)
    require(isinstance(scope.get("non_goals"), list), "scope.non_goals must be a list", errors)
    if isinstance(scope.get("non_goals"), list):
        for index, item in enumerate(scope["non_goals"]):
            validate_evidence(item, f"scope.non_goals[{index}]", errors)

    for key in ("platforms", "integrations", "sensitive_data", "compliance_targets"):
        require(isinstance(constraints.get(key), list), f"constraints.{key} must be a list", errors)
        if isinstance(constraints.get(key), list):
            for index, item in enumerate(constraints[key]):
                validate_evidence(item, f"constraints.{key}[{index}]", errors)

    if errors:
        print("[validate-project-definition] FAIL:")
        for item in errors:
            print(f"  - {item}")
        return 1

    print("[validate-project-definition] PASS: project definition is structurally valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())
