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

The checked-in assessment closes reflexive-loop v0.2 integration, semantic-
merge advice, the OpenTofu plan path, and release promotion from immutable
upstream evidence. Release promotion is closed only by the reflexive-loop
v0.3 internal lifecycle, promotion, rollback-boundary, and immutable-target
receipts; it does not imply core semantic authority or external utility.
It intentionally leaves only external utility evidence `UNKNOWN`. Core
semantic authority is now `REFUTED` by a fresh `pull_request_target` Guardian
runtime contradiction: `ReferenceError: beforeDigest is not defined` on the
open #609 feature PR. The previous core `UNKNOWN` record is preserved as an
append-only `UNKNOWN -> REFUTED` transition event. The live `UNKNOWN` cell
retains exactly `stage`, `step`, `reason`, `unknown_class`, `next_operation`,
and a minimal non-empty `blocked_by` frontier. A missing or contradictory
locked release cannot close a cell.

The core refutation binds the merged/admin migration receipt on dev commit
`7f45792e3c23100cbb10cca8b229132060982a7b`, successful dev CI #3405, the
`ci-guardian.yml` workflow blob, and the fresh #609 Guardian run, artifact, and
annotation. The not-yet-released receipt-schema-migration v0.2 work is tracked
as an optional dependency only; it is not a gate.

The separate `non-completeness-capability-evidence-registry-v1` records nine
independent evidence inputs without treating its entry count as the portfolio
denominator. Current registry disposition is `6 CLOSED / 0 UNKNOWN / 3
REFUTED`: the three historical v0.1.0 refutations remain preserved and are
linked to immutable v0.1.1 successor locks; the fourth new closed frontier is
the immutable receipt-schema-migration v0.1.1 input. These capability evidence
states do not change portfolio cells. The registry emits no completeness
percentage or score.

Successor closure requires matching REST release metadata, a successful
GraphQL release/tag lookup, the resolved tag target, every release asset's API
identity and downloaded SHA-256 digest, and any locked source Actions run and
artifact. The receipt-schema-migration successor additionally verifies the
adoption-proposal file digest and its declared proposal digest. Historical
`REFUTED` records are never deleted or promoted in place.

`contracts/release-locks-v1.json` pins the exact release URL, tag, target
commit, and consumer asset identities for the ten immutable inputs requested
by the portfolio. CI fetches every asset and verifies its exact size and SHA-256
digest before using it as cell evidence. The reflexive-loop v0.3 lock also
binds its source Actions artifact and upstream release-manifest lock digest.
A later immutable release updates the evidence lock and assessment input; it
does not change the 12-cell denominator.

GitHub Actions is the verification authority. The workflow uses Go 1.27 and
records integer directory/file counts, Go/Gooo physical files and lines (root
README excluded from line accounting), fetch/verify/report `wall_ms` plus raw
nanosecond durations, peak RSS, caller-owned artifact files/bytes, release
verified/unknown/refuted counts, zero runtime repository writes, and zero
developer-local gofmt/build/test/vet/conformance executions. It emits exact
closed/unknown/refuted counts and the complete human-readable cell table; it
does not emit a percentage or score.
