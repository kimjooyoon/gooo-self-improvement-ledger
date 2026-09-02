#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.55 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0550-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0550-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

mode=$1
root=$(realpath "$2")
parent_target="20ed18182087a76c6f6f54cf345397febc59f1d9"

if [ "$mode" = --repository ]; then
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0550-wave-v1.json"
  for required_file in "$contract" "$portfolio" "$assessment" "$wave"; do test -s "$required_file"; done
  command -v jq >/dev/null
  command -v git >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/release-locks/v1" and (.releases|length)==72 and
    .releases.output_authority_projector_durable_release=={
      repository:"kimjooyoon/gooo-output-authority-projector",tag:"v0.1.1",release_id:380949449,immutable:true,
      tag_object_sha:"e3f6251bf30fda7b7b472368524e9238a3700b77",target_commit_sha:"6fd787a9b6a40da74c032b2e88be5c5b0933ba02",
      assets:[
        {download_url:"https://github.com/kimjooyoon/gooo-output-authority-projector/releases/download/v0.1.1/gooo-output-authority-projector",id:540522209,name:"gooo-output-authority-projector",sha256:"sha256:699327a9f032258f4be0e4ff860f3253d5c2116541dccfa2da59a99e5a29b287",size_bytes:4468921},
        {download_url:"https://github.com/kimjooyoon/gooo-output-authority-projector/releases/download/v0.1.1/SHA256SUMS",id:540522213,name:"SHA256SUMS",sha256:"sha256:f0f484edee28a6c2bc75b879a4c8483f4d34f9786a3f9a3cd211c2ca7f94f928",size_bytes:122}
      ],release_url:"https://github.com/kimjooyoon/gooo-output-authority-projector/releases/tag/v0.1.1"
    } and
    .releases.protected_change_gate_projector_durable_release=={
      repository:"kimjooyoon/gooo-protected-change-gate-projector",tag:"v0.1.1",release_id:380957875,immutable:true,
      tag_object_sha:"66d44c732d666d58069522c86b296c51e1538d1f",target_commit_sha:"64f08cfa4e28e38cd040fc7cca0a51a49aaa8117",
      assets:[
        {download_url:"https://github.com/kimjooyoon/gooo-protected-change-gate-projector/releases/download/v0.1.1/conformance.json",id:540550228,name:"conformance.json",sha256:"sha256:b837e97e298a1b9c33941ccc31f071273959645735667073a337163b9cbddf07",size_bytes:32056},
        {download_url:"https://github.com/kimjooyoon/gooo-protected-change-gate-projector/releases/download/v0.1.1/measurement.json",id:540550227,name:"measurement.json",sha256:"sha256:4957d1e8d973bbba71dc39fde48a5b9d5c0a71dc7ba6065ea741695d9925c147",size_bytes:32088},
        {download_url:"https://github.com/kimjooyoon/gooo-protected-change-gate-projector/releases/download/v0.1.1/replay.json",id:540550229,name:"replay.json",sha256:"sha256:4031d13f224549d6654898c892397ddad5f33d7c0d7f21d90c8a77e51aebb65b",size_bytes:31996},
        {download_url:"https://github.com/kimjooyoon/gooo-protected-change-gate-projector/releases/download/v0.1.1/SHA256SUMS",id:540550226,name:"SHA256SUMS",sha256:"sha256:f1bf93d86ada68d7fec543ba7647bc8b1497bd375afcc9aa4ec806de473a9f9c",size_bytes:355}
      ],release_url:"https://github.com/kimjooyoon/gooo-protected-change-gate-projector/releases/tag/v0.1.1"
    } and
    .releases.semantic_wave_merge_projector_durable_release=={
      repository:"kimjooyoon/gooo-semantic-wave-merge-projector",tag:"v0.1.3",release_id:380905719,immutable:true,
      tag_object_sha:"3c795b9577e3fe8050601c40896e2f247074fb90",target_commit_sha:"d1abdcba2e72ca8aaf2992887ede753884b88c7f",
      assets:[{download_url:"https://github.com/kimjooyoon/gooo-semantic-wave-merge-projector/releases/download/v0.1.3/gooo-semantic-wave-merge-projector-v0.1.3.tar.gz",id:540372611,name:"gooo-semantic-wave-merge-projector-v0.1.3.tar.gz",sha256:"sha256:fe55255e0337c8625f4c1fee42608fbcea20b3057f05a4f5370617147abf1744",size_bytes:6190}],release_url:"https://github.com/kimjooyoon/gooo-semantic-wave-merge-projector/releases/tag/v0.1.3"
    }
  ' "$contract" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==81 and
    .denominator_migration=={from:53,to:81,add:28,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:4,COHERENCE:72,REGRESSION:5} and .indicator_totals=={DRIVER:4,OUTCOME:72,GUARDRAIL:5} and
    .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy=={aggregate_percentage:false,aggregate_score:false,caller_owned_temp_output_only:true,cross_project_required_gates:0,denominator_mutation_during_run:false,runtime_repository_writes:0,status_inference_from_missing_evidence:false} and
    ([.cells[-6:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}]==[
      {ordinal:76,id:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",axis:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptOutputAuthorityProjectorDurableRelease",evaluator:"output-authority-projector",metric_denominator:1,release_key:"output_authority_projector_durable_release"},
      {ordinal:77,id:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",axis:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptProtectedChangeGateProjectorDurableRelease",evaluator:"protected-change-gate-projector",metric_denominator:1,release_key:"protected_change_gate_projector_durable_release"},
      {ordinal:78,id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",axis:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveCoreSemanticAuthorityFrontier",evaluator:"core-semantic-authority-frontier-resolution",metric_denominator:1,release_key:null},
      {ordinal:79,id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",axis:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveSemanticDriftPullRequestFrontier",evaluator:"semantic-drift-pull-request-frontier-resolution",metric_denominator:1,release_key:null},
      {ordinal:80,id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION_V2",axis:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION_V2",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveCoreSemanticAuthorityFrontierV2",evaluator:"core-semantic-authority-frontier-resolution-v2",metric_denominator:1,release_key:null},
      {ordinal:81,id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION_V2",axis:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION_V2",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveSemanticDriftPullRequestFrontierV2",evaluator:"semantic-drift-pull-request-frontier-resolution-v2",metric_denominator:1,release_key:null}
    ])
  ' "$portfolio" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==81 and
    ([.cells[-6:][]|{cell_id,state,release_key}]==[
      {cell_id:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"output_authority_projector_durable_release"},
      {cell_id:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"protected_change_gate_projector_durable_release"},
      {cell_id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",state:"CLOSED",release_key:null},
      {cell_id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",state:"CLOSED",release_key:null},
      {cell_id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION_V2",state:"CLOSED",release_key:null},
      {cell_id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION_V2",state:"CLOSED",release_key:null}
    ]) and
    any(.cells[]; .cell_id=="EXTERNAL_UTILITY_EVIDENCE" and .state=="UNKNOWN" and .unknown=={blocked_by:["exact-before-after-utility-pair"],next_operation:"PROVIDE_INDEPENDENT_EXTERNAL_UTILITY_EVIDENCE",reason:"EXTERNAL_UTILITY_NOT_OBSERVED",stage:"EXTERNAL_UTILITY",step:"REQUIRE_INDEPENDENT_EXTERNAL_UTILITY_EVIDENCE",unknown_class:"CAUSALITY_UNPROVEN"}) and
    ([.refutation_resolution_events[]|select((.schema_version // 0)>=2)]|length)==2 and
    any(.frontier_resolution_schema_classifications[]; .event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.54.0" and .schema_version==1 and .classification=="INCOMPLETE" and .preserved==true and .successor_event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.55.0-V2") and
    any(.frontier_resolution_schema_classifications[]; .event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.54.0" and .schema_version==1 and .classification=="INCOMPLETE" and .preserved==true and .successor_event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.55.0-V2")
  ' "$assessment" >/dev/null

  temp_root="${RUNNER_TEMP:-$root/.v0550-input-preflight}"
  mkdir -p "$temp_root"
  git show "$parent_target:evidence/assessment-v1.json" | jq -S '[.refutation_resolution_events[]|select(.event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.54.0" or .event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.54.0")]' > "$temp_root/parent-v054-events.json"
  jq -S '[.refutation_resolution_events[]|select(.event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.54.0" or .event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.54.0")]' "$assessment" > "$temp_root/current-v054-events.json"
  cmp -s "$temp_root/parent-v054-events.json" "$temp_root/current-v054-events.json"
  git show "$parent_target:contracts/release-locks-v1.json" > "$temp_root/parent-v054-release-locks.json"
  cmp -s "$temp_root/parent-v054-release-locks.json" "$contract"

  jq -e '
    any(.refutation_resolution_events[]; .event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.55.0-V2" and .cell_id=="CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION_V2" and .append_only==true and .schema_version==2 and .supersedes_event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.54.0" and .historical_cell_ordinal==1 and .historical_cell_id=="CORE_SEMANTIC_AUTHORITY" and .historical_state=="REFUTED" and .historical_refutation_preserved==true and .historical_next_operation=="PUBLISH_EXECUTABLE_PROTECTED_PATH_AUTHORIZATION_DISPATCH_AND_ADOPT_GATE_ORDER" and .next_operation==.historical_next_operation and .next_operation_match==true and .resolution_state=="CLOSED" and .coverage=={components:["PROTECTED_PATH_OUTPUT_AUTHORIZATION","DISPATCH_AND_ADOPT_GATE_ORDER"],denominator:2,covered:2,complete:true} and .edge_ids==["resolution-edge/core-semantic-authority/output-authority-v1","resolution-edge/core-semantic-authority/protected-change-gate-v1"] and (.resolved_by|length)==2 and .resolved_by[0].edge_id=="resolution-edge/core-semantic-authority/output-authority-v1" and .resolved_by[0].cell_id=="OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE" and .resolved_by[0].cell_ordinal==76 and .resolved_by[0].release_lock=="release-lock/71" and .resolved_by[0].release_lock_ordinal==71 and .resolved_by[0].release_key=="output_authority_projector_durable_release" and .resolved_by[0].product_release=="kimjooyoon/gooo-output-authority-projector@v0.1.1" and .resolved_by[0].release_id==380949449 and .resolved_by[0].tag=="v0.1.1" and .resolved_by[0].immutable==true and .resolved_by[0].adopted_asset=={id:540522209,name:"gooo-output-authority-projector",size_bytes:4468921,digest:"sha256:699327a9f032258f4be0e4ff860f3253d5c2116541dccfa2da59a99e5a29b287"} and .resolved_by[0].coverage_component=="PROTECTED_PATH_OUTPUT_AUTHORIZATION" and .resolved_by[1].edge_id=="resolution-edge/core-semantic-authority/protected-change-gate-v1" and .resolved_by[1].cell_id=="PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE" and .resolved_by[1].cell_ordinal==77 and .resolved_by[1].release_lock=="release-lock/72" and .resolved_by[1].release_lock_ordinal==72 and .resolved_by[1].release_key=="protected_change_gate_projector_durable_release" and .resolved_by[1].product_release=="kimjooyoon/gooo-protected-change-gate-projector@v0.1.1" and .resolved_by[1].release_id==380957875 and .resolved_by[1].tag=="v0.1.1" and .resolved_by[1].immutable==true and .resolved_by[1].adopted_asset=={id:540550228,name:"conformance.json",size_bytes:32056,digest:"sha256:b837e97e298a1b9c33941ccc31f071273959645735667073a337163b9cbddf07"} and .resolved_by[1].coverage_component=="DISPATCH_AND_ADOPT_GATE_ORDER") and
    any(.refutation_resolution_events[]; .event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.55.0-V2" and .cell_id=="SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION_V2" and .append_only==true and .schema_version==2 and .supersedes_event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.54.0" and .historical_cell_ordinal==16 and .historical_cell_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and .historical_state=="REFUTED" and .historical_refutation_preserved==true and .historical_next_operation=="REQUIRE_PULL_REQUEST_FOR_SUBSTANTIVE_IMPLEMENTATION" and .next_operation==.historical_next_operation and .next_operation_match==true and .resolution_state=="CLOSED" and .coverage=={components:["SUBSTANTIVE_CHANGE_REQUIRES_PULL_REQUEST"],denominator:1,covered:1,complete:true} and .edge_id=="resolution-edge/semantic-drift/pr-first-v1" and .edge_ids==["resolution-edge/semantic-drift/pr-first-v1"] and (.resolved_by|length)==1 and .resolved_by[0].edge_id=="resolution-edge/semantic-drift/pr-first-v1" and .resolved_by[0].cell_id=="PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE" and .resolved_by[0].cell_ordinal==77 and .resolved_by[0].release_lock=="release-lock/72" and .resolved_by[0].release_lock_ordinal==72 and .resolved_by[0].release_key=="protected_change_gate_projector_durable_release" and .resolved_by[0].product_release=="kimjooyoon/gooo-protected-change-gate-projector@v0.1.1" and .resolved_by[0].release_id==380957875 and .resolved_by[0].tag=="v0.1.1" and .resolved_by[0].tag=="v0.1.1" and .resolved_by[0].immutable==true and .resolved_by[0].adopted_asset=={id:540550228,name:"conformance.json",size_bytes:32056,digest:"sha256:b837e97e298a1b9c33941ccc31f071273959645735667073a337163b9cbddf07"} and .resolved_by[0].coverage_component=="SUBSTANTIVE_CHANGE_REQUIRES_PULL_REQUEST")
  ' "$assessment" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-ledger/atomic-v0550-adoption-wave/v1" and
    .wave=={atomic:true,cell_count:2,cell_state:"CLOSED",indicator_totals:{DRIVER:4,GUARDRAIL:5,OUTCOME:72},ordinals:[80,81],parent_profile_state:{closed:76,refuted:2,total:79,unknown:1},projected_profile_state:{closed:78,refuted:2,total:81,unknown:1},proof_totals:{COHERENCE:72,FOUNDATION:4,REGRESSION:5},release_tag:"v0.55.0"} and
    .parent_preservation.parent_release=="v0.54.0" and .parent_preservation.parent_release_id==380979192 and .parent_preservation.parent_reused==72 and .parent_preservation.parent_selected==0 and .parent_preservation.parent_executed==0 and .parent_preservation.changed_selected==0 and .parent_preservation.changed_executed==0 and .parent_preservation.changed_reused==0 and .parent_preservation.full_72_lock_audit==false and .parent_preservation.product_receipts_reused_from_parent==true and
    .semantic_wave.fixture_mode=="REPLACE_NORMAL_FIXTURE" and .semantic_wave.scenario_denominator==12 and .semantic_wave.accepted_wave_order==["proposal-cell-80","proposal-cell-81"] and .semantic_wave.proposal_write_sets==[{proposal_id:"proposal-cell-80",writes:["cell/80","frontier-resolution-v2/core-semantic-authority"]},{proposal_id:"proposal-cell-81",writes:["cell/81","frontier-resolution-v2/semantic-drift-pr-first"]}] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.replay_match==true and .semantic_wave.new_release_lock_writes==0 and
    .resolution_record_schema.generic_schema_version_minimum==2 and .resolution_record_schema.v0540_events_preserved_as_incomplete==["CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.54.0","SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.54.0"] and .resolution_record_schema.v0550_successor_events==["CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.55.0-V2","SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.55.0-V2"] and .resolution_record_schema.stable_edge_ids==["resolution-edge/core-semantic-authority/output-authority-v1","resolution-edge/core-semantic-authority/protected-change-gate-v1","resolution-edge/semantic-drift/pr-first-v1"] and .resolution_record_schema.historical_refutations_preserved==true and
    .preservation.v0540_incomplete_resolution_records_preserved==true and .preservation.historical_refutations_preserved==true and .preservation.external_utility_state=="UNKNOWN" and .preservation.general_program_equivalence_claim==false and .preservation.improvement_aggregation=="NOT_CLAIMED" and .preservation.mutation_policy=="NO_DELETE_NO_OVERWRITE" and
    .authority=={cross_project_gates:0,local_validation_commands:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS_ONLY"}
  ' "$wave" >/dev/null
  test "$(grep -F -c 'activity ResolveCoreSemanticAuthorityFrontierV2(' "$root/examples/self-improvement-portfolio/main.gooo")" -eq 1
  test "$(grep -F -c 'activity ResolveSemanticDriftPullRequestFrontierV2(' "$root/examples/self-improvement-portfolio/main.gooo")" -eq 1
  echo "v0.55 repository preflight passed: 81-cell profile, exact V2 frontier records, preserved v0.54 records, and two-proposal wave"
  exit 0
fi

if [ "$mode" != --artifact ]; then exit 64; fi
report="$root/report.json"
conformance="$root/conformance.json"
verification="$root/releases/verification.json"
parent_receipt="$root/v0550-parent-lock-receipt.json"
live_receipt="$root/v0550-live-lock-receipt.json"
wave="$root/atomic-v0550-wave-v1.json"
products="$root/v0550-products/product-integration.json"
meta="$root/frontier-resolution-meta-assertions.json"
for required_file in "$report" "$conformance" "$verification" "$parent_receipt" "$live_receipt" "$wave" "$products" "$meta"; do test -s "$required_file"; done

jq -e '
  (.schema=="gooo/gooo-self-improvement-portfolio/report/v1" or .schema=="gooo/self-improvement-portfolio/report/v1") and .summary=={total:81,closed:78,unknown:1,refuted:2} and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.COHERENCE.denominator==72 and .proof_counts.REGRESSION.denominator==5 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.OUTCOME.denominator==72 and .indicator_counts.GUARDRAIL.denominator==5 and .bindings=={one_to_one:true,cells:81,activities:81,unique_axes:81,unique_metrics:81,source_bindings:81,ir_bindings:81,generated_artifact_bindings:81,evaluator_bindings:81} and .releases=={total:72,verified:72,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$report" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:81,closed:78,unknown:1,refuted:2} and .repository_writes==0' "$conformance" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72 and .release_lock_snapshot.parent_reuse=={executed:0,mode:"PARENT_V0540_RELEASE_RECEIPT_REUSE",parent_input_api_requests:0,parent_metadata_api_requests:0,reused:72,selected:0} and .release_lock_snapshot.changed_live=={changed_lock_ids:[],executed:0,live_verified:0,reused:0,selected:0,parallel_live_metrics:{completed:0,refuted:0,requests:0,unknown:0}} and .release_lock_snapshot.full_72_lock_audit=={executed:false,reason:"PARENT_REUSE_ONLY_NO_NEW_RELEASE_LOCKS",required:false}' "$verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-parent-lock-receipt/v1" and .parent.repository=="kimjooyoon/gooo-self-improvement-ledger" and .parent.tag=="v0.54.0" and .parent.release_id==380979192 and .parent.tag_object_sha=="51b8c42db6cc23ac724dc102245ff02f2693cf75" and .parent.target_commit_sha=="20ed18182087a76c6f6f54cf345397febc59f1d9" and .parent.release_asset=={id:540625084,name:"gooo-self-improvement-ledger-20ed18182087a76c6f6f54cf345397febc59f1d9",sha256:"sha256:e1b1dbd3f3e540ab88c9b62ade806d1154496439dfbeace2072cb162d1ae5a1c",size_bytes:63441343} and .primary.state=="CLOSED" and .primary.api_observation=={executed:0,reused:72,selected:0,source:"PARENT_V0540_RELEASE_RECEIPT_REUSE"} and .lock_set=={current_count:72,current_key_digest:.lock_set.current_key_digest,parent_count:72,parent_key_digest:.lock_set.parent_key_digest,unchanged_72_lock_set:true,keys_match:true} and .full_fallback=={executed:0,required:false,reused:72,selected:0,state:"NOT_REQUIRED"} and .product_receipt_reuse=={output_authority:true,protected_change_gate:true,semantic_wave:true,source:"V0.54.0_IMMUTABLE_RELEASE_ASSET"} and .authority=={cross_project_required_gates:0,local_validation_commands:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS_ONLY"}' "$parent_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-live-lock-receipt/v1" and .parent_reuse.mode=="PARENT_V0540_RELEASE_RECEIPT_REUSE" and .parent_reuse.selected==0 and .parent_reuse.executed==0 and .parent_reuse.reused==72 and .changed_live.selected==0 and .changed_live.executed==0 and .changed_live.reused==0 and .changed_live.live_verified==0 and .changed_live.requests==0 and .changed_live.completed==0 and .changed_live.unknown==0 and .changed_live.refuted==0 and .changed_live.changed_lock_ids==[] and .full_72_lock_audit=={executed:false,reason:"PARENT_REUSE_ONLY_NO_NEW_RELEASE_LOCKS",required:false} and .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,verification:"GITHUB_ACTIONS"}' "$live_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0550-adoption-wave/v1" and .wave.projected_profile_state=={closed:78,refuted:2,total:81,unknown:1} and .parent_preservation.parent_release=="v0.54.0" and .parent_preservation.parent_reused==72 and .parent_preservation.changed_selected==0 and .parent_preservation.changed_executed==0 and .parent_preservation.full_72_lock_audit==false and .semantic_wave.fixture_mode=="REPLACE_NORMAL_FIXTURE" and .semantic_wave.scenario_denominator==12 and .semantic_wave.accepted_wave_order==["proposal-cell-80","proposal-cell-81"] and .semantic_wave.new_release_lock_writes==0 and .authority.repository_writes==0' "$wave" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-product-integration/v1" and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.output_authority_projector.release.release_id==380949449 and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.release.release_id==380957875 and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.release.release_id==380905719 and .parent_receipt_reuse=={output_authority:true,protected_change_gate:true,semantic_wave:true,source_release:"v0.54.0",source_release_id:380979192} and .frontier_resolutions.core_semantic_authority.schema_version==2 and .frontier_resolutions.core_semantic_authority.resolution_state=="CLOSED" and .frontier_resolutions.semantic_drift_pull_request.schema_version==2 and .frontier_resolutions.semantic_drift_pull_request.resolution_state=="CLOSED" and .claims=={external_utility:"UNKNOWN",general_program_equivalence:false,improvement_aggregation:"NOT_CLAIMED",whole_language_improvement:"UNKNOWN"} and .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS"}' "$products" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/frontier-resolution-generated-meta-assertions/v1" and .generated==true and .source.authority=="GOOO" and .schema_policy.frontier_resolution_schema_version_minimum==2 and (.assertions|length)==2 and .summary=={failed:0,passed:2,schemas_observed:2} and all(.assertions[];.pass==true) and .authority.repository_writes==0' "$meta" >/dev/null
echo "v0.55 artifact preflight passed: 81-cell report, 72 parent locks reused, zero live lock additions, V2 resolution metadata, and semantic wave verified"
