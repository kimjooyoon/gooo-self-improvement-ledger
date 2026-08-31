# Self-improvement portfolio v1

## Scope

The portfolio is an evidence ledger for twenty-one specifically named capabilities.
It is not a language-wide quality score, maturity score, or completeness claim.
The only aggregate values are exact state counts and fixed bucket counts.

## Fixed denominator

The source of truth is `contracts/self-improvement-portfolio-v1.json`. Its
`cells` array is immutable during a run and contains twenty-one entries. The v0.15
migration is append-only `ADD1/RETIRE0/SPLIT0` from the prior twenty-cell
profile. Every entry has a stable axis, proof bucket, indicator bucket, activity name, source path,
IR path, generated artifact path, evaluator path, and metric with denominator
one. The authoritative source activity set is
`examples/self-improvement-portfolio/main.gooo`.

The proof buckets are `FOUNDATION/COHERENCE/REGRESSION` at `4/12/5`.
The indicator buckets are `DRIVER/OUTCOME/GUARDRAIL` at `4/12/5`.
Changing a release, evaluator, or evidence artifact never changes those counts.

## Disposition

Each assessment starts with an explicit state. Release-backed `CLOSED` cells
are eligible only when the CI verifier confirms the release URL, tag, exact
target commit, immutable flag, asset URL, asset size, and asset SHA-256 digest.
`REFUTED` wins over `UNKNOWN`, and `UNKNOWN` wins over `CLOSED`.

An `UNKNOWN` record contains exactly these six fields:

`stage`, `step`, `reason`, `unknown_class`, `next_operation`, and `blocked_by`.

The current frontier closes reflexive-loop v0.2 integration, semantic merge
advice, and the OpenTofu plan path only after their immutable release evidence
passes the evaluator. It also closes release promotion only when the immutable
reflexive-loop v0.3 release carries internal lifecycle-final `PROMOTED`,
promotion, rollback-boundary, and immutable-target receipts. This does not
infer core semantic authority or independent external utility evidence.

The v0.11 frontier appends `IMPROVEMENT_FRONTIER_RELEASE`. It closes only
when the immutable `gooo-improvement-frontier@v0.1.0` release binds its
annotated tag target, source Actions run/job, downloaded receipt and source
archive bytes, and the receipt's fixed protocol result. Six failed upstream
implementation attempts remain append-only counterexample references and are
not included in the closure-gated release map.

The v0.12 frontier appends `AUTHORITY_BOOTSTRAP_RELEASE`. It closes only when
the immutable `gooo-authority-bootstrap@v0.1.0` release binds its annotated tag
target, successful required and post-main Actions runs, post-main artifact, all
six downloaded release assets, and the exact bootstrap receipt. The upstream
receipt's own `UNKNOWN` and `immutable=false` fields are preserved as source
data; the ledger cell records only the immutable release-adoption boundary.

The v0.13 frontier appends `OPENTOFU_ENVELOPE_RELEASE`. It closes only when
the immutable `gooo-opentofu-envelope@v0.1.1` release binds its annotated tag
target, successful PR and post-main Actions runs, post-main artifact, both
release assets, and the source envelope's exact 12-cell observation. The
mutable v0.1.0 release and its two failed CI runs remain append-only
`FAILED_RELEASE_IMMUTABILITY` and `FAILED_CI_VALIDATION` counterexamples.

The v0.14 frontier appends `IMPROVEMENT_PROPOSER_RELEASE`. It closes only when
the immutable `gooo-improvement-proposer@v0.1.1` release binds its annotated
tag object and target, successful release run `33397566380`, post-main
conformance run `33397372252`, post-main artifact `9759855868`, all four
release assets, the upstream 12-cell observation, and the six fixed output
artifacts per conformance case. The upstream v0.1.0 tag object/target and
failed run `33396465907`/job `99502048200` are retained as a separate
`FAILED_RELEASE_TRIGGER` with no release and cannot close the cell. Earlier
failed runs are not success evidence.

The v0.15 frontier appends `TEST_FRONTIER_RELEASE`. It closes only when the
immutable `gooo-test-frontier@v0.1.1` release binds tag object
`398577621c42eb7450416bdf086b9304c8c1e42a` to target
`f8e1f8aebb67abbda237073893a4a855a8659df5`, successful release/audit run
`33398545885`/job `99508911340`, post-main run `33398482775`/job
`99508698139`, artifact `9760281954`, and all three release assets. The
upstream protocol has 12 activities/cells, `4/4/4` proof and indicator totals,
10 cases (`3 CLOSED / 3 UNKNOWN / 4 REFUTED`), exact test totals
`40/9/16/10/5`, invalidated frontier 20, and zero product-authority writes,
local test executions, and cross-project gates. Its v0.1.0 release ID
`379770450` remains an append-only `REFUTED`
`SELF_ASSERTED_IMMUTABILITY_CONTRADICTED_BY_PLATFORM` counterexample because
the GitHub API reports `immutable=false`; the direct-main `7281ead` observation
is workflow-only with no pull request and is not confused with product state.

The non-completeness capability evidence registry is a separate seventeen-entry
external-input ledger. Its count and dispositions never alter this fixed
twenty-one-cell denominator; unavailable inputs remain `UNKNOWN`, while known
release/API or digest contradictions remain `REFUTED`.

## Authority and measurements

Runtime writes are limited to caller-owned temporary output. The source
checkout is snapshotted before and after CI work and must remain unchanged.
The report records `wall_ms` and raw `duration_ns` separately so sub-millisecond
runs do not disappear through rounding. Inventory lines are physical lines;
the root README is excluded from line accounting. CI also records exact build,
test, and peak-RSS observations in `ci-observations.json`. Developer-local
verification counts remain zero because all build, test, formatting, vet, and
conformance checks are performed by GitHub Actions.
