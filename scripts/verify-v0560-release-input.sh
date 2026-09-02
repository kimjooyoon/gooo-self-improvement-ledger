#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.56 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0560-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0560-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

mode=$1
root=$(realpath "$2")
parent_target="a6591498d5096b73586d06760e1008370fae5eef"

if [ "$mode" = --repository ]; then
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0560-wave-v1.json"
  source_gooo="$root/examples/self-improvement-portfolio/main.gooo"
  for required_file in "$contract" "$portfolio" "$assessment" "$wave" "$source_gooo"; do test -s "$required_file"; done
  command -v jq >/dev/null
  command -v git >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/release-locks/v1" and (.releases|length)==77 and
    .releases.claim_discharge_calculus_release=={
      assets:[{download_url:"https://github.com/kimjooyoon/gooo-claim-discharge-calculus/releases/download/v0.1.1/gooo-claim-discharge-calculus-v0.1.1.tar.gz",id:540720771,name:"gooo-claim-discharge-calculus-v0.1.1.tar.gz",sha256:"sha256:4bc34e27f2bdd1944d8efd1053fb7e5f17ba64876b58633e07f4b23f1d1bd675",size_bytes:13847}],immutable:true,release_id:381013465,release_url:"https://github.com/kimjooyoon/gooo-claim-discharge-calculus/releases/tag/v0.1.1",repository:"kimjooyoon/gooo-claim-discharge-calculus",source_artifact:{artifact_id:9833989616,name:"gooo-claim-discharge-calculus-main-33597747526",run_id:33597747526,sha256:"sha256:616174bce4811cabe1d459c66a43f95056a29e11c526c221ac611d4c9d5ef333",size_bytes:15820},source_run:{artifact_ids:[9833989616],conclusion:"success",head_sha:"e66a26afc39525bf0d1a4c76e8572e09b613b21d",job_id:100144543893,job_name:"Main Go 1.27 evidence",job_url:"https://github.com/kimjooyoon/gooo-claim-discharge-calculus/actions/runs/33597747526/job/100144543893",run_id:33597747526,workflow_url:"https://github.com/kimjooyoon/gooo-claim-discharge-calculus/actions/runs/33597747526"},tag:"v0.1.1",tag_object_sha:"b6e6fbbe59cd1627df4df3f02757f19ac51dbdc6",target_commit_sha:"e66a26afc39525bf0d1a4c76e8572e09b613b21d"
    } and
    .releases.self_hosted_semantic_kernel_release.release_id==381013558 and .releases.self_hosted_semantic_kernel_release.tag_object_sha=="6f7e59239461b14717a2583a3707b54bffc28222" and .releases.self_hosted_semantic_kernel_release.target_commit_sha=="14949f52b9c55d21841fada27f4cbde7d6593711" and .releases.self_hosted_semantic_kernel_release.assets==[{download_url:"https://github.com/kimjooyoon/gooo-self-hosted-semantic-kernel/releases/download/v0.1.1/gooo-conformance-v0.1.1-33597926498.tar.gz",id:540721071,name:"gooo-conformance-v0.1.1-33597926498.tar.gz",sha256:"sha256:e1758574126f3e5ebdcac1030ad7dd613aedac2caf92d1a6888a83ea2b79e45d",size_bytes:2524538}] and .releases.self_hosted_semantic_kernel_release.source_run.job_id==100145084337 and .releases.self_hosted_semantic_kernel_release.source_run.job_name=="go1.27 bounded conformance" and .releases.self_hosted_semantic_kernel_release.source_secondary_successful_job.job_id==100145084538 and .releases.self_hosted_semantic_kernel_release.source_secondary_successful_job.job_name=="actionlint" and .releases.self_hosted_semantic_kernel_release.source_artifact.artifact_id==9834057612 and .releases.self_hosted_semantic_kernel_release.source_artifact.sha256=="sha256:faebd308d967871a0087045e24e80dca3f3b8c338ad045d015d85ab60a6f9e65" and
    .releases.incremental_conformance_planner_release.release_id==381036116 and .releases.incremental_conformance_planner_release.tag_object_sha=="d2f16f107819822277421ff9cd0771d7ef3ca0c6" and .releases.incremental_conformance_planner_release.target_commit_sha=="39df38fc084f7caae318c4ba79bca478b0a86825" and .releases.incremental_conformance_planner_release.lineage=={tag_target_commit_sha:"39df38fc084f7caae318c4ba79bca478b0a86825",recovery_source_head_sha:"fbe78a13c01e016f9410620c208953c28c7fe478",current_main_head_sha:"fbe78a13c01e016f9410620c208953c28c7fe478",current_main_compare:{status:"ahead",ahead_by:15,behind_by:0,total_commits:15,merge_base_sha:"39df38fc084f7caae318c4ba79bca478b0a86825"}} and .releases.incremental_conformance_planner_release.source_run.job_id==100160823798 and .releases.incremental_conformance_planner_release.source_run.job_name=="release" and .releases.incremental_conformance_planner_release.source_artifact.artifact_id==9835929022 and .releases.incremental_conformance_planner_release.source_artifact.sha256=="sha256:23c71a7dc261fdb4a22fd9cb60147632e69b618d99a616342841dbf74416635f" and
    .releases.opentofu_service_contract_bridge_release.release_id==381006835 and .releases.opentofu_service_contract_bridge_release.tag_object_sha=="041abe030a2d9f7366c3232475430bddb223174c" and .releases.opentofu_service_contract_bridge_release.target_commit_sha=="be0541ab2058608c2251ba644dad2998b42670ef" and .releases.opentofu_service_contract_bridge_release.assets==[{download_url:"https://github.com/kimjooyoon/gooo-opentofu-service-contract-bridge/releases/download/v0.1.0/evidence-v0.1.0.tar.gz",id:540704480,name:"evidence-v0.1.0.tar.gz",sha256:"sha256:af8e1a88a06c11aebb1d6e53d812b1c1aa77f5df94339e26a6b2235c480f7456",size_bytes:8548}] and .releases.opentofu_service_contract_bridge_release.source_run.job_id==100141348735 and .releases.opentofu_service_contract_bridge_release.source_run.job_name=="verify" and .releases.opentofu_service_contract_bridge_release.source_artifact.artifact_id==9833627742 and
    .releases.release_lineage_guard_release.release_id==381017586 and .releases.release_lineage_guard_release.tag_object_sha=="3032a02d2e600e7432eea66ef3d5905dfe04c449" and .releases.release_lineage_guard_release.target_commit_sha=="2a9f08fe34516d8f6502e5a4ddd4d4521426d42d" and .releases.release_lineage_guard_release.assets==[{download_url:"https://github.com/kimjooyoon/gooo-release-lineage-guard/releases/download/v0.1.0/gooo-release-lineage-guard-v0.1.0.tar.gz",id:540726942,name:"gooo-release-lineage-guard-v0.1.0.tar.gz",sha256:"sha256:a3cf3f470f912201335cef950682b308523f1861a7ad225cf7fd4f29f66cc5f7",size_bytes:34789}] and .releases.release_lineage_guard_release.source_run=={artifact_ids:[],conclusion:"success",head_sha:"2a9f08fe34516d8f6502e5a4ddd4d4521426d42d",job_id:100146635917,job_name:"authoritative-go-checks",job_url:"https://github.com/kimjooyoon/gooo-release-lineage-guard/actions/runs/33598442463/job/100146635917",run_id:33598442463,workflow_url:"https://github.com/kimjooyoon/gooo-release-lineage-guard/actions/runs/33598442463"}
  ' "$contract" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==88 and
    .denominator_migration=={from:81,to:88,add:7,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:5,COHERENCE:75,REGRESSION:8} and .indicator_totals=={DRIVER:5,OUTCOME:75,GUARDRAIL:8} and
    .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy=={aggregate_percentage:false,aggregate_score:false,caller_owned_temp_output_only:true,cross_project_required_gates:0,denominator_mutation_during_run:false,runtime_repository_writes:0,status_inference_from_missing_evidence:false} and
    ([.cells[-7:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key,dependency_edge,release_lock_id}]==[
      {ordinal:82,id:"PRODUCT_CLAIM_DISCHARGE_CALCULUS_ADOPTION",axis:"PRODUCT_CLAIM_DISCHARGE_CALCULUS_ADOPTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptClaimDischargeCalculus",evaluator:"claim-discharge-calculus",metric_denominator:1,release_key:"claim_discharge_calculus_release",dependency_edge:"adoption-edge/claim-discharge-calculus/v1",release_lock_id:"release-lock/73"},
      {ordinal:83,id:"PRODUCT_SELF_HOSTED_SEMANTIC_KERNEL_ADOPTION",axis:"PRODUCT_SELF_HOSTED_SEMANTIC_KERNEL_ADOPTION",proof:"FOUNDATION",indicator:"DRIVER",activity:"AdoptSelfHostedSemanticKernel",evaluator:"self-hosted-semantic-kernel",metric_denominator:1,release_key:"self_hosted_semantic_kernel_release",dependency_edge:"adoption-edge/self-hosted-semantic-kernel/v1",release_lock_id:"release-lock/74"},
      {ordinal:84,id:"PRODUCT_INCREMENTAL_CONFORMANCE_PLANNER_ADOPTION",axis:"PRODUCT_INCREMENTAL_CONFORMANCE_PLANNER_ADOPTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptIncrementalConformancePlanner",evaluator:"incremental-conformance-planner",metric_denominator:1,release_key:"incremental_conformance_planner_release",dependency_edge:"adoption-edge/incremental-conformance-planner/v1",release_lock_id:"release-lock/75"},
      {ordinal:85,id:"PRODUCT_OPENTOFU_SERVICE_CONTRACT_BRIDGE_ADOPTION",axis:"PRODUCT_OPENTOFU_SERVICE_CONTRACT_BRIDGE_ADOPTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptOpenTofuServiceContractBridge",evaluator:"opentofu-service-contract-bridge",metric_denominator:1,release_key:"opentofu_service_contract_bridge_release",dependency_edge:"adoption-edge/opentofu-service-contract-bridge/v1",release_lock_id:"release-lock/76"},
      {ordinal:86,id:"PRODUCT_RELEASE_LINEAGE_GUARD_ADOPTION",axis:"PRODUCT_RELEASE_LINEAGE_GUARD_ADOPTION",proof:"REGRESSION",indicator:"GUARDRAIL",activity:"AdoptReleaseLineageGuard",evaluator:"release-lineage-guard",metric_denominator:1,release_key:"release_lineage_guard_release",dependency_edge:"adoption-edge/release-lineage-guard/v1",release_lock_id:"release-lock/77"},
      {ordinal:87,id:"OPERATIONAL_PUBLIC_RELEASE_DELETE_CLAIM_DISCHARGE",axis:"OPERATIONAL_PUBLIC_RELEASE_DELETE_CLAIM_DISCHARGE",proof:"REGRESSION",indicator:"GUARDRAIL",activity:"PreserveClaimDischargeReleaseDeletionRefutation",evaluator:"operational-public-release-delete-claim-discharge",metric_denominator:1,release_key:null,dependency_edge:"operational-edge/public-release-delete/claim-discharge/v1",release_lock_id:null},
      {ordinal:88,id:"OPERATIONAL_PUBLIC_RELEASE_DELETE_OPENTOFU_BRIDGE",axis:"OPERATIONAL_PUBLIC_RELEASE_DELETE_OPENTOFU_BRIDGE",proof:"REGRESSION",indicator:"GUARDRAIL",activity:"PreserveOpenTofuReleaseDeletionRefutation",evaluator:"operational-public-release-delete-opentofu-bridge",metric_denominator:1,release_key:null,dependency_edge:"operational-edge/public-release-delete/opentofu-bridge/v1",release_lock_id:null}
    ])
  ' "$portfolio" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==88 and
    ([.cells[-7:][]|{cell_id,state,release_key}]==[
      {cell_id:"PRODUCT_CLAIM_DISCHARGE_CALCULUS_ADOPTION",state:"CLOSED",release_key:"claim_discharge_calculus_release"},
      {cell_id:"PRODUCT_SELF_HOSTED_SEMANTIC_KERNEL_ADOPTION",state:"CLOSED",release_key:"self_hosted_semantic_kernel_release"},
      {cell_id:"PRODUCT_INCREMENTAL_CONFORMANCE_PLANNER_ADOPTION",state:"CLOSED",release_key:"incremental_conformance_planner_release"},
      {cell_id:"PRODUCT_OPENTOFU_SERVICE_CONTRACT_BRIDGE_ADOPTION",state:"CLOSED",release_key:"opentofu_service_contract_bridge_release"},
      {cell_id:"PRODUCT_RELEASE_LINEAGE_GUARD_ADOPTION",state:"CLOSED",release_key:"release_lineage_guard_release"},
      {cell_id:"OPERATIONAL_PUBLIC_RELEASE_DELETE_CLAIM_DISCHARGE",state:"REFUTED",release_key:null},
      {cell_id:"OPERATIONAL_PUBLIC_RELEASE_DELETE_OPENTOFU_BRIDGE",state:"REFUTED",release_key:null}
    ]) and
    ([.cells[-2:][] | .refutation | keys | sort] == [["blocked_by","next_operation","reason","stage","step","unknown_class"],["blocked_by","next_operation","reason","stage","step","unknown_class"]]) and
    any(.cells[]; .cell_id=="EXTERNAL_UTILITY_EVIDENCE" and .state=="UNKNOWN" and .unknown=={blocked_by:["exact-before-after-utility-pair"],next_operation:"PROVIDE_INDEPENDENT_EXTERNAL_UTILITY_EVIDENCE",reason:"EXTERNAL_UTILITY_NOT_OBSERVED",stage:"EXTERNAL_UTILITY",step:"REQUIRE_INDEPENDENT_EXTERNAL_UTILITY_EVIDENCE",unknown_class:"CAUSALITY_UNPROVEN"})
  ' "$assessment" >/dev/null

  current_contract=$(mktemp)
  current_assessment=$(mktemp)
  current_locks=$(mktemp)
  current_events=$(mktemp)
  parent_events=$(mktemp)
  trap 'rm -f "$current_contract" "$current_assessment" "$current_locks" "$current_events" "$parent_events"' EXIT
  git show "$parent_target:contracts/release-locks-v1.json" > "$current_locks"
  git show "$parent_target:contracts/self-improvement-portfolio-v1.json" > "$current_contract"
  git show "$parent_target:evidence/assessment-v1.json" > "$current_assessment"
  jq -S --slurpfile parent "$current_contract" '.cells[0:81] == $parent[0].cells and .denominator_migration == $parent[0].denominator_migration and .policy == $parent[0].policy' "$portfolio" >/dev/null
  jq -S --slurpfile parent "$current_assessment" '.cells[0:81] == $parent[0].cells and .core_refutation_observation_events == $parent[0].core_refutation_observation_events and .refutation_resolution_events == $parent[0].refutation_resolution_events and .state_transition_events == $parent[0].state_transition_events and .frontier_resolution_schema_classifications == $parent[0].frontier_resolution_schema_classifications' "$assessment" >/dev/null
  jq -S --slurpfile parent "$current_locks" '([.releases|to_entries[]|select(.key as $key | ($parent[0].releases|has($key)))]|length)==72 and ([.releases|to_entries[]|select(.key as $key | ($parent[0].releases|has($key)))|.value] == ($parent[0].releases|to_entries|map(.value)))' "$contract" >/dev/null
  git show "$parent_target:evidence/assessment-v1.json" | jq -S '{core_refutation_observation_events,refutation_resolution_events,state_transition_events,frontier_resolution_schema_classifications}' > "$parent_events"
  jq -S '{core_refutation_observation_events,refutation_resolution_events,state_transition_events,frontier_resolution_schema_classifications}' "$assessment" > "$current_events"
  cmp -s "$parent_events" "$current_events"
  test "$(grep -F -c 'activity AdoptClaimDischargeCalculus(' "$source_gooo")" -eq 1
  test "$(grep -F -c 'activity AdoptSelfHostedSemanticKernel(' "$source_gooo")" -eq 1
  test "$(grep -F -c 'activity AdoptIncrementalConformancePlanner(' "$source_gooo")" -eq 1
  test "$(grep -F -c 'activity AdoptOpenTofuServiceContractBridge(' "$source_gooo")" -eq 1
  test "$(grep -F -c 'activity AdoptReleaseLineageGuard(' "$source_gooo")" -eq 1
  test "$(grep -F -c 'activity PreserveClaimDischargeReleaseDeletionRefutation(' "$source_gooo")" -eq 1
  test "$(grep -F -c 'activity PreserveOpenTofuReleaseDeletionRefutation(' "$source_gooo")" -eq 1
  jq -e '
    .schema=="gooo/self-improvement-ledger/atomic-v0560-adoption-wave/v1" and
    .wave=={atomic:true,cell_count:7,cell_state:"CLOSED",indicator_totals:{DRIVER:5,GUARDRAIL:8,OUTCOME:75},ordinals:[82,83,84,85,86,87,88],parent_profile_state:{closed:78,refuted:2,total:81,unknown:1},projected_profile_state:{closed:83,refuted:4,total:88,unknown:1},proof_totals:{COHERENCE:75,FOUNDATION:5,REGRESSION:8},release_tag:"v0.56.0"} and
    .parent_preservation.parent_release=="v0.55.0" and .parent_preservation.parent_release_id==380997346 and .parent_preservation.parent_reused==72 and .parent_preservation.parent_selected==0 and .parent_preservation.parent_executed==0 and .parent_preservation.changed_selected==5 and .parent_preservation.changed_executed==5 and .parent_preservation.changed_reused==0 and .parent_preservation.full_72_lock_audit==false and .parent_preservation.product_receipts_reused_from_parent==true and
    .semantic_wave.fixture_mode=="REPLACE_NORMAL_FIXTURE" and .semantic_wave.scenario_denominator==12 and .semantic_wave.accepted_wave_order==["proposal-cell-82","proposal-cell-83","proposal-cell-84","proposal-cell-85","proposal-cell-86","proposal-cell-87","proposal-cell-88"] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.replay_match==true and .semantic_wave.new_release_lock_writes==0 and
    .preservation.existing_81_cells_byte_semantic==true and .preservation.existing_refutation_resolution_events_byte_semantic==true and .preservation.existing_72_release_locks_byte_semantic==true and .preservation.external_utility_state=="UNKNOWN" and .preservation.improvement_aggregation=="NOT_CLAIMED" and .authority=={cross_project_gates:0,local_validation_commands:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS_ONLY"}
  ' "$wave" >/dev/null
  echo "v0.56 repository preflight passed: exact 88-cell append-only profile, five immutable product locks, two preserved refutations, and seven-proposal wave"
  exit 0
fi

if [ "$mode" != --artifact ]; then exit 64; fi
report="$root/report.json"
conformance="$root/conformance.json"
verification="$root/releases/verification.json"
parent_receipt="$root/v0560-parent-lock-receipt.json"
live_receipt="$root/v0560-live-lock-receipt.json"
wave="$root/atomic-v0560-wave-v1.json"
products="$root/v0560-products/product-integration.json"
meta="$root/frontier-resolution-meta-assertions.json"
guard="$root/v0560-products/release-lineage-guard-plan-assertions.json"
runtime="$root/runtime.json"
for required_file in "$report" "$conformance" "$verification" "$parent_receipt" "$live_receipt" "$wave" "$products" "$meta" "$guard" "$runtime"; do test -s "$required_file"; done

jq -e '
  (.schema=="gooo/gooo-self-improvement-portfolio/report/v1" or .schema=="gooo/self-improvement-portfolio/report/v1") and .summary=={total:88,closed:83,unknown:1,refuted:4} and .proof_counts.FOUNDATION.denominator==5 and .proof_counts.COHERENCE.denominator==75 and .proof_counts.REGRESSION.denominator==8 and .indicator_counts.DRIVER.denominator==5 and .indicator_counts.OUTCOME.denominator==75 and .indicator_counts.GUARDRAIL.denominator==8 and .bindings=={one_to_one:true,cells:88,activities:88,unique_axes:88,unique_metrics:88,source_bindings:88,ir_bindings:88,generated_artifact_bindings:88,evaluator_bindings:88} and .releases=={total:77,verified:77,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$report" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:88,closed:83,unknown:1,refuted:4} and .repository_writes==0 and .authority.local_validation_commands==0' "$conformance" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:77,verified:77,unknown:0,refuted:0} and (.releases|length)==77 and .release_lock_snapshot.parent_reuse.reused==72 and .release_lock_snapshot.parent_reuse.selected==0 and .release_lock_snapshot.parent_reuse.executed==0 and .release_lock_snapshot.changed_live.changed_lock_ids==["claim_discharge_calculus_release","incremental_conformance_planner_release","opentofu_service_contract_bridge_release","release_lineage_guard_release","self_hosted_semantic_kernel_release"] and .release_lock_snapshot.changed_live.selected==5 and .release_lock_snapshot.changed_live.executed==5 and .release_lock_snapshot.changed_live.reused==0 and .release_lock_snapshot.full_historical_reexecution.executed==false' "$verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0560-parent-lock-receipt/v1" and .primary.state=="CLOSED" and .parent.release_id==380997346 and .parent.target_commit_sha=="a6591498d5096b73586d06760e1008370fae5eef" and .parent.release_asset.id==540679512 and .parent.release_asset.sha256=="sha256:804ed35da651c369deb491ecbb7313bff24027e1f25e2916a4a7e16ce75d23c0" and .lock_set.current_count==77 and .lock_set.parent_count==72 and .lock_set.unchanged_72_lock_set==true and .primary.api_observation.selected==0 and .primary.api_observation.executed==0 and .primary.api_observation.reused==72 and .primary.api_observation.source=="PARENT_V0550_RELEASE_RECEIPT_REUSE" and .full_fallback.executed==0 and .full_fallback.required==false and .full_fallback.reused==72 and .full_fallback.state=="NOT_REQUIRED"' "$parent_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0560-live-lock-receipt/v1" and .parent_reuse.reused==72 and .parent_reuse.selected==0 and .parent_reuse.executed==0 and .changed_live.selected==5 and .changed_live.executed==5 and .changed_live.reused==0 and .changed_live.live_verified==5 and .full_historical_reexecution.executed==false and .authority.repository_writes==0' "$live_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0560-adoption-wave/v1" and .wave.projected_profile_state=={closed:83,refuted:4,total:88,unknown:1} and .semantic_wave.accepted_wave_order==["proposal-cell-82","proposal-cell-83","proposal-cell-84","proposal-cell-85","proposal-cell-86","proposal-cell-87","proposal-cell-88"] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.new_release_lock_writes==0 and .authority.repository_writes==0' "$wave" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0560-product-integration/v1" and (.products|length)==7 and .claims.general_program_equivalence==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.external_utility=="UNKNOWN" and .claims.improvement_aggregation=="NOT_CLAIMED" and .authority.repository_writes==0 and .authority.local_product_validation_executions==0' "$products" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/frontier-resolution-generated-meta-assertions/v1" and .summary.failed==0 and .authority.repository_writes==0' "$meta" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0560-release-lineage-guard-plan-assertions/v1" and .policy_conformance.pass==true and .policy_conformance.limitations.state=="UNKNOWN" and .authority.repository_writes==0' "$guard" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/runtime/v1" and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0}' "$runtime" >/dev/null
echo "v0.56 artifact preflight passed: 88-cell report, 77-lock verification, parent reuse, five changed locks, products, lineage guard, and seven-proposal wave"
