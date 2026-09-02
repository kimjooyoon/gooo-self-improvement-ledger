#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.55 conformance failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 3 ]; then
  echo "usage: conformance-v0550.sh REPORT_BINARY REPOSITORY_ROOT ARTIFACT_ROOT" >&2
  exit 64
fi

binary=$(realpath "$1")
repository=$(realpath "$2")
artifact=$(realpath "$3")
probe="${RUNNER_TEMP:-$artifact}/v0550-conformance-probe"
rm -rf "$probe"
mkdir -p "$probe"
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v date >/dev/null
test -x "$binary"
test -s "$artifact/runtime.json"
test -s "$artifact/releases/verification.json"

echo "v0.55 conformance: verify repository profile, preserved history, and V2 frontier records"
bash "$repository/scripts/verify-v0550-release-input.sh" --repository "$repository"
jq -e '
  .schema=="gooo/self-improvement-portfolio/contract/v1" and .profile_id=="self-improvement-portfolio-v1" and .total_cells==81 and
  .proof_totals=={COHERENCE:72,FOUNDATION:4,REGRESSION:5} and .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:72} and
  .denominator_migration=={from:53,to:81,add:28,retire:0,split:0,append_only:true} and .policy.aggregate_percentage==false and .policy.aggregate_score==false and
  ([.cells[-2:][]|{ordinal,id,proof,indicator,activity}] == [
    {ordinal:80,id:"CORE_SEMANTIC_AUTHORITY_FRONTIER_RESOLUTION_V2",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveCoreSemanticAuthorityFrontierV2"},
    {ordinal:81,id:"SEMANTIC_DRIFT_PULL_REQUEST_FRONTIER_RESOLUTION_V2",proof:"COHERENCE",indicator:"OUTCOME",activity:"ResolveSemanticDriftPullRequestFrontierV2"}
  ])
' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null
jq -e '
  any(.cells[]; .cell_id=="EXTERNAL_UTILITY_EVIDENCE" and .state=="UNKNOWN" and .unknown=={blocked_by:["exact-before-after-utility-pair"],next_operation:"PROVIDE_INDEPENDENT_EXTERNAL_UTILITY_EVIDENCE",reason:"EXTERNAL_UTILITY_NOT_OBSERVED",stage:"EXTERNAL_UTILITY",step:"REQUIRE_INDEPENDENT_EXTERNAL_UTILITY_EVIDENCE",unknown_class:"CAUSALITY_UNPROVEN"}) and
  ([.refutation_resolution_events[]|select((.schema_version // 0)>=2)]|length)==2 and
  any(.refutation_resolution_events[]; .event_id=="CORE_SEMANTIC_AUTHORITY-FRONTIER-RESOLVED-v0.55.0-V2") and
  any(.refutation_resolution_events[]; .event_id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS-FRONTIER-RESOLVED-v0.55.0-V2")
' "$repository/evidence/assessment-v1.json" >/dev/null

echo "v0.55 conformance: verify reused lock receipt, zero live additions, products, and generated meta assertions"
test -s "$artifact/v0550-parent-lock-receipt.json"
test -s "$artifact/v0550-live-lock-receipt.json"
test -s "$artifact/v0550-products/product-integration.json"
test -s "$artifact/frontier-resolution-meta-assertions.json"
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72 and .release_lock_snapshot.parent_reuse.mode=="PARENT_V0540_RELEASE_RECEIPT_REUSE" and .release_lock_snapshot.parent_reuse.selected==0 and .release_lock_snapshot.parent_reuse.executed==0 and .release_lock_snapshot.parent_reuse.reused==72 and .release_lock_snapshot.changed_live.selected==0 and .release_lock_snapshot.changed_live.executed==0 and .release_lock_snapshot.changed_live.reused==0 and .release_lock_snapshot.full_72_lock_audit.executed==false' "$artifact/releases/verification.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-parent-lock-receipt/v1" and .primary.state=="CLOSED" and .parent.release_id==380979192 and .parent.release_asset.id==540625084 and .lock_set.current_count==72 and .lock_set.parent_count==72 and .lock_set.unchanged_72_lock_set==true and .primary.api_observation.selected==0 and .primary.api_observation.executed==0 and .primary.api_observation.reused==72 and .full_fallback.required==false' "$artifact/v0550-parent-lock-receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-live-lock-receipt/v1" and .parent_reuse.reused==72 and .changed_live.selected==0 and .changed_live.executed==0 and .changed_live.reused==0 and .changed_live.live_verified==0 and .full_72_lock_audit.executed==false and .authority.repository_writes==0' "$artifact/v0550-live-lock-receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-product-integration/v1" and .parent_receipt_reuse.source_release_id==380979192 and .parent_receipt_reuse.output_authority==true and .parent_receipt_reuse.protected_change_gate==true and .parent_receipt_reuse.semantic_wave==true and .receipts.output_authority_projector.release.release_id==380949449 and .receipts.protected_change_gate_projector.release.release_id==380957875 and .receipts.semantic_wave_merge_projector.release.release_id==380905719 and .frontier_resolutions.core_semantic_authority.schema_version==2 and .frontier_resolutions.semantic_drift_pull_request.schema_version==2 and .semantic_wave.new_release_lock_writes==0 and .claims.external_utility=="UNKNOWN" and .claims.whole_language_improvement=="UNKNOWN" and .claims.improvement_aggregation=="NOT_CLAIMED" and .authority.repository_writes==0' "$artifact/v0550-products/product-integration.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/frontier-resolution-generated-meta-assertions/v1" and .generated==true and .source.authority=="GOOO" and .schema_policy.frontier_resolution_schema_version_minimum==2 and (.assertions|length)==2 and .summary.failed==0 and .summary.passed==2 and all(.assertions[];.pass==true)' "$artifact/frontier-resolution-meta-assertions.json" >/dev/null

echo "v0.55 conformance: generate report through GitHub Actions runtime"
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
jq -e '
  (.schema=="gooo/gooo-self-improvement-portfolio/report/v1" or .schema=="gooo/self-improvement-portfolio/report/v1") and
  .summary=={total:81,closed:78,unknown:1,refuted:2} and .proof_counts.FOUNDATION.denominator==4 and .proof_counts.COHERENCE.denominator==72 and .proof_counts.REGRESSION.denominator==5 and
  .indicator_counts.DRIVER.denominator==4 and .indicator_counts.OUTCOME.denominator==72 and .indicator_counts.GUARDRAIL.denominator==5 and
  .bindings=={one_to_one:true,cells:81,activities:81,unique_axes:81,unique_metrics:81,source_bindings:81,ir_bindings:81,generated_artifact_bindings:81,evaluator_bindings:81} and
  .releases=={total:72,verified:72,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and
  .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and
  .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$artifact/report.json" >/dev/null

jq -S -n --slurpfile report "$artifact/report.json" --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" \
  '{schema:"gooo/self-improvement-portfolio/conformance/v1",tests:{executed:1,reused:0,skipped:0},report_decision:$report[0].decision,summary:$report[0].summary,report_generation:{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$rss},repository_writes:$report[0].authority.runtime_repository_writes}' \
  > "$artifact/conformance.json"
jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .summary=={total:81,closed:78,unknown:1,refuted:2} and .repository_writes==0' "$artifact/conformance.json" >/dev/null
bash "$repository/scripts/verify-v0550-release-input.sh" --artifact "$artifact"
jq '{schema,decision,summary,proof_counts,indicator_counts,releases,authority,local_execution_counts}' "$artifact/report.json"
echo "v0.55 conformance passed: total=81 closed=78 unknown=1 refuted=2 releases=72 parent_reused=72 changed_live=0"
