#!/usr/bin/env bash
# Cheap-model bulk reader. The worker model reads the file; the frontier
# model only reads these bullets. Usage: summarize.sh <file> [question]
set -euo pipefail

file="${1:?usage: summarize.sh <file> [question]}"
question="${2:-Summarize structure, key definitions/signatures, and anything notable.}"
model="${PONYTAIL_WORKER_MODEL:-claude-haiku-4-5-20251001}"

[ -f "$file" ] || { echo "no such file: $file" >&2; exit 1; }

prompt="You are a bulk file reader. Answer the QUESTION about the FILE below.
Output ONLY terse structured bullets: definitions, signatures, key logic,
with line numbers where useful. No prose, no preamble, no markdown fences.

QUESTION: $question

FILE: $file
---
$(cat "$file")"

printf '%s' "$prompt" | claude -p --model "$model"

