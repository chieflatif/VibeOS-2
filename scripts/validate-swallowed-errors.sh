#!/usr/bin/env bash
# VibeOS-2 — Swallowed Error Detection Gate
# Scans for silently swallowed errors: empty catch blocks, bare except-pass,
# discarded error returns, and other patterns where exceptions or errors are
# eaten rather than handled, logged, or propagated.
#
# For each finding the gate explains (in plain English) what could go wrong,
# and assesses from code context whether the silence looks intentional or
# accidental — so non-technical adopters can make informed decisions.
#
# Findings can be suppressed inline with a required explanation:
#
#   Python:         except Foo:  # gate-allow: swallowed-error <reason>
#   JS / TS / Java: catch (e) { // gate-allow: swallowed-error <reason> }
#   Go:             _ = err // gate-allow: swallowed-error <reason>
#   Rust:           Err(_) => {} // gate-allow: swallowed-error <reason>
#
# The reason field is mandatory (≥ 10 chars). A suppression comment without
# a reason is itself a gate failure — silence with no explanation is not
# allowed. No manifest baselines are accepted for this gate.
#
# Usage:
#   bash scripts/validate-swallowed-errors.sh [path ...]
#
# Environment:
#   SCAN_DIRS — space-separated directories to scan (default: current directory)
#
# Exit codes:
#   0 = No swallowed error patterns (or all suppressed with valid explanations)
#   1 = Swallowed error patterns found (or suppression missing explanation)
#   2 = Configuration error
set -euo pipefail

FRAMEWORK_VERSION="2.0.0"
GATE_NAME="validate-swallowed-errors"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/validate-swallowed-errors.sh [path ...]

Environment:
  SCAN_DIRS  Space-separated directories to scan (default: current directory)

Suppression syntax (explanation required, ≥ 10 chars):
  Python:    except Foo:  # gate-allow: swallowed-error <reason>
  JS/TS/Java: catch (e) { // gate-allow: swallowed-error <reason> }
  Go:         _ = err // gate-allow: swallowed-error <reason>
  Rust:       Err(_) => {} // gate-allow: swallowed-error <reason>

No manifest baselines are accepted. Every suppressed error must be
justified in-code next to the pattern being allowed.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

echo "[$GATE_NAME] Swallowed Error Detection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SCAN_ARGS=()
if [[ $# -gt 0 ]]; then
  SCAN_ARGS=("$@")
elif [[ -n "${SCAN_DIRS:-}" ]]; then
  read -ra SCAN_ARGS <<< "$SCAN_DIRS"
else
  SCAN_ARGS=(".")
fi

python3 - "${SCAN_ARGS[@]}" <<'PY'
from __future__ import annotations

import os
import re
import sys
import textwrap
from pathlib import Path

# ============================================================
# File iteration
# ============================================================

paths = [Path(p) for p in sys.argv[1:]] or [Path(".")]

EXCLUDE_DIRS = {
    ".git", "node_modules", "__pycache__", ".pytest_cache", "htmlcov",
    "coverage", ".nyc_output", "dist", "build", "venv", ".venv", "vendor",
    "target", ".mypy_cache", ".tox",
}

LANG_EXTS: dict[str, set[str]] = {
    "python": {".py"},
    "js":     {".js", ".jsx", ".mjs", ".cjs"},
    "ts":     {".ts", ".tsx"},
    "go":     {".go"},
    "rust":   {".rs"},
    "java":   {".java", ".kt", ".kts"},
}
ALL_EXTS = {ext for exts in LANG_EXTS.values() for ext in exts}


def excluded(path: Path) -> bool:
    for part in path.parts:
        if part in EXCLUDE_DIRS or part.startswith(".venv"):
            return True
    return False


def lang_of(p: Path) -> str:
    ext = p.suffix.lower()
    for lang, exts in LANG_EXTS.items():
        if ext in exts:
            return lang
    return "unknown"


def iter_files():
    seen: set[Path] = set()
    for base in paths:
        base = base.resolve()
        if base.is_file():
            if base not in seen:
                seen.add(base)
                yield base
            continue
        if not base.exists():
            continue
        for root, dirs, files in os.walk(base):
            rp = Path(root)
            if excluded(rp):
                dirs[:] = []
                continue
            dirs[:] = [d for d in dirs if not excluded(rp / d)]
            for f in files:
                p = rp / f
                if p in seen:
                    continue
                seen.add(p)
                if p.suffix.lower() not in ALL_EXTS:
                    continue
                yield p


def lineno_of(text: str, offset: int) -> int:
    return text[:offset].count("\n") + 1

# ============================================================
# Suppression
# ============================================================

GATE_ALLOW_RE = re.compile(
    r"gate-allow:\s*swallowed-error\s*(.*)",
    re.IGNORECASE,
)
MIN_EXPLANATION = 10


def check_gate_allow(snippet: str) -> tuple[bool, str]:
    """
    Returns (present, explanation).
    present=True means the gate-allow comment was found.
    explanation is "" when present but missing/too short.
    """
    m = GATE_ALLOW_RE.search(snippet)
    if not m:
        return False, ""
    return True, m.group(1).strip()

# ============================================================
# Context analysis — intentionality signals
# ============================================================

INTENTIONAL_FUNC_SIGNALS = re.compile(
    r"\b(close[sd]?|cleanup|clean_up|teardown|tear_down|dispose[d]?"
    r"|finalize[d]?|shutdown|shut_down|optional|fallback|fall_back"
    r"|graceful|best_effort|bestEffort|on_exit|on_close|on_shutdown"
    r"|destructor|finalizer|flush)\b",
    re.IGNORECASE,
)

CRITICAL_FUNC_SIGNALS = re.compile(
    r"\b(auth(?:enticate|orize)?|login|logout|sign_in|sign_out"
    r"|payment|charge|bill(?:ing)?|process_payment|process_order"
    r"|validate|verify|encrypt|decrypt|sign|token|session|credential"
    r"|submit|save|persist|write(?:_to)?|update|delete|insert|migrate|commit)\b",
    re.IGNORECASE,
)

EXPLAINING_COMMENT = re.compile(
    r"(?:#|//).*\b(intentional|ignore[sd]?|optional|best[_\s]effort"
    r"|not\s+critical|non.critical|fallback|expected|ok\s+to\s+ignore"
    r"|safe\s+to\s+ignore|swallow(?:ed)?|no.op)\b",
    re.IGNORECASE,
)


def get_func_name(text: str, offset: int) -> str | None:
    recent = "\n".join(text[:offset].split("\n")[-50:])
    patterns = [
        re.compile(r"\bdef\s+(\w+)\s*\("),
        re.compile(r"\bfunc(?:tion)?\s+(\w+)\s*\("),
        re.compile(r"\bfn\s+(\w+)\s*\("),
    ]
    last_name: str | None = None
    last_pos = -1
    for pat in patterns:
        for m in pat.finditer(recent):
            if m.start() > last_pos:
                last_pos = m.start()
                last_name = m.group(1)
    return last_name


def get_context_before(text: str, offset: int, n: int = 5) -> str:
    return "\n".join(text[:offset].split("\n")[-n:])


def assess_intentionality(
    snippet: str,
    context_before: str,
    func_name: str | None,
    is_broad: bool,
) -> tuple[str, list[str]]:
    score = 0
    signals: list[str] = []

    if is_broad:
        score -= 2
        signals.append("broad exception type — catches more than likely intended")

    if func_name:
        if CRITICAL_FUNC_SIGNALS.search(func_name):
            score -= 2
            signals.append(f"function '{func_name}' looks like a critical code path")
        if INTENTIONAL_FUNC_SIGNALS.search(func_name):
            score += 2
            signals.append(f"function '{func_name}' suggests cleanup or optional operation")

    combined = context_before + "\n" + snippet
    if EXPLAINING_COMMENT.search(combined):
        score += 2
        signals.append("nearby comment suggests the silence may be intentional")

    if not signals:
        signals.append("no context found — intent unclear")

    if score >= 2:
        return "POSSIBLY INTENTIONAL", signals
    elif score <= -2:
        return "LIKELY ACCIDENTAL", signals
    else:
        return "UNKNOWN", signals

# ============================================================
# Python exception type helpers
# ============================================================

def extract_python_exception(snippet: str) -> tuple[str | None, bool]:
    """Returns (exception_name_str, is_broad)."""
    if re.match(r"\s*except\s*:", snippet):
        return None, True  # bare except — catches literally everything
    m = re.match(r"\s*except\s+([\w,\s()]+?)(?:\s+as\s+\w+)?:", snippet)
    if m:
        exc = m.group(1).strip()
        broad = {"Exception", "BaseException"}
        exc_names = set(re.findall(r"\b[A-Z]\w*\b", exc))
        return exc, bool(exc_names & broad)
    return None, False

# ============================================================
# Impact descriptions (plain English)
# ============================================================

def impact_text(pattern_key: str, exc_name: str | None = None) -> str:
    if pattern_key == "py_bare":
        return (
            "bare except catches EVERYTHING including KeyboardInterrupt and "
            "SystemExit — not just application errors. The program will silently "
            "continue in a potentially broken state with no record of what failed."
        )
    if pattern_key == "py_broad":
        name = exc_name or "Exception"
        return (
            f"catching {name} and silencing it makes any runtime error "
            "invisible — type mismatches, network failures, missing data, failed "
            "writes. Callers will never know the operation failed."
        )
    if pattern_key == "py_specific":
        name = exc_name or "this exception"
        return (
            f"silencing {name} means if this error occurs, execution continues "
            "as if nothing happened. Depending on what follows, this may produce "
            "wrong results, silent data loss, or confusing failures downstream."
        )
    if pattern_key in ("js_empty", "ts_empty", "java_empty", "kt_empty"):
        return (
            "any error thrown here — network failure, type error, unexpected "
            "state — is discarded. The function returns normally even if the "
            "operation completely failed, leaving callers with no way to know."
        )
    if pattern_key == "go_discard":
        return (
            "the error return from this call is explicitly thrown away. If it "
            "fails, execution continues silently and downstream code runs with "
            "no indication that the previous step failed."
        )
    if pattern_key == "rust_err":
        return (
            "if this returns an error it is silently discarded. The program "
            "continues as if it succeeded, which may corrupt state or produce "
            "wrong results downstream."
        )
    return "error is silently swallowed — failures are invisible to callers."

# ============================================================
# Patterns
# ============================================================

# Python multi-line: except … body is only optional comments + pass
PY_EXCEPT_PASS = re.compile(
    r"^([ \t]*except[^:\n]*:[ \t]*(?:#[^\n]*)?\n"
    r"(?:[ \t]*(?:#[^\n]*)?\n)*"
    r"[ \t]*pass[ \t]*(?:#[^\n]*)?)$",
    re.MULTILINE,
)
# Python single-line: except Foo: pass
PY_EXCEPT_PASS_INLINE = re.compile(
    r"^[ \t]*except[^:\n]*:[ \t]*pass[ \t]*(?:#[^\n]*)?$",
    re.MULTILINE,
)
# JS/TS/Java/Kotlin: catch block with empty or comment-only body
# Also handles TS 4.0+ bare catch (no parens)
CATCH_EMPTY = re.compile(
    r"\bcatch\s*(?:\([^)]*\))?\s*\{"
    r"(?:\s*(?://[^\n]*|/\*.*?\*/)\s*)*"
    r"\s*\}",
    re.DOTALL,
)
# Go: discard an error return — full line captured for gate-allow support
GO_DISCARD_ERR = re.compile(
    r"^\s*_\s*=\s*(?:err\b|\w*(?:Err|Error)\b)[^\n]*",
    re.MULTILINE,
)
# Rust: empty Err arm — rest of line captured for gate-allow support
RUST_EMPTY_ERR_ARM = re.compile(
    r"\bErr\s*\([^)]*\)\s*=>\s*\{[ \t]*\}[^\n]*",
)

# ============================================================
# Scan
# ============================================================

Finding = tuple[str, int, str, str, str, list[str], bool]
findings: list[Finding] = []
seen_locations: set[tuple[str, int]] = set()


def record(
    fp: str,
    lno: int,
    check: str,
    impact: str,
    snippet: str,
    signals: list[str],
    missing_explanation: bool,
) -> None:
    key = (fp, lno)
    if key not in seen_locations:
        seen_locations.add(key)
        findings.append((fp, lno, check, impact, snippet, signals, missing_explanation))


for f in iter_files():
    try:
        data = f.read_bytes()
    except Exception:
        continue
    if b"\x00" in data[:4096]:
        continue
    text = data.decode("utf-8", errors="ignore")
    lang = lang_of(f)
    fp = str(f)

    if lang == "python":
        for pat in (PY_EXCEPT_PASS, PY_EXCEPT_PASS_INLINE):
            for m in pat.finditer(text):
                snippet = m.group(0)
                lno = lineno_of(text, m.start())
                present, explanation = check_gate_allow(snippet)
                if present and len(explanation) >= MIN_EXPLANATION:
                    continue

                exc_name, is_broad = extract_python_exception(snippet)
                ctx = get_context_before(text, m.start())
                func = get_func_name(text, m.start())
                label, signals = assess_intentionality(snippet, ctx, func, is_broad)

                if exc_name is None:
                    pk = "py_bare"
                elif is_broad:
                    pk = "py_broad"
                else:
                    pk = "py_specific"

                record(
                    fp, lno,
                    f"Python — bare except/pass [{label}]",
                    impact_text(pk, exc_name),
                    snippet.strip().split("\n")[0].strip()[:100],
                    signals,
                    missing_explanation=present and len(explanation) < MIN_EXPLANATION,
                )

    elif lang in ("js", "ts", "java"):
        for m in CATCH_EMPTY.finditer(text):
            snippet = m.group(0)
            lno = lineno_of(text, m.start())
            present, explanation = check_gate_allow(snippet)
            if present and len(explanation) >= MIN_EXPLANATION:
                continue

            ctx = get_context_before(text, m.start())
            func = get_func_name(text, m.start())
            label, signals = assess_intentionality(snippet, ctx, func, is_broad=True)

            record(
                fp, lno,
                f"{lang.upper()} — empty catch block [{label}]",
                impact_text(f"{lang}_empty"),
                snippet.strip().split("\n")[0].strip()[:100],
                signals,
                missing_explanation=present and len(explanation) < MIN_EXPLANATION,
            )

    elif lang == "go":
        for m in GO_DISCARD_ERR.finditer(text):
            snippet = m.group(0)
            lno = lineno_of(text, m.start())
            present, explanation = check_gate_allow(snippet)
            if present and len(explanation) >= MIN_EXPLANATION:
                continue

            ctx = get_context_before(text, m.start())
            func = get_func_name(text, m.start())
            label, signals = assess_intentionality(snippet, ctx, func, is_broad=True)

            record(
                fp, lno,
                f"Go — error explicitly discarded [{label}]",
                impact_text("go_discard"),
                snippet.strip()[:100],
                signals,
                missing_explanation=present and len(explanation) < MIN_EXPLANATION,
            )

    elif lang == "rust":
        for m in RUST_EMPTY_ERR_ARM.finditer(text):
            snippet = m.group(0)
            lno = lineno_of(text, m.start())
            present, explanation = check_gate_allow(snippet)
            if present and len(explanation) >= MIN_EXPLANATION:
                continue

            ctx = get_context_before(text, m.start())
            func = get_func_name(text, m.start())
            label, signals = assess_intentionality(snippet, ctx, func, is_broad=True)

            record(
                fp, lno,
                f"Rust — empty Err arm [{label}]",
                impact_text("rust_err"),
                snippet.strip()[:100],
                signals,
                missing_explanation=present and len(explanation) < MIN_EXPLANATION,
            )

# ============================================================
# Report
# ============================================================

if not findings:
    print("[validate-swallowed-errors] PASS: No swallowed error patterns detected")
    sys.exit(0)

needs_fix  = [x for x in findings if not x[6]]  # not missing_explanation == normal finding
needs_expl = [x for x in findings if x[6]]       # suppression present but explanation missing

print(f"[validate-swallowed-errors] FAIL: {len(findings)} finding(s)\n")

def print_finding(fp, lno, check, impact, snippet, signals, missing_expl):
    if missing_expl:
        badge = "SUPPRESSION — EXPLANATION REQUIRED"
    elif "LIKELY ACCIDENTAL" in check:
        badge = "LIKELY ACCIDENTAL"
    elif "POSSIBLY INTENTIONAL" in check:
        badge = "POSSIBLY INTENTIONAL"
    else:
        badge = "UNKNOWN INTENT"

    check_clean = re.sub(r"\s*\[.*?\]", "", check).strip()

    print(f"  {badge}  {fp}:{lno}")
    print(f"  Pattern : {check_clean}")
    print(f"  Code    : {snippet}")

    # Wrap impact at 68 chars; subsequent lines align with first word
    wrapped = textwrap.fill(impact, width=68)
    impact_lines = wrapped.split("\n")
    print(f"  Impact  : {impact_lines[0]}")
    for line in impact_lines[1:]:
        print(f"            {line}")

    if signals:
        print(f"  Signals : {signals[0]}")
        for s in signals[1:]:
            print(f"            {s}")

    comment = "#" if "Python" in check else "//"
    if missing_expl:
        print("  Action  : your suppression comment needs a meaningful explanation (≥10 chars):")
        print(f"            {comment} gate-allow: swallowed-error <why this is safe to ignore>")
    else:
        print("  Action  : fix/log the error, or if intentional add inline:")
        print(f"            {comment} gate-allow: swallowed-error <why this is safe to ignore>")

    print()

for row in findings:
    print_finding(*row)

# Summary line — exclude missing_explanation findings from label counts
# (they are their own category and shouldn't double-count)
label_findings = [x for x in findings if not x[6]]
print("─" * 70)
accidental       = sum(1 for _, _, c, *_ in label_findings if "LIKELY ACCIDENTAL"    in c)
possibly_intl    = sum(1 for _, _, c, *_ in label_findings if "POSSIBLY INTENTIONAL" in c)
unknown          = sum(1 for _, _, c, *_ in label_findings if "UNKNOWN"              in c and "ACCIDENTAL" not in c and "INTENTIONAL" not in c)
missing_expl_cnt = len(needs_expl)

parts = []
if accidental:
    parts.append(f"{accidental} likely accidental")
if possibly_intl:
    parts.append(f"{possibly_intl} possibly intentional (verify)")
if unknown:
    parts.append(f"{unknown} unknown intent")
if missing_expl_cnt:
    parts.append(f"{missing_expl_cnt} suppression missing explanation")
print(f"[validate-swallowed-errors] {len(findings)} finding(s): {' | '.join(parts)}")
sys.exit(1)
PY
