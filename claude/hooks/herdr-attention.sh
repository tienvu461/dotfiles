#!/bin/sh
# Report Claude attention state to herdr, mirroring the old tmux ⚠️ flag.
# Custom hook beside herdr's managed integration file (herdr-agent-state.sh).
# Arg 1: state — blocked (needs input) | idle (done) | working (cleared).
# No-ops when Claude runs outside a herdr pane.
[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0

state="${1:-blocked}"
herdr="$(command -v herdr 2>/dev/null || echo "$HOME/.local/bin/herdr")"
[ -x "$herdr" ] || exit 0

# Monotonic seq so out-of-order delivery can't revive a stale state.
seq="$(python3 -c 'import time;print(time.time_ns())' 2>/dev/null || date +%s)"

"$herdr" pane report-agent "$HERDR_PANE_ID" \
  --source claude-hooks --agent claude --state "$state" --seq "$seq" \
  >/dev/null 2>&1 || true
