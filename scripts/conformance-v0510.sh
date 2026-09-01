#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.51 conformance failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 3 ]; then
  echo "usage: conformance-v0510.sh REPORT_BINARY REPOSITORY_ROOT ARTIFACT_ROOT" >&2
  exit 64
fi

binary=$(realpath "$1")
repository=$(realpath "$2")
artifact=$(realpath "$3")
probe=$(mktemp -d)
mkdir -p "$probe"

command -v jq >/dev/null
command -v sha256sum >/dev/null
test -x "$binary"
test -s "$artifact/releases/verification.json"

echo "v0.51 conformance: verify append-only 67-cell profile"
jq -e '
  .schema == "gooo/self-improvement-portfolio/contract/v1" and
  .profile_id == "self-improvement-portfolio-v1" and
  .total_cells == 67 and
  .denominator_migration == {from:53,to:67,add:14,retire:0,split:0,append_only:true} and
  .proof_totals == {FOUNDATION:4,COHERENCE:58,REGRESSION:5} and
  .indicator_totals == {DRIVER:4,OUTCOME:58,GUARDRAIL:5} and
  .precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .policy == {denominator_mutation_during_run:false,status_inference_from_missing_evidence:false,runtime_repository_writes:0,caller_owned_temp_output_only:true,cross_project_required_gates:0,aggregate_percentage:false,aggregate_score:false} and
  (.cells|length) == 67 and
  ([.cells[-3:][] | {ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}] == [
    {ordinal:65,id:"MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE",axis:"MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptMeasurementBoundaryV2ProjectorDurableRelease",evaluator:"measurement-boundary-v2-projector",metric_denominator:1,release_key:"measurement_boundary_v2_projector_durable_release"},
    {ordinal:66,id:"OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE",axis:"OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptOperationalProvenanceProjectorDurableRelease",evaluator:"operational-provenance-projector",metric_denominator:1,release_key:"operational_provenance_projector_durable_release"},
    {ordinal:67,id:"SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE",axis:"SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptSelfImprovementFrontierProjectorDurableRelease",evaluator:"self-improvement-frontier-projector",metric_denominator:1,release_key:"self_improvement_frontier_projector_durable_release"}
  ])
' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null

echo "v0.51 conformance: verify assessment and lock identities"
jq -e '
  .schema == "gooo/self-improvement-portfolio/assessment/v1" and
  .profile_id == "self-improvement-portfolio-v1" and
  (.cells|length) == 67 and
  ([.cells[-3:][] | {cell_id,state,release_key}] == [
    {cell_id:"MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"measurement_boundary_v2_projector_durable_release"},
    {cell_id:"OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"operational_provenance_projector_durable_release"},
    {cell_id:"SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"self_improvement_frontier_projector_durable_release"}
  ])
' "$repository/evidence/assessment-v1.json" >/dev/null
jq -e '
  .schema == "gooo/self-improvement-ledger/release-locks/v1" and
  (.releases|length) == 62 and
  .releases.measurement_boundary_v2_projector_durable_release == {
    repository:"kimjooyoon/gooo-measurement-boundary-projector",tag:"v0.2.0",release_id:380839207,immutable:true,
    tag_object_sha:"1bacf104da7ea9d6cf3ebd130801608b8e5afb14",target_commit_sha:"1cff6318e748fec494dd9d28ec65db98b94293e0",
    assets:[
      {id:540176712,name:"gooo-measurement-boundary-projector-v0.2.0.tar.gz",size_bytes:50378,sha256:"sha256:90acd1f0a56ab38afe6c2b2b2033bd48b361b9dc43dc1257f606568f89076658",download_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/download/v0.2.0/gooo-measurement-boundary-projector-v0.2.0.tar.gz"},
      {id:540176709,name:"release-manifest.json",size_bytes:2012,sha256:"sha256:f4513680b4603f1bf3a5429c652a1d3218ea0854ab7847eabd95c734f46f8b69",download_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/download/v0.2.0/release-manifest.json"},
      {id:540176708,name:"SHA256SUMS",size_bytes:218,sha256:"sha256:f46491b22a54ff610d6f3d63826a92f7975a4f16264febcd27349bd965db7a68",download_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/download/v0.2.0/SHA256SUMS"}
    ],release_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/tag/v0.2.0"
  } and
  .releases.operational_provenance_projector_durable_release.release_id == 380835618 and
  .releases.operational_provenance_projector_durable_release.tag_object_sha == "7f21cb959ab8d45c82a9790046a4eb86308c4622" and
  .releases.operational_provenance_projector_durable_release.target_commit_sha == "36126b2a4b177d2b6f44713ffbf6908eb490af4b" and
  .releases.operational_provenance_projector_durable_release.assets == [
    {id:540170176,name:"gooo-operational-provenance-projector-evidence.tar.gz",size_bytes:14601,sha256:"sha256:23ed475552506ff279ae84210c1b825b44335db0b1ed258d407b88a59db1de16",download_url:"https://github.com/kimjooyoon/gooo-operational-provenance-projector/releases/download/v0.1.2/gooo-operational-provenance-projector-evidence.tar.gz"},
    {id:540170177,name:"release-audit.json",size_bytes:3043,sha256:"sha256:88af337623e89ea5f2e5c83c9e5ff3f2ae12244bb2abd2ac03e5a7427ba79d06",download_url:"https://github.com/kimjooyoon/gooo-operational-provenance-projector/releases/download/v0.1.2/release-audit.json"}
  ] and
  .releases.self_improvement_frontier_projector_durable_release.release_id == 380832128 and
  .releases.self_improvement_frontier_projector_durable_release.tag_object_sha == "042ca1bf7dfb432bd2ec0abef9e9884c9abe0286" and
  .releases.self_improvement_frontier_projector_durable_release.target_commit_sha == "98c3529013dad271337e424a7f07d4e5131d7edf" and
  .releases.self_improvement_frontier_projector_durable_release.assets == [
    {id:540161705,name:"frontier-projector-evidence.tar.gz",size_bytes:18846,sha256:"sha256:112564378170baddfba44a1b3f5bd39216af65aefbc1f43f13732dbbbd5695a3",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/download/v0.2.0/frontier-projector-evidence.tar.gz"},
    {id:540161738,name:"frontier-projector-source.tar.gz",size_bytes:38900,sha256:"sha256:51240e7d8c39a5d6e807c2233cc1cee19e5bc9e7157bc4b2c4d611a0ba0cc2f9",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/download/v0.2.0/frontier-projector-source.tar.gz"},
    {id:540161755,name:"release-manifest-v0.2.0.json",size_bytes:493,sha256:"sha256:d0df22bfc53909eb8df6b5a5726df6a942b4c4dfc988ccf80c3214cc90b823d6",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/download/v0.2.0/release-manifest-v0.2.0.json"}
  ]
' "$repository/contracts/release-locks-v1.json" >/dev/null

echo "v0.51 conformance: verify parent reuse and three-lock live wave"
jq -e '
  .schema == "gooo/self-improvement-ledger/v0510-parent-lock-receipt/v1" and
  .parent == {repository:"kimjooyoon/gooo-self-improvement-ledger",tag:"v0.50.0",release_id:380866481,tag_object_sha:"9e3263ea902bef64fa31c05ca7c1ab038ef962ef",target_commit_sha:"e93768f4204e8a88214026ffa22febad7ecedcbd",immutable:true,release_asset:{id:540246273,name:"gooo-self-improvement-ledger-e93768f4204e8a88214026ffa22febad7ecedcbd",size_bytes:55178070,sha256:"sha256:80575837d8ebb8d838bab912ff7802946fb37b2d90d923e8a9cec27bdf543e25"},release_lock_manifest:{sha256:"sha256:7fbcb681ac47f1ae26935615229c824b21d4aca08ea41cb7639d74ea5bdf38a3",size_bytes:307511,contents_blob_sha:"9b3cb03c401a2faa6044cc05ad58030504a09a7f"},parent_lock_set_digest:"sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71"}
' "$artifact/v0510-parent-lock-receipt.json" >/dev/null
jq -e '
  .primary.state == "CLOSED" and .primary.api_observation == {requests:0,selected:0,executed:0,reused:59,bytes_read:0,bytes_downloaded:0,source:"PARENT_V050_RELEASE_RECEIPT_REUSE"} and
  .lock_set.current_count == 62 and .lock_set.parent_count == 59 and .lock_set.current_digest == "sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71" and .lock_set.parent_digest == "sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71" and .lock_set.unchanged_59_lock_set == true and
  (.parent_input_observation.metadata_api_requests|type) == "number" and
  (.parent_input_observation.release_asset_download_requests|type) == "number" and
  (.parent_input_observation.api_requests|type) == "number" and
  .parent_input_observation.source == "GITHUB_API_AND_IMMUTABLE_RELEASE_ASSET" and
  .full_fallback.required == false and .full_fallback.executed == 0
' "$artifact/v0510-parent-lock-receipt.json" >/dev/null
jq -e '
  .schema == "gooo/self-improvement-ledger/v0510-live-lock-receipt/v1" and
  .parent_reuse.reused == 59 and .parent_reuse.selected == 0 and .parent_reuse.executed == 0 and
  .changed_live.selected == 3 and .changed_live.executed == 3 and .changed_live.reused == 0 and .changed_live.live_verified == 3 and
  .changed_live.unknown == 0 and .changed_live.refuted == 0 and
  .full_62_lock_audit == {executed:false,required:false} and
  .authority == {verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}
' "$artifact/v0510-live-lock-receipt.json" >/dev/null
jq -e '
  .schema == "gooo/self-improvement-portfolio/release-verification/v1" and
  .summary == {total:62,verified:62,unknown:0,refuted:0} and
  (.releases|length) == 62 and
  .release_lock_snapshot.parent_reuse.reused == 59 and
  .release_lock_snapshot.changed_live.selected == 3 and
  .release_lock_snapshot.changed_live.executed == 3 and
  .release_lock_snapshot.changed_live.live_verified == 3 and
  .release_lock_snapshot.full_62_lock_audit.executed == false
' "$artifact/releases/verification.json" >/dev/null

test -s "$artifact/v050-parent-report.json"
jq -e '.summary == {total:64,closed:61,unknown:1,refuted:2}' "$artifact/v050-parent-report.json" >/dev/null
jq -e '
  .schema == "gooo/self-improvement-ledger/atomic-v0510-adoption-wave/v1" and
  .wave == {release_tag:"v0.51.0",atomic:true,cell_count:3,ordinals:[65,66,67],cell_state:"CLOSED",parent_profile_state:{total:64,closed:61,unknown:1,refuted:2},projected_profile_state:{total:67,closed:64,unknown:1,refuted:2},proof_totals:{FOUNDATION:4,COHERENCE:58,REGRESSION:5},indicator_totals:{DRIVER:4,OUTCOME:58,GUARDRAIL:5}} and
  .parent_preservation.release_id == 380866481 and .parent_preservation.target_commit_sha == "e93768f4204e8a88214026ffa22febad7ecedcbd" and
  .parent_preservation.parent_lock_count == 59 and .parent_preservation.primary_reused == 59 and .parent_preservation.changed_selected == 3 and .parent_preservation.changed_executed == 3 and .parent_preservation.full_62_lock_audit_executed == false and
  .preservation == {v0_50_semantic_summary:{total:64,closed:61,unknown:1,refuted:2},historical_refutations_preserved:true,external_utility_state:"UNKNOWN",mutation_policy:"NO_DELETE_NO_OVERWRITE"} and
  .authority.verification == "GITHUB_ACTIONS" and .authority.repository_writes == 0 and .authority.local_test_executions == 0 and .authority.cross_project_required_gates == 0
' "$repository/evidence/atomic-v0510-wave-v1.json" >/dev/null

echo "v0.51 conformance: generate report through GitHub Actions runtime"
start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$probe/report-peak-rss" "$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$probe/report.json" \
  -output-markdown "$probe/report.md" \
  2>"$artifact/report-command.stderr"
end=$(date +%s%N)
report_wall=$(( (end - start) / 1000000 ))
report_raw=$(( end - start ))
report_rss=$(cat "$probe/report-peak-rss")
jq --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" \
  '.timing.report={wall_ms:$wall,duration_ns:$raw,peak_rss_kib:($rss|tonumber)}' \
  "$artifact/runtime.json" > "$probe/runtime.json"
mv "$probe/runtime.json" "$artifact/runtime.json"

start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$probe/final-report-peak-rss" "$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$artifact/report.json" \
  -output-markdown "$artifact/report.md" \
  2>"$artifact/final-report-command.stderr"
end=$(date +%s%N)
final_report_wall=$(( (end - start) / 1000000 ))
final_report_raw=$(( end - start ))

echo "v0.51 conformance: verify generated report"
jq -e '
  .schema == "gooo/gooo-self-improvement-portfolio/report/v1" or .schema == "gooo/self-improvement-portfolio/report/v1"
' "$artifact/report.json" >/dev/null
jq -e '
  .summary == {total:67,closed:64,unknown:1,refuted:2} and
  .proof_counts.FOUNDATION.denominator == 4 and .proof_counts.COHERENCE.denominator == 58 and .proof_counts.REGRESSION.denominator == 5 and
  .indicator_counts.DRIVER.denominator == 4 and .indicator_counts.OUTCOME.denominator == 58 and .indicator_counts.GUARDRAIL.denominator == 5 and
  .bindings == {one_to_one:true,cells:67,activities:67,unique_axes:67,unique_metrics:67,source_bindings:67,ir_bindings:67,generated_artifact_bindings:67,evaluator_bindings:67} and
  .releases == {total:62,verified:62,unknown:0,refuted:0} and
  .precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .policy.aggregate_percentage == false and .policy.aggregate_score == false and
  .authority.runtime_repository_writes == 0 and .authority.caller_owned_temp_output == true and .authority.cross_project_required_gates == 0 and
  .local_execution_counts == {gofmt:0,build:0,test:0,vet:0,conformance:0} and
  (has("percentage")|not) and (has("score")|not)
' "$artifact/report.json" >/dev/null

jq -S -n --slurpfile report "$artifact/report.json" --argjson wall "$final_report_wall" --argjson raw "$final_report_raw" --argjson rss "$(cat "$probe/final-report-peak-rss")" \
  '{schema:"gooo-self-improvement-portfolio/conformance/v1",tests:{executed:1,reused:0,skipped:0},report_decision:$report[0].decision,summary:$report[0].summary,report_generation:{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$rss},repository_writes:$report[0].authority.runtime_repository_writes}' \
  > "$artifact/conformance.json"

jq -e '.schema == "gooo-self-improvement-portfolio/conformance/v1" and .summary == {total:67,closed:64,unknown:1,refuted:2} and .repository_writes == 0' "$artifact/conformance.json" >/dev/null
jq '{schema,decision,summary,proof_counts,indicator_counts,releases,authority,local_execution_counts}' "$artifact/report.json"
echo "v0.51 conformance passed: total=67 closed=64 unknown=1 refuted=2 releases=62"
