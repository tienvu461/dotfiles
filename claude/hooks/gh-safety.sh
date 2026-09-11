#!/usr/bin/env bash
# PreToolUse hook: gates `gh` CLI commands run via the Bash tool.
# Silent (exit 0, no stdout) on anything it has no opinion about, so those fall through
# to Claude Code's normal permission flow.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0

CMD=$(jq -r '.tool_input.command // empty')
[[ -z "$CMD" ]] && exit 0

echo "$CMD" | grep -qE '\bgh\b' || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/permission-log.sh"

decide() {
  local decision="$1" reason="$2"
  jq -n --arg d "$decision" --arg r "$reason" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse", permissionDecision:$d, permissionDecisionReason:$r}}'
  log_decision "gh-safety" "$decision" "$reason" "$CMD"
  exit 0
}

# --- deny: CI triggers, secret mutation, token exposure ---
DENY_RE='gh[[:space:]]+workflow[[:space:]]+run|gh[[:space:]]+secret[[:space:]]+(set|remove)|gh[[:space:]]+repo[[:space:]]+delete|gh[[:space:]]+release[[:space:]]+delete|gh[[:space:]]+auth[[:space:]]+token'
if echo "$CMD" | grep -qEi "$DENY_RE"; then
  decide "deny" "Blocked: CI trigger, secret mutation, or token exposure via gh"
fi

# --- ask: chaining / substitution ---
if echo "$CMD" | grep -qE '(;|&&|\|\||`|\$\()'; then
  decide "ask" "Command chaining/substitution detected in gh command"
fi

# --- ask: mutating gh operations ---
ASK_RE='gh[[:space:]]+pr[[:space:]]+merge|gh[[:space:]]+pr[[:space:]]+close|gh[[:space:]]+issue[[:space:]]+close|gh[[:space:]]+repo[[:space:]]+edit|gh[[:space:]]+api[[:space:]].*-X[[:space:]]+(POST|PUT|DELETE|PATCH)'
if echo "$CMD" | grep -qEi "$ASK_RE"; then
  decide "ask" "Mutating gh command"
fi

# --- allow: read-only gh operations ---
ALLOW_RE='gh[[:space:]]+(pr|issue)[[:space:]]+(view|list|diff|checks|status)|gh[[:space:]]+repo[[:space:]]+view|gh[[:space:]]+run[[:space:]]+(view|list)|gh[[:space:]]+auth[[:space:]]+status'
if echo "$CMD" | grep -qEi "$ALLOW_RE"; then
  decide "allow" "Read-only gh command"
fi

exit 0
