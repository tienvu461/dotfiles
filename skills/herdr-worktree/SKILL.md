---
name: herdr-worktree
description: Isolate large tasks (expected to touch more than ~10 files) into their own git worktree and branch using herdr, implement the work there as a first-class herdr agent, then commit and open a PR so CI runs before the user reviews and merges. Use when the user asks to start a big ticket or task in herdr, mentions worktrees, "new worktree", "large task", "big ticket", "run CI", or "PR for ticket X", or when a task is estimated to touch more than ten files.
---

# Large-Task Workflow: Ticket → Worktree → PR (herdr + opencode)

Run large tasks in an isolated git worktree on its own branch, so `main` and the
user's other workspaces stay clean and CI runs on a real branch before review.

## When to use

- **Isolate** when the task/ticket is estimated to touch **more than ~10 files**
  (models, services, views, templates, JS, tests, migrations, fixtures, e2e).
- **Stay put** when the task is small (<10 files): work in the current workspace
  on the current branch.
- If the estimate is unclear, ask the user. If mid-task scope grows past the
  threshold, pause and propose isolating the rest.

## Prerequisites

- You are running inside a herdr pane: `test "${HERDR_ENV:-}" = 1`. If not, say
  you are not inside herdr and stop.
- `gh` is installed and authenticated (`gh auth status`). If missing, tell the
  user: `brew install gh && gh auth login`.
- `jq` is installed for parsing herdr JSON (`brew install jq`).
- `git` remote is reachable (SSH or https).
- Read `AGENTS.md` in the target repo and follow its commit style, lint, and
  test commands. The commands below use generic names; substitute the repo's.

## Step 1 — Create the worktree from latest main

Fetch first so the base is fresh `origin/main`, then let herdr create the
checkout, open it as a workspace, and group it with the parent repo:

```bash
git fetch origin main
create=$(herdr worktree create --base origin/main \
  --branch "<branch>" --label "<ticket title>" --no-focus)
echo "$create" | jq -r '.result.workspace.workspace_id, .result.tab.tab_id, .result.root_pane.pane_id'
```

- `--branch`: existing repo convention, e.g. `feat/<ticket-slug>`, `fix/<slug>`,
  `refactor/<slug>`. If the branch exists locally it is checked out; otherwise
  herdr creates it from `--base`.
- `--label`: human-readable ticket title (shows in the herdr sidebar).
- `--no-focus`: keep the user's focus where it is.
- Capture from the JSON response: `workspace_id`, `tab_id`, `root_pane_id`.
  herdr puts the checkout under its worktrees directory; do not guess the path.

## Step 2 — Start the agent in the worktree

The worktree's root pane is a shell at the worktree path. Start opencode there
with a stable, unique name (match `[a-z][a-z0-9_-]{0,31}`):

```bash
herdr agent start "<agent-name>" --kind opencode --pane "<root_pane_id>"
```

`<agent-name>` = the ticket slug, e.g. `el-2-grading`. It inherits the repo's
opencode config and AGENTS.md because it runs in the same checkout.

The agent is now a first-class entry in `herdr agent list`. The user can talk
to it directly at any time:

- TUI: click its pane / focus it in the sidebar and type.
- CLI: `herdr agent prompt "<name>" "..."`, `herdr agent read "<name>"`.

Install the opencode integration once if state detection is unreliable:
`herdr integration install opencode`.

## Step 3 — Hand off the work and monitor

Submit the full ticket to the worker agent and wait for it to settle:

```bash
herdr agent prompt "<name>" "<full task prompt with ticket ref, acceptance criteria>" --wait --timeout 600000
herdr agent read "<name>" --source recent-unwrapped --lines 200
```

- Read status anytime: `herdr agent get "<name>"`, `herdr agent list`.
- If it lands on `blocked`, tell the user what it's asking (read the pane)
  instead of answering approvals yourself unless the user asked you to relay.
- The user can interject with `herdr agent prompt "<name>" ...` or by focusing
  the pane; the agent is always on the list while alive.

## Step 4 — Commit and open the PR (CI gate)

When the worker reports done, in the worktree checkout:

```bash
# repo verification (substitute AGENTS.md commands, e.g. just pre-commit run --all-files, just test ..., mypy ...)
git add -A
git commit -m "<conventional message per repo style, e.g. feat: add assignment grading>"
git push -u origin "<branch>"
gh pr create --base main --head "<branch>" \
  --title "<Ticket key: title>" \
  --body "Refs: <ticket>. Implements ... "
```

Report the PR URL. CI runs on the PR; the user reviews and merges. If the user
wants CI to run before it looks ready for review, add `--draft` and mark ready
later.

## Step 5 — After the PR is merged

```bash
herdr worktree remove --workspace "<worktree_workspace_id>"
git branch -d "<branch>"
```

`worktree remove` runs `git worktree remove` and deletes the checkout (it never
deletes the branch, so merged branch cleanup is a separate `git branch -d`).
Keep the worktree instead if follow-up work is expected.

## Notes

- Never create a worktree unless the task clears the size gate or the user asks
  for one explicitly.
- Don't switch the user's focus or close workspaces you did not create.
- Parse all IDs from herdr JSON responses; do not predict them.
