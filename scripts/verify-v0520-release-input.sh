#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.52 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -lt 2 ]; then
  echo "usage: verify-v0520-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0520-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

mode=$1
root=$(realpath "$2")

if [ "$mode" = --repository ]; then
  [ "$#" -eq 2 ] || exit 64
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0520-wave-v1.json"
  for path in "$contract" "$portfolio" "$assessment" "$wave"; do test -s "$path"; done

  jq -e '
    .schema=="gooo/self-improvement-portfolio/release-locks/v1" and (.releases|length)==66 and
    .releases.bounded_self_change_compiler_v2_durable_release=={
      repository:"kimjooyoon/gooo-bounded-self-change-compiler",tag:"v0.2.1",release_id:380886826,immutable:true,
      tag_object_sha:"8b5d6b5293d85f54c90a9217c485f219f9d778ee",target_commit_sha:"1162d3a9de043564bf8002fa441f99996069cb43",
      assets:[{id:540290070,name:"gooo-bounded-self-change-compiler-v0.2.1-ci-evidence.tar.gz",size_bytes:17923,sha256:"sha256:da4793a5e5a669952faf5289ce5aa90e7307bd158b1d5e4593621bc3b1ab77e1",download_url:"https://github.com/kimjooyoon/gooo-bounded-self-change-compiler/releases/download/v0.2.1/gooo-bounded-self-change-compiler-v0.2.1-ci-evidence.tar.gz"}],release_url:"https://github.com/kimjooyoon/gooo-bounded-self-change-compiler/releases/tag/v0.2.1"
    } and
    .releases.causal_counterexample_reducer_durable_release=={
      repository:"kimjooyoon/gooo-causal-counterexample-reducer",tag:"v0.1.1",release_id:380886153,immutable:true,
      tag_object_sha:"72d2160945daf959d98404ebe5a454adc69ad9ab",target_commit_sha:"f98d7b7ad88d4190e103e2202a696dd6e6e3928d",
      assets:[{id:540288031,name:"conformance-report.json",size_bytes:9354,sha256:"sha256:4b920fd4c85c34cf31ebb2e67a38b6eb34c845379838849ba5ce20b67ab596b4",download_url:"https://github.com/kimjooyoon/gooo-causal-counterexample-reducer/releases/download/v0.1.1/conformance-report.json"}],release_url:"https://github.com/kimjooyoon/gooo-causal-counterexample-reducer/releases/tag/v0.1.1"
    } and
    .releases.bounded_observational_equivalence_durable_release=={
      repository:"kimjooyoon/gooo-bounded-observational-equivalence-projector",tag:"v0.1.2",release_id:380897010,immutable:true,
      tag_object_sha:"6a605cd4d123f5eebee254850715a92922edda0d",target_commit_sha:"95b544d438a71e31511c12b4e9c9cd848f1f8091",
      assets:[{id:540332168,name:"gooo-bounded-observational-equivalence-evidence-v0.1.2.tar.gz",size_bytes:2624296,sha256:"sha256:738165e9d6cc423e8944aa63048ec5f00e22008be9c2a03e3c2abe84882ce365",download_url:"https://github.com/kimjooyoon/gooo-bounded-observational-equivalence-projector/releases/download/v0.1.2/gooo-bounded-observational-equivalence-evidence-v0.1.2.tar.gz"}],release_url:"https://github.com/kimjooyoon/gooo-bounded-observational-equivalence-projector/releases/tag/v0.1.2"
    } and
    .releases.semantic_wave_merge_projector_durable_release=={
      repository:"kimjooyoon/gooo-semantic-wave-merge-projector",tag:"v0.1.3",release_id:380905719,immutable:true,
      tag_object_sha:"3c795b9577e3fe8050601c40896e2f247074fb90",target_commit_sha:"d1abdcba2e72ca8aaf2992887ede753884b88c7f",
      assets:[{id:540372611,name:"gooo-semantic-wave-merge-projector-v0.1.3.tar.gz",size_bytes:6190,sha256:"sha256:fe55255e0337c8625f4c1fee42608fbcea20b3057f05a4f5370617147abf1744",download_url:"https://github.com/kimjooyoon/gooo-semantic-wave-merge-projector/releases/download/v0.1.3/gooo-semantic-wave-merge-projector-v0.1.3.tar.gz"}],release_url:"https://github.com/kimjooyoon/gooo-semantic-wave-merge-projector/releases/tag/v0.1.3"
    }
  ' "$contract" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==71 and
    .denominator_migration=={from:53,to:71,add:18,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:4,COHERENCE:62,REGRESSION:5} and .indicator_totals=={DRIVER:4,OUTCOME:62,GUARDRAIL:5} and
    .precedence==["REFUTED","UNKNOWN","CLOSED"] and
    ([.cells[-4:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}]==[
      {ordinal:68,id:"BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE",axis:"BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptBoundedSelfChangeCompilerV2DurableRelease",evaluator:"bounded-self-change-compiler-v2",metric_denominator:1,release_key:"bounded_self_change_compiler_v2_durable_release"},
      {ordinal:69,id:"CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE",axis:"CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptCausalCounterexampleReducerDurableRelease",evaluator:"causal-counterexample-reducer",metric_denominator:1,release_key:"causal_counterexample_reducer_durable_release"},
      {ordinal:70,id:"BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE",axis:"BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptBoundedObservationalEquivalenceDurableRelease",evaluator:"bounded-observational-equivalence-projector",metric_denominator:1,release_key:"bounded_observational_equivalence_durable_release"},
      {ordinal:71,id:"SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE",axis:"SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptSemanticWaveMergeProjectorDurableRelease",evaluator:"semantic-wave-merge-projector",metric_denominator:1,release_key:"semantic_wave_merge_projector_durable_release"}
    ])
  ' "$portfolio" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==71 and
    ([.cells[-4:][]|{cell_id,state,release_key}]==[
      {cell_id:"BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE",state:"CLOSED",release_key:"bounded_self_change_compiler_v2_durable_release"},
      {cell_id:"CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE",state:"CLOSED",release_key:"causal_counterexample_reducer_durable_release"},
      {cell_id:"BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE",state:"CLOSED",release_key:"bounded_observational_equivalence_durable_release"},
      {cell_id:"SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"semantic_wave_merge_projector_durable_release"}
    ])
  ' "$assessment" >/dev/null

  jq -e '
    .schema=="gooo/self-improvement-ledger/atomic-v0520-adoption-wave/v1" and
    .wave=={release_tag:"v0.52.0",atomic:true,cell_count:4,ordinals:[68,69,70,71],cell_state:"CLOSED",parent_profile_state:{total:67,closed:64,unknown:1,refuted:2},projected_profile_state:{total:71,closed:68,unknown:1,refuted:2},proof_totals:{FOUNDATION:4,COHERENCE:62,REGRESSION:5},indicator_totals:{DRIVER:4,OUTCOME:62,GUARDRAIL:5}} and
    ([.cells[].cell_id]==["BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE","CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE","BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE","SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE"]) and
    .parent_preservation=={parent_release:"v0.51.0",parent_lock_count:62,parent_selected:0,parent_executed:0,parent_reused:62,changed_selected:4,changed_executed:4,changed_reused:0,full_66_lock_audit:false,fallback_only_if_parent_not_closed:true} and
    .semantic_wave.state=="CLOSED" and .semantic_wave.accepted_wave_order==["proposal-cell-68","proposal-cell-69","proposal-cell-70","proposal-cell-71"] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.replay_match==true and
    .preservation.external_utility_state=="UNKNOWN" and .preservation.general_program_equivalence_claim==false and .preservation.improvement_aggregation=="NOT_CLAIMED" and .preservation.historical_refutations_preserved==true and
    .authority=={repository_writes:0,local_validation_commands:0,cross_project_gates:0,verification:"GITHUB_ACTIONS_ONLY",token_source:"github.token"}
  ' "$wave" >/dev/null
  echo "v0.52 source preflight passed: 66 release locks, four append-only CLOSED cells, and v0.51 parent continuity"
  exit 0
fi

if [ "$mode" != --artifact ] || [ "$#" -ne 2 ]; then exit 64; fi

report="$root/report.json"
conformance="$root/conformance.json"
verification="$root/releases/verification.json"
parent="$root/v0520-parent-lock-receipt.json"
live="$root/v0520-live-lock-receipt.json"
wave="$root/atomic-v0520-wave-v1.json"
products="$root/v052-products/product-integration.json"
semantic="$root/semantic-denominator-projector/semantic-denominator.json"
for path in "$report" "$conformance" "$verification" "$parent" "$live" "$wave" "$products" "$semantic"; do test -s "$path"; done

jq -e '
  (.schema=="gooo/self-improvement-portfolio/report/v1" or .schema=="gooo/gooo-self-improvement-portfolio/report/v1") and
  .summary=={total:71,closed:68,unknown:1,refuted:2} and .proof_counts.COHERENCE.denominator==62 and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.REGRESSION.denominator==5 and
  .indicator_counts.OUTCOME.denominator==62 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.GUARDRAIL.denominator==5 and
  .releases=={total:66,verified:66,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and
  .authority.runtime_repository_writes==0 and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$report" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:71,closed:68,unknown:1,refuted:2} and .repository_writes==0' "$conformance" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/semantic-denominator/v1" and .scenario_denominator==71 and .state_counts=={total:71,closed:68,unknown:1,refuted:2} and .proof_totals=={COHERENCE:62,FOUNDATION:4,REGRESSION:5} and .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:62}' "$semantic" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v0520-parent-lock-receipt/v1" and .parent.repository=="kimjooyoon/gooo-self-improvement-ledger" and .parent.tag=="v0.51.0" and .parent.release_id==380894827 and .parent.tag_object_sha=="72e10b201780fa40825e3846a1363cb721918a75" and .parent.target_commit_sha=="70ae4252312e3c39d873762bece4b3c40d60bb1b" and .parent.release_asset=={id:540322888,name:"gooo-self-improvement-ledger-70ae4252312e3c39d873762bece4b3c40d60bb1b",size_bytes:55473731,sha256:"sha256:565adc039ee9db092775d2abe309a3341a94ee589414c0368857711c8e0e60f9"} and .parent.release_lock_manifest=={sha256:"sha256:950c2c8e10a8ffc5366f5868f8d7df0222b418aef220024e562ef932d9f35936",size_bytes:311470,contents_blob_sha:"9338c7e2fcf79d194ce8869b9135d79d8182dcb3"} and .parent.parent_lock_set_digest=="sha256:b0f7f528afff9cceb278b717bc42a53727b1a46fe1f9bbb142be6cfc0fb39b53" and
  .primary.state=="CLOSED" and .primary.api_observation=={requests:0,selected:0,executed:0,reused:62,bytes_read:0,bytes_downloaded:0,source:"PARENT_V051_RELEASE_RECEIPT_REUSE"} and .lock_set=={current_count:66,current_digest:"sha256:b0f7f528afff9cceb278b717bc42a53727b1a46fe1f9bbb142be6cfc0fb39b53",parent_count:62,parent_digest:"sha256:b0f7f528afff9cceb278b717bc42a53727b1a46fe1f9bbb142be6cfc0fb39b53",unchanged_62_lock_set:true} and .full_fallback.required==false and .full_fallback.executed==0
' "$parent" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0520-live-lock-receipt/v1" and .parent_reuse.mode=="PARENT_V051_RELEASE_RECEIPT_REUSE" and .parent_reuse.selected==0 and .parent_reuse.executed==0 and .parent_reuse.reused==62 and .changed_live.selected==4 and .changed_live.executed==4 and .changed_live.reused==0 and .changed_live.live_verified==4 and .changed_live.unknown==0 and .changed_live.refuted==0 and .full_66_lock_audit=={executed:false,required:false} and .authority=={verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}' "$live" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:66,verified:66,unknown:0,refuted:0} and (.releases|length)==66 and .release_lock_snapshot.parent_reuse.reused==62 and .release_lock_snapshot.changed_live.selected==4 and .release_lock_snapshot.changed_live.executed==4 and .release_lock_snapshot.changed_live.live_verified==4 and .release_lock_snapshot.full_66_lock_audit.executed==false' "$verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0520-adoption-wave/v1" and .wave.projected_profile_state=={total:71,closed:68,unknown:1,refuted:2} and .parent_preservation.parent_release=="v0.51.0" and .parent_preservation.parent_reused==62 and .parent_preservation.changed_selected==4 and .parent_preservation.changed_executed==4 and .parent_preservation.full_66_lock_audit==false and .semantic_wave.state=="CLOSED" and .semantic_wave.conflict_witnesses==[] and .authority.verification=="GITHUB_ACTIONS_ONLY" and .authority.repository_writes==0' "$wave" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0520-product-integration/v1" and .products.bounded_self_change_compiler_v2.release_id==380886826 and .products.causal_counterexample_reducer.release_id==380886153 and .products.bounded_observational_equivalence.release_id==380897010 and .products.semantic_wave_merge.release_id==380905719 and .receipts.bounded_self_change_compiler_v2.adoption_state=="CLOSED" and .receipts.causal_counterexample_reducer.adoption_state=="CLOSED" and .receipts.bounded_observational_equivalence.adoption_state=="CLOSED" and .receipts.semantic_wave_merge.adoption_state=="CLOSED" and .claims.general_program_equivalence==false and .claims.aggregate_percentage==false and .claims.aggregate_score==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.external_utility=="UNKNOWN" and .claims.candidate_release_immutable==false and .authority=={verification:"GITHUB_ACTIONS",repository_writes:0,cross_project_required_gates:0}' "$products" >/dev/null
jq -e '.summary=={total:67,closed:64,unknown:1,refuted:2}' "$root/v051-parent-report.json" >/dev/null
echo "v0.52 artifact preflight passed: 71-cell report, 62-lock parent reuse, four changed locks, semantic wave, and four product receipts verified"
