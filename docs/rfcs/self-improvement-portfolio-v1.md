# Self-improvement portfolio v1

## Scope

The portfolio is an evidence ledger for eighteen specifically named capabilities.
It is not a language-wide quality score, maturity score, or completeness claim.
The only aggregate values are exact state counts and fixed bucket counts.

## Fixed denominator

The source of truth is `contracts/self-improvement-portfolio-v1.json`. Its
`cells` array is immutable during a run and contains eighteen entries. The v0.12
migration is append-only `ADD1/RETIRE0/SPLIT0` from the prior seventeen-cell
profile. Every entry has a stable axis, proof bucket, indicator bucket, activity name, source path,
IR path, generated artifact path, evaluator path, and metric with denominator
one. The authoritative source activity set is
`examples/self-improvement-portfolio/main.gooo`.

The proof buckets are `FOUNDATION/COHERENCE/REGRESSION` at `4/9/5`.
The indicator buckets are `DRIVER/OUTCOME/GUARDRAIL` at `4/9/5`.
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

The non-completeness capability evidence registry is a separate seventeen-entry
external-input ledger. Its count and dispositions never alter this fixed
eighteen-cell denominator; unavailable inputs remain `UNKNOWN`, while known
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
