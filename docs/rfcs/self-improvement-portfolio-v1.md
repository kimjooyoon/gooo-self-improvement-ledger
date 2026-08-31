# Self-improvement portfolio v1

## Scope

The portfolio is an evidence ledger for twelve specifically named capabilities.
It is not a language-wide quality score, maturity score, or completeness claim.
The only aggregate values are exact state counts and fixed bucket counts.

## Fixed denominator

The source of truth is `contracts/self-improvement-portfolio-v1.json`. Its
`cells` array is immutable during a run and contains twelve entries. Every entry
has a stable axis, proof bucket, indicator bucket, activity name, source path,
IR path, generated artifact path, evaluator path, and metric with denominator
one. The authoritative source activity set is
`examples/self-improvement-portfolio/main.gooo`.

The proof buckets are four each: `FOUNDATION`, `COHERENCE`, and `REGRESSION`.
The indicator buckets are four each: `DRIVER`, `OUTCOME`, and `GUARDRAIL`.
Changing a release, evaluator, or evidence artifact never changes those counts.

## Disposition

Each assessment starts with an explicit state. Release-backed `CLOSED` cells
are eligible only when the CI verifier confirms the release URL, tag, exact
target commit, immutable flag, asset URL, asset size, and asset SHA-256 digest.
`REFUTED` wins over `UNKNOWN`, and `UNKNOWN` wins over `CLOSED`.

An `UNKNOWN` record contains exactly these six fields:

`stage`, `step`, `reason`, `unknown_class`, `next_operation`, and `blocked_by`.

The current frontier closes reflexive-loop v0.2 integration and semantic merge
advice, and the OpenTofu plan path only after their immutable release evidence
passes the evaluator. It does not infer success for core promotion, release
promotion, or independent external utility evidence.

## Authority and measurements

Runtime writes are limited to caller-owned temporary output. The source
checkout is snapshotted before and after CI work and must remain unchanged.
The report records `wall_ms` and raw `duration_ns` separately so sub-millisecond
runs do not disappear through rounding. Inventory lines are physical lines;
the root README is excluded from line accounting. Developer-local verification
counts remain zero because all build, test, formatting, vet, and conformance
checks are performed by GitHub Actions.
