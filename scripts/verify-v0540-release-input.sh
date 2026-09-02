#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.54 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0540-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0540-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi
mode=$1
root=$(realpath "$2")

if [ "$mode" = --repository ]; then
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0540-wave-v1.json"
  for required_file in "$contract" "$portfolio" "$assessment" "$wave"; do test -s "$required_file"; done
  jq -e '.schema=="gooo/self-improvement-portfolio/release-locks/v1" and (.releases|length)==72 and
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
    }' "$contract" >/dev/null
  jq -e '.schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==79 and
    .denominator_migration=={from:53,to:79,add:26,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:4,COHERENCE:70,REGRESSION:5} and .indicator_totals=={DRIVER:4,OUTCOME:70,GUARDRAIL:5} and
    .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy=={aggregate_percentage:false,aggregate_score:false,caller_owned_temp_output_only:true,cross_project_required_gates:0,denominator_mutation_during_run:false,runtime_repository_writes:0,status_inference_from_missing_evidence:false} and
    ([.cells[-4:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}]==[
      {ordinal:76,id:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",axis:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptOutputAuthorityProjectorDurableRelease",evaluator:"output-authority-projector",metric_denominator:1,release_key:"output_authority_projector_durable_release"},
      {ordinal:77,id:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",axis:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptProtectedChangeGateProjectorDurableRelease",evaluator:"protected-change-gate-projector",metric_denominator:1,release_key:"protected_change_gate_projector_durable_release"},
      {ordinal:78,id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",axis:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveCoreSemanticAuthorityFrontier",evaluator:"core-semantic-authority-frontier-resolution",metric_denominator:1,release_key:null},
      {ordinal:79,id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",axis:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveSemanticDriftPullRequestFrontier",evaluator:"semantic-drift-pull-request-frontier-resolution",metric_denominator:1,release_key:null}
    ])' "$portfolio" >/dev/null
  jq -e '.schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==79 and
    ([.cells[-4:][]|{cell_id,state,release_key}] == [
      {cell_id:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"output_authority_projector_durable_release"},
      {cell_id:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"protected_change_gate_projector_durable_release"},
      {cell_id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",state:"CLOSED",release_key:null},
      {cell_id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",state:"CLOSED",release_key:null}
    ]) and
    any(.refutation_resolution_events[];.event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.54.0" and .append_only==true and .previous_refutation.cell_id=="CORE_SEMANTIC_AUTHORITY" and .resolved_by.decision=="CLOSED") and
    any(.refutation_resolution_events[];.event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.54.0" and .append_only==true and .previous_refutation.cell_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and .resolved_by.decision=="CLOSED")' "$assessment" >/dev/null
  jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0540-adoption-wave/v1" and
    .wave=={atomic:true,cell_count:4,cell_state:"CLOSED",indicator_totals:{DRIVER:4,GUARDRAIL:5,OUTCOME:70},ordinals:[76,77,78,79],parent_profile_state:{closed:72,refuted:2,total:75,unknown:1},projected_profile_state:{closed:76,refuted:2,total:79,unknown:1},proof_totals:{COHERENCE:70,FOUNDATION:4,REGRESSION:5},release_tag:"v0.54.0"} and
    .parent_preservation=={changed_executed:2,changed_reused:0,changed_selected:2,fallback_only_if_parent_not_closed:true,full_72_lock_audit:false,parent_executed:0,parent_lock_count:70,parent_release:"v0.53.0",parent_release_id:380943341,parent_reused:70,parent_selected:0} and
    .semantic_wave.state=="CLOSED" and .semantic_wave.accepted_wave_order==["proposal-cell-76","proposal-cell-77","proposal-cell-78","proposal-cell-79"] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.replay_match==true and
    .preservation=={external_utility_state:"UNKNOWN",general_program_equivalence_claim:false,historical_refutations_preserved:true,improvement_aggregation:"NOT_CLAIMED",mutation_policy:"NO_DELETE_NO_OVERWRITE",v_0_53_semantic_summary:"preserved_as_parent_release_evidence"} and
    .authority=={cross_project_gates:0,local_validation_commands:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS_ONLY"}' "$wave" >/dev/null
  test "$(grep -F -c 'activity AdoptOutputAuthorityProjectorDurableRelease(' "$root/examples/self-improvement-portfolio/main.gooo")" -eq 1
  test "$(grep -F -c 'activity AdoptProtectedChangeGateProjectorDurableRelease(' "$root/examples/self-improvement-portfolio/main.gooo")" -eq 1
  test "$(grep -F -c 'activity ResolveCoreSemanticAuthorityFrontier(' "$root/examples/self-improvement-portfolio/main.gooo")" -eq 1
  test "$(grep -F -c 'activity ResolveSemanticDriftPullRequestFrontier(' "$root/examples/self-improvement-portfolio/main.gooo")" -eq 1
  old_lock_digest="sha256:$(jq -cS 'del(.releases.output_authority_projector_durable_release,.releases.protected_change_gate_projector_durable_release)|.releases' "$contract" | sha256sum | awk '{print $1}')"
  test "$old_lock_digest" = "sha256:31f9885ee4282a1b72308021814c968221003d9bcbdc5b1ec4c7533c2fd59635"
  echo "v0.54 repository preflight passed: 79-cell profile, exact upstream locks, append-only frontier resolutions, and parent continuity"
  exit 0
fi

if [ "$mode" != --artifact ]; then exit 64; fi
report="$root/report.json"
conformance="$root/conformance.json"
verification="$root/releases/verification.json"
parent_receipt="$root/v0540-parent-lock-receipt.json"
live_receipt="$root/v0540-live-lock-receipt.json"
wave="$root/atomic-v0540-wave-v1.json"
products="$root/v0540-products/product-integration.json"
for required_file in "$report" "$conformance" "$verification" "$parent_receipt" "$live_receipt" "$wave" "$products"; do test -s "$required_file"; done
jq -e '(.schema=="gooo/gooo-self-improvement-portfolio/report/v1" or .schema=="gooo/self-improvement-portfolio/report/v1") and .summary=={total:79,closed:76,unknown:1,refuted:2} and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.COHERENCE.denominator==70 and .proof_counts.REGRESSION.denominator==5 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.OUTCOME.denominator==70 and .indicator_counts.GUARDRAIL.denominator==5 and .releases=={total:72,verified:72,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)' "$report" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:79,closed:76,unknown:1,refuted:2} and .repository_writes==0' "$conformance" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72 and .release_lock_snapshot.parent_reuse=={executed:0,mode:"PARENT_V0530_RELEASE_RECEIPT_REUSE",reused:70,selected:0} and .release_lock_snapshot.changed_live.selected==2 and .release_lock_snapshot.changed_live.executed==2 and .release_lock_snapshot.changed_live.reused==0 and .release_lock_snapshot.changed_live.live_verified==2 and .release_lock_snapshot.full_72_lock_audit=={executed:false,required:false,reason:"PARENT_REUSE_PLUS_TWO_CHANGED_LOCKS"}' "$verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-parent-lock-receipt/v1" and .parent.repository=="kimjooyoon/gooo-self-improvement-ledger" and .parent.tag=="v0.53.0" and .parent.release_id==380943341 and .parent.tag_object_sha=="dd204df84abecdd634e9321cc40b2714f91d96eb" and .parent.target_commit_sha=="e84c9209316cfa6d07d2ea96d988d05c8c6f7367" and .parent.parent_lock_set_digest=="sha256:31f9885ee4282a1b72308021814c968221003d9bcbdc5b1ec4c7533c2fd59635" and .parent.release_lock_manifest=={contents_blob_sha:"2c6877c2fea2090fe19ab0782872c076dd79507c",sha256:"sha256:8802e3874758fb4f00a2c8ad906f23b51524bdbcc06f308fcf91688a296e7bb9",size_bytes:314813} and .primary.state=="CLOSED" and .primary.api_observation.selected==0 and .primary.api_observation.executed==0 and .primary.api_observation.reused==70 and .lock_set.current_count==72 and .lock_set.parent_count==70 and .lock_set.unchanged_70_lock_set==true and .full_fallback=={executed:0,required:false,reused:70,selected:0,state:"NOT_REQUIRED"} and .authority.repository_writes==0 and .authority.local_product_validation_executions==0 and .authority.cross_project_required_gates==0' "$parent_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-live-lock-receipt/v1" and .parent_reuse=={executed:0,mode:"PARENT_V0530_RELEASE_RECEIPT_REUSE",reused:70,selected:0} and .changed_live.selected==2 and .changed_live.executed==2 and .changed_live.reused==0 and .changed_live.live_verified==2 and .changed_live.unknown==0 and .changed_live.refuted==0 and .full_72_lock_audit=={executed:false,required:false} and .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,verification:"GITHUB_ACTIONS"}' "$live_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0540-adoption-wave/v1" and .wave.projected_profile_state=={closed:76,refuted:2,total:79,unknown:1} and .parent_preservation.parent_release=="v0.53.0" and .parent_preservation.parent_lock_count==70 and .parent_preservation.parent_reused==70 and .parent_preservation.changed_selected==2 and .parent_preservation.changed_executed==2 and .parent_preservation.full_72_lock_audit==false and .semantic_wave.state=="CLOSED" and .authority.verification=="GITHUB_ACTIONS_ONLY" and .authority.repository_writes==0' "$wave" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-product-integration/v1" and (.products|length)==2 and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .frontier_resolutions.core_semantic_authority=={case:"normal_implementation_pr_path",historical_refutation_preserved:true,state:"CLOSED"} and .frontier_resolutions.semantic_drift_pull_request=={case:"normal_maintenance_pr_path",historical_refutation_preserved:true,state:"CLOSED"} and .claims=={external_utility:"UNKNOWN",general_program_equivalence:false,improvement_aggregation:"NOT_CLAIMED",whole_language_improvement:"UNKNOWN"} and .authority=={cross_project_required_gates:0,local_product_validation_executions:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS"}' "$products" >/dev/null
echo "v0.54 artifact preflight passed: 79-cell report, 70-lock parent reuse, two live locks, released products, and frontier resolutions verified"
