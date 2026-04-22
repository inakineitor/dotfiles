# jj-spr Quick Reference

## Daily Commands

| Do this                                   | Command                                  |
| ----------------------------------------- | ---------------------------------------- |
| Create/update PR from `@-`                | `jj spr diff`                            |
| Create/update a specific PR               | `jj spr diff -r <change-id>`             |
| Push local title/body change to PR        | `jj spr diff --update-message`           |
| Create a PR that's independent of parent  | `jj spr diff --cherry-pick`              |
| Create/update PRs for the whole stack     | `jj spr diff --all`                      |
| Merge PR (ASK USER FIRST)                 | `jj spr land -r @-`                      |
| Merge an independent PR                   | `jj spr land --cherry-pick -r <id>`      |
| Pull PR title/body from GitHub            | `jj spr amend`                           |
| List your open PRs                        | `jj spr list`                            |
| Close a PR without merging                | `jj spr close -r @-`                     |
| Reformat local description only           | `jj spr format`                          |
| Set up in a new repo                      | `jj spr init`                            |

## Canonical Single-PR Flow

```bash
jj git fetch
jj new main@origin
# ... edit ...
jj describe -m "feat: ..."
jj new
jj spr diff
# ... review feedback: edit ...
jj squash
jj spr diff --update-message
jj spr land -r @-                    # ASK USER FIRST
jj git fetch                          # MANDATORY
jj rebase -r @ -d main@origin         # MANDATORY
```

## State Transitions

| After                             | `@` contains | `@-` contains             |
| --------------------------------- | ------------ | ------------------------- |
| `jj new main@origin` + edits      | edits        | trunk tip                 |
| `jj describe -m "..."`            | described    | trunk tip                 |
| `jj new`                          | empty        | your PR change            |
| `jj spr diff`                     | empty        | PR change + PR trailer    |
| edit + `jj squash`                | empty        | PR change w/ new edits    |
| `jj spr diff --update-message`    | empty        | PR change (title updated) |
| `jj spr land -r @-`               | empty        | landed (now stale)        |
| `jj rebase -r @ -d main@origin`   | empty, fresh | —                         |

## Stack Update

```bash
# Edit at @, then:
jj squash --into <change-id>
jj spr diff -r <change-id>
```

## Stack Rebase onto Fresh Trunk

```bash
jj git fetch
jj rebase -s <root-change-id> -d main@origin
jj spr diff --all
```

## Dependent-Stack Land (parent first)

```bash
jj spr land -r <parent>
jj git fetch
jj rebase -r @ -d main@origin
jj rebase -s <child> -d main@origin
jj spr diff --all
# then:
jj spr land -r <child>
jj git fetch
jj rebase -r @ -d main@origin
```

## Description Sync Direction

| Want                | Command                        |
| ------------------- | ------------------------------ |
| Local → GitHub      | `jj spr diff --update-message` |
| GitHub → Local      | `jj spr amend`                 |
| Local reformat only | `jj spr format`                |

## Commit Message Format

```
Short title (→ PR title)

Body (→ PR description).

Reviewers: alice, bob         # you write — optional, comma/space sep.
Pull Request: <auto>          # added by jj spr diff — don't edit
Reviewed By: <auto>           # added by jj spr land
```

## Config (`.git/config` → `[spr]`)

| Key                      | Default                    |
| ------------------------ | -------------------------- |
| `spr.githubAuthToken`    | —                          |
| `spr.githubRemoteName`   | `origin`                   |
| `spr.githubRepository`   | from remote URL            |
| `spr.githubMasterBranch` | `main` / GitHub default    |
| `spr.branchPrefix`       | `jj-spr/<user>/`           |
| `spr.requireApproval`    | `false` (`true` via init)  |

Env: `GITHUB_TOKEN`, `JJ_SPR_BRANCH_PREFIX`.

Lookup priority: CLI flag > `~/.jjconfig.toml` > `.jj/repo/config.toml` > `.git/config` > env > defaults.

## One-Time Alias

```bash
jj config set --user 'aliases.spr' '["util", "exec", "--", "jj-spr"]'
```

## Troubleshooting

| Problem                                       | Fix                                                              |
| --------------------------------------------- | ---------------------------------------------------------------- |
| `jj spr land` tried to land empty change      | Pass `-r @-` (land defaults to `@`; diff defaults to `@-`)       |
| Next change based on stale trunk after land   | Forgot mandatory `jj git fetch && jj rebase -r @ -d main@origin` |
| `jj spr diff` created a new PR (not updated)  | `Pull Request:` trailer was rewritten away; find orphan, re-link |
| PR description edits revert next sync         | Someone used `jj describe` instead of `jj spr amend`             |
| Local title/body change not on GitHub         | Run `jj spr diff --update-message`                               |
| Dependent child has wrong base after parent lands | `jj rebase -s <child> -d main@origin && jj spr diff --all`   |
| `jj spr`: command not found                   | Alias missing: `jj config set --user 'aliases.spr' '[...]'`      |
| Auth error after token rotation               | `jj spr init` again, or `git config spr.githubAuthToken "..."`   |
| External contributor can't push               | jj-spr requires write access — no fork flow; use plain git+fork  |
| `jj spr land` refuses: "not approved"         | `spr.requireApproval=true`; get approval or flip the flag        |

## Git/jj Equivalents (for jj-spr users)

| Common git workflow             | jj-spr equivalent                           |
| ------------------------------- | ------------------------------------------- |
| `git push origin HEAD` + `gh pr create` | `jj spr diff`                       |
| `git commit --amend` + `git push -f`    | `jj squash` + `jj spr diff`          |
| `gh pr merge --squash`                  | `jj spr land -r @-`                  |
| `gh pr edit --title/--body`             | Edit locally + `jj spr diff --update-message` |
| `gh pr list --author @me`               | `jj spr list`                        |
| `gh pr close`                           | `jj spr close -r @-`                 |
| Stacked PRs via `git branch` per layer  | `jj spr diff --all` on a linear stack |
