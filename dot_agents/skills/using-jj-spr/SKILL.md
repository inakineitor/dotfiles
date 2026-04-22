---
name: using-jj-spr
description: Stacked-diff GitHub PR workflows with jj-spr (LucioFranco/jj-spr) — `jj spr diff/land/amend/format/list/close`, independent vs dependent stacks, `--cherry-pick` flag, mandatory post-land fetch+rebase, `--update-message` for description sync, PR-as-source-of-truth commit trailers, `spr.*` git-config keys, `jj spr init` setup. Covers non-obvious rules (`jj spr land` defaults to `@` not `@-`, PR description overrides `jj describe`, write access required — no forks) that prevent stale-work and silently-clobbered-message bugs. Assumes `using-jj` knowledge; skip for plain jj or plain gh workflows.
---

# jj-spr Workflow

Stacked pull requests for Jujutsu, integrated with GitHub. Builds on `using-jj` — read that first for jj fundamentals (`@`, `@-`, change IDs, immutable_heads, etc.).

## Philosophy

1. **Local amend, remote append.** jj-spr bridges jj's "rewrite freely" with GitHub's "append-only review history." You `jj squash` / `jj describe` locally; the PR branch on GitHub gets new commits on top. Reviewers never see a force-push.
2. **Change IDs are the PR handle.** A PR is bound to a change ID, not a branch name. Rebase, squash, abandon-and-recreate — the PR stays linked via the `Pull Request:` trailer.
3. **Work at `@-`, edit at `@`.** `jj spr diff` defaults to `@-`. Keep `@` empty as scratch. The canonical setup is: edit → describe → `jj new` → your change sits at `@-`, `@` is empty.
4. **PR description is the source of truth.** Once a PR exists, GitHub's title/body wins. `jj spr amend` pulls remote edits down; `jj spr diff --update-message` pushes local edits up. Pick a direction explicitly per operation — bare `jj describe` changes silently lose next sync.
5. **Write access is mandatory.** jj-spr uses the GitHub API to create PR branches directly in the target repo. No fork workflow. External contributors must fall back to plain git + fork.
6. **Independent stacks are the default.** `--cherry-pick` lands in any order with no inter-PR coupling. Dependent stacks exist only for genuine code dependencies and triple the landing ceremony.
7. **Colocated repos only.** jj-spr requires a jj-colocated git repo (it drives git under the hood).

## CRITICAL Rules

**`jj spr land` defaults to `@`, not `@-`.** `jj spr diff` defaults to `@-`. Easy to confuse. Always pass `-r @-` (or an explicit change ID) to `land`, otherwise you'll try to land your empty scratch change:

```bash
# WRONG — operates on @ (usually empty)
jj spr land

# CORRECT
jj spr land -r @-
```

**Post-land `jj git fetch && jj rebase` is MANDATORY.** jj-spr does not rebase for you:

```bash
jj spr land -r @-
jj git fetch                      # Required
jj rebase -r @ -d main@origin     # Required
```

Skipping this leaves `@` on stale trunk — next change compounds the drift.

**`jj describe` alone will not update the PR.** Local description edits don't push until:

```bash
jj spr diff --update-message
```

**Use `jj spr amend`, NOT `jj describe`, to pull GitHub-side edits.** If a reviewer edits the PR title/body on GitHub, run `jj spr amend` to sync it locally. Manually rewriting with `jj describe` gets clobbered next `--update-message`.

**`jj spr` is an alias for `jj util exec -- jj-spr`.** If `jj spr` is "command not found," the alias isn't configured — see Installation below.

**Confirm before `jj spr land` and `jj spr close` on active PRs.** These have real remote side effects. `land` is effectively irreversible (revert-PR only); `close` loses review context. Ask the user first.

## Core Concepts

### @ vs @- (with jj-spr context)

- `@` — scratch, expected empty after `jj new`. `jj spr land` acts here by default (footgun).
- `@-` — your described PR change. `jj spr diff` acts here by default.

Canonical setup from trunk:

```bash
jj new main@origin          # Start fresh from trunk
# ... edit files ...
jj describe -m "feat: ..."  # Describe @ in place
jj new                      # Empty @ created; described change → @-
jj spr diff                 # PR created from @-
```

### Change-ID → PR link (trailers)

After `jj spr diff`, your description gains:

```
feat: add the widget

Longer body explaining things.

Reviewers: alice, bob
Pull Request: https://github.com/org/repo/pull/1234
```

- `Reviewers:` — you write this; comma- or space-separated GitHub usernames → reviewer requests.
- `Pull Request:` — jj-spr appends after PR creation. Deleting it orphans the link.
- `Reviewed By:` — added by `jj spr land` once approvals land.

### Description sync directions

Pick the direction per operation:

| Direction             | Command                        |
| --------------------- | ------------------------------ |
| Local → GitHub        | `jj spr diff --update-message` |
| GitHub → Local        | `jj spr amend`                 |
| Local reformat only   | `jj spr format`                |

## Installation

```bash
git clone https://github.com/LucioFranco/jj-spr.git
cd jj-spr
cargo install --path spr      # → ~/.cargo/bin/jj-spr
```

Wire up the `jj spr` subcommand alias (one-time, user-global):

```bash
jj config set --user 'aliases.spr' '["util", "exec", "--", "jj-spr"]'
```

Verify: `jj-spr --version`.

## Per-Repo Setup

Run once inside each jj-colocated repo:

```bash
jj spr init
```

Prompts for:

- **Auth** — preferred: `gh auth login`, then pick "GitHub CLI" (no tokens in git config). Fallback: PAT with `repo` scope (+ `workflow` only if editing `.github/workflows/`). The token gets written into `.git/config` — don't commit it anywhere.
- **Repository** — defaults to `owner/repo` extracted from the `origin` URL.
- **Master branch** — defaults from GitHub's default branch.
- **Branch prefix** — defaults to `jj-spr/<github-username>/`.
- **Require approval** — defaults to `true` when set via `init` (blocks landing unapproved PRs).

Re-run `jj spr init` any time to tweak — it uses current settings as defaults.

## Simple Workflow (one PR)

```bash
# 1. Fresh start from trunk
jj git fetch
jj new main@origin

# 2. Edit files (working copy is @)

# 3. Describe and promote to @-
jj describe -m "feat: add widget"
jj new

# 4. Create PR
jj spr diff

# 5. Address review: edit, squash, push message update
# ... edit ...
jj squash                          # @ edits → @-
jj spr diff --update-message       # Push updated PR (and message)

# 6. Merge (ASK USER FIRST)
jj spr land -r @-

# 7. MANDATORY post-land cleanup
jj git fetch
jj rebase -r @ -d main@origin
```

## Stacked Workflow

### Independent changes (preferred — `--cherry-pick`)

Two or more PRs that can land in any order. Each starts from `main@origin`:

```bash
# PR #1
jj new main@origin
# ... edit ...
jj describe -m "refactor: extract helper"
jj new
jj spr diff --cherry-pick

# PR #2 — also from trunk, NOT stacked on #1
jj new main@origin
# ... edit ...
jj describe -m "fix: off-by-one in widget"
jj new
jj spr diff --cherry-pick
```

Land in any order:

```bash
jj spr land --cherry-pick -r <change-id>
jj git fetch
jj rebase -r @ -d main@origin
```

### Dependent stacks (only when the child truly depends on the parent)

Build sequentially:

```bash
jj new main@origin
# ... edit ...
jj describe -m "feat: add auth module"

jj new
# ... edit ...
jj describe -m "feat: wire auth into profile"

jj new                  # Empty @ on top

jj spr diff --all       # Creates PRs for the whole stack
```

Landing — parent first, rebase between each child:

```bash
# Land parent
jj spr land -r <parent-change-id>
jj git fetch
jj rebase -r @ -d main@origin
jj rebase -s <child-change-id> -d main@origin
jj spr diff --all       # Update child's base on GitHub

# Then land child
jj spr land -r <child-change-id>
jj git fetch
jj rebase -r @ -d main@origin
```

That's 4 commands per land (vs 2 for independent). Prefer `--cherry-pick` unless there's a real code dependency.

### Updating a specific change in a stack

Preferred — edit at `@`, squash into target, push:

```bash
# @ has new edits
jj squash --into <change-id>
jj spr diff -r <change-id>
```

Alternative — edit in place:

```bash
jj edit <change-id>
# ... edit ...
jj spr diff -r @
jj new <parent-change-id>     # Return to empty @ on top
```

### Rebasing a whole stack onto fresh trunk

```bash
jj git fetch
jj rebase -s <root-change-id> -d main@origin
jj spr diff --all
```

## Commit Message Format

```
Short title (becomes PR title)

Longer body — multiple paragraphs OK (becomes PR description).

Reviewers: alice, bob
```

- `Reviewers:` is optional, comma- or space-separated GitHub usernames.
- `Pull Request:` trailer — added by jj-spr, don't edit or remove.
- `Reviewed By:` trailer — added by `jj spr land`.

Customizable description templates: `.jj/repo/config.toml`.

## Configuration Reference

Settings live in `.git/config` under `[spr]` by default. Lookup priority (highest first):

1. CLI flag (e.g. `--github-repository`)
2. jj user config `~/.jjconfig.toml`
3. jj repo config `.jj/repo/config.toml`
4. Git repo config `.git/config` (where `jj spr init` writes)
5. Env vars
6. Built-in defaults

| Key                      | Default                      | Purpose                                 |
| ------------------------ | ---------------------------- | --------------------------------------- |
| `spr.githubAuthToken`    | —                            | PAT (skip if using gh CLI auth)         |
| `spr.githubRemoteName`   | `origin`                     | Git remote pointing at GitHub           |
| `spr.githubRepository`   | from remote URL              | `owner/repo`                            |
| `spr.githubMasterBranch` | `main` or GitHub default     | Target branch for merges                |
| `spr.branchPrefix`       | `jj-spr/<user>/`             | Prefix for auto-generated PR branches   |
| `spr.requireApproval`    | `false` (init sets `true`)   | Block landing unapproved PRs            |

Env overrides: `GITHUB_TOKEN` (→ `githubAuthToken`), `JJ_SPR_BRANCH_PREFIX` (→ `branchPrefix`).

Update later without re-running init:

```bash
git config spr.requireApproval true
```

## Recovery & Troubleshooting

```bash
jj spr list              # Your open PRs
jj spr amend             # Pull remote description into local change
jj spr close -r @-       # Close without merging (ASK USER FIRST if any review)
jj spr format            # Reformat local description only
```

If a change lost its `Pull Request:` trailer:
- Search the PR on GitHub, close it manually if orphaned, then `jj spr diff` to create a fresh one. (`jj op restore` won't bring the trailer back if it was rewritten away.)

If `jj spr land` landed the wrong change: revert via the GitHub UI (creates a revert PR). `jj op restore` only rewinds local state — the merge on main stays.

## Bail Out

Local-only: `rm -rf .jj` (deletes jj state, keeps git).

Remote: `jj spr close -r <change-id>` closes the PR; re-running `jj spr diff` can recreate one.
