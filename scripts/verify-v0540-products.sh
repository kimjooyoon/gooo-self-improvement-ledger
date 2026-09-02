#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.54 product integration failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0540-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v0540-products"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0540-products-temp}"
lock_file="$repository/contracts/release-locks-v1.json"
mkdir -p "$artifact_root" "$temp_root"
rm -rf "$products" "$temp_root/v0540-product-work"
mkdir -p "$products" "$temp_root/v0540-product-work"
command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v awk >/dev/null
command -v wc >/dev/null
command -v chmod >/dev/null
test -n "${GH_TOKEN:-}"

lock_json() { jq -c --arg key "$1" '.releases[$key]' "$lock_file"; }
sha256_prefixed() { printf 'sha256:%s\n' "$(sha256sum "$1" | awk '{print $1}')"; }

verify_release_metadata() {
  local lock_value=$1
  local release_repo release_id release_json
  release_repo=$(jq -r '.repository' <<<"$lock_value")
  release_id=$(jq -r '.release_id' <<<"$lock_value")
  release_json=$(gh api "repos/$release_repo/releases/$release_id")
  jq -e --argjson lock "$lock_value" '
    .id==$lock.release_id and .tag_name==$lock.tag and .draft==false and .prerelease==false and .immutable==true and
    ([.assets[]|{id,name,size_bytes:.size,digest:.digest}]|sort_by(.id)) == ($lock.assets|map({id,name,size_bytes,sha256:.sha256})|map({id,name,size_bytes, digest:.sha256})|sort_by(.id))
  ' <<<"$release_json" >/dev/null
}

fetch_locked_asset() {
  local lock_value=$1
  local asset_id=$2
  local destination=$3
  local expected_size expected_digest release_repo
  release_repo=$(jq -r '.repository' <<<"$lock_value")
  expected_size=$(jq -r --argjson id "$asset_id" '.assets[]|select(.id==$id)|.size_bytes' <<<"$lock_value")
  expected_digest=$(jq -r --argjson id "$asset_id" '.assets[]|select(.id==$id)|.sha256' <<<"$lock_value")
  test -n "$expected_size" -a -n "$expected_digest"
  gh api -H 'Accept: application/octet-stream' "repos/$release_repo/releases/assets/$asset_id" > "$destination"
  test "$(wc -c <"$destination" | tr -d ' ')" = "$expected_size"
  test "$(sha256_prefixed "$destination")" = "$expected_digest"
}

output_key=output_authority_projector_durable_release
output_lock=$(lock_json "$output_key")
verify_release_metadata "$output_lock"
output_dir="$products/output-authority"
mkdir -p "$output_dir"
output_binary="$output_dir/gooo-output-authority-projector"
output_sums="$output_dir/SHA256SUMS"
fetch_locked_asset "$output_lock" 540522209 "$output_binary"
fetch_locked_asset "$output_lock" 540522213 "$output_sums"
chmod 0755 "$output_binary"
caller_root="$temp_root/output-authority-caller"
mkdir -p "$caller_root"
"$output_binary" conformance --caller-root "$caller_root" --repository-root "$repository" --output "$caller_root/conformance.json"
cp "$caller_root/conformance.json" "$output_dir/conformance.json"
jq -e '
  (has("schema")|not) and .authority_identity=="gooo-output-authority-projector@0.1" and
  .authority_digest=="sha256:1e803f8b4528e1dc5694c38d8f37dc2e8fdd863ebbd4e840e409dc8b2cf4b8dd" and
  .status_precedence==["REFUTED","UNKNOWN","CLOSED"] and
  .proof_choice_counts=={COHERENCE:4,FOUNDATION:4,REGRESSION:4} and
  .indicator_counts=={DRIVER:4,GUARDRAIL:4,OUTCOME:4} and (.cases|length)==12 and
  ([.cases[]|{name,status:.decision.status}]|sort_by(.name))==[
    {name:"append-only-overwrite",status:"REFUTED"},{name:"deterministic-replay",status:"CLOSED"},
    {name:"missing-authority",status:"UNKNOWN"},{name:"overlapping-ownership",status:"UNKNOWN"},
    {name:"parent-traversal",status:"REFUTED"},{name:"repository-root-write",status:"REFUTED"},
    {name:"shared-temp-ancestor-deletion",status:"REFUTED"},{name:"sibling-deletion",status:"REFUTED"},
    {name:"stale-authority-digest",status:"UNKNOWN"},{name:"symlink-escape",status:"REFUTED"},
    {name:"valid-nested-output",status:"CLOSED"},{name:"valid-own-subtree-cleanup",status:"CLOSED"}
  ] and
  .metrics=={requested_paths:12,owned_roots:2,accepted_operations:3,unknown_operations:3,refuted_operations:6,ancestor_delete_attempts:1,sibling_overlap_attempts:2,repository_writes:0,destructive_operations_executed:0,generated_artifact_count:1,wall_ms:null,rss_bytes:null,measurement_status:"UNKNOWN"} and
  .external_utility.status=="UNKNOWN" and .performance_improvement.status=="UNKNOWN" and .local_validation_count==0 and
  (.operational_refuted_history|index("v0.1.0:SEMANTIC_REFUTED_MISSING_PROOF_INDICATOR_FIELDS"))!=null
' "$output_dir/conformance.json" >/dev/null
jq -S -n --argjson lock "$output_lock" --slurpfile conformance "$output_dir/conformance.json" \
  '{schema:"gooo/self-improvement-ledger/v0540-output-authority-projector-receipt/v1",release:$lock,adoption_state:"CLOSED",released_conformance:$conformance[0],claims:{bounded_output_authority:true,repository_writes:0,destructive_operations:0,general_program_equivalence:false,external_utility:"UNKNOWN",performance_improvement:"UNKNOWN"},preservation:{v0_1_0_semantic_refuted_predecessor:true,historical_refutations_preserved:true},authority:{verification:"GITHUB_ACTIONS",token_source:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$output_dir/receipt.json"

protected_key=protected_change_gate_projector_durable_release
protected_lock=$(lock_json "$protected_key")
verify_release_metadata "$protected_lock"
protected_dir="$products/protected-change-gate"
mkdir -p "$protected_dir"
for asset_name in conformance.json measurement.json replay.json SHA256SUMS; do
  asset_id=$(jq -r --arg name "$asset_name" '.assets[]|select(.name==$name)|.id' <<<"$protected_lock")
  fetch_locked_asset "$protected_lock" "$asset_id" "$protected_dir/$asset_name"
done
jq -e '
  .schema=="gooo.protected-change-gate-projector/v0.1" and
  .proof_choice_counts=={COHERENCE:4,FOUNDATION:4,REGRESSION:4} and
  .indicator_counts=={DRIVER:4,GUARDRAIL:4,OUTCOME:4} and (.cases|length)==12 and
  ([.cases[]|{name,proof_choice,indicator}]|sort_by(.name))==[
    {name:"attempt_to_replace_immutable_asset",proof_choice:"REGRESSION",indicator:"OUTCOME"},
    {name:"direct_main_implementation",proof_choice:"FOUNDATION",indicator:"OUTCOME"},
    {name:"direct_main_release_plumbing",proof_choice:"FOUNDATION",indicator:"OUTCOME"},
    {name:"interrupted_release_resumed_by_exact_release_id_without_recreation",proof_choice:"REGRESSION",indicator:"GUARDRAIL"},
    {name:"lightweight_instead_of_annotated_tag",proof_choice:"COHERENCE",indicator:"DRIVER"},
    {name:"main_ci_stale",proof_choice:"COHERENCE",indicator:"GUARDRAIL"},
    {name:"normal_implementation_pr_path",proof_choice:"FOUNDATION",indicator:"DRIVER"},
    {name:"normal_maintenance_pr_path",proof_choice:"FOUNDATION",indicator:"DRIVER"},
    {name:"pr_ci_missing",proof_choice:"COHERENCE",indicator:"OUTCOME"},
    {name:"publish_before_asset_verification",proof_choice:"REGRESSION",indicator:"GUARDRAIL"},
    {name:"publish_before_policy",proof_choice:"REGRESSION",indicator:"GUARDRAIL"},
    {name:"tag_target_mismatch",proof_choice:"COHERENCE",indicator:"DRIVER"}
  ] and
  ([.cases[].projection.decision]|group_by(.)|map({key:.[0],value:length})|from_entries)=={CLOSED:3,UNKNOWN:2,REFUTED:7} and
  ([.cases[]|select(.name=="normal_implementation_pr_path" or .name=="normal_maintenance_pr_path" or .name=="interrupted_release_resumed_by_exact_release_id_without_recreation")|.projection.decision]|sort)==["CLOSED","CLOSED","CLOSED"] and
  ([.cases[]|select(.name=="direct_main_implementation" or .name=="direct_main_release_plumbing" or .name=="lightweight_instead_of_annotated_tag" or .name=="tag_target_mismatch" or .name=="publish_before_policy" or .name=="publish_before_asset_verification" or .name=="attempt_to_replace_immutable_asset")|.projection.decision]|sort)==["REFUTED","REFUTED","REFUTED","REFUTED","REFUTED","REFUTED","REFUTED"] and
  (.operational_history|length)==10 and all(.[];.classification=="OPERATIONAL_REFUTED") and any(.[];.release_id==380952007 and .tag=="v0.1.0")
' "$protected_dir/conformance.json" >/dev/null
jq -e '
  .schema=="gooo.protected-change-gate-projector/v0.1" and (.cases|length)==12 and
  all(.cases[]; .projection.measurement.state=="UNKNOWN" and .projection.measurement.wall_ms==null and .projection.measurement.rss_bytes==null) and
  ({events_observed:([.cases[].projection.metrics.events_observed]|add),gates_required:([.cases[].projection.metrics.gates_required]|add),gates_closed:([.cases[].projection.metrics.gates_closed]|add),gates_unknown:([.cases[].projection.metrics.gates_unknown]|add),gates_refuted:([.cases[].projection.metrics.gates_refuted]|add),direct_main_events:([.cases[].projection.metrics.direct_main_events]|add),recreated_artifact_attempts:([.cases[].projection.metrics.recreated_artifact_attempts]|add),accepted_resume_operations:([.cases[].projection.metrics.accepted_resume_operations]|add),repository_writes:([.cases[].projection.metrics.repository_writes]|add),remote_mutations:([.cases[].projection.metrics.remote_mutations]|add),destructive_operations:([.cases[].projection.metrics.destructive_operations]|add)})=={events_observed:92,gates_required:144,gates_closed:82,gates_unknown:2,gates_refuted:7,direct_main_events:2,recreated_artifact_attempts:1,accepted_resume_operations:1,repository_writes:0,remote_mutations:0,destructive_operations:0} and
  all(.cases[]; .projection.utility_improvement.state=="UNKNOWN" and .projection.metrics.repository_writes==0 and .projection.metrics.remote_mutations==0 and .projection.metrics.destructive_operations==0)
' "$protected_dir/measurement.json" >/dev/null
jq -e --slurpfile conformance "$protected_dir/conformance.json" '
  .schema=="gooo.protected-change-gate-projector/v0.1" and (.cases|length)==12 and
  ([.cases[]|{name,status:.projection.decision}]|sort_by(.name))==($conformance[0].cases|map({name,status:.projection.decision})|sort_by(.name)) and
  all(.cases[]; .projection.metrics.repository_writes==0 and .projection.metrics.remote_mutations==0 and .projection.metrics.destructive_operations==0)
' "$protected_dir/replay.json" >/dev/null
jq -S -n --argjson lock "$protected_lock" --slurpfile conformance "$protected_dir/conformance.json" --slurpfile measurement "$protected_dir/measurement.json" --slurpfile replay "$protected_dir/replay.json" \
  '{schema:"gooo/self-improvement-ledger/v0540-protected-change-gate-projector-receipt/v1",release:$lock,adoption_state:"CLOSED",released:{conformance:$conformance[0],measurement:$measurement[0],replay:$replay[0]},claims:{normal_implementation_path:"CLOSED",normal_maintenance_path:"CLOSED",direct_main_counterexamples:"REFUTED",immutable_asset_replacement:"REFUTED",external_utility:"UNKNOWN",improvement:"UNKNOWN",general_program_equivalence:false},preservation:{mutable_v0_1_0_predecessor:true,operational_refuted_history_count:10,historical_refutations_preserved:true},authority:{verification:"GITHUB_ACTIONS",token_source:"github.token",repository_writes:0,remote_mutations:0,destructive_operations:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$protected_dir/receipt.json"

wave_key=semantic_wave_merge_projector_durable_release
wave_lock=$(lock_json "$wave_key")
verify_release_metadata "$wave_lock"
wave_dir="$products/semantic-wave"
wave_temp="$temp_root/v0540-product-work/semantic-wave"
mkdir -p "$wave_dir/upstream" "$wave_temp"
wave_asset_id=$(jq -r '.assets[0].id' <<<"$wave_lock")
wave_archive="$wave_temp/semantic-wave.tar.gz"
fetch_locked_asset "$wave_lock" "$wave_asset_id" "$wave_archive"
tar --no-xattrs -xzf "$wave_archive" -C "$wave_temp"
copy_named() { local search_root=$1 asset_name=$2 destination=$3; local source_file; source_file=$(find "$search_root" -type f -name "$asset_name" -print -quit); test -n "$source_file"; cp "$source_file" "$destination"; }
for asset_name in wave-projection.json wave-distribution.json generated-assertions.json replay-receipt.json report.md; do
  copy_named "$wave_temp" "$asset_name" "$wave_dir/upstream/$asset_name"
done
jq -e '.schema=="gooo/semantic-wave-merge-projector/wave-projection/v1" and .scenario_denominator==12 and .state_counts=={total:12,closed:4,unknown:4,refuted:4} and .authority.repository_writes==0 and .authority.local_test_executions==0 and .authority.cross_project_required_gates==0' "$wave_dir/upstream/wave-projection.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/wave-distribution/v1" and .states=={total:12,closed:4,unknown:4,refuted:4} and .direct_counts_only==true' "$wave_dir/upstream/wave-distribution.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/replay-receipt/v1" and .state=="CLOSED" and .match==true and .normal_digest==.order_perturbed_digest and .immutable==true' "$wave_dir/upstream/replay-receipt.json" >/dev/null
jq -e '(.schema|startswith("gooo/")) and (if has("assertions") then all(.assertions[];.pass==true) else true end)' "$wave_dir/upstream/generated-assertions.json" >/dev/null
jq -S '{schema:"gooo/self-improvement-ledger/v0540-semantic-wave-proposals/v1",base_release:.semantic_wave.base_release,base_asset_digest:.semantic_wave.base_asset_digest,accepted_wave_order:.semantic_wave.accepted_wave_order,proposal_write_sets:.semantic_wave.proposal_write_sets,conflict_witnesses:.semantic_wave.conflict_witnesses,deferred_frontier:.semantic_wave.deferred_frontier,state:.semantic_wave.state,authority:.authority}' "$repository/evidence/atomic-v0540-wave-v1.json" > "$wave_dir/v0540-proposals.json"
jq -e '.schema=="gooo/self-improvement-ledger/v0540-semantic-wave-proposals/v1" and .base_release=="v0.53.0" and .accepted_wave_order==["proposal-cell-76","proposal-cell-77","proposal-cell-78","proposal-cell-79"] and (.proposal_write_sets|length)==4 and .conflict_witnesses==[] and .deferred_frontier==[] and .state=="CLOSED" and .authority.repository_writes==0' "$wave_dir/v0540-proposals.json" >/dev/null
jq -S -n --argjson lock "$wave_lock" --arg asset_digest "$(sha256_prefixed "$wave_archive")" --slurpfile projection "$wave_dir/upstream/wave-projection.json" --slurpfile distribution "$wave_dir/upstream/wave-distribution.json" --slurpfile assertions "$wave_dir/upstream/generated-assertions.json" --slurpfile replay "$wave_dir/upstream/replay-receipt.json" --slurpfile proposals "$wave_dir/v0540-proposals.json" \
  '{schema:"gooo/self-improvement-ledger/v0540-semantic-wave-merge-receipt/v1",release:$lock,asset_observed_digest:$asset_digest,adoption_state:"CLOSED",upstream:{projection:$projection[0],distribution:$distribution[0],generated_assertions:$assertions[0],replay:$replay[0]},v0540_proposals:$proposals[0],claims:{four_envelope_serializability:true,replay_match:true,general_program_equivalence:false,external_utility:"UNKNOWN",improvement_aggregation:"NOT_CLAIMED"},preservation:{base_release:"v0.53.0",historical_refutations_preserved:true},authority:{verification:"GITHUB_ACTIONS",token_source:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$wave_dir/receipt.json"

jq -S -n --argjson output_lock "$output_lock" --argjson protected_lock "$protected_lock" --argjson wave_lock "$wave_lock" \
  --slurpfile output_receipt "$output_dir/receipt.json" --slurpfile protected_receipt "$protected_dir/receipt.json" --slurpfile wave_receipt "$wave_dir/receipt.json" \
  --slurpfile wave "$repository/evidence/atomic-v0540-wave-v1.json" \
  '{schema:"gooo/self-improvement-ledger/v0540-product-integration/v1",
    products:["output_authority_projector_durable_release","protected_change_gate_projector_durable_release"],
    receipts:{output_authority_projector:$output_receipt[0],protected_change_gate_projector:$protected_receipt[0],semantic_wave_merge_projector:$wave_receipt[0]},
    supporting_release_locks:{output_authority_projector:$output_lock,protected_change_gate_projector:$protected_lock,semantic_wave_merge_projector:$wave_lock},
    frontier_resolutions:{core_semantic_authority:{state:"CLOSED",case:"normal_implementation_pr_path",historical_refutation_preserved:true},semantic_drift_pull_request:{state:"CLOSED",case:"normal_maintenance_pr_path",historical_refutation_preserved:true}},
    claims:{general_program_equivalence:false,whole_language_improvement:"UNKNOWN",external_utility:"UNKNOWN",improvement_aggregation:"NOT_CLAIMED"},
    semantic_wave:$wave[0].semantic_wave,
    authority:{verification:"GITHUB_ACTIONS",token_source:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$products/product-integration.json"
jq -e '.schema=="gooo/self-improvement-ledger/v0540-product-integration/v1" and (.products|length)==2 and ([.receipts|keys[]|select(.=="output_authority_projector" or .=="protected_change_gate_projector" or .=="semantic_wave_merge_projector")]|length)==3 and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .frontier_resolutions.core_semantic_authority.state=="CLOSED" and .frontier_resolutions.semantic_drift_pull_request.state=="CLOSED" and all(.frontier_resolutions[];.historical_refutation_preserved==true) and .claims=={external_utility:"UNKNOWN",general_program_equivalence:false,improvement_aggregation:"NOT_CLAIMED",whole_language_improvement:"UNKNOWN"} and .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS"}' "$products/product-integration.json" >/dev/null
echo "v0.54 products verified: output authority CLOSED, protected change gate CLOSED, semantic wave CLOSED, historical refutations preserved"
