#!/usr/bin/env bash
# PreToolUse hook: gates aws / aws-vault / kubectl / helm / mole / gosak commands run via the Bash tool.
# Silent (exit 0, no stdout) on anything it has no opinion about, so those fall through
# to Claude Code's normal permission flow.
set -euo pipefail

command -v jq >/dev/null 2>&1 || exit 0

CMD=$(jq -r '.tool_input.command // empty')
[[ -z "$CMD" ]] && exit 0

echo "$CMD" | grep -qEi '\b(aws|aws-vault|kubectl|helm|mole|gosak)\b' || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/permission-log.sh"

decide() {
  local decision="$1" reason="$2"
  jq -n --arg d "$decision" --arg r "$reason" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse", permissionDecision:$d, permissionDecisionReason:$r}}'
  log_decision "cloud-safety" "$decision" "$reason" "$CMD"
  exit 0
}

# --- deny: hard-blocked patterns ---
DENY_RE='rm[[:space:]]+-rf[[:space:]]+/|kubectl[[:space:]]+delete[[:space:]].*--all|helm[[:space:]]+(uninstall|delete)[[:space:]].*--all|aws[[:space:]]+s3[[:space:]]+rm[[:space:]].*--recursive|aws[[:space:]]+iam[[:space:]]+delete-user|aws[[:space:]].*delete-bucket|terraform[[:space:]]+destroy|aws[[:space:]]+codepipeline[[:space:]]+start-pipeline-execution|aws[[:space:]]+codebuild[[:space:]]+start-build|cat[[:space:]].*\.aws/credentials'
if echo "$CMD" | grep -qEi "$DENY_RE"; then
  decide "deny" "Blocked: destructive or credential-exposing command"
fi

# --- ask: kubectl explicitly targeting the prod cluster (mirrors the aws admin/danger-profile ask) ---
if echo "$CMD" | grep -qEi 'kubectl' && echo "$CMD" | grep -qEi '(--context[[:space:]]+\S*ieprod|--kubeconfig[[:space:]]+\S*ieprod|KUBECONFIG=\S*ieprod)'; then
  decide "ask" "kubectl command explicitly targets the prod cluster"
fi

# --- allow: read-only verbs on the nonprod readonly profile (always allow, no reprompt) ---
READONLY_RE='kubectl[[:space:]]+(get|describe|logs|top|explain|version|api-resources)|helm[[:space:]]+(list|status|get|history)|aws[[:space:]]+[^ ]+[[:space:]]+(describe|list|get)|aws[[:space:]]+s3[[:space:]]+ls|aws[[:space:]]+sts[[:space:]]+get-caller-identity|mole[[:space:]]+ls|gosak[[:space:]]+mole[[:space:]]+ls|gosak[[:space:]]+ec2[[:space:]]+list'
if echo "$CMD" | grep -qEi 'persuit-nonprod-ro\b' && echo "$CMD" | grep -qEi "$READONLY_RE"; then
  decide "allow" "Read-only command on nonprod readonly profile"
fi

# --- ask: chaining / substitution (harder to review at a glance) ---
if echo "$CMD" | grep -qE '(;|&&|\|\||`|\$\()'; then
  decide "ask" "Command chaining/substitution detected in cloud command"
fi

# --- ask: write-capable / danger profile keywords (mirrors zshrc's danger_profiles list) ---
if echo "$CMD" | grep -qEi '(admin|master-admin|master-ro)'; then
  decide "ask" "References a write-capable/danger AWS profile"
fi

# --- ask: gosak assume printing STS creds to stdout ---
if echo "$CMD" | grep -qEi 'gosak[[:space:]]+assume.*(-o\b|--output\b)'; then
  decide "ask" "gosak assume prints STS credentials to stdout"
fi

# --- ask: mutating verbs ---
MUTATE_RE='kubectl[[:space:]]+(apply|delete|scale|rollout|patch|create|edit|drain|cordon|exec)|helm[[:space:]]+(install|upgrade|uninstall|rollback)|aws[[:space:]]+[^ ]+[[:space:]]+(put-|create-|delete-|update-|terminate-|modify-|start-|stop-|reboot-)|gosak[[:space:]]+ec2[[:space:]]+(start|stop)'
if echo "$CMD" | grep -qEi "$MUTATE_RE"; then
  decide "ask" "Mutating cloud/cluster command"
fi

# --- allow: read-only verbs ---
if echo "$CMD" | grep -qEi "$READONLY_RE"; then
  decide "allow" "Read-only cloud/cluster command"
fi

exit 0
