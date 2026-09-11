#!/usr/bin/env bash
# Shared logging helper — sourced by cloud-safety.sh and gh-safety.sh.
# Fail-open: a logging failure must never block or fail the calling hook.

LOG_FILE="${HOME}/.claude/logs/cloud-safety-decisions.jsonl"

log_decision() {
  local hook="$1" decision="$2" reason="$3" command="$4"
  {
    mkdir -p "$(dirname "$LOG_FILE")"
    jq -n --arg ts "$(date -u +%FT%TZ)" --arg hook "$hook" --arg d "$decision" \
      --arg r "$reason" --arg cmd "$command" \
      '{ts:$ts, hook:$hook, decision:$d, reason:$r, command:$cmd}' >> "$LOG_FILE"
  } 2>/dev/null || true
}
