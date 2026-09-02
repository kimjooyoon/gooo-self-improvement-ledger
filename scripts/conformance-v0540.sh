#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.54 conformance failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 3 ]; then
  echo "usage: conformance-v0540.sh REPORT_BINARY REPOSITORY_ROOT ARTIFACT_ROOT" >&2
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
test -s "$artifact/runtime.json"
test -s "$artifact/releases/verification.json"

echo "v0.54 conformance: verify 79-cell append-only profile"
jq -e '.schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==79 and .proof_totals=={COHERENCE:70,FOUNDATION:4,REGRESSION:5} and .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:70} and .denominator_migration=={from:53,to:79,add:26,retire:0,split:0,append_only:true} and .policy.aggregate_percentage==false and .policy.aggregate_score==false and (.cells|length)==79 and ([.cells[-4:][]|{ordinal,id,state:(null),proof,indicator,activity}] == [
  {ordinal:76,id:"OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE",state:null,proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptOutputAuthorityProjectorDurableRelease"},
  {ordinal:77,id:"PROTECTED_CHANGE_GATE_PROJECTOR_DURABLE_RELEASE",state:null,proof:"COHERENCE",indicator:"OUTCOME",activity:"AdoptProtectedChangeGateProjectorDurableRelease"},
  {ordinal:78,id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION",state:null,proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveCoreSemanticAuthorityFrontier"},
  {ordinal:79,id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION",state:null,proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveSemanticDriftPullRequestFrontier"}
])' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/assessment/v1" and .profile_id=="self-improvement-portfolio-v1" and (.cells|length)==79 and all(.cells[-4:][]; .state=="CLOSED") and .cells[-4].cell_id=="OUTPUT_AUTHORITY_PROJECTOR_DURABLE_RELEASE" and .cells[-1].cell_id=="SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION"' "$repository/evidence/assessment-v1.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0540-adoption-wave/v1" and .wave.projected_profile_state=={closed:76,refuted:2,total:79,unknown:1} and .parent_preservation.parent_lock_count==70 and .parent_preservation.parent_reused==70 and .parent_preservation.changed_selected==2 and .parent_preservation.changed_executed==2 and .parent_preservation.full_72_lock_audit==false and .semantic_wave.state=="CLOSED" and .semantic_wave.replay_match==true and .preservation.historical_refutations_preserved==true and .authority=={cross_project_gates:0,local_validation_commands:0,repository_writes:0,token_source:"github.token",verification:"GITHUB_ACTIONS_ONLY"}' "$repository/evidence/atomic-v0540-wave-v1.json" >/dev/null

echo "v0.54 conformance: verify parent reuse, two live locks, and released product receipts"
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72 and .release_lock_snapshot.parent_reuse.mode=="PARENT_V0530_RELEASE_RECEIPT_REUSE" and .release_lock_snapshot.parent_reuse.reused==70 and .release_lock_snapshot.changed_live==(.release_lock_snapshot.changed_live|. + {selected:2,executed:2,reused:0,live_verified:2}) and .release_lock_snapshot.full_72_lock_audit=={executed:false,required:false,reason:"PARENT_REUSE_PLUS_TWO_CHANGED_LOCKS"}' "$artifact/releases/verification.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-parent-lock-receipt/v1" and .primary.state=="CLOSED" and .parent.tag=="v0.53.0" and .parent.release_id==380943341 and .parent.target_commit_sha=="e84c9209316cfa6d07d2ea96d988d05c8c6f7367" and .parent.parent_lock_set_digest=="sha256:ffc92192ef7ba838e8f4917c5f7c97d878786a00a79f6079e0761f64a05001b3" and .lock_set.current_count==72 and .lock_set.parent_count==70 and .lock_set.unchanged_70_lock_set==true and .full_fallback.required==false' "$artifact/v0540-parent-lock-receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-live-lock-receipt/v1" and .parent_reuse.reused==70 and .changed_live.selected==2 and .changed_live.executed==2 and .changed_live.live_verified==2 and .changed_live.unknown==0 and .changed_live.refuted==0 and .full_72_lock_audit.executed==false and .authority.repository_writes==0' "$artifact/v0540-live-lock-receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-product-integration/v1" and (.products|length)==2 and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .frontier_resolutions.core_semantic_authority.state=="CLOSED" and .frontier_resolutions.semantic_drift_pull_request.state=="CLOSED" and all(.frontier_resolutions[];.historical_refutation_preserved==true) and .claims.general_program_equivalence==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.external_utility=="UNKNOWN" and .claims.improvement_aggregation=="NOT_CLAIMED" and .authority.repository_writes==0' "$artifact/v0540-products/product-integration.json" >/dev/null

echo "v0.54 conformance: generate report through GitHub Actions runtime"
start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$probe/report-peak-rss" "$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$artifact/report.json" \
  -output-markdown "$artifact/report.md" 2>"$artifact/report-command.stderr"
end=$(date +%s%N)
report_wall=$(( (end-start) / 1000000 ))
report_raw=$(( end-start ))
report_rss=$(cat "$probe/report-peak-rss")
jq --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" '.timing.report={wall_ms:$wall,duration_ns:$raw,peak_rss_kib:($rss|tonumber)}' "$artifact/runtime.json" > "$probe/runtime.json"
mv "$probe/runtime.json" "$artifact/runtime.json"
jq -e '(.schema=="gooo/gooo-self-improvement-portfolio/report/v1" or .schema=="gooo/self-improvement-portfolio/report/v1") and .summary=={total:79,closed:76,unknown:1,refuted:2} and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.COHERENCE.denominator==70 and .proof_counts.REGRESSION.denominator==5 and .indicator_counts.DRIVER.denominator==4 and .indicator_counts.OUTCOME.denominator==70 and .indicator_counts.GUARDRAIL.denominator==5 and .bindings=={one_to_one:true,cells:79,activities:79,unique_axes:79,unique_metrics:79,source_bindings:79,ir_bindings:79,generated_artifact_bindings:79,evaluator_bindings:79} and .releases=={total:72,verified:72,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)' "$artifact/report.json" >/dev/null
jq -S -n --slurpfile report "$artifact/report.json" --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" '{schema:"gooo/self-improvement-portfolio/conformance/v1",tests:{executed:1,reused:0,skipped:0},report_decision:$report[0].decision,summary:$report[0].summary,report_generation:{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$rss},repository_writes:$report[0].authority.runtime_repository_writes}' > "$artifact/conformance.json"
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:79,closed:76,unknown:1,refuted:2} and .repository_writes==0' "$artifact/conformance.json" >/dev/null
jq '{schema,decision,summary,proof_counts,indicator_counts,releases,authority,local_execution_counts}' "$artifact/report.json"
echo "v0.54 conformance passed: total=79 closed=76 unknown=1 refuted=2 releases=72 parent_reused=70 changed_live=2"
