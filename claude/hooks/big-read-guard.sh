#!/usr/bin/env bash
# PreToolUse hook: block reads of large files, redirect Claude to summarize.sh
# so a cheap worker model eats the tokens instead of the frontier model.
set -euo pipefail

MAX_LINES="${PONYTAIL_MAX_READ_LINES:-350}"
input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

file=""
case "$tool" in
  Read)
    file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
    ;;
  Bash)
    cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:];|&])(cat|head|tail|less|more)([[:space:]]|$)'; then
      # ponytail: best-effort first path-looking token; misses exotic quoting, upgrade to a real parser if it bites
      file=$(printf '%s' "$cmd" | grep -oE '[^[:space:]]+\.[A-Za-z0a9_]+' | head -1)
    fi
    ;;
esac

[ -n "$file" ] && [ -f "$file" ] || exit 0

lines=$(wc -l < "$file" | tr -d ' ')
[ "$lines" -le "$MAX_LINES" ] && exit 0

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
{
  echo "'$file' has $lines lines (> $MAX_LINES). Do NOT read it directly."
  echo "Run instead: $script_dir/summarize.sh '$file' '<what you need to know>'"
  echo "It returns a cheap-model bullet digest instead of burning frontier tokens on the raw file."
} >&2
exit 2

