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
semantic authority remains `REFUTED` by a fresh `pull_request_target` Guardian
runtime observation on the open #609 feature PR: the protected-path gate
preempted foundation authorization. The prior `ReferenceError: beforeDigest is
not defined` refutation is preserved in an append-only
`RESOLVED_BY_EXECUTABLE_GUARDIAN_SCOPE_ADOPTION` event. The live external
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

The separate `non-completeness-capability-evidence-registry-v1` records ten
independent evidence inputs without treating its entry count as the portfolio
denominator. Current registry disposition is `7 CLOSED / 0 UNKNOWN / 3
REFUTED`: the three historical v0.1.0 refutations remain preserved and are
linked to immutable v0.1.1 successor locks; the fourth new closed frontier is
the immutable receipt-schema-migration v0.1.1 input, followed by its immutable
v0.2.2 closed successor. These capability evidence states do not change
portfolio cells. The registry emits no completeness percentage or score.

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
