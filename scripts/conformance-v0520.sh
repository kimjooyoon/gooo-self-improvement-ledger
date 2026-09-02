#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.52 conformance failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 3 ]; then
  echo "usage: conformance-v0520.sh REPORT_BINARY REPOSITORY_ROOT ARTIFACT_ROOT" >&2
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

echo "v0.52 conformance: verify 71-cell append-only profile"
jq -e '
  .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==71 and
  .denominator_migration=={from:53,to:71,add:18,retire:0,split:0,append_only:true} and .proof_totals=={FOUNDATION:4,COHERENCE:62,REGRESSION:5} and .indicator_totals=={DRIVER:4,OUTCOME:62,GUARDRAIL:5} and
  .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy=={denominator_mutation_during_run:false,status_inference_from_missing_evidence:false,runtime_repository_writes:0,caller_owned_temp_output_only:true,cross_project_required_gates:0,aggregate_percentage:false,aggregate_score:false} and (.cells|length)==71 and
  ([.cells[-4:][]|{ordinal,id,axis,proof,indicator,activity,evaluator,metric_denominator,release_key}]==[
    {ordinal:68,id:"BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE",axis:"BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptBoundedSelfChangeCompilerV2DurableRelease",evaluator:"bounded-self-change-compiler-v2",metric_denominator:1,release_key:"bounded_self_change_compiler_v2_durable_release"},
    {ordinal:69,id:"CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE",axis:"CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptCausalCounterexampleReducerDurableRelease",evaluator:"causal-counterexample-reducer",metric_denominator:1,release_key:"causal_counterexample_reducer_durable_release"},
    {ordinal:70,id:"BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE",axis:"BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptBoundedObservationalEquivalenceDurableRelease",evaluator:"bounded-observational-equivalence-projector",metric_denominator:1,release_key:"bounded_observational_equivalence_durable_release"},
    {ordinal:71,id:"SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE",axis:"SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE",proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptSemanticWaveMergeProjectorDurableRelease",evaluator:"semantic-wave-merge-projector",metric_denominator:1,release_key:"semantic_wave_merge_projector_durable_release"}
  ])
' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null
jq -e '
  .schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==71 and
  ([.cells[-4:][]|{cell_id,state,release_key}]==[
    {cell_id:"BOUNDED_SELF_CHANGE_COMPILER_V2_DURABLE_RELEASE",state:"CLOSED",release_key:"bounded_self_change_compiler_v2_durable_release"},
    {cell_id:"CAUSAL_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE",state:"CLOSED",release_key:"causal_counterexample_reducer_durable_release"},
    {cell_id:"BOUNDED_OBSERVATIONAL_EQUIVALENCE_DURABLE_RELEASE",state:"CLOSED",release_key:"bounded_observational_equivalence_durable_release"},
    {cell_id:"SEMANTIC_WAVE_MERGE_PROJECTOR_DURABLE_RELEASE",state:"CLOSED",release_key:"semantic_wave_merge_projector_durable_release"}
  ])
' "$repository/evidence/assessment-v1.json" >/dev/null

echo "v0.52 conformance: verify lock reuse, semantic wave, and product receipts"
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:66,verified:66,unknown:0,refuted:0} and (.releases|length)==66 and .release_lock_snapshot.parent_reuse.reused==62 and .release_lock_snapshot.changed_live==(.release_lock_snapshot.changed_live|. + {selected:4,executed:4,reused:0,live_verified:4}) and .release_lock_snapshot.full_66_lock_audit.executed==false' "$artifact/releases/verification.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0520-live-lock-receipt/v1" and .parent_reuse.mode=="PARENT_V051_RELEASE_RECEIPT_REUSE" and .parent_reuse.reused==62 and .changed_live.selected==4 and .changed_live.executed==4 and .changed_live.live_verified==4 and .changed_live.unknown==0 and .changed_live.refuted==0 and .full_66_lock_audit=={executed:false,required:false}' "$artifact/v0520-live-lock-receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0520-adoption-wave/v1" and .wave.projected_profile_state=={total:71,closed:68,unknown:1,refuted:2} and .semantic_wave.state=="CLOSED" and .semantic_wave.accepted_wave_order==["proposal-cell-68","proposal-cell-69","proposal-cell-70","proposal-cell-71"] and .semantic_wave.conflict_witnesses==[] and .semantic_wave.deferred_frontier==[] and .semantic_wave.replay_match==true and .preservation.historical_refutations_preserved==true and .preservation.external_utility_state=="UNKNOWN"' "$repository/evidence/atomic-v0520-wave-v1.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0520-product-integration/v1" and (.products|length)==4 and .receipts.bounded_self_change_compiler_v2.adoption_state=="CLOSED" and .receipts.causal_counterexample_reducer.adoption_state=="CLOSED" and .receipts.bounded_observational_equivalence.adoption_state=="CLOSED" and .receipts.semantic_wave_merge.adoption_state=="CLOSED" and .claims.general_program_equivalence==false and .claims.whole_language_improvement=="UNKNOWN" and .authority.repository_writes==0' "$artifact/v052-products/product-integration.json" >/dev/null

echo "v0.52 conformance: generate report through GitHub Actions runtime"
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
jq --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" '.timing.report={wall_ms:$wall,duration_ns:$raw,peak_rss_kib:($rss|tonumber)}' "$artifact/runtime.json" > "$probe/runtime.json"
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

jq -e '
  (.schema=="gooo/gooo-self-improvement-portfolio/report/v1" or .schema=="gooo/self-improvement-portfolio/report/v1") and .summary=={total:71,closed:68,unknown:1,refuted:2} and
  .proof_counts.FOUNDATION.denominator==4 and .proof_counts.COHERENCE.denominator==62 and .proof_counts.REGRESSION.denominator==5 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.OUTCOME.denominator==62 and .indicator_counts.GUARDRAIL.denominator==5 and
  .bindings=={one_to_one:true,cells:71,activities:71,unique_axes:71,unique_metrics:71,source_bindings:71,ir_bindings:71,generated_artifact_bindings:71,evaluator_bindings:71} and .releases=={total:66,verified:66,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$artifact/report.json" >/dev/null
jq -S -n --slurpfile report "$artifact/report.json" --argjson wall "$final_report_wall" --argjson raw "$final_report_raw" --argjson rss "$(cat "$probe/final-report-peak-rss")" \
  '{schema:"gooo/self-improvement-portfolio/conformance/v1",tests:{executed:1,reused:0,skipped:0},report_decision:$report[0].decision,summary:$report[0].summary,report_generation:{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$rss},repository_writes:$report[0].authority.runtime_repository_writes}' > "$artifact/conformance.json"
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:71,closed:68,unknown:1,refuted:2} and .repository_writes==0' "$artifact/conformance.json" >/dev/null
jq '{schema,decision,summary,proof_counts,indicator_counts,releases,authority,local_execution_counts}' "$artifact/report.json"
echo "v0.52 conformance passed: total=71 closed=68 unknown=1 refuted=2 releases=66"
