#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.55 product integration failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0550-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v0550-products"
parent_products="$artifact_root/v0550-parent-v0540-products"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0550-products-temp}"
work_root="$temp_root/v0550-product-work"
parent_product="$parent_products/product-integration.json"
assessment="$repository/evidence/assessment-v1.json"
wave_evidence="$repository/evidence/atomic-v0550-wave-v1.json"

mkdir -p "$artifact_root" "$temp_root"
rm -rf "$products" "$work_root"
mkdir -p "$products/output-authority" "$products/protected-change-gate" "$products/semantic-wave/upstream" "$products/semantic-wave/actual" "$work_root"
command -v gh >/dev/null
command -v go >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v awk >/dev/null
command -v wc >/dev/null
test -n "${GH_TOKEN:-}"
for required_file in "$parent_product" "$parent_products/output-authority/receipt.json" "$parent_products/protected-change-gate/receipt.json" "$parent_products/semantic-wave/receipt.json" "$parent_products/semantic-wave/upstream/wave-projection.json" "$parent_products/semantic-wave/upstream/wave-distribution.json" "$parent_products/semantic-wave/upstream/generated-assertions.json" "$parent_products/semantic-wave/upstream/replay-receipt.json" "$assessment" "$wave_evidence"; do
  test -s "$required_file"
done

sha256_prefixed() { printf 'sha256:%s\n' "$(sha256sum "$1" | awk '{print $1}')"; }
copy_parent_receipt() { cp "$1" "$2"; }

jq -e '
  .schema=="gooo/self-improvement-ledger/v0540-product-integration/v1" and
  .receipts.output_authority_projector.adoption_state=="CLOSED" and
  .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and
  .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and
  .claims.general_program_equivalence==false and .claims.whole_language_improvement=="UNKNOWN" and
  .claims.external_utility=="UNKNOWN" and .claims.improvement_aggregation=="NOT_CLAIMED" and
  .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS"}
' "$parent_product" >/dev/null

copy_parent_receipt "$parent_products/output-authority/receipt.json" "$products/output-authority/receipt.json"
copy_parent_receipt "$parent_products/protected-change-gate/receipt.json" "$products/protected-change-gate/receipt.json"
for wave_asset in wave-projection.json wave-distribution.json generated-assertions.json replay-receipt.json; do
  copy_parent_receipt "$parent_products/semantic-wave/upstream/$wave_asset" "$products/semantic-wave/upstream/$wave_asset"
done

jq -e '
  .schema=="gooo/self-improvement-ledger/v0540-output-authority-projector-receipt/v1" and
  .adoption_state=="CLOSED" and .release.release_id==380949449 and .release.immutable==true and
  .release.assets[0].id==540522209 and .release.assets[0].sha256=="sha256:699327a9f032258f4be0e4ff860f3253d5c2116541dccfa2da59a99e5a29b287" and
  .authority.repository_writes==0 and .authority.local_product_validation_executions==0
' "$products/output-authority/receipt.json" >/dev/null
jq -e '
  .schema=="gooo/self-improvement-ledger/v0540-protected-change-gate-projector-receipt/v1" and
  .adoption_state=="CLOSED" and .release.release_id==380957875 and .release.immutable==true and
  any(.release.assets[]; .id==540550228 and .sha256=="sha256:b837e97e298a1b9c33941ccc31f071273959645735667073a337163b9cbddf07") and
  .authority.repository_writes==0 and .authority.local_product_validation_executions==0
' "$products/protected-change-gate/receipt.json" >/dev/null

wave_receipt="$parent_products/semantic-wave/receipt.json"
wave_release_id=$(jq -r '.release.release_id' "$wave_receipt")
wave_asset_id=$(jq -r '.release.assets[0].id' "$wave_receipt")
wave_asset_name=$(jq -r '.release.assets[0].name' "$wave_receipt")
wave_asset_digest=$(jq -r '.asset_observed_digest' "$wave_receipt")
wave_target=$(jq -r '.release.target_commit_sha' "$wave_receipt")
test "$wave_release_id" = 380905719
test "$wave_asset_id" = 540372611
test "$wave_asset_name" = gooo-semantic-wave-merge-projector-v0.1.3.tar.gz
test "$wave_asset_digest" = sha256:fe55255e0337c8625f4c1fee42608fbcea20b3057f05a4f5370617147abf1744
test "$wave_target" = d1abdcba2e72ca8aaf2992887ede753884b88c7f

wave_archive="$work_root/$wave_asset_name"
wave_source_archive="$work_root/semantic-wave-source.tar.gz"
wave_release_root="$work_root/semantic-wave-release"
wave_source_root="$work_root/semantic-wave-source"
wave_cases="$work_root/semantic-wave-cases"
wave_bin="$work_root/semantic-wave-projector"
gh api -H 'Accept: application/octet-stream' "repos/kimjooyoon/gooo-semantic-wave-merge-projector/releases/assets/$wave_asset_id" > "$wave_archive"
test "$(sha256_prefixed "$wave_archive")" = "$wave_asset_digest"
test "$(wc -c <"$wave_archive" | tr -d ' ')" = "$(jq -r '.release.assets[0].size_bytes' "$wave_receipt")"
mkdir -p "$wave_release_root" "$wave_source_root" "$wave_cases"
tar --no-xattrs -xzf "$wave_archive" -C "$wave_release_root"
gh api -H 'Accept: application/vnd.github.raw+json' "repos/kimjooyoon/gooo-semantic-wave-merge-projector/tarball/$wave_target" > "$wave_source_archive"
tar --no-xattrs -xzf "$wave_source_archive" -C "$wave_source_root"
wave_source_dir=$(find "$wave_source_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
wave_release_dir=$(find "$wave_release_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$wave_source_dir"
test -n "$wave_release_dir"
wave_graph="$wave_source_dir/.gooo/semantic-wave-merge-projector.gooo"
test -s "$wave_graph"
cp "$wave_source_dir"/fixtures/cases/*.json "$wave_cases/"
test "$(find "$wave_cases" -type f -name '*.json' | wc -l | tr -d ' ')" = 12

jq -S -n --slurpfile wave "$wave_evidence" --arg output_digest "sha256:699327a9f032258f4be0e4ff860f3253d5c2116541dccfa2da59a99e5a29b287" --arg protected_digest "sha256:b837e97e298a1b9c33941ccc31f071273959645735667073a337163b9cbddf07" '
  . as $empty |
  ($wave[0].semantic_wave) as $semantic |
  {fixture_id:"independent-merge",expected_state:"CLOSED",base_ledger_digest:"ledger:wave-v1",evidence_digests:[$output_digest,$protected_digest],proposals:[
    {proposal_id:"proposal-cell-80",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","frontier-resolution/core-semantic-authority"],semantic_write_set:(($semantic.proposal_write_sets[]|select(.proposal_id=="proposal-cell-80")|.writes)),required_evidence_digests:[$output_digest,$protected_digest],tool_release_locks:[{tool_id:"OUTPUT_AUTHORITY_PROJECTOR",release_digest:$output_digest,mutable:false,verified:true},{tool_id:"PROTECTED_CHANGE_GATE_PROJECTOR",release_digest:$protected_digest,mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-81",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","frontier-resolution/semantic-drift-pr-first"],semantic_write_set:(($semantic.proposal_write_sets[]|select(.proposal_id=="proposal-cell-81")|.writes)),required_evidence_digests:[$protected_digest],tool_release_locks:[{tool_id:"PROTECTED_CHANGE_GATE_PROJECTOR",release_digest:$protected_digest,mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]}
  ]}
' > "$wave_cases/01-independent-merge.json"

jq -e --slurpfile wave "$wave_evidence" '
  .schema=="gooo/self-improvement-ledger/atomic-v0550-adoption-wave/v1" and
  .semantic_wave.fixture_mode=="REPLACE_NORMAL_FIXTURE" and .semantic_wave.scenario_denominator==12 and
  .semantic_wave.accepted_wave_order==["proposal-cell-80","proposal-cell-81"] and
  .semantic_wave.proposal_write_sets==[
    {proposal_id:"proposal-cell-80",writes:["cell/80","frontier-resolution-v2/core-semantic-authority"]},
    {proposal_id:"proposal-cell-81",writes:["cell/81","frontier-resolution-v2/semantic-drift-pr-first"]}
  ] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and
  .semantic_wave.new_release_lock_writes==0 and
  ([$wave[0].semantic_wave.proposal_write_sets[].writes[]|select(startswith("release-lock/"))]|length)==0
' "$wave_evidence" >/dev/null

jq -e '
  (.proposals|length)==2 and
  (([.proposals[].semantic_write_set[]] | unique | length) == ([.proposals[].semantic_write_set[]] | length)) and
  (([.proposals[].semantic_write_set[][] | select(startswith("release-lock/"))] | length) == 0)
' "$wave_cases/01-independent-merge.json" >/dev/null

(cd "$wave_source_dir" && go build -trimpath -o "$wave_bin" ./cmd/projector)
wave_cli="$products/semantic-wave/actual-cli-output.json"
/usr/bin/time -f '%M' -o "$products/semantic-wave/actual-peak-rss" "$wave_bin" generate --source "$wave_graph" --cases "$wave_cases" --output "$products/semantic-wave/actual" --root "$wave_source_dir" --reviewed-pr 4 --reviewed-merge-sha "$wave_target" --release-tag v0.1.3 > "$wave_cli"
jq -e '.decision=="CONFORMANT" and .scenario_denominator==12 and .closed==4 and .unknown==4 and .refuted==4 and .replay_match==true' "$wave_cli" >/dev/null
jq -e '
  .schema=="gooo/semantic-wave-merge-projector/wave-projection/v1" and
  .scenario_denominator==12 and (.cases|length)==12 and .state_counts=={total:12,closed:4,unknown:4,refuted:4} and
  .cases[0].case_id=="independent-merge" and .cases[0].state=="CLOSED" and
  .cases[0].accepted_wave==["proposal-cell-80","proposal-cell-81"] and
  .cases[0].deferred_frontier==[] and .cases[0].conflict_witnesses==null
' "$products/semantic-wave/actual/wave-projection.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/replay-receipt/v1" and .match==true and .immutable==true' "$products/semantic-wave/actual/replay-receipt.json" >/dev/null

actual_wave="$products/semantic-wave/actual/wave-projection.json"
actual_replay="$products/semantic-wave/actual/replay-receipt.json"
actual_cli="$products/semantic-wave/actual-cli-output.json"
actual_rss=$(cat "$products/semantic-wave/actual-peak-rss")
jq -S -n --arg asset_digest "$wave_asset_digest" --arg source_digest "$(sha256_prefixed "$wave_graph")" --arg target "$wave_target" --argjson rss "$actual_rss" --slurpfile parent "$wave_receipt" --slurpfile upstream "$products/semantic-wave/upstream/wave-projection.json" --slurpfile actual "$actual_wave" --slurpfile replay "$actual_replay" --slurpfile cli "$actual_cli" --slurpfile proposals "$wave_cases/01-independent-merge.json" '
  {schema:"gooo/self-improvement-ledger/v0550-semantic-wave-merge-receipt/v1",release:$parent[0].release,asset_observed_digest:$asset_digest,source:{target_commit_sha:$target,graph_digest:$source_digest,reviewed_pr:4,reviewed_merge_sha:$target,release_tag:"v0.1.3"},adoption_state:"CLOSED",fixed_suite:{scenario_denominator:12,upstream_state_counts:{total:12,closed:4,unknown:4,refuted:4},upstream_replay_match:true,parent_receipt_reused:true},upstream_release_evidence:$upstream[0],actual_projection:{cli:$cli[0],projection:$actual[0],replay:$replay[0],base_release:"v0.54.0",base_asset_digest:"sha256:e1b1dbd3f3e540ab88c9b62ade806d1154496439dfbeace2072cb162d1ae5a1c",fixture_mode:"REPLACE_NORMAL_FIXTURE",wall_ms:null,peak_rss_kib:$rss},proposal_envelopes:{count:2,write_sets:($proposals[0].proposals|map(.semantic_write_set)),accepted_wave_order:["proposal-cell-80","proposal-cell-81"],disjoint:true,conflict_witnesses:[],deferred_frontier:[],new_release_lock_writes:0},improvement:{state:"UNKNOWN",reason:"semantic wave confluence is not a same-scenario before-after performance claim"},external_utility:{state:"UNKNOWN"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' > "$products/semantic-wave/receipt.json"

jq -e --slurpfile assessment "$assessment" '
  .schema=="gooo/self-improvement-ledger/v0550-semantic-wave-merge-receipt/v1" and .adoption_state=="CLOSED" and
  .release.release_id==380905719 and .release.immutable==true and .release.assets[0].id==540372611 and
  .asset_observed_digest=="sha256:fe55255e0337c8625f4c1fee42608fbcea20b3057f05a4f5370617147abf1744" and
  .fixed_suite=={parent_receipt_reused:true,scenario_denominator:12,upstream_replay_match:true,upstream_state_counts:{closed:4,refuted:4,total:12,unknown:4}} and
  .actual_projection.fixture_mode=="REPLACE_NORMAL_FIXTURE" and .actual_projection.projection.scenario_denominator==12 and
  .actual_projection.projection.cases[0].accepted_wave==["proposal-cell-80","proposal-cell-81"] and
  .actual_projection.replay.match==true and .proposal_envelopes=={accepted_wave_order:["proposal-cell-80","proposal-cell-81"],conflict_witnesses:[],count:2,deferred_frontier:[],disjoint:true,new_release_lock_writes:0,write_sets:[["cell/80","frontier-resolution-v2/core-semantic-authority"],["cell/81","frontier-resolution-v2/semantic-drift-pr-first"]]} and
  .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,verification:"GITHUB_ACTIONS"} and
  any($assessment[0].refutation_resolution_events[]; .event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.55.0-V2" and .resolution_state=="CLOSED") and
  any($assessment[0].refutation_resolution_events[]; .event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.55.0-V2" and .resolution_state=="CLOSED")
' "$products/semantic-wave/receipt.json" >/dev/null

resolution_core=$(jq -c '.refutation_resolution_events[]|select(.event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.55.0-V2")' "$assessment")
resolution_drift=$(jq -c '.refutation_resolution_events[]|select(.event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.55.0-V2")' "$assessment")
jq -S -n --slurpfile parent "$parent_product" --slurpfile output "$products/output-authority/receipt.json" --slurpfile protected "$products/protected-change-gate/receipt.json" --slurpfile wave "$products/semantic-wave/receipt.json" --argjson core "$resolution_core" --argjson drift "$resolution_drift" '
  {schema:"gooo/self-improvement-ledger/v0550-product-integration/v1",products:["output_authority_projector_durable_release","protected_change_gate_projector_durable_release"],receipts:{output_authority_projector:$output[0],protected_change_gate_projector:$protected[0],semantic_wave_merge_projector:$wave[0]},parent_receipt_reuse:{source_release:"v0.54.0",source_release_id:380979192,output_authority:true,protected_change_gate:true,semantic_wave:true},frontier_resolutions:{core_semantic_authority:$core,semantic_drift_pull_request:$drift},claims:{general_program_equivalence:false,whole_language_improvement:"UNKNOWN",external_utility:"UNKNOWN",improvement_aggregation:"NOT_CLAIMED"},semantic_wave:$wave[0].proposal_envelopes,authority:{verification:"GITHUB_ACTIONS",token_source:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0},preserved_parent_product_integration_schema:$parent[0].schema}' > "$products/product-integration.json"

jq -e '
  .schema=="gooo/self-improvement-ledger/v0550-product-integration/v1" and
  .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.output_authority_projector.release.release_id==380949449 and
  .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.release.release_id==380957875 and
  .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.release.release_id==380905719 and
  .parent_receipt_reuse=={output_authority:true,protected_change_gate:true,semantic_wave:true,source_release:"v0.54.0",source_release_id:380979192} and
  .frontier_resolutions.core_semantic_authority.schema_version==2 and .frontier_resolutions.core_semantic_authority.resolution_state=="CLOSED" and
  .frontier_resolutions.semantic_drift_pull_request.schema_version==2 and .frontier_resolutions.semantic_drift_pull_request.resolution_state=="CLOSED" and
  .semantic_wave=={accepted_wave_order:["proposal-cell-80","proposal-cell-81"],conflict_witnesses:[],count:2,deferred_frontier:[],disjoint:true,new_release_lock_writes:0,write_sets:[["cell/80","frontier-resolution-v2/core-semantic-authority"],["cell/81","frontier-resolution-v2/semantic-drift-pr-first"]]} and
  .claims=={external_utility:"UNKNOWN",general_program_equivalence:false,improvement_aggregation:"NOT_CLAIMED",whole_language_improvement:"UNKNOWN"} and
  .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS"}
' "$products/product-integration.json" >/dev/null
echo "v0.55 products verified: immutable v0.54 receipts reused, semantic-wave v0.1.3 replayed with two disjoint V2 proposals, and V2 frontier resolutions CLOSED"
