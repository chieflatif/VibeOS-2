#!/usr/bin/env bash
# VibeOS-2 — Template Renderer
# Dual rendering: jq for JSON files, sed for markdown/text files.
# Usage: bash render-template.sh <template_file> <output_file> <config_json_file>
#        bash render-template.sh <template_file> <output_file> KEY1=VALUE1 KEY2=VALUE2 ...
set -euo pipefail

FRAMEWORK_VERSION="2.0.0"
SCRIPT_NAME="render-template"

usage() {
    echo "Usage:"
    echo "  $0 <template> <output> <config.json>          # JSON config mode"
    echo "  $0 <template> <output> KEY1=VAL1 KEY2=VAL2    # Key-value mode"
    echo ""
    echo "Template syntax:"
    echo "  {{KEY}}  — replaced with value from config"
    echo ""
    echo "JSON files (.json) use jq for safe escaping."
    echo "All other files use sed for replacement."
    exit 2
}

if [[ $# -lt 3 ]]; then
    usage
fi

TEMPLATE_FILE="$1"
OUTPUT_FILE="$2"
shift 2

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "[${SCRIPT_NAME}] FAIL: Template not found: $TEMPLATE_FILE"
    exit 1
fi

# Ensure output directory exists
OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Detect rendering mode based on file extension
IS_JSON=false
if [[ "$TEMPLATE_FILE" == *.json* ]]; then
    IS_JSON=true
fi

# --- MODE 1: JSON config file ---
if [[ $# -eq 1 ]] && [[ -f "$1" ]]; then
    CONFIG_FILE="$1"

    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        echo "[${SCRIPT_NAME}] FAIL: Invalid JSON config: $CONFIG_FILE"
        exit 1
    fi

    if $IS_JSON; then
        # JSON template → use jq for safe rendering
        # Extract all {{KEY}} placeholders from template
        PLACEHOLDERS=$(grep -oE '\{\{[A-Za-z_][A-Za-z0-9_]*\}\}' "$TEMPLATE_FILE" | sort -u | sed 's/[{}]//g')

        # Start with template content
        cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

        for KEY in $PLACEHOLDERS; do
            # Read value from config (supports nested keys with dot notation)
            VALUE=$(jq -r ".$KEY // empty" "$CONFIG_FILE" 2>/dev/null || true)

            if [[ -n "$VALUE" ]]; then
                # Use jq to safely replace in JSON (handles escaping)
                TEMP_FILE=$(mktemp)
                jq --arg key "{{${KEY}}}" --arg val "$VALUE" \
                    'walk(if type == "string" then gsub($key; $val) else . end)' \
                    "$OUTPUT_FILE" > "$TEMP_FILE" 2>/dev/null && mv "$TEMP_FILE" "$OUTPUT_FILE" || {
                    # Fallback to sed if jq walk fails (template might not be valid JSON yet)
                    rm -f "$TEMP_FILE"
                    sed -i.bak "s|{{${KEY}}}|${VALUE}|g" "$OUTPUT_FILE"
                    rm -f "${OUTPUT_FILE}.bak"
                }
            fi
        done
    else
        # Non-JSON template → use sed
        PLACEHOLDERS=$(grep -oE '\{\{[A-Za-z_][A-Za-z0-9_]*\}\}' "$TEMPLATE_FILE" | sort -u | sed 's/[{}]//g')

        cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

        for KEY in $PLACEHOLDERS; do
            VALUE=$(jq -r ".$KEY // empty" "$CONFIG_FILE" 2>/dev/null || true)
            if [[ -n "$VALUE" ]]; then
                # Use | as sed delimiter to avoid issues with / in paths
                sed -i.bak "s|{{${KEY}}}|${VALUE}|g" "$OUTPUT_FILE"
                rm -f "${OUTPUT_FILE}.bak"
            fi
        done
    fi

    echo "[${SCRIPT_NAME}] PASS: Rendered $TEMPLATE_FILE → $OUTPUT_FILE"

# --- MODE 2: Key-value pairs ---
else
    cp "$TEMPLATE_FILE" "$OUTPUT_FILE"

    for ARG in "$@"; do
        if [[ "$ARG" == *"="* ]]; then
            KEY="${ARG%%=*}"
            VALUE="${ARG#*=}"

            if $IS_JSON; then
                # For JSON, try jq first, fallback to sed
                TEMP_FILE=$(mktemp)
                jq --arg key "{{${KEY}}}" --arg val "$VALUE" \
                    'walk(if type == "string" then gsub($key; $val) else . end)' \
                    "$OUTPUT_FILE" > "$TEMP_FILE" 2>/dev/null && mv "$TEMP_FILE" "$OUTPUT_FILE" || {
                    rm -f "$TEMP_FILE"
                    sed -i.bak "s|{{${KEY}}}|${VALUE}|g" "$OUTPUT_FILE"
                    rm -f "${OUTPUT_FILE}.bak"
                }
            else
                sed -i.bak "s|{{${KEY}}}|${VALUE}|g" "$OUTPUT_FILE"
                rm -f "${OUTPUT_FILE}.bak"
            fi
        else
            echo "[${SCRIPT_NAME}] WARN: Skipping invalid argument (expected KEY=VALUE): $ARG"
        fi
    done

    echo "[${SCRIPT_NAME}] PASS: Rendered $TEMPLATE_FILE → $OUTPUT_FILE"
fi

# --- VALIDATION ---

# Check for remaining placeholders
REMAINING=$(grep -oE '\{\{[A-Za-z_][A-Za-z0-9_]*\}\}' "$OUTPUT_FILE" 2>/dev/null | sort -u || true)
if [[ -n "$REMAINING" ]]; then
    echo "[${SCRIPT_NAME}] WARN: Unreplaced placeholders in $OUTPUT_FILE:"
    echo "$REMAINING" | sed 's/^/  /'
fi

# Validate JSON output
if [[ "$OUTPUT_FILE" == *.json ]]; then
    if ! jq empty "$OUTPUT_FILE" 2>/dev/null; then
        echo "[${SCRIPT_NAME}] FAIL: Output is invalid JSON: $OUTPUT_FILE"
        exit 1
    fi
fi

exit 0
