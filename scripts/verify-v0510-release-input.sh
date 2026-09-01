#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.51 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -lt 2 ]; then
  echo "usage: verify-v0510-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0510-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

mode=$1
root=$(realpath "$2")

if [ "$mode" = --repository ]; then
  [ "$#" -eq 2 ] || { echo "usage: verify-v0510-release-input.sh --repository REPOSITORY_ROOT" >&2; exit 64; }
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0510-wave-v1.json"
  for path in "$contract" "$portfolio" "$assessment" "$wave"; do test -s "$path"; done

  jq -e '
    .schema=="gooo/self-improvement-portfolio/release-locks/v1" and
    (.releases|length)==62 and
    .releases.measurement_boundary_v2_projector_durable_release=={
      repository:"kimjooyoon/gooo-measurement-boundary-projector",tag:"v0.2.0",release_id:380839207,immutable:true,
      tag_object_sha:"1bacf104da7ea9d6cf3ebd130801608b8e5afb14",target_commit_sha:"1cff6318e748fec494dd9d28ec65db98b94293e0",
      assets:[
        {id:540176712,name:"gooo-measurement-boundary-projector-v0.2.0.tar.gz",size_bytes:50378,sha256:"sha256:90acd1f0a56ab38afe6c2b2b2033bd48b361b9dc43dc1257f606568f89076658",download_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/download/v0.2.0/gooo-measurement-boundary-projector-v0.2.0.tar.gz"},
        {id:540176709,name:"release-manifest.json",size_bytes:2012,sha256:"sha256:f4513680b4603f1bf3a5429c652a1d3218ea0854ab7847eabd95c734f46f8b69",download_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/download/v0.2.0/release-manifest.json"},
        {id:540176708,name:"SHA256SUMS",size_bytes:218,sha256:"sha256:f46491b22a54ff610d6f3d63826a92f7975a4f16264febcd27349bd965db7a68",download_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/download/v0.2.0/SHA256SUMS"}
      ],release_url:"https://github.com/kimjooyoon/gooo-measurement-boundary-projector/releases/tag/v0.2.0"
    } and
    .releases.operational_provenance_projector_durable_release=={
      repository:"kimjooyoon/gooo-operational-provenance-projector",tag:"v0.1.2",release_id:380835618,immutable:true,
      tag_object_sha:"7f21cb959ab8d45c82a9790046a4eb86308c4622",target_commit_sha:"36126b2a4b177d2b6f44713ffbf6908eb490af4b",
      assets:[
        {id:540170176,name:"gooo-operational-provenance-projector-evidence.tar.gz",size_bytes:14601,sha256:"sha256:23ed475552506ff279ae84210c1b825b44335db0b1ed258d407b88a59db1de16",download_url:"https://github.com/kimjooyoon/gooo-operational-provenance-projector/releases/download/v0.1.2/gooo-operational-provenance-projector-evidence.tar.gz"},
        {id:540170177,name:"release-audit.json",size_bytes:3043,sha256:"sha256:88af337623e89ea5f2e5c83c9e5ff3f2ae12244bb2abd2ac03e5a7427ba79d06",download_url:"https://github.com/kimjooyoon/gooo-operational-provenance-projector/releases/download/v0.1.2/release-audit.json"}
      ],release_url:"https://github.com/kimjooyoon/gooo-operational-provenance-projector/releases/tag/v0.1.2"
    } and
    .releases.self_improvement_frontier_projector_durable_release=={
      repository:"kimjooyoon/gooo-self-improvement-frontier-projector",tag:"v0.2.0",release_id:380832128,immutable:true,
      tag_object_sha:"042ca1bf7dfb432bd2ec0abef9e9884c9abe0286",target_commit_sha:"98c3529013dad271337e424a7f07d4e5131d7edf",
      assets:[
        {id:540161705,name:"frontier-projector-evidence.tar.gz",size_bytes:18846,sha256:"sha256:112564378170baddfba44a1b3f5bd39216af65aefbc1f43f13732dbbbd5695a3",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/download/v0.2.0/frontier-projector-evidence.tar.gz"},
        {id:540161738,name:"frontier-projector-source.tar.gz",size_bytes:38900,sha256:"sha256:51240e7d8c39a5d6e807c2233cc1cee19e5bc9e7157bc4b2c4d611a0ba0cc2f9",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/download/v0.2.0/frontier-projector-source.tar.gz"},
        {id:540161755,name:"release-manifest-v0.2.0.json",size_bytes:493,sha256:"sha256:d0df22bfc53909eb8df6b5a5726df6a942b4c4dfc988ccf80c3214cc90b823d6",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/download/v0.2.0/release-manifest-v0.2.0.json"}
      ],release_url:"https://github.com/kimjooyoon/gooo-self-improvement-frontier-projector/releases/tag/v0.2.0"
    }
  ' "$contract" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==67 and
    .denominator_migration=={from:53,to:67,add:14,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:4,COHERENCE:58,REGRESSION:5} and .indicator_totals=={DRIVER:4,OUTCOME:58,GUARDRAIL:5} and
    .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy=={denominator_mutation_during_run:false,status_inference_from_missing_evidence:false,runtime_repository_writes:0,caller_owned_temp_output_only:true,cross_project_required_gates:0,aggregate_percentage:false,aggregate_score:false} and
    ([.cells[-3:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}]==[
      {ordinal:65,id:"MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE",axis:"MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptMeasurementBoundaryV2ProjectorDurableRelease",evaluator:"measurement-boundary-v2-projector",metric_denominator:1,release_key:"measurement_boundary_v2_projector_durable_release"},
      {ordinal:66,id:"OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE",axis:"OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptOperationalProvenanceProjectorDurableRelease",evaluator:"operational-provenance-projector",metric_denominator:1,release_key:"operational_provenance_projector_durable_release"},
      {ordinal:67,id:"SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE",axis:"SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptSelfImprovementFrontierProjectorDurableRelease",evaluator:"self-improvement-frontier-projector",metric_denominator:1,release_key:"self_improvement_frontier_projector_durable_release"}
    ])
  ' "$portfolio" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==67 and
    ([.cells[-3:][]|{cell_id,state,release_key}]==[
      {cell_id:"MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"measurement_boundary_v2_projector_durable_release"},
      {cell_id:"OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"operational_provenance_projector_durable_release"},
      {cell_id:"SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"self_improvement_frontier_projector_durable_release"}
    ])
  ' "$assessment" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-ledger/atomic-v0510-adoption-wave/v1" and
    .wave=={release_tag:"v0.51.0",atomic:true,cell_count:3,ordinals:[65,66,67],cell_state:"CLOSED",parent_profile_state:{total:64,closed:61,unknown:1,refuted:2},projected_profile_state:{total:67,closed:64,unknown:1,refuted:2},proof_totals:{FOUNDATION:4,COHERENCE:58,REGRESSION:5},indicator_totals:{DRIVER:4,OUTCOME:58,GUARDRAIL:5}} and
    ([.cells[].cell_id]==["MEASUREMENT_BOUNDARY_V2_PROJECTOR_DURABLE_RELEASE","OPERATIONAL_PROVENANCE_PROJECTOR_DURABLE_RELEASE","SELF_IMPROVEMENT_FRONTIER_PROJECTOR_DURABLE_RELEASE"]) and
    .parent_preservation=={release_id:380866481,tag:"v0.50.0",tag_object_sha:"9e3263ea902bef64fa31c05ca7c1ab038ef962ef",target_commit_sha:"e93768f4204e8a88214026ffa22febad7ecedcbd",parent_lock_count:59,primary_reused:59,changed_selected:3,changed_executed:3,full_62_lock_audit_executed:false} and
    .preservation=={v0_50_semantic_summary:{total:64,closed:61,unknown:1,refuted:2},historical_refutations_preserved:true,external_utility_state:"UNKNOWN",mutation_policy:"NO_DELETE_NO_OVERWRITE"} and
    .authority.verification=="GITHUB_ACTIONS" and .authority.repository_writes==0 and .authority.local_test_executions==0 and .authority.cross_project_required_gates==0
  ' "$wave" >/dev/null
  echo "v0.51 source preflight passed: 62 release locks, three append-only CLOSED cells, and v0.50 parent continuity"
  exit 0
fi

if [ "$mode" != --artifact ] || [ "$#" -ne 2 ]; then
  echo "usage: verify-v0510-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0510-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

report="$root/report.json"
conformance="$root/conformance.json"
verification="$root/releases/verification.json"
parent="$root/v0510-parent-lock-receipt.json"
live="$root/v0510-live-lock-receipt.json"
wave="$root/atomic-v0510-wave-v1.json"
products="$root/v051-products/product-integration.json"
semantic="$root/semantic-denominator-projector/semantic-denominator.json"
for path in "$report" "$conformance" "$verification" "$parent" "$live" "$wave" "$products" "$semantic"; do test -s "$path"; done

jq -e '
  (.schema=="gooo/self-improvement-portfolio/report/v1" or .schema=="gooo/gooo-self-improvement-portfolio/report/v1") and
  .summary=={total:67,closed:64,unknown:1,refuted:2} and
  .proof_counts.COHERENCE.denominator==58 and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.REGRESSION.denominator==5 and
  .indicator_counts.OUTCOME.denominator==58 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.GUARDRAIL.denominator==5 and
  .releases=={total:62,verified:62,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and
  .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.cross_project_required_gates==0 and
  .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$report" >/dev/null

jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:67,closed:64,unknown:1,refuted:2} and .repository_writes==0' "$conformance" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/semantic-denominator/v1" and .scenario_denominator==67 and .state_counts=={total:67,closed:64,unknown:1,refuted:2} and .proof_totals=={COHERENCE:58,FOUNDATION:4,REGRESSION:5} and .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:58}' "$semantic" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v0510-parent-lock-receipt/v1" and
  .parent.repository=="kimjooyoon/gooo-self-improvement-ledger" and .parent.tag=="v0.50.0" and .parent.release_id==380866481 and .parent.tag_object_sha=="9e3263ea902bef64fa31c05ca7c1ab038ef962ef" and .parent.target_commit_sha=="e93768f4204e8a88214026ffa22febad7ecedcbd" and .parent.release_asset=={id:540246273,name:"gooo-self-improvement-ledger-e93768f4204e8a88214026ffa22febad7ecedcbd",size_bytes:55178070,sha256:"sha256:80575837d8ebb8d838bab912ff7802946fb37b2d90d923e8a9cec27bdf543e25"} and
  .primary.state=="CLOSED" and .primary.api_observation=={requests:0,selected:0,executed:0,reused:59,bytes_read:0,bytes_downloaded:0,source:"PARENT_V050_RELEASE_RECEIPT_REUSE"} and
  .lock_set.current_count==62 and .lock_set.parent_count==59 and .lock_set.current_digest=="sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71" and .lock_set.parent_digest=="sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71" and .lock_set.unchanged_59_lock_set==true and
  .full_fallback.required==false and .full_fallback.executed==0
' "$parent" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v0510-live-lock-receipt/v1" and .parent_reuse.mode=="PARENT_V050_RECEIPT_REUSE" and .parent_reuse.selected==0 and .parent_reuse.executed==0 and .parent_reuse.reused==59 and (.parent_reuse.parent_input_api_requests|type)=="number" and (.parent_reuse.parent_metadata_api_requests|type)=="number" and
  .changed_live.selected==3 and .changed_live.executed==3 and .changed_live.reused==0 and .changed_live.live_verified==3 and .changed_live.unknown==0 and .changed_live.refuted==0 and
  .full_62_lock_audit=={executed:false,required:false} and .authority=={verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}
' "$live" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:62,verified:62,unknown:0,refuted:0} and (.releases|length)==62 and
  .release_lock_snapshot.parent_reuse.reused==59 and .release_lock_snapshot.changed_live.selected==3 and .release_lock_snapshot.changed_live.executed==3 and .release_lock_snapshot.changed_live.live_verified==3 and .release_lock_snapshot.full_62_lock_audit.executed==false
' "$verification" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/atomic-v0510-adoption-wave/v1" and .wave.projected_profile_state=={total:67,closed:64,unknown:1,refuted:2} and .parent_preservation.release_id==380866481 and .parent_preservation.primary_reused==59 and .parent_preservation.changed_selected==3 and .parent_preservation.changed_executed==3 and .parent_preservation.full_62_lock_audit_executed==false and .authority.verification=="GITHUB_ACTIONS" and .authority.repository_writes==0
' "$wave" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v0510-product-integration/v1" and
  .products.measurement_boundary_v2_projector.release_id==380839207 and .products.measurement_boundary_v2_projector.tag=="v0.2.0" and
  .products.operational_provenance_projector.release_id==380835618 and .products.operational_provenance_projector.tag=="v0.1.2" and
  .products.self_improvement_frontier_projector.release_id==380832128 and .products.self_improvement_frontier_projector.tag=="v0.2.0" and
  .receipts.measurement_boundary_v2.evaluation.decision=="CLOSED" and .receipts.measurement_boundary_v2.evaluation.closed_count==2 and .receipts.measurement_boundary_v2.improvement.state=="UNKNOWN" and
  .receipts.operational_provenance.project_report.summary=={closed:4,unknown:4,refuted:4} and .receipts.operational_provenance.operator_api_attempts==null and .receipts.operational_provenance.operator_api_attempts_state=="UNKNOWN" and
  .receipts.self_improvement_frontier.v050_parent.immutable==true and .receipts.self_improvement_frontier.v050_parent.release_id==380866481 and .receipts.self_improvement_frontier.v051_candidate.source_release=="v0.51.0-candidate" and .receipts.self_improvement_frontier.v051_candidate.parent_cache_present==false and
  .receipts.packaging.candidate_only==true and .receipts.packaging.baseline_published==false and .receipts.packaging.improvement.state=="UNKNOWN" and
  .external_utility.state=="UNKNOWN" and .claims.aggregate_score==false and .claims.aggregate_percentage==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.candidate_release_immutable==false and
  .authority=={verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}
' "$products" >/dev/null

echo "v0.51 artifact preflight passed: 67-cell report, 59-lock parent reuse, three changed locks, and three product receipts verified"
