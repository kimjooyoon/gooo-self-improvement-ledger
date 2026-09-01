#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.49 release-input preflight failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -lt 2 ]; then
  echo "usage: verify-v0490-release-input.sh --repository REPOSITORY_ROOT --output OUTPUT_JSON" >&2
  echo "       verify-v0490-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

mode=$1
root=$(realpath "$2")

if [ "$mode" = --repository ]; then
  output=""
  if [ "$#" -eq 4 ] && [ "$3" = --output ]; then
    output="$4"
  elif [ "$#" -ne 2 ]; then
    echo "usage: verify-v0490-release-input.sh --repository REPOSITORY_ROOT --output OUTPUT_JSON" >&2
    exit 64
  fi
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  test -s "$contract" -a -s "$portfolio"
  lock_set_digest=$(jq -cS '.releases' "$contract" | sha256sum | awk '{print $1}')
  jq -e '
    .schema=="gooo/self-improvement-ledger/release-locks/v1" and (.releases|length)==59
  ' "$contract" >/dev/null
  jq -e '
    .total_cells==62 and .denominator_migration=={from:53,to:62,add:9,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:4,COHERENCE:53,REGRESSION:5} and
    .indicator_totals=={DRIVER:4,OUTCOME:53,GUARDRAIL:5}
  ' "$portfolio" >/dev/null
  if [ -n "$output" ]; then
    mkdir -p "$(dirname "$output")"
    jq -S -n --arg digest "$lock_set_digest" --arg contract "contracts/release-locks-v1.json" \
      '{schema:"gooo/self-improvement-ledger/v0490-source-preflight/v1",state:"CLOSED",lock_set:{count:59,digest:$digest},contract:$contract,portfolio:{total_cells:62,proof_totals:{FOUNDATION:4,COHERENCE:53,REGRESSION:5},indicator_totals:{DRIVER:4,OUTCOME:53,GUARDRAIL:5}},authority:{repository_writes:0,local_validation_executions:0,verification:"GITHUB_ACTIONS"}}' \
      > "$output"
  fi
  echo "v0.49 source preflight passed: 59 locks, lock_set_digest=$lock_set_digest, portfolio_total=62"
  exit 0
fi

if [ "$mode" != --artifact ] || [ "$#" -ne 2 ]; then
  echo "usage: verify-v0490-release-input.sh --repository REPOSITORY_ROOT --output OUTPUT_JSON" >&2
  echo "       verify-v0490-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

report="$root/report.json"
wave="$root/atomic-v0490-wave-v1.json"
product="$root/v049-products/product-integration.json"
semantic="$root/semantic-denominator-projector/semantic-denominator.json"
audit="$root/v0490-release-audit-receipt.json"

for path in "$report" "$wave" "$product" "$semantic"; do
  test -s "$path"
done
test -s "$audit"

jq -e '
  .schema=="gooo/self-improvement-portfolio/report/v1" and
  .summary=={total:62,closed:59,unknown:1,refuted:2} and
  .proof_counts=={
    COHERENCE:{denominator:53,closed:53,unknown:0,refuted:0},
    FOUNDATION:{denominator:4,closed:3,unknown:0,refuted:1},
    REGRESSION:{denominator:5,closed:3,unknown:1,refuted:1}
  } and
  .indicator_counts=={
    DRIVER:{denominator:4,closed:3,unknown:0,refuted:1},
    GUARDRAIL:{denominator:5,closed:3,unknown:1,refuted:1},
    OUTCOME:{denominator:53,closed:53,unknown:0,refuted:0}
  } and
  .authority.runtime_repository_writes==0 and
  .authority.caller_owned_temp_output==true and
  .authority.cross_project_required_gates==0
' "$report" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/atomic-v0490-adoption-wave/v1" and
  .wave.release_tag=="v0.49.0" and .wave.atomic==true and .wave.cell_count==2 and
  .wave.ordinals==[61,62] and .wave.cell_state=="CLOSED" and
  .wave.parent_profile_state=={total:60,closed:57,unknown:1,refuted:2} and
  .wave.projected_profile_state=={total:62,closed:59,unknown:1,refuted:2} and
  .wave.proof_totals=={FOUNDATION:4,COHERENCE:53,REGRESSION:5} and
  .wave.indicator_totals=={DRIVER:4,OUTCOME:53,GUARDRAIL:5} and
  ([.cells[]|{ordinal,release_key,immutable}]|sort_by(.ordinal))==[
    {ordinal:61,release_key:"measurement_boundary_projector_durable_release",immutable:true},
    {ordinal:62,release_key:"content_addressed_proof_reuse_durable_release",immutable:true}
  ]
' "$wave" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v049-product-integration/v1" and
  .adoption.parent_profile=={release_tag:"v0.48.0",lock_count:57} and
  .adoption.current_lock_count==59 and
  .adoption.baseline.selected==59 and .adoption.baseline.executed==59 and .adoption.baseline.reused==0 and
  .adoption.candidate.selected==2 and .adoption.candidate.executed==2 and .adoption.candidate.reused==57 and
  .adoption.canonical_comparison.status=="CLOSED" and
  .adoption.canonical_comparison.unknown_equal==true and
  .adoption.canonical_comparison.refuted_equal==true and
  .adoption.canonical_comparison.canonical_evidence_equal==true and
  .adoption.measurement_receipt.schema=="gooo/self-improvement-ledger/v049-measurement-receipt/v1" and
  .adoption.measurement_receipt.source.projector_source=="RELEASED_GOOO" and
  .adoption.measurement_receipt.source.observed_in_same_ci_job==true and
  .adoption.measurement_receipt.metric_vector==["wall_ms","peak_rss_kib","requests","bytes_read","bytes_downloaded","selected","executed","reused"] and
  .adoption.measurement_receipt.semantic=={decision:"CLOSED",fail_closed:false,aggregate_policy:"FORBID_UNSCOPED_SCALAR"} and
  .adoption.measurement_receipt.single_receipt_chain=={
    collector_generated:true,measured_once:true,source_authority:"content-reuse-run.json",
    report_authority:"measurement-evaluation.json",verification_authority:"measurement-evaluation.json",
    report_verification_authority_same:true,consumer_receipts_exact:true
  } and
  .adoption.measurement_receipt.api_observation==.adoption.release_audit.api_observation and
  .adoption.measurement_receipt.release_audit==.adoption.release_audit and
  .adoption.measurement_receipt.authority.repository_writes==0 and
  .adoption.measurement_receipt.authority.local_product_validation_executions==0 and
  .adoption.measurement_receipt.authority.cross_project_required_gates==0 and
  .adoption.measurement_receipt.authority.caller_owned_temp_output_only==true and
  .adoption.measurement_receipt.authority.verification=="GITHUB_ACTIONS" and
  .authority.repository_writes==0 and
  .authority.local_product_validation_executions==0 and
  .authority.cross_project_required_gates==0 and
  .authority.caller_owned_temp_output_only==true and
  .authority.verification=="GITHUB_ACTIONS"
' "$product" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v049-product-integration/v1" and
  (.adoption.release_audit.schema=="gooo/self-improvement-ledger/v049-release-audit-receipt/v1") and
  (.adoption.release_audit.primary.state=="CLOSED" or .adoption.release_audit.primary.state=="UNKNOWN" or .adoption.release_audit.primary.state=="REFUTED") and
  (.adoption.release_audit.api_observation | has("requests") and has("reused") and has("selected") and has("executed") and has("rate_limit")) and
  (.adoption.release_audit.api_observation.requests>=0) and
  (.adoption.release_audit.api_observation.reused>=0) and
  (.adoption.release_audit.api_observation.selected>=0) and
  (.adoption.release_audit.api_observation.executed>=0) and
  (.adoption.release_audit.api_observation.rate_limit | has("remaining") and has("reset") and has("observed")) and
  (if .adoption.release_audit.primary.state=="CLOSED" then
    .adoption.release_audit.lock_set.unchanged==true and
    .adoption.release_audit.matched_parent.immutable==true and
    .adoption.release_audit.full_fallback.required==false and
    .adoption.release_audit.api_observation=={requests:.adoption.release_audit.api_observation.requests,reused:57,selected:2,executed:2,rate_limit:.adoption.release_audit.api_observation.rate_limit,source:"PARENT_ARTIFACT_PREPARE"} and
    .adoption.canonical_comparison.semantic_root==.adoption.release_audit.matched_parent.semantic_root and
    .adoption.canonical_comparison.status==.adoption.release_audit.matched_parent.semantic_status and
    .adoption.canonical_comparison.canonical_evidence_equal==.adoption.release_audit.matched_parent.canonical_evidence_equal
  else
    .adoption.release_audit.full_fallback.required==true and
    .adoption.release_audit.full_fallback.state=="CLOSED" and
    .adoption.release_audit.api_observation=={requests:.adoption.release_audit.api_observation.requests,reused:0,selected:59,executed:59,rate_limit:.adoption.release_audit.api_observation.rate_limit,source:"FULL_59_LOCK_AUDIT"} and
    ((.adoption.release_audit.primary.state=="UNKNOWN" and (.adoption.release_audit.primary.unknown|keys|sort)==["blocked_by","next_operation","reason","stage","step","unknown_class"]) or
     (.adoption.release_audit.primary.state=="REFUTED" and (.adoption.release_audit.primary.refuted|keys|sort)==["blocked_by","next_operation","reason","stage","step","unknown_class"]))
  end
' "$product" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-portfolio/semantic-denominator/v1" and
  .scenario_denominator==62 and
  .state_counts=={total:62,closed:59,unknown:1,refuted:2} and
  .proof_totals=={COHERENCE:53,FOUNDATION:4,REGRESSION:5} and
  .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:53}
' "$semantic" >/dev/null

cmp "$audit" <(jq -S '.adoption.release_audit' "$product")

echo "v0.49 release-input preflight passed: structured report, atomic wave, product receipt, semantic denominator, and authority fields verified"
