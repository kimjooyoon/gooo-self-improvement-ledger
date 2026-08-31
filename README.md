# Gooo self-improvement ledger

This repository records a deliberately narrow `self-improvement-portfolio-v1`
capability profile. It does not estimate the completeness of Gooo or any other
language. The denominator is exactly 17 named cells, each bound one-to-one to
one real `.gooo` activity, one semantic-IR location, one generated artifact,
and one evaluator binding.

The fixed axes are:

`CORE_SEMANTIC_AUTHORITY`, `RESOLUTION_DESCENT`, `CAUSAL_CI_SELECTION`,
`META_RESOURCE_BUDGET`, `DENOMINATOR_EVOLUTION`, `REFLEXIVE_LOOP`,
`IMMUTABLE_INPUT_INTEGRATION`, `SEMANTIC_MERGE_ADVICE`,
`DESIGN_CONSUMER_PATH`, `OPENTOFU_PLAN_PATH`, `RELEASE_PROMOTION`,
`EXTERNAL_UTILITY_EVIDENCE`, `COUNTERFACTUAL_CHANGE_RELEASE`,
`VERIFICATION_REUSE_RELEASE`, `SEMANTIC_DRIFT_RELEASE`, and
`SEMANTIC_DRIFT_DEVELOPMENT_PROCESS`, and `IMPROVEMENT_FRONTIER_RELEASE`.

The denominator migration is explicit and append-only: `16 -> 17` with
`ADD1/RETIRE0/SPLIT0`. The proof buckets are `FOUNDATION/COHERENCE/REGRESSION`
`4/8/5`, and the indicator buckets are `DRIVER/OUTCOME/GUARDRAIL` `4/8/5`.
Every physical metric has a denominator of `1`. Status precedence is
`REFUTED > UNKNOWN > CLOSED`.

The checked-in assessment closes reflexive-loop v0.2 integration, semantic-
merge advice, the OpenTofu plan path, and release promotion from immutable
upstream evidence. Release promotion is closed only by the reflexive-loop
v0.3 internal lifecycle, promotion, rollback-boundary, and immutable-target
receipts; it does not imply core semantic authority or external utility.
It intentionally leaves only external utility evidence `UNKNOWN`. Core
semantic authority remains `REFUTED` by a fresh `pull_request_target` Guardian
runtime observation on the open #609 feature PR: the protected-path gate
preempted foundation authorization. The prior `ReferenceError: beforeDigest is
not defined` refutation is preserved in an append-only
`RESOLVED_BY_EXECUTABLE_GUARDIAN_SCOPE_ADOPTION` event. v0.9 appends a second
CORE observation without replacing either prior event: candidate PR #615 is
still open and unmerged, while two same-head CI attempts reproduce the known
`KNOWN_VERIFICATION_CONTRADICTION` `OPERATION_DURATION_NEGATIVE` result. This
is a `REFUTED` verification contradiction, not an `UNKNOWN` state. The
append-only frontier records `CI_EFFORT_OBSERVATION` /
`DERIVE_OPERATION_DURATION` and the next operation is to publish the CI time
causality protocol with exact clock-domain semantics. The new protocol is
tracked only as an unreleased, non-required optional dependency.
The four release-adoption cells close only from exact immutable release evidence:
`gooo-counterfactual-change@v0.1.2` release `379663025`,
`gooo-verification-reuse@v0.1.2` release `379662322`, and
`gooo-semantic-drift@v0.1.1` release `379664434`, plus
`gooo-improvement-frontier@v0.1.0` release `379728340`. Their full release
IDs, annotated tag objects, targets, source Actions runs/jobs, source artifact
IDs, asset IDs, sizes, URLs, and SHA-256 digests are locked in
`contracts/release-locks-v1.json` and re-fetched by CI. The improvement-frontier
receipt is also matched field-for-field, including 5 executed tests, 3950 ms
build time, 1770 ms test time, 282632 KiB peak RSS, and zero product-authority
writes, local test executions, and cross-project required gates.

`SEMANTIC_DRIFT_DEVELOPMENT_PROCESS` remains `REFUTED` independently of the
successful product release: substantive commit
`e83e42611eeed30100018a98c1f1835e1f17b821` landed directly on the upstream
`main` line without a pull request. This process deviation is preserved in a
separate `process_deviations` record and is not erased by release success.
The live external
`UNKNOWN` cell
retains exactly `stage`, `step`, `reason`, `unknown_class`, `next_operation`,
and a minimal non-empty `blocked_by` frontier. A missing or contradictory
locked release cannot close a cell.

The resolved event binds merged/admin PR #614, dev commit
`e440cbc99f24ceb8385f1b89c70f8cdada10cdbb`, successful dev CI #3408, and its
proof artifact. The current refutation binds the fresh #609 Guardian run
`33359548617`, job `99388126433`, exact base/head/merge-base tuple, 92 changed
files, and 26 protected kernel paths; its foundation, digest, and stage
observations are null because dispatch stopped at the protected-path gate. The
receipt-schema-migration v0.2.2 immutable release is locked as supporting
evidence, while the not-yet-released v0.3 work is tracked as an optional
dependency only and is not a gate.

The separate `non-completeness-capability-evidence-registry-v1` records
seventeen independent evidence inputs without treating its entry count as the portfolio
denominator. Current registry disposition is `13 CLOSED / 0 UNKNOWN / 4
REFUTED`: the three historical v0.1.0 refutations remain preserved and are
linked to immutable v0.1.1 successor locks; the immutable receipt-schema-
migration v0.1.1 input is followed by v0.2.2 and v0.3.1 closed successors; and
the semantic-observer v0.1.0 receipt-digest defect remains a preserved
refuted baseline linked to corrected v0.1.1 evidence. The registry also
records immutable adoption-transaction, self-repair-example, and
adoption-regression inputs. These capability evidence states do not change
portfolio cells. The registry emits no completeness percentage or score.

The release lock also preserves four mutable predecessor releases as exact,
append-only counterexamples: counterfactual-change v0.1.0 and v0.1.1,
verification-reuse v0.1.1, and semantic-drift v0.1.0. They remain refuted by
`immutable=false` and are never used as closure evidence.

Successor closure requires matching REST release metadata, a successful
GraphQL release/tag lookup, the resolved tag target, every release asset's API
identity and downloaded SHA-256 digest, and any locked source Actions run and
artifact. The receipt-schema-migration successor additionally verifies the
adoption-proposal file digest and its declared proposal digest. Historical
`REFUTED` records are never deleted or promoted in place.

`contracts/release-locks-v1.json` pins the exact release URL, tag, target
commit, and consumer asset identities for the fourteen immutable inputs
requested by the portfolio. CI fetches every asset and verifies its exact size and SHA-256
digest before using it as cell evidence. It also verifies the six failed
improvement-frontier upstream attempts as append-only counterexample
references; those runs are never closure-gated. The reflexive-loop v0.3 lock also
binds its source Actions artifact and upstream release-manifest lock digest.
A later immutable release updates the evidence lock and assessment input; it
does not change the 17-cell denominator.

GitHub Actions is the verification authority. The workflow uses Go 1.27 and
records integer directory/file counts, Go/Gooo physical files and lines (root
README excluded from line accounting), fetch/verify/report `wall_ms` plus raw
nanosecond durations, peak RSS, caller-owned artifact files/bytes, release
verified/unknown/refuted counts, zero runtime repository writes, and zero
developer-local gofmt/build/test/vet/conformance executions. It also uploads
exact CI build/test commands, durations, test-event counts, and peak-RSS
observations in `ci-observations.json`. It emits exact
closed/unknown/refuted counts and the complete human-readable cell table; it
does not emit a percentage or score.
