---
name: reduce-pr-loc
description: Reduce the total handwritten source code needed to deliver a pull request's intent while preserving behavior, genuine external contracts, coverage, and maintainability. Use when asked to shrink a PR, cut LOC, simplify a diff, remove boilerplate or AI slop, find a smaller implementation, or make a change easier to review. Inspect the PR and adjacent existing code, redesign repository-internal contracts and migrate callers when that unlocks a smaller generic primitive, search current platform and library leverage, pursue code-judo moves that delete whole mechanisms, measure both PR-local and repository-wide reductions, verify the result, and report mechanical before/after metrics. Do not use for minification or code golf.
---

# Reduce PR LOC

Make the implementation smaller by deleting concepts and mechanisms, not by hiding the same complexity on fewer physical lines. Optimize the repository-wide implementation of the PR's intent, not the apparent size of one function, package, diff, or call site. Existing internal contracts are design material when changing them and migrating their callers produces a smaller system.

A well-chosen library can be a genuine deletion. A mature, documented, tested library gives readers a trusted external contract so they do not need to understand or maintain a bespoke local implementation. Treat that as leverage, not as cheating, when the fit is real and the final integration is verifiably smaller.

## Contract

Optimize in this order:

1. Preserve the PR's intended behavior and genuine external contracts.
2. Redesign controllable repository-internal contracts when a caller migration deletes more code or yields a substantially more generic primitive.
3. Delete concepts, branches, states, layers, duplicated decisions, and maintenance surface.
4. Reduce reader load by relying on direct code and stable, well-understood contracts, including suitable third-party libraries.
5. Reduce both non-generated PR additions and total repository-wide handwritten implementation LOC.
6. Preserve or improve operability, debuggability, and ease of future change.

A lower line count is not a win when it removes required behavior or coverage, weakens types or boundary validation, compresses statements, introduces unexplained magic, or merely relocates bespoke complexity into wrappers, configuration, generated code, or an ill-fitting dependency.

Third-party implementation detail is not automatically reader load. Readers may rely on a library's public contract when the library is credible, its behavior is verified for this use, and the local integration remains narrow. Do not reproduce the library internally “for safety” unless the fallback is a real requirement.

`NO SAFE REDUCTION` is a valid result. Never manufacture a win.

Classify contracts before preserving them:

- **External contracts** include user-visible behavior, public APIs used outside the repository, persistence and wire formats, security boundaries, and compatibility promises. Preserve them unless the user explicitly authorizes a migration.
- **Repository-internal contracts** include private workspace packages, internal service APIs, shared types, callbacks, and conventions whose callers are all controllable in the repository. Treat them as candidates for redesign even when they predate the PR.
- **PR-local surfaces** include new exports, options, state names, adapters, and file boundaries introduced by the unmerged change. They are implementation choices unless the PR explicitly promises them.

A narrow internal contract change that deletes a large specialized mechanism is often the highest-value code-judo move. Do not freeze an existing abstraction merely because it lives outside the current diff.

## Defaults

Unless the user specifies otherwise:

- Target the current PR or branch against its merge base.
- Preserve observable behavior, genuine external APIs, persistence and wire formats, error semantics, security boundaries, and the performance envelope. Internal APIs with controllable callers may be migrated.
- Count production source separately from tests, documentation/configuration, generated files, snapshots, vendored code, and lockfiles.
- Report non-generated production-source additions as the review-size metric. Use the repository-wide simplification delta as the deciding LOC metric for internal contract redesigns, and also report production net LOC.
- Protect meaningful tests, types, comments, validation, and documentation. Remove them only when they are redundant and the same contract remains enforced elsewhere.
- Judge helper extraction across the helper definition, every changed call site, and all helper-specific support code. Do not replace a few direct lines used once with a longer helper plus a one-line call.
- Change adjacent pre-existing code when doing so directly enables a substantially smaller implementation of the PR's intent.
- Accept a wider diff when a small internal-contract migration reduces total repository LOC, removes transport or platform knowledge from a shared core, or eliminates a whole family of branches. Measure the complete migration rather than penalizing it for touching existing files.
- Search the standard library, platform APIs, current dependencies, repository helpers, and the current online library ecosystem. Do not rely only on memory when online search is available.
- Adding a new dependency is allowed when it is the best-fitting simplification and the final library-backed implementation is strictly smaller than the best credible version without that dependency.
- A dependency is not disqualified merely because it is broad, large, used in only one place, or provides much more functionality than this PR needs. Package size and one-time use are costs to evaluate, not automatic vetoes.
- Prefer a focused library when it is equally capable and trustworthy, but do not reject a broad mature library when no smaller good fit exists and it yields the simplest correct implementation.
- Do not force a library into the design. If the API, semantics, platform support, maintenance status, license, security posture, or integration shape are a poor fit, keep the dependency-free solution.
- For substantial changes, actively search for a path that removes roughly half of the added implementation or deletes an entire mechanism. Treat this as an ambition and search heuristic, not a quota.
- When the user asks to reduce or simplify, make reversible edits directly. When the user asks only for a review or plan, do not edit.
- Once the user selects a library, primitive, or architecture, treat it as fixed unless implementation proves it infeasible. Continue simplifying within that choice instead of repeatedly reopening settled alternatives.

## LOC accounting

Use one stable, mechanical counting method for all comparisons.

Measure two different deltas. Neither substitutes for the other:

1. **Intent delta:** merge-base tree to simplified candidate tree. This describes the final PR reviewers will see.
2. **Simplification delta:** current PR tree to simplified candidate tree. This captures all code removed by the simplification, including pre-existing code outside the original PR diff.

For the PR-level intent delta, report:

- non-generated production-source additions and deletions;
- production net LOC;
- tests, docs, hand-authored configuration, generated files, snapshots, vendored code, and lockfiles separately.

For the repository-wide simplification delta, report:

- total non-generated production-source LOC in the current PR tree and simplified candidate tree;
- handwritten production lines added and removed between those two trees;
- lines removed from files that were not part of the original PR;
- files, exported symbols, states, configuration options, adapters, and lifecycle methods removed;
- caller-migration cost separately from the shared mechanism it allowed the candidate to delete.

Use the total repository reduction when judging an internal contract redesign. For example, adding a five-line callback and changing three callers can be a major win when it deletes two transport-specific implementations, their mode enum, configuration branches, dependencies, and tests. Do not judge that move only by the LOC of the current PR's original files.

For a library decision, compare **net handwritten implementation LOC** between the best credible dependency-free design and the library-backed design. Include every line unique to each path:

- imports and exports;
- production source;
- adapters and wrappers;
- local type declarations or schemas;
- setup and hand-authored configuration;
- error translation, compatibility handling, and fallbacks;
- dependency-specific test fixtures or harness code required to establish the same behavior.

Exclude generated lockfile churn and the library's own source code, but report dependency and lockfile changes separately. Shared behavioral tests that are identical across both paths do not affect the comparison.

The library-backed path must end with strictly fewer net handwritten implementation lines than the best credible no-new-dependency path. A tiny numerical win is not automatically worthwhile: if a library saves only a few lines and does not clearly reduce reader load or remove a mechanism, continue searching for a stronger simplification.

Do not make the final decision from an estimated line count when the candidate can be materialized. Models often misestimate the cost of imports, type signatures, adapters, helper definitions, call sites, formatting, setup, and changes elsewhere in the diff. Use estimates only to choose which candidates to try. Materialize the complete candidate in a reversible patch, branch, or worktree; format it; then mechanically measure the resulting files and diff. Accept or reject it using measured final LOC.

## Workflow

### 1. Resolve the target and pin the intent

1. Read repository instructions such as `AGENTS.md`, `CONTRIBUTING.md`, and local style or test guidance.
2. Resolve the PR's base branch and merge base. Prefer PR metadata when available; otherwise use the repository's default branch or the base named by the user.
3. Read the PR title and description, linked issue or design notes, commits, full diff, affected callers, and relevant tests.
4. State the required behavior in one short paragraph. Separate requirements from implementation choices introduced by the PR.
5. Identify contracts that must not move: externally consumed APIs, serialized data, user-visible behavior, error behavior, security boundaries, performance-sensitive paths, and compatibility requirements.
6. Classify every relevant contract as external, repository-internal, or PR-local. Only the first category is protected by default.

Do not infer that every line in the diff is required merely because it is already implemented.

### 2. Capture the baseline

Record before editing:

- changed files;
- additions and deletions per file;
- non-generated production-source additions and deletions;
- tests/docs/config/generated changes separately;
- dependency and lockfile changes;
- repository-wide non-generated production LOC for both the merge-base tree and current PR tree;
- the relevant test, type-check, build, lint, smoke, benchmark, or equivalence commands and their current results.

A suitable Git default is `git diff --numstat <merge-base>` plus repository-aware file classification. Detect the repository's actual version-control workflow first. In a Jujutsu workspace, use `jj diff` between the resolved trunk tree and target change rather than assuming ordinary Git commands work. Resolve the conceptual trunk tree instead of trusting a synthetic stacked-PR base branch name. Do not count formatting churn as a simplification.

If behavior is not already pinned by tests, create the smallest characterization test, snapshot, fixture, temporary old-vs-new harness, or external smoke probe that can detect a behavior change. Type-checking alone is not a behavior pin. Do not add permanent production injection points solely to support an ephemeral comparison. If the user excludes new committed tests, use an existing test surface or temporary verification rather than silently dropping behavior checks.

### 3. Audit use sites, ownership, and contract shape

Before generating solutions, inventory every meaningful addition and every existing contract that might be blocking a larger deletion:

| Surface | Production consumers | Test-only consumers | Current owner | Better canonical owner | Required contract? |
| --- | --- | --- | --- | --- | --- |
| class, interface, or factory | | | | | |
| option or dependency injection point | | | | | |
| state or data representation | | | | | |
| adapter or translator | | | | | |
| lifecycle method | | | | | |

Apply these rules:

1. Design from actual consumers rather than hypothetical future consumers.
2. Delete PR-local exports and options with no production consumer unless the intent explicitly requires them.
3. Delete test-only injection seams when no retained test or real alternate implementation uses them.
4. If an existing repository abstraction owns the behavior, expose or return it directly instead of wrapping all its methods, properties, events, or states.
5. Prefer changing an internal consumer to accept the canonical contract over translating the producer into a second vocabulary.
6. If every consumer is platform-specific, do not maintain a generic core plus a platform adapter without another real consumer.
7. Search for parallel representations of the same fact. Prefer one canonical type or value object and derive views from it instead of synchronizing aliases, booleans, host/port/origin fields, or translated state unions.
8. For each responsibility, name its rightful owner: operating system, runtime, framework, shared repository core, third-party library, or feature boundary. Delete duplicate ownership.

Before classifying a contract as controllable, search runtime callers, tests, scripts, generated clients, plugin boundaries, package publication settings, documentation, and downstream repositories or open changes when accessible. Do not assume an older internal API is better than the PR's new design. Compare the smallest end-to-end system obtainable by changing either side of the boundary.

### 4. Generate genuinely different simplification paths

Before committing to an implementation, generate competing approaches. For a non-trivial change, consider at least three genuinely different paths when they are plausible:

1. Delete or narrow unnecessary scope so the mechanism is no longer needed.
2. Reframe the data model, ownership boundary, or control flow so the requirement becomes native to the existing architecture.
3. Use a standard-library or platform capability.
4. Reuse an existing repository helper or current dependency.
5. Add a focused third-party library.
6. Add a broader mature library or framework that subsumes the mechanism.
7. Replace the entire approach with a different primitive, protocol, data representation, or execution model.
8. Redesign a pre-existing repository-internal contract and migrate all callers so a shared core can become smaller and more generic.
9. Separate stable policy from variable mechanism, passing the mechanism as a minimal function or capability instead of teaching the core every transport, platform, or protocol variant.

At least one candidate should cross the original PR boundary and ask whether changing existing internal contracts deletes a whole subsystem, family of branches, state machine, adapter layer, or approximately half of the implementation. Do not let the search collapse into several cosmetic variants of the same design.

Do not stop at a helper that removes three or five lines while preserving the same architecture. Small helpers are acceptable residue cleanup after the high-leverage search, not a substitute for it.

### 5. Search online for library leverage

When the change implements a capability likely to exist in the ecosystem, search online before finalizing the design.

1. Search by the capability and contract, not only by the names used in the current implementation. Try broader and narrower formulations, adjacent primitives, and alternative architectural approaches.
2. Search the relevant package registry, official documentation, source repositories, release history, examples, and issue tracker. Prefer current primary sources over summaries or memory.
3. Look for both focused packages and broader libraries that may collapse more of the implementation. Do not assume the smallest package is the simplest integration.
4. For a non-trivial capability, evaluate at least two plausible library candidates when they exist, plus the best credible no-new-dependency path. If only one candidate is credible, record why the others were not real fits.
5. Inspect enough of each API to implement or fully prototype the complete integration, including initialization, types, errors, lifecycle, edge cases, and teardown. Do not estimate savings from a happy-path snippet alone, and do not select a library until the complete formatted integration has been counted.
6. Check the exact current version and whether it supports the repository's runtime, language version, platforms, module system, bundler, deployment model, and licensing constraints.
7. Establish whether the contract is trustworthy enough to replace local code. Consider documentation quality, test coverage, maintenance and release activity, issue health, adoption, security history, and API stability.
8. Search for evidence that the library already handles the difficult cases represented by the bespoke implementation. A trusted contract reduces reader load only when it actually covers the required behavior.

Create a capability map for serious candidates:

| Responsibility | Library API, option, default, or guarantee | Local code deleted | Verification |
| --- | --- | --- | --- |
| acquisition or transport | | | |
| caching, retry, or cancellation | | | |
| integrity or validation | | | |
| parsing or extraction | | | |
| permissions or normalization | | | |
| lifecycle or cleanup | | | |

After choosing a library, inspect local preprocessing and post-processing. Delete code that recreates a documented option, default, output guarantee, or supported input form. Verify those guarantees against the exact installed version rather than relying on memory.

Do not reject a library solely because it is large, has many transitive dependencies, or is used once. Those facts may affect bundle size, startup time, attack surface, or operations, but they do not negate a large source-code and reader-load reduction when the performance and security envelopes remain acceptable.

Do not add a library merely because one exists. Reject candidates that require awkward adapters, duplicate validation, semantic workarounds, fragile monkey-patching, large compatibility shims, or a local reimplementation of the very behavior the library was supposed to replace.

### 6. Search for structural reductions in priority order

Use the competing paths and library research to look beyond local cleanup:

1. **Redesign a constraining internal contract.** Change the shared primitive and migrate its callers when this deletes specialized modes, parallel implementations, dependencies, adapters, or configuration across the repository.
2. **Separate policy from mechanism.** Keep scheduling, retry, timeout, ordering, and state policy in the reusable core. Accept the environment-specific operation as a minimal function or capability supplied by the caller.
3. **Remove unnecessary scope.** Delete speculative features, out-of-scope edge cases, unused options, premature extension points, and changes unrelated to the stated intent.
4. **Use external leverage.** Replace bespoke code with a platform feature, standard-library operation, current dependency, well-fitting third-party library, schema, generator, protocol primitive, or established repository pattern.
5. **Delete dual paths.** Migrate all internal callers to the preferred API and remove the old API, compatibility shim, fallback path, feature flag, adapter, tests, and documentation that exist only for the superseded path.
6. **Simplify the model.** Replace scattered booleans, repeated shape checks, synchronized state, or branch chains with a data shape that makes the common flow direct. Use a table, registry, discriminated union, state machine, reducer, or authoritative source only when it deletes branches or invalid states.
7. **Concentrate boundaries.** Validate and normalize external input once at the real boundary. Remove repeated internal guards, parsing, narrowing, and defensive `try/catch` blocks when trusted internal types already establish the invariant.
8. **Collapse unearned indirection.** Audit every new helper, wrapper, adapter, and class across its definition and all call sites. Inline one-caller wrappers, pass-through adapters, identity transforms, interfaces with one implementation, thin helpers, and configuration layers that do not hide meaningful complexity or produce a measured whole-diff reduction.
9. **Consolidate decisions.** Put each policy choice in one canonical place. Remove repeated conditionals, duplicated defaults, and parallel representations that must stay synchronized.
10. **Delete residue.** Remove dead code, unused exports, obsolete comments, stale TODOs, temporary migration code, redundant tests, unnecessary casts, and AI-style narration introduced by the PR.

Prefer deleting a mechanism over polishing it. Prefer direct local code over an unearned local abstraction. This does not imply rejecting a one-call library integration whose maintained contract replaces substantial bespoke behavior.

#### Code judo: make the shared primitive generic over mechanism

One of the strongest reductions is to replace a shared component's list of supported mechanisms with a caller-supplied operation. This is dependency inversion used for deletion, not abstraction for its own sake.

Suppose a supervisor contains separate HTTP-liveness and process-liveness implementations, a mode union, transport-specific options, validation for both shapes, and branches selecting between them. If the supervisor's true job is deciding **when** to check health and **what to do** after failure, change its contract to accept a function such as `check(context): Promise<boolean>`. Let each feature implement the HTTP, process, socket, RPC, or other transport-specific check at its natural boundary.

The generic callback is earned when all of these are true:

- the shared core retains real policy such as scheduling, timeouts, thresholds, retries, and state transitions;
- the caller supplies only the variable mechanism;
- the new input is smaller and more stable than the specialized configuration variants it replaces;
- transport-specific dependencies and types leave the shared package;
- all controlled callers can migrate without compatibility shims;
- the complete repository ends with fewer handwritten lines, branches, states, and concepts.

Search for this shape anywhere a core package enumerates transports, storage backends, protocols, platform checks, serialization formats, or execution environments. Ask whether the core needs to know each variant, or whether it only needs the result of an operation. A one-function contract can delete entire specialized subsystems even when the current PR did not originally modify the shared package.

Do not confuse this with speculative dependency injection. A callback that merely mirrors one implementation and deletes nothing is unearned. The evidence is the complete migrated repository, not the elegance of the signature.

#### Audit helper economics

Do not confuse extraction with deletion. Moving code into a named helper can make one function look shorter while increasing total LOC and forcing readers to jump elsewhere.

For every helper added, expanded, or retained by the PR, compare the complete cost against the direct implementation across all affected call sites. Count:

- the full helper definition, including its signature, types, comments, overloads, and exports;
- every call site and any new imports;
- wrappers, setup, fixtures, and tests unique to the abstraction;
- the exact inline code the helper replaces.

For a helper claimed as a LOC reduction, require this inequality after formatting:

```text
helper definition + imports/exports/types + all replacement call sites
< all inline code removed
```

A one-call helper receives no reuse amortization and should normally be inlined unless it establishes a real boundary, encapsulates a non-obvious invariant, or is independently required for correctness. Even when such a helper is justified, do not call it a LOC reduction when the total line count rises. A multi-call helper is a LOC simplification only when its complete definition plus all call sites is smaller than the repeated direct code, or when it enables a larger structural deletion. This rule does not prohibit a one-call third-party library integration that deletes substantial bespoke code behind a credible external contract; still count every local integration line.

Repository constraints take precedence over helper economics. A one-call helper may be necessary when the direct form violates lint rules, type constraints, framework requirements, or a real boundary. Keep the smallest compliant form, but report it as necessary implementation cost rather than claiming it as a reduction. Never judge a helper from the cleanliness of its call site in isolation; measure the whole-repository result.

#### Audit lifecycle and cleanup code

For every `start`, `stop`, `shutdown`, `dispose`, cleanup callback, and quit handler, determine:

1. What concrete resource does it release?
2. Can that resource outlive the hosting process?
3. Does correctness require cleanup to finish before exit?
4. Is completion actually awaited?
5. Does the operating system, runtime, framework, or an existing supervisor already own termination?
6. What observable failure occurs if the cleanup code is removed?

Delete lifecycle APIs that only duplicate process termination or abort work that cannot survive the process. Keep explicit teardown for child processes, durable transactions, locks, external leases, or resources whose abrupt termination violates a real invariant. Put related application cleanup under one coordinator rather than splitting shutdown responsibilities between an event listener and the function it invokes unless timing requires the split.

### 7. Compare, prototype, and choose

Match the work to the user's authorization:

- In proposal-only mode, research and compare complete target shapes without editing or materializing them. Label all LOC figures as estimates.
- In implementation mode, materialize serious finalists when formatting, adapters, caller migrations, or configuration could change the decision. Measure rather than predict.
- Create separate branches, worktrees, or PRs for competing implementations only when the user requests tangible comparisons or when isolated prototypes are necessary to choose safely.

For each meaningful candidate, estimate during exploration, then mechanically measure every finalist after applying and formatting the complete patch:

- complete repository-wide handwritten implementation LOC, including helper definitions and all changed call sites;
- production-source additions and net LOC;
- total repository production LOC before and after the candidate, including reductions in pre-existing files;
- caller-migration LOC versus shared-mechanism LOC deleted;
- concepts, branches, layers, states, files, and public surface removed;
- reader load and how much behavior can be treated as a stable contract;
- behavior, compatibility, security, and performance risk;
- verification burden;
- operational and maintenance cost, including dependency lifecycle and transitive surface.

Do not compare a library candidate only against the current verbose PR. Compare it against the **best credible dependency-free simplification** you can find.

For the strongest candidates:

1. Sketch the complete target shape, including callers and error paths.
2. Materialize the complete selected candidate in a temporary branch, worktree, or reversible patch. For a library-backed choice, also materialize or preserve the best credible dependency-free comparison.
3. Format both paths and recount all handwritten integration lines using the same classification. Do not extrapolate from snippets or rely on a predicted delta.
4. Run the narrowest behavioral verification that distinguishes the designs.
5. Prefer the path that removes the most mechanisms and reader load while preserving the contract.

A library-backed path is eligible only when:

- its API is a natural fit for the required behavior;
- the exact version and platform compatibility are verified;
- its contract is credible enough to rely on;
- behavior remains pinned by tests or equivalence checks;
- the final integration has strictly fewer net handwritten implementation lines than the best credible dependency-free path;
- any bundle, startup, security, licensing, or operational costs remain inside the stated envelope.

A broad library used for one call may still be the correct answer. A narrow library that saves two lines but requires readers to learn an awkward abstraction may not be.

When a substantial structural choice has no obvious winner, compare at least two full target shapes rather than polishing the first idea. Choose the smallest boring design that makes the requirement feel inevitable in hindsight.

### 8. Apply reductions incrementally

1. Make one independently understandable simplification at a time.
2. Search every caller and reference before deleting or reshaping an API.
3. Run the narrowest relevant verification after each non-trivial change.
4. Format, recount, and inspect the entire diff after each high-leverage change.
5. Keep a change as a LOC reduction only when behavior remains pinned and both the intent delta and repository-wide simplification delta show the formatted final design is smaller where claimed. If a change improves naming or architecture but does not reduce LOC, report it separately rather than claiming it as a reduction. Reject local helper extractions that shorten one call site while increasing total LOC.
6. When adding a library, delete the bespoke mechanism it replaces. Do not keep an unused or speculative fallback implementation.
7. When migrating an internal contract, update every controlled caller and delete the superseded contract, specialized implementations, modes, adapters, tests, and documentation in the same final design. Do not leave a compatibility shim unless an external consumer requires it.
8. Revert library experiments that fail the fit, trust, behavior, or net-LOC test.
9. Revert all other experiments that are neutral, speculative, riskier, or merely move complexity elsewhere.
10. Format only the touched code. Avoid unrelated cleanup that obscures the LOC comparison.

Intermediate additions are acceptable only when they unlock a larger verified deletion in the final state.

## Dependency acceptance rules

Treat dependency choice as an engineering decision, not a purity test.

Accept a new dependency when the evidence supports all of the following:

- It directly implements the required contract rather than approximately resembling it.
- It replaces meaningful local implementation, not merely a tiny convenience helper.
- Its public API is easier to understand than the code it deletes.
- The project can rely on its behavior without layering a large wrapper or duplicate fallback around it.
- The exact installed version is maintained, documented, license-compatible, and suitable for the target platforms.
- The final path is strictly smaller in net handwritten implementation LOC than the best credible path without it.
- The resulting runtime, bundle, security, and operational tradeoffs are acceptable for this repository.

The following are **not**, by themselves, reasons to reject a dependency:

- it is used only once;
- it is much larger than the subset being used;
- it brings transitive dependencies;
- a smaller library does not exist;
- the same functionality could theoretically be implemented locally.

Reject a dependency when it is a poor semantic fit, untrustworthy, incompatible, operationally unacceptable, or when its complete integration is not actually smaller.

## Anti-gaming guardrails

Do not reduce the metric by:

- joining statements onto fewer lines, minifying, using dense expressions, or removing whitespace needed for readability;
- deleting tests without preserving equivalent behavioral coverage;
- replacing precise types with `any`, unchecked casts, strings, maps, reflection, or implicit conventions;
- dropping validation or error handling at genuine external boundaries;
- moving logic into generated files, templates, shell one-liners, configuration, data blobs, prompts, or comments;
- counting only a shortened call site while ignoring the new helper, wrapper, class, signature, imports, exports, types, tests, and other call-site changes;
- counting only the library call while ignoring imports, wrappers, setup, configuration, error translation, compatibility code, or dependency-specific test harnesses;
- adding a library while retaining the bespoke implementation, speculative fallback, or parallel path it was meant to replace;
- wrapping a library so heavily that the repository still owns nearly all of the complexity;
- choosing an ill-fitting library and recreating its missing semantics locally;
- adding a dependency whose final implementation is equal to or larger than the best credible dependency-free implementation;
- creating a generic local abstraction with no demonstrated value merely to hide lines;
- extracting a one-off helper whose full definition plus call site is longer than the direct code it replaces;
- claiming a reduction from a shorter call site while excluding the helper, import, types, wrapper, or setup moved elsewhere;
- hiding required behavior behind defaults, silent fallbacks, or undocumented magic;
- changing behavior, API compatibility, security posture, or performance merely because the implementation becomes shorter.
- deleting build filters, resource declarations, native libraries, assets, or platform-specific files without preserving the runtime artifact's dependency closure and intended distribution contents.

Generated output should be changed through its source or generator, not hand-edited. Report generated and lockfile churn separately.

Treat source LOC, build-configuration LOC, dependency size, and distributed artifact contents as separate dimensions. A shorter packaging configuration is not a win when it ships unrelated tools, omits required dynamic libraries, or produces an artifact that cannot execute.

## Final verification

Before declaring success:

1. Run the relevant tests, type-check, build, lint, and user-facing smoke or equivalence checks.
2. Compare final behavior against the pinned baseline on the real surface, not only through compilation.
3. Inspect the complete diff for accidental behavior changes, deleted coverage, hidden compatibility changes, and unrelated edits.
4. Format the final code, then mechanically recompute both the merge-base-to-candidate intent delta and current-PR-to-candidate repository-wide simplification delta. Do not report estimated LOC as final LOC.
5. When a library was considered, record the exact candidates, versions, and complete handwritten LOC comparison against the best dependency-free path.
6. When a library was selected, verify installation, imports, build and packaging behavior, target-platform support, error semantics, and any material performance or bundle impact.
7. Confirm that the selected library path deleted the local mechanism rather than layering on top of it.
8. Check that reader load fell: fewer layers to trace, less state to remember, fewer duplicated decisions, and a clear external contract rather than new local magic.
9. Audit every helper introduced or retained by the simplification. Count its complete definition and all call sites; inline one-off helpers that increased total LOC without establishing a real boundary.
10. Re-run the highest-value tests after dependency and lockfile resolution to catch version or packaging differences.
11. For every changed internal contract, verify all repository consumers migrated and no compatibility layer remains accidentally.
12. When build composition changes, inspect and execute the packaged artifact on the relevant platform and architecture. Compilation alone does not establish runtime completeness.

If the library-backed version does not end with strictly fewer net handwritten implementation lines than the best credible dependency-free version, reject it even if the API looks elegant. Establish this from the formatted implementation, not an estimate.

If verification cannot establish equivalence, return `INCONCLUSIVE` rather than claiming success.

## Output

Use this shape:

```text
REDUCED | NO SAFE REDUCTION | INCONCLUSIVE

Intent preserved:
<one-paragraph behavior contract>

Metrics:
- Production additions versus merge base: <current PR> -> <candidate> (<delta>, <percent>)
- Production deletions versus merge base: <current PR> -> <candidate>
- Production net LOC versus merge base: <current PR> -> <candidate> (<delta>)
- Repository production LOC: <current PR tree> -> <candidate tree> (<total reduction>)
- Pre-existing production lines removed outside the original PR: <count>
- Internal-contract migration: <caller lines changed> enabled <shared mechanism lines deleted>
- Tests/docs/config/generated: <before> -> <after>, reported separately
- Dependencies/lockfile: <before> -> <after>, reported separately

Surface reduction:
- Files: <before> -> <after>
- Exported symbols: <before> -> <after>
- Configuration options: <before> -> <after>
- Parallel state or data representations: <before> -> <after>
- Wrapper or adapter layers: <before> -> <after>
- Explicit lifecycle methods: <before> -> <after>

Alternatives considered:
- <dependency-free or architectural path>: <measured LOC if it remained a serious candidate; otherwise clearly labeled estimate, and why kept or rejected>
- <library name and exact version>: <measured complete formatted integration LOC and why kept or rejected>
- <other materially different path>: <result>

Simplifications kept:
- <mechanism removed and why the replacement is smaller>

Library contract relied on:
- <library/version, capability delegated, evidence of fit, or "none">

Verification:
- <command or artifact>: <result>

Remaining opportunities:
- <only high-value opportunities not taken, with estimated reduction and reason>
```

Put the largest structural win first. Do not pad the report with cosmetic nits. Do not present a library substitution as a win without the measured no-library comparison. Do not present a helper extraction as a win by showing only the shortened call site.
