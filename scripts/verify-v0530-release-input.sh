#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.53 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -lt 2 ]; then
  echo "usage: verify-v0530-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0530-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi
mode=$1
root=$(realpath "$2")

if [ "$mode" = --repository ]; then
  [ "$#" -eq 2 ] || exit 64
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0530-wave-v1.json"
  for path in "$contract" "$portfolio" "$assessment" "$wave"; do test -s "$path"; done

  jq -e '
    .schema=="gooo/self-improvement-portfolio/release-locks/v1" and (.releases|length)==70 and
    .releases.evaluator_integrity_projector_durable_release=={
      repository:"kimjooyoon/gooo-evaluator-integrity-projector",tag:"v0.1.1",release_id:380918566,immutable:true,
      tag_object_sha:"8f1deddca824228ad50fc8fe7060e8a9aa84a558",target_commit_sha:"56c252ffe4545d0fcd95ab10da33cb247bfaf5cc",
      assets:[
        {id:540421694,name:"conformance.json",size_bytes:58466,sha256:"sha256:a26a0e87d257f7c48a482b59e14182a0173727e53f6f4a725c16bc451142eee6",download_url:"https://github.com/kimjooyoon/gooo-evaluator-integrity-projector/releases/download/v0.1.1/conformance.json"},
        {id:540421690,name:"github-run.json",size_bytes:144,sha256:"sha256:59ce2d04fcfb3c5d5d639bea932088a099f168be06ecd79e72d9715f49becb0e",download_url:"https://github.com/kimjooyoon/gooo-evaluator-integrity-projector/releases/download/v0.1.1/github-run.json"},
        {id:540421693,name:"provenance.json",size_bytes:2621,sha256:"sha256:1721188d64c9b134f036674ac6a8becee0bb3c9b21d0fc6e74175245ffd18272",download_url:"https://github.com/kimjooyoon/gooo-evaluator-integrity-projector/releases/download/v0.1.1/provenance.json"},
        {id:540421692,name:"replay.json",size_bytes:3302,sha256:"sha256:2547ed1336c059b3249855cbc42b8bfc7c0416daa9b02ab1c95b4e4f19f391fa",download_url:"https://github.com/kimjooyoon/gooo-evaluator-integrity-projector/releases/download/v0.1.1/replay.json"},
        {id:540421691,name:"SHA256SUMS",size_bytes:341,sha256:"sha256:5b743b77316bfcc4140fa03a78143f8608fcb2334ffcacb4ba817d1e14c1faa7",download_url:"https://github.com/kimjooyoon/gooo-evaluator-integrity-projector/releases/download/v0.1.1/SHA256SUMS"}
      ],release_url:"https://github.com/kimjooyoon/gooo-evaluator-integrity-projector/releases/tag/v0.1.1"
    } and
    .releases.semantic_impact_slicer_durable_release=={
      repository:"kimjooyoon/gooo-semantic-impact-slicer",tag:"v0.1.1",release_id:380918864,immutable:true,
      tag_object_sha:"4addcaba527622ed03010a10a14f0bfa3c7b2ee7",target_commit_sha:"7d9fac1a614a8a35a7578f7bff7800c440da0184",
      assets:[
        {id:540422714,name:"gooo-semantic-impact-slicer-v0.1.1.tar.gz",size_bytes:18501,sha256:"sha256:bd6d6a4cf9d1173ff908b97d7c8f04cb281a64e66601c8361eceefc1386a93e9",download_url:"https://github.com/kimjooyoon/gooo-semantic-impact-slicer/releases/download/v0.1.1/gooo-semantic-impact-slicer-v0.1.1.tar.gz"},
        {id:540422715,name:"gooo-semantic-impact-slicer-v0.1.1.tar.gz.sha256",size_bytes:108,sha256:"sha256:14695a6f36a7b35c4cc673db76afbb5f94b84fcbb9d97397f7dc71edad7ce432",download_url:"https://github.com/kimjooyoon/gooo-semantic-impact-slicer/releases/download/v0.1.1/gooo-semantic-impact-slicer-v0.1.1.tar.gz.sha256"},
        {id:540422713,name:"SHA256SUMS",size_bytes:297,sha256:"sha256:52298a256e8936debb2b8030432eb8bc9c7c3ecd57250100681e7440e80eb3f9",download_url:"https://github.com/kimjooyoon/gooo-semantic-impact-slicer/releases/download/v0.1.1/SHA256SUMS"}
      ],release_url:"https://github.com/kimjooyoon/gooo-semantic-impact-slicer/releases/tag/v0.1.1"
    } and
    .releases.self_improvement_cycle_detector_durable_release=={
      repository:"kimjooyoon/gooo-self-improvement-cycle-detector",tag:"v0.1.0",release_id:380919907,immutable:true,
      tag_object_sha:"71b7f851d3965d1c3cd1e2480d2e09ce79cbc3d1",target_commit_sha:"d7ded6c362af36543586da934336136ad211d757",
      assets:[{id:540426258,name:"gooo-release-report-v0.1.0.tar.gz",size_bytes:5831,sha256:"sha256:454b73cf8e260f9fbe2ea1cfe535bd8500ea526d3d70f4d2dc426e74f57eea0",download_url:"https://github.com/kimjooyoon/gooo-self-improvement-cycle-detector/releases/download/v0.1.0/gooo-release-report-v0.1.0.tar.gz"}],release_url:"https://github.com/kimjooyoon/gooo-self-improvement-cycle-detector/releases/tag/v0.1.0"
    } and
    .releases.closed_loop_self_improvement_usecase_durable_release=={
      repository:"kimjooyoon/gooo-closed-loop-self-improvement-usecase",tag:"v0.1.3",release_id:380921827,immutable:true,
      tag_object_sha:"9d36711bd5dac7feca52b40fccbec89800734bed",target_commit_sha:"1aea2dd16f0921d3577eb717a47ae92461eefac1",
      assets:[{id:540431125,name:"v0.1.3.tar.gz",size_bytes:8002,sha256:"sha256:0fea71e3154f01053bf6b39689630dadad4de18301bcb6af96e8c235ac9eabf5",download_url:"https://github.com/kimjooyoon/gooo-closed-loop-self-improvement-usecase/releases/download/v0.1.3/v0.1.3.tar.gz"}],release_url:"https://github.com/kimjooyoon/gooo-closed-loop-self-improvement-usecase/releases/tag/v0.1.3"
    }
  ' "$contract" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==75 and
    .denominator_migration=={from:53,to:75,add:22,retire:0,split:0,append_only:true} and .proof_totals=={FOUNDATION:4,COHERENCE:66,REGRESSION:5} and .indicator_totals=={DRIVER:4,OUTCOME:66,GUARDRAIL:5} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and
    ([.cells[-4:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}]==[
      {ordinal:72,id:"EVALUATOR_INTEGRITY_PROJECTOR_DURABLE_RELEASE",axis:"EVALUATOR_INTEGRITY_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptEvaluatorIntegrityProjectorDurableRelease",evaluator:"evaluator-integrity-projector",metric_denominator:1,release_key:"evaluator_integrity_projector_durable_release"},
      {ordinal:73,id:"SEMANTIC_IMPACT_SLICER_DURABLE_RELEASE",axis:"SEMANTIC_IMPACT_SLICER_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptSemanticImpactSlicerDurableRelease",evaluator:"semantic-impact-slicer",metric_denominator:1,release_key:"semantic_impact_slicer_durable_release"},
      {ordinal:74,id:"SELF_IMPROVEMENT_CYCLE_DETECTOR_DURABLE_RELEASE",axis:"SELF_IMPROVEMENT_CYCLE_DETECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptSelfImprovementCycleDetectorDurableRelease",evaluator:"self-improvement-cycle-detector",metric_denominator:1,release_key:"self_improvement_cycle_detector_durable_release"},
      {ordinal:75,id:"CLOSED_LOOP_SELF_IMPROVEMENT_USECASE_DURABLE_RELEASE",axis:"CLOSED_LOOP_SELF_IMPROVEMENT_USECASE_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptClosedLoopSelfImprovementUsecaseDurableRelease",evaluator:"closed-loop-self-improvement-usecase",metric_denominator:1,release_key:"closed_loop_self_improvement_usecase_durable_release"}
    ])
  ' "$portfolio" >/dev/null

  jq -e '.schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==75 and ([.cells[-4:][]|{cell_id,state,release_key}]==[
    {cell_id:"EVALUATOR_INTEGRITY_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"evaluator_integrity_projector_durable_release"},
    {cell_id:"SEMANTIC_IMPACT_SLICER_DURABLE_RELEASE",state:"CLOSED",release_key:"semantic_impact_slicer_durable_release"},
    {cell_id:"SELF_IMPROVEMENT_CYCLE_DETECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"self_improvement_cycle_detector_durable_release"},
    {cell_id:"CLOSED_LOOP_SELF_IMPROVEMENT_USECASE_DURABLE_RELEASE",state:"CLOSED",release_key:"closed_loop_self_improvement_usecase_durable_release"}
  ])' "$assessment" >/dev/null

  jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0530-adoption-wave/v1" and .wave=={release_tag:"v0.53.0",atomic:true,cell_count:4,ordinals:[72,73,74,75],cell_state:"CLOSED",parent_profile_state:{total:71,closed:68,unknown:1,refuted:2},projected_profile_state:{total:75,closed:72,unknown:1,refuted:2},proof_totals:{FOUNDATION:4,COHERENCE:66,REGRESSION:5},indicator_totals:{DRIVER:4,OUTCOME:66,GUARDRAIL:5}} and .parent_preservation=={parent_release:"v0.52.0",parent_lock_count:66,parent_selected:0,parent_executed:0,parent_reused:66,changed_selected:4,changed_executed:4,changed_reused:0,full_70_lock_audit:false,fallback_only_if_parent_not_closed:true} and .semantic_wave.state=="CLOSED" and .semantic_wave.accepted_wave_order==["proposal-cell-72","proposal-cell-73","proposal-cell-74","proposal-cell-75"] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.replay_match==true and .preservation.external_utility_state=="UNKNOWN" and .preservation.general_program_equivalence_claim==false and .preservation.improvement_aggregation=="NOT_CLAIMED" and .preservation.historical_refutations_preserved==true and .authority=={repository_writes:0,local_validation_commands:0,cross_project_gates:0,verification:"GITHUB_ACTIONS_ONLY",token_source:"github.token"}' "$wave" >/dev/null
  echo "v0.53 source preflight passed: 70 release locks, four append-only CLOSED cells, and v0.52 parent continuity"
  exit 0
fi

if [ "$mode" != --artifact ] || [ "$#" -ne 2 ]; then exit 64; fi
report="$root/report.json"; conformance="$root/conformance.json"; verification="$root/releases/verification.json"; parent="$root/v0530-parent-lock-receipt.json"; live="$root/v0530-live-lock-receipt.json"; wave="$root/atomic-v0530-wave-v1.json"; products="$root/v0530-products/product-integration.json"; semantic="$root/semantic-denominator-projector/semantic-denominator.json"
for path in "$report" "$conformance" "$verification" "$parent" "$live" "$wave" "$products" "$semantic"; do test -s "$path"; done
jq -e '(.schema=="gooo/self-improvement-portfolio/report/v1" or .schema=="gooo/gooo-self-improvement-portfolio/report/v1") and .summary=={total:75,closed:72,unknown:1,refuted:2} and .proof_counts.COHERENCE.denominator==66 and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.REGRESSION.denominator==5 and .indicator_counts.OUTCOME.denominator==66 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.GUARDRAIL.denominator==5 and .releases=={total:70,verified:70,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)' "$report" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:75,closed:72,unknown:1,refuted:2} and .repository_writes==0' "$conformance" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/semantic-denominator/v1" and .scenario_denominator==75 and .state_counts=={total:75,closed:72,unknown:1,refuted:2} and .proof_totals=={COHERENCE:66,FOUNDATION:4,REGRESSION:5} and .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:66}' "$semantic" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0530-parent-lock-receipt/v1" and .parent.tag=="v0.52.0" and .parent.release_id==380923246 and .parent.tag_object_sha=="b952230430c3cffb16f3b3cc2f9d33e388c87a4d" and .parent.target_commit_sha=="a58356a8d3fd40ba8b9d06c41e735df7b62d426b" and .parent.release_asset=={id:540435763,name:"gooo-self-improvement-ledger-a58356a8d3fd40ba8b9d06c41e735df7b62d426b",size_bytes:57996564,sha256:"sha256:5560540aaa9d8336b98380ed72e8daed843ab8fcbe27de494c7c726560123686"} and .parent.release_lock_manifest=={sha256:"sha256:8802e3874758fb4f00a2c8ad906f23b51524bdbcc06f308fcf91688a296e7bb9",size_bytes:314813,contents_blob_sha:"2c6877c2fea2090fe19ab0782872c076dd79507c"} and .parent.parent_lock_set_digest=="sha256:31f9885ee4282a1b72308021814c968221003d9bcbdc5b1ec4c7533c2fd59635" and .primary.state=="CLOSED" and .primary.api_observation.reused==66 and .lock_set=={current_count:70,current_digest:"sha256:31f9885ee4282a1b72308021814c968221003d9bcbdc5b1ec4c7533c2fd59635",parent_count:66,parent_digest:"sha256:31f9885ee4282a1b72308021814c968221003d9bcbdc5b1ec4c7533c2fd59635",unchanged_66_lock_set:true} and .full_fallback.required==false and .full_fallback.executed==0' "$parent" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0530-live-lock-receipt/v1" and .parent_reuse.reused==66 and .parent_reuse.selected==0 and .parent_reuse.executed==0 and .changed_live.selected==4 and .changed_live.executed==4 and .changed_live.live_verified==4 and .changed_live.unknown==0 and .changed_live.refuted==0 and .full_70_lock_audit=={executed:false,required:false} and .authority=={verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}' "$live" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:70,verified:70,unknown:0,refuted:0} and (.releases|length)==70 and .release_lock_snapshot.parent_reuse.reused==66 and .release_lock_snapshot.changed_live.selected==4 and .release_lock_snapshot.changed_live.executed==4 and .release_lock_snapshot.full_70_lock_audit.executed==false' "$verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0530-adoption-wave/v1" and .wave.projected_profile_state=={total:75,closed:72,unknown:1,refuted:2} and .parent_preservation.parent_release=="v0.52.0" and .parent_preservation.parent_reused==66 and .parent_preservation.changed_selected==4 and .parent_preservation.changed_executed==4 and .parent_preservation.full_70_lock_audit==false and .semantic_wave.state=="CLOSED" and .authority.verification=="GITHUB_ACTIONS_ONLY" and .authority.repository_writes==0' "$wave" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0530-product-integration/v1" and (.products|length)==4 and ([.receipts|keys[]|select(.!="packaging")]|length)==4 and ([.receipts|to_entries[]|select(.value.adoption_state=="CLOSED")]|length)==4 and .claims.general_program_equivalence==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.external_utility=="UNKNOWN" and .authority.repository_writes==0' "$products" >/dev/null
jq -e '.summary=={total:71,closed:68,unknown:1,refuted:2}' "$root/v052-parent-report.json" >/dev/null
echo "v0.53 artifact preflight passed: 75-cell report, 66-lock parent reuse, four changed locks, semantic wave, and four product receipts verified"
