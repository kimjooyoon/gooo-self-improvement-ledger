# Gooo self-improvement ledger

This repository records a deliberately narrow `self-improvement-portfolio-v1`
capability profile. It does not estimate the completeness of Gooo or any other
language. The denominator is exactly 12 named cells, each bound one-to-one to
one real `.gooo` activity, one semantic-IR location, one generated artifact,
and one evaluator binding.

The fixed axes are:

`CORE_SEMANTIC_AUTHORITY`, `RESOLUTION_DESCENT`, `CAUSAL_CI_SELECTION`,
`META_RESOURCE_BUDGET`, `DENOMINATOR_EVOLUTION`, `REFLEXIVE_LOOP`,
`IMMUTABLE_INPUT_INTEGRATION`, `SEMANTIC_MERGE_ADVICE`,
`DESIGN_CONSUMER_PATH`, `OPENTOFU_PLAN_PATH`, `RELEASE_PROMOTION`, and
`EXTERNAL_UTILITY_EVIDENCE`.

The profile keeps `FOUNDATION`, `COHERENCE`, and `REGRESSION` at `4/4/4`, and
`DRIVER`, `OUTCOME`, and `GUARDRAIL` at `4/4/4`. Every physical metric has a
denominator of `1`. Status precedence is `REFUTED > UNKNOWN > CLOSED`.

The checked-in assessment closes reflexive-loop v0.2 integration and semantic-
merge advice from their immutable upstream evidence. It intentionally leaves
these four cells `UNKNOWN`: core semantic authority, OpenTofu plan path,
release promotion, and external utility evidence.
Each retains exactly `stage`, `step`, `reason`, `unknown_class`,
`next_operation`, and a minimal non-empty `blocked_by` frontier. A missing or
contradictory locked release cannot close a cell.

`contracts/release-locks-v1.json` pins the exact release URL, tag, target
commit, and consumer asset identities for the eight immutable inputs requested
by the portfolio. CI fetches every asset and verifies its exact size and SHA-256
digest before using it as cell evidence. A later immutable release updates the
evidence lock and assessment input; it does not change the 12-cell denominator.

GitHub Actions is the verification authority. The workflow uses Go 1.27 and
records integer directory/file counts, Go/Gooo physical files and lines (root
README excluded from line accounting), fetch/verify/report `wall_ms` plus raw
nanosecond durations, peak RSS, caller-owned artifact files/bytes, release
verified/unknown/refuted counts, zero runtime repository writes, and zero
developer-local gofmt/build/test/vet/conformance executions. It emits exact
closed/unknown/refuted counts and the complete human-readable cell table; it
does not emit a percentage or score.
