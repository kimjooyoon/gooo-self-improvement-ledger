#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.52 product integration failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0520-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v052-products"
temp_root="${RUNNER_TEMP:-$artifact_root/.v052-products-temp}"
rm -rf "$products" "$temp_root"
mkdir -p "$products" "$temp_root"

command -v gh >/dev/null
command -v go >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v awk >/dev/null
command -v wc >/dev/null
test -n "${GH_TOKEN:-}"

sha256_prefixed() {
  printf 'sha256:%s\n' "$(sha256sum "$1" | awk '{print $1}')"
}

file_bytes() {
  find "$1" -type f -exec wc -c {} + | awk 'END {print $1+0}'
}

file_count() {
  find "$1" -type f -print | wc -l | tr -d ' '
}

lock_json() {
  jq -c --arg key "$1" '.releases[$key]' "$repository/contracts/release-locks-v1.json"
}

copy_named() {
  source_root=$1
  name=$2
  destination=$3
  source_file=$(find "$source_root" -type f -name "$name" -print -quit)
  test -n "$source_file"
  cp "$source_file" "$destination"
}

echo "v0.52 products: reconcile bounded self-change compiler v0.2.1"
self_key=bounded_self_change_compiler_v2_durable_release
self_lock=$(lock_json "$self_key")
self_archive="$artifact_root/releases/$self_key/assets/gooo-bounded-self-change-compiler-v0.2.1-ci-evidence.tar.gz"
self_temp="$temp_root/bounded-self-change"
self_product="$products/bounded-self-change-compiler-v2"
mkdir -p "$self_temp" "$self_product"
tar --no-xattrs -xzf "$self_archive" -C "$self_temp"
copy_named "$self_temp" ci-evidence.json "$self_product/ci-evidence.json"
copy_named "$self_temp" cycle-manifest.json "$self_product/cycle-manifest.json"
copy_named "$self_temp" evidence-manifest.json "$self_product/evidence-manifest.json"
copy_named "$self_temp" frontier-receipt.json "$self_product/frontier-receipt.json"
copy_named "$self_temp" change-proposal.json "$self_product/change-proposal.json"
copy_named "$self_temp" test-impact-receipt.json "$self_product/test-impact-receipt.json"
copy_named "$self_temp" measurement-receipt.json "$self_product/measurement-receipt.json"
copy_named "$self_temp" next-wave-proposal.json "$self_product/next-wave-proposal.json"
jq -e '.schema=="gooo/bounded-self-change/cycle/v2" and .decision=="CLOSED" and .vector=={total:12,closed:4,unknown:4,refuted:4} and .authority.repository_writes==0 and .authority.local_test_executions==0 and .authority.cross_project_required_gates==0' "$self_product/cycle-manifest.json" >/dev/null
jq -e '.schema=="gooo/bounded-self-change/evidence-manifest/v2" and .decision=="CLOSED" and .vector=={total:12,closed:4,unknown:4,refuted:4}' "$self_product/evidence-manifest.json" >/dev/null
jq -S -n --argjson lock "$self_lock" --arg asset_digest "$(sha256_prefixed "$self_archive")" --slurpfile cycle "$self_product/cycle-manifest.json" --slurpfile manifest "$self_product/evidence-manifest.json" --slurpfile measurement "$self_product/measurement-receipt.json" --slurpfile frontier "$self_product/frontier-receipt.json" --slurpfile proposal "$self_product/change-proposal.json" --slurpfile impact "$self_product/test-impact-receipt.json" --slurpfile next "$self_product/next-wave-proposal.json" \
  '{schema:"gooo/self-improvement-ledger/v0520-bounded-self-change-receipt/v1",release:$lock,asset_observed_digest:$asset_digest,adoption_state:"CLOSED",released_evidence:{cycle_manifest:$cycle[0],evidence_manifest:$manifest[0],measurement_receipt:$measurement[0],frontier_receipt:$frontier[0],change_proposal:$proposal[0],test_impact_receipt:$impact[0],next_wave_proposal:$next[0]},improvement:{state:"UNKNOWN",reason:"no exact same scenario/source/contract/fixture/toolchain/runner before-after pair was supplied by this adoption"},external_utility:{state:"UNKNOWN",claim:"not aggregated"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' > "$self_product/receipt.json"

echo "v0.52 products: reconcile causal counterexample reducer v0.1.1"
reducer_key=causal_counterexample_reducer_durable_release
reducer_lock=$(lock_json "$reducer_key")
reducer_product="$products/causal-counterexample-reducer"
mkdir -p "$reducer_product"
reducer_asset="$artifact_root/releases/$reducer_key/assets/conformance-report.json"
cp "$reducer_asset" "$reducer_product/conformance-report.json"
jq -e '.schema=="gooo.causal-counterexample-reducer/conformance/v1" and .denominator_id=="causal-counterexample-reducer-v1" and .scenarios==7 and .closed==0 and .unknown==3 and .refuted==4 and .pass==true and .repository_writes==0 and .local_test_executions==0 and .cross_project_required_gates==0' "$reducer_product/conformance-report.json" >/dev/null
jq -S -n --argjson lock "$reducer_lock" --arg asset_digest "$(sha256_prefixed "$reducer_asset")" --slurpfile report "$reducer_product/conformance-report.json" \
  '{schema:"gooo/self-improvement-ledger/v0520-causal-counterexample-reducer-receipt/v1",release:$lock,asset_observed_digest:$asset_digest,adoption_state:"CLOSED",released_conformance:$report[0],preservation:{historical_refuted:4,historical_unknown:3,decision_improvement_aggregation:"NOT_CLAIMED"},improvement:{state:"UNKNOWN",reason:"reducer conformance is not a same-scenario before-after ledger measurement"},external_utility:{state:"UNKNOWN"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' > "$reducer_product/receipt.json"

echo "v0.52 products: reconcile bounded observational equivalence projector v0.1.2"
equivalence_key=bounded_observational_equivalence_durable_release
equivalence_lock=$(lock_json "$equivalence_key")
equivalence_archive="$artifact_root/releases/$equivalence_key/assets/gooo-bounded-observational-equivalence-evidence-v0.1.2.tar.gz"
equivalence_temp="$temp_root/bounded-observational-equivalence"
equivalence_product="$products/bounded-observational-equivalence"
mkdir -p "$equivalence_temp" "$equivalence_product"
tar --no-xattrs -xzf "$equivalence_archive" -C "$equivalence_temp"
copy_named "$equivalence_temp" evidence.json "$equivalence_product/evidence.json"
jq -e '.schema=="gooo.bounded-observational-equivalence/evidence/v1" and .authority=="github-actions" and .corpus=={total:11,normal:3,unknown:4,refuted:4} and .test_counts=={total:11,selected:11,executed:11,reused:0,failed:0,unknown:4} and .denominator=={foundation:4,coherence:4,regression:4,driver:4,outcome:4,guardrail:4} and .improvement.status=="UNKNOWN"' "$equivalence_product/evidence.json" >/dev/null
jq -S -n --argjson lock "$equivalence_lock" --arg asset_digest "$(sha256_prefixed "$equivalence_archive")" --slurpfile evidence "$equivalence_product/evidence.json" \
  '{schema:"gooo/self-improvement-ledger/v0520-bounded-observational-equivalence-receipt/v1",release:$lock,asset_observed_digest:$asset_digest,adoption_state:"CLOSED",released_evidence:$evidence[0],scope:{bounded_observations:true,general_program_equivalence:false},improvement:{state:"UNKNOWN",reason:"exact same scenario/source/contract/fixture/toolchain/runner integer before-after evidence is absent"},external_utility:{state:"UNKNOWN"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' > "$equivalence_product/receipt.json"

echo "v0.52 products: project four-envelope semantic wave with released v0.1.3 source"
wave_key=semantic_wave_merge_projector_durable_release
wave_lock=$(lock_json "$wave_key")
wave_archive="$artifact_root/releases/$wave_key/assets/gooo-semantic-wave-merge-projector-v0.1.3.tar.gz"
wave_temp="$temp_root/semantic-wave-release"
wave_product="$products/semantic-wave-merge"
mkdir -p "$wave_temp" "$wave_product/upstream" "$wave_product/actual"
tar --no-xattrs -xzf "$wave_archive" -C "$wave_temp"
for name in wave-projection.json wave-distribution.json generated-assertions.json replay-receipt.json report.md; do copy_named "$wave_temp" "$name" "$wave_product/upstream/$name"; done
events_file=$(find "$wave_temp" -type f -name projection-events.ndjson -print -quit)
test -n "$events_file"
cp "$events_file" "$wave_product/upstream/projection-events.ndjson"
jq -e '.schema=="gooo/semantic-wave-merge-projector/wave-projection/v1" and .scenario_denominator==12 and .state_counts=={total:12,closed:4,unknown:4,refuted:4} and .authority.repository_writes==0 and .authority.local_test_executions==0 and .authority.cross_project_required_gates==0' "$wave_product/upstream/wave-projection.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/wave-distribution/v1" and .states=={total:12,closed:4,unknown:4,refuted:4} and .direct_counts_only==true' "$wave_product/upstream/wave-distribution.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/replay-receipt/v1" and .state=="CLOSED" and .match==true and .normal_digest==.order_perturbed_digest and .immutable==true' "$wave_product/upstream/replay-receipt.json" >/dev/null

wave_source_archive="$temp_root/semantic-wave-source.tar.gz"
gh api -H 'Accept: application/vnd.github.raw+json' repos/kimjooyoon/gooo-semantic-wave-merge-projector/tarball/d1abdcba2e72ca8aaf2992887ede753884b88c7f > "$wave_source_archive"
wave_source_root="$temp_root/semantic-wave-source"
mkdir -p "$wave_source_root"
tar --no-xattrs -xzf "$wave_source_archive" -C "$wave_source_root"
wave_source_dir=$(find "$wave_source_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$wave_source_dir"
wave_source_graph="$wave_source_dir/.gooo/semantic-wave-merge-projector.gooo"
test -s "$wave_source_graph"
wave_cases="$temp_root/semantic-wave-cases"
mkdir -p "$wave_cases"
# The released graph has a fixed twelve-case denominator. Preserve its declared
# cases and replace the CLOSED independent-merge case with the four-envelope
# v0.52 wave fixture below.
cp "$wave_source_dir"/fixtures/cases/*.json "$wave_cases/"
jq -n --arg compiler "$(jq -r '.assets[0].sha256' <<< "$self_lock")" --arg reducer "$(jq -r '.assets[0].sha256' <<< "$reducer_lock")" --arg equivalence "$(jq -r '.assets[0].sha256' <<< "$equivalence_lock")" --arg wave "$(jq -r '.assets[0].sha256' <<< "$wave_lock")" '
  {fixture_id:"independent-merge",expected_state:"CLOSED",base_ledger_digest:"ledger:wave-v1",evidence_digests:[$compiler,$reducer,$equivalence,$wave],proposals:[
    {proposal_id:"proposal-cell-68",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","upstream/bounded-self-change"],semantic_write_set:["cell/68","release-lock/63"],required_evidence_digests:[$compiler],tool_release_locks:[{tool_id:"BOUNDED_SELF_CHANGE_COMPILER_V2",release_digest:$compiler,mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-69",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","upstream/causal-counterexample-reducer"],semantic_write_set:["cell/69","release-lock/64"],required_evidence_digests:[$reducer],tool_release_locks:[{tool_id:"CAUSAL_COUNTEREXAMPLE_REDUCER",release_digest:$reducer,mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-70",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","upstream/bounded-observational-equivalence"],semantic_write_set:["cell/70","release-lock/65"],required_evidence_digests:[$equivalence],tool_release_locks:[{tool_id:"BOUNDED_OBSERVATIONAL_EQUIVALENCE",release_digest:$equivalence,mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-71",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","upstream/semantic-wave-merge"],semantic_write_set:["cell/71","release-lock/66"],required_evidence_digests:[$wave],tool_release_locks:[{tool_id:"SEMANTIC_WAVE_MERGE_PROJECTOR",release_digest:$wave,mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]}
  ]}' > "$wave_cases/01-independent-merge.json"

wave_bin="$temp_root/semantic-wave-projector"
(cd "$wave_source_dir" && go build -trimpath -o "$wave_bin" ./cmd/projector)
wave_start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$wave_product/actual-peak-rss" "$wave_bin" generate --source "$wave_source_graph" --cases "$wave_cases" --output "$wave_product/actual" --root "$wave_source_dir" --reviewed-pr 4 --reviewed-merge-sha d1abdcba2e72ca8aaf2992887ede753884b88c7f --release-tag v0.1.3 > "$wave_product/actual-cli-output.json"
wave_end=$(date +%s%N)
wave_wall_ms=$(( (wave_end - wave_start) / 1000000 ))
if [ "$wave_wall_ms" -lt 1 ]; then wave_wall_ms=1; fi
jq -e '.decision=="CONFORMANT" and .scenario_denominator==12 and .closed==4 and .unknown==4 and .refuted==4 and .replay_match==true' "$wave_product/actual-cli-output.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/wave-projection/v1" and .scenario_denominator==12 and .state_counts=={total:12,closed:4,unknown:4,refuted:4} and .cases[0].case_id=="independent-merge" and .cases[0].state=="CLOSED" and .cases[0].accepted_wave==["proposal-cell-68","proposal-cell-69","proposal-cell-70","proposal-cell-71"] and .cases[0].deferred_frontier==[] and .cases[0].conflict_witnesses==null' "$wave_product/actual/wave-projection.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/replay-receipt/v1" and .match==true and .immutable==true' "$wave_product/actual/replay-receipt.json" >/dev/null
jq -S -n --argjson lock "$wave_lock" --arg asset_digest "$(sha256_prefixed "$wave_archive")" --arg source_digest "$(sha256_prefixed "$wave_source_graph")" --arg base_asset_digest "$(jq -r '.base_asset_digest' "$repository/evidence/atomic-v0520-wave-v1.json")" --argjson wall "$wave_wall_ms" --argjson rss "$(cat "$wave_product/actual-peak-rss")" --slurpfile upstream "$wave_product/upstream/wave-projection.json" --slurpfile actual "$wave_product/actual/wave-projection.json" --slurpfile replay "$wave_product/actual/replay-receipt.json" \
  '{schema:"gooo/self-improvement-ledger/v0520-semantic-wave-merge-receipt/v1",release:$lock,asset_observed_digest:$asset_digest,source:{target_commit_sha:"d1abdcba2e72ca8aaf2992887ede753884b88c7f",graph_digest:$source_digest,reviewed_pr:4,reviewed_merge_sha:"d1abdcba2e72ca8aaf2992887ede753884b88c7f",release_tag:"v0.1.3"},adoption_state:"CLOSED",upstream_release_evidence:$upstream[0],actual_projection:{projection:$actual[0],replay:$replay[0],base_release:"v0.51.0",base_asset_digest:$base_asset_digest,wall_ms:$wall,peak_rss_kib:$rss},proposal_envelopes:{count:4,write_sets:[["cell/68","release-lock/63"],["cell/69","release-lock/64"],["cell/70","release-lock/65"],["cell/71","release-lock/66"]],conflict_witnesses:[],deferred_frontier:[]},improvement:{state:"UNKNOWN",reason:"semantic wave confluence is not a same-scenario before-after performance claim"},external_utility:{state:"UNKNOWN"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' > "$wave_product/receipt.json"

echo "v0.52 products: emit candidate-only packaging measurements"
candidate="$temp_root/candidate-package"
mkdir -p "$candidate"
cp -a "$products/." "$candidate/"
cp "$repository/contracts/release-locks-v1.json" "$candidate/release-locks-v1.json"
cp "$repository/contracts/self-improvement-portfolio-v1.json" "$candidate/self-improvement-portfolio-v1.json"
candidate_start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$temp_root/candidate-peak-rss" tar --no-xattrs -czf "$temp_root/v0520-candidate-package.tar.gz" -C "$candidate" .
candidate_end=$(date +%s%N)
candidate_wall_ms=$(( (candidate_end - candidate_start) / 1000000 ))
if [ "$candidate_wall_ms" -lt 1 ]; then candidate_wall_ms=1; fi
candidate_files=$(file_count "$candidate")
candidate_bytes=$(file_bytes "$candidate")
candidate_rss=$(cat "$temp_root/candidate-peak-rss")
jq -S -n --argjson files "$candidate_files" --argjson bytes "$candidate_bytes" --argjson wall "$candidate_wall_ms" --argjson rss "$candidate_rss" \
  '{schema:"gooo/self-improvement-ledger/v0520-packaging-receipt/v1",candidate_only:true,baseline_published:false,candidate:{files:$files,bytes:$bytes,wall_ms:$wall,peak_rss_kib:$rss},baseline:{files:null,bytes:null,wall_ms:null,peak_rss_kib:null},improvement:{state:"UNKNOWN",reason:"no exact immutable v0.51-to-v0.52 package before-after pair is published"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' > "$products/packaging-receipt.json"

jq -S -n \
  --argjson self "$(cat "$self_lock")" --argjson reducer "$(cat "$reducer_lock")" --argjson equivalence "$(cat "$equivalence_lock")" --argjson wave "$(cat "$wave_lock")" \
  --slurpfile self_receipt "$self_product/receipt.json" --slurpfile reducer_receipt "$reducer_product/receipt.json" --slurpfile equivalence_receipt "$equivalence_product/receipt.json" --slurpfile wave_receipt "$wave_product/receipt.json" --slurpfile packaging "$products/packaging-receipt.json" \
  '{schema:"gooo/self-improvement-ledger/v0520-product-integration/v1",products:{bounded_self_change_compiler_v2:$self,causal_counterexample_reducer:$reducer,bounded_observational_equivalence:$equivalence,semantic_wave_merge:$wave},receipts:{bounded_self_change_compiler_v2:$self_receipt[0],causal_counterexample_reducer:$reducer_receipt[0],bounded_observational_equivalence:$equivalence_receipt[0],semantic_wave_merge:$wave_receipt[0],packaging:$packaging[0]},claims:{general_program_equivalence:false,aggregate_percentage:false,aggregate_score:false,whole_language_improvement:"UNKNOWN",external_utility:"UNKNOWN",candidate_release_immutable:false},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,cross_project_required_gates:0}}' > "$products/product-integration.json"
jq -e '.schema=="gooo/self-improvement-ledger/v0520-product-integration/v1" and .receipts.bounded_self_change_compiler_v2.adoption_state=="CLOSED" and .receipts.causal_counterexample_reducer.adoption_state=="CLOSED" and .receipts.bounded_observational_equivalence.adoption_state=="CLOSED" and .receipts.semantic_wave_merge.adoption_state=="CLOSED" and .claims.general_program_equivalence==false and .claims.aggregate_percentage==false and .claims.aggregate_score==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.external_utility=="UNKNOWN" and .authority.repository_writes==0' "$products/product-integration.json" >/dev/null
echo "v0.52 product integration passed: four immutable upstream receipts, one four-envelope CLOSED wave, and candidate-only packaging"
