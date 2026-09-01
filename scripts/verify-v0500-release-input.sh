#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.50 release-input verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -lt 2 ]; then
  echo "usage: verify-v0500-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0500-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

mode=$1
root=$(realpath "$2")

if [ "$mode" = --repository ]; then
  [ "$#" -eq 2 ] || { echo "usage: verify-v0500-release-input.sh --repository REPOSITORY_ROOT" >&2; exit 64; }
  contract="$root/contracts/release-locks-v1.json"
  portfolio="$root/contracts/self-improvement-portfolio-v1.json"
  assessment="$root/evidence/assessment-v1.json"
  wave="$root/evidence/atomic-v0500-wave-v1.json"
  test -s "$contract" -a -s "$portfolio" -a -s "$assessment" -a -s "$wave"
  jq -e '.schema=="gooo/self-improvement-portfolio/release-locks/v1" and (.releases|length)==59' "$contract" >/dev/null
  jq -e '
    .total_cells==64 and
    .denominator_migration=={from:53,to:64,add:11,retire:0,split:0,append_only:true} and
    .proof_totals=={FOUNDATION:4,COHERENCE:55,REGRESSION:5} and
    .indicator_totals=={DRIVER:4,OUTCOME:55,GUARDRAIL:5} and
    .cells[62]=={activity:"RecordParentLockReceiptContinuity",axis:"PARENT_LOCK_RECEIPT_CONTINUITY",depends_on:[],evaluator:"parent-lock-receipt-continuity",generated_artifact:"evidence/cells/PARENT_LOCK_RECEIPT_CONTINUITY.json",id:"PARENT_LOCK_RECEIPT_CONTINUITY",indicator:"OUTCOME",ir:"semantic-ir/activity/RecordParentLockReceiptContinuity",metric_denominator:1,metric_id:"gooo.metric.self-improvement.parent-lock-receipt-continuity.v1",ordinal:63,proof:"COHERENCE",release_key:null,source:"examples/self-improvement-portfolio/main.gooo#RecordParentLockReceiptContinuity"} and
    .cells[63]=={activity:"ProjectContentAddressedReleaseProjection",axis:"CONTENT_ADDRESSED_RELEASE_PROJECTION",depends_on:[],evaluator:"content-addressed-release-projection",generated_artifact:"evidence/cells/CONTENT_ADDRESSED_RELEASE_PROJECTION.json",id:"CONTENT_ADDRESSED_RELEASE_PROJECTION",indicator:"OUTCOME",ir:"semantic-ir/activity/ProjectContentAddressedReleaseProjection",metric_denominator:1,metric_id:"gooo.metric.self-improvement.content-addressed-release-projection.v1",ordinal:64,proof:"COHERENCE",release_key:null,source:"examples/self-improvement-portfolio/main.gooo#ProjectContentAddressedReleaseProjection"}
  ' "$portfolio" >/dev/null
  jq -e '(.cells|length)==64 and (.cells[-2:]|map(.cell_id))==["PARENT_LOCK_RECEIPT_CONTINUITY","CONTENT_ADDRESSED_RELEASE_PROJECTION"] and (.cells[-2:]|all(.state=="CLOSED" and .release_key==null and (.evidence|length)>0)) and .denominator_migration=={add:11,append_only:true,from:53,retire:0,split:0,to:64}' "$assessment" >/dev/null
  jq -e '
    .schema=="gooo/self-improvement-ledger/atomic-v0500-adoption-wave/v1" and
    .wave=={release_tag:"v0.50.0",atomic:true,cell_count:2,ordinals:[63,64],cell_state:"CLOSED",parent_profile_state:{total:62,closed:59,unknown:1,refuted:2},projected_profile_state:{total:64,closed:61,unknown:1,refuted:2},proof_totals:{FOUNDATION:4,COHERENCE:55,REGRESSION:5},indicator_totals:{DRIVER:4,OUTCOME:55,GUARDRAIL:5}} and
    ([.cells[].cell_id]==["PARENT_LOCK_RECEIPT_CONTINUITY","CONTENT_ADDRESSED_RELEASE_PROJECTION"]) and
    .operational_refuted.state=="REFUTED" and .operational_refuted.exact_local_static_validation_commands==5 and .operational_refuted.preserved==true and .preservation.v0_49_semantic_summary=={total:62,closed:59,unknown:1,refuted:2} and .preservation.external_utility_state=="UNKNOWN"
  ' "$wave" >/dev/null
  echo "v0.50 source preflight passed: 59 unchanged locks, two append-only CLOSED cells, and preserved REFUTED/UNKNOWN states"
  exit 0
fi

if [ "$mode" != --artifact ] || [ "$#" -ne 2 ]; then
  echo "usage: verify-v0500-release-input.sh --repository REPOSITORY_ROOT" >&2
  echo "       verify-v0500-release-input.sh --artifact EVIDENCE_ROOT" >&2
  exit 64
fi

report="$root/report.json"
wave="$root/atomic-v0500-wave-v1.json"
semantic="$root/semantic-denominator-projector/semantic-denominator.json"
receipt="$root/v0500-parent-lock-receipt.json"
products="$root/v050-products/content-addressed-release-projection.json"
pair="$root/v050-products/exact-pair-comparison.json"
for path in "$report" "$wave" "$semantic" "$receipt" "$products" "$pair"; do test -s "$path"; done

jq -e '
  .schema=="gooo/self-improvement-portfolio/report/v1" and
  .summary=={total:64,closed:61,unknown:1,refuted:2} and
  .proof_counts=={COHERENCE:{denominator:55,closed:55,unknown:0,refuted:0},FOUNDATION:{denominator:4,closed:3,unknown:0,refuted:1},REGRESSION:{denominator:5,closed:3,unknown:1,refuted:1}} and
  .indicator_counts=={DRIVER:{denominator:4,closed:3,unknown:0,refuted:1},GUARDRAIL:{denominator:5,closed:3,unknown:1,refuted:1},OUTCOME:{denominator:55,closed:55,unknown:0,refuted:0}} and
  .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and
  .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)
' "$report" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-portfolio/semantic-denominator/v1" and .scenario_denominator==64 and .state_counts=={total:64,closed:61,unknown:1,refuted:2} and .proof_totals=={COHERENCE:55,FOUNDATION:4,REGRESSION:5} and .indicator_totals=={DRIVER:4,GUARDRAIL:5,OUTCOME:55}
' "$semantic" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v050-parent-lock-receipt/v1" and
  .parent=={repository:"kimjooyoon/gooo-self-improvement-ledger",tag:"v0.49.0",release_id:380810861,tag_object_sha:"36f4fa271a72616a39a703c9658e905b670f5f64",target_commit_sha:"036d2d1e25df72a5568aeb16f6ac0a077ce4471f",release_asset:{id:540115901,name:"gooo-self-improvement-ledger-036d2d1e25df72a5568aeb16f6ac0a077ce4471f",size_bytes:84127616,sha256:"sha256:e680c234fee34e36bae27685a29c716208cf83bb67e9375a31a9ee5194ca5208"},source_artifact:{id:9819745734,run_id:33556630730,job_id:100018938289,size_bytes:84127616,sha256:"sha256:e680c234fee34e36bae27685a29c716208cf83bb67e9375a31a9ee5194ca5208"},release_lock_manifest_digest:"sha256:7fbcb681ac47f1ae26935615229c824b21d4aca08ea41cb7639d74ea5bdf38a3",lock_set_digest:"sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71"} and
  .lock_set=={count:59,current_digest:"sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71",parent_digest:"sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71",unchanged:true} and
  .primary.state=="CLOSED" and .primary.mode=="CONTENT_ADDRESSED_PARENT_RELEASE_REUSE" and .primary.api_observation=={requests:0,selected:0,executed:0,reused:59,bytes_read:0,bytes_downloaded:0,rate_limit:.primary.api_observation.rate_limit,source:"PARENT_RELEASE_RECEIPT_REUSE"} and
  .full_fallback=={required:false,state:"NOT_REQUIRED",reason:""} and
  .authority=={verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,local_test_executions:0,cross_project_required_gates:0,caller_owned_temp_outputs_only:true}
' "$receipt" >/dev/null

jq -e '
  .schema=="gooo/self-improvement-ledger/v050-content-addressed-release-projection/v1" and
  .primary_gate.primary_state=="CLOSED" and .primary_gate.selected==0 and .primary_gate.executed==0 and .primary_gate.reused==59 and .primary_gate.full_fallback_required==false and
  .semantic_root_equality==true and .inclusion_proofs_verified==true and .replay_equality==true and .baseline_published==false and .external_utility.state=="UNKNOWN" and
  .packaging_pair.baseline.scenario==.packaging_pair.candidate.scenario and .packaging_pair.baseline.input_digest==.packaging_pair.candidate.input_digest and .packaging_pair.baseline.contract_digest==.packaging_pair.candidate.contract_digest and .packaging_pair.baseline.toolchain==.packaging_pair.candidate.toolchain and .packaging_pair.baseline.runner==.packaging_pair.candidate.runner and .packaging_pair.baseline.job==.packaging_pair.candidate.job and
  (.packaging_pair.indicators|sort)==["bytes","files","peak_rss_kib","wall_ms"] and
  (.packaging_pair.baseline.bytes|type)=="number" and (.packaging_pair.baseline.files|type)=="number" and (.packaging_pair.baseline.wall_ms|type)=="number" and (.packaging_pair.baseline.peak_rss_kib|type)=="number" and
  (.packaging_pair.candidate.bytes|type)=="number" and (.packaging_pair.candidate.files|type)=="number" and (.packaging_pair.candidate.wall_ms|type)=="number" and (.packaging_pair.candidate.peak_rss_kib|type)=="number" and
  .improvement_vs_v049=={state:"UNKNOWN",reason:"NO_EXACT_V049_IDENTITY_MATCH"} and
  .authority=={verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,local_test_executions:0,cross_project_required_gates:0,caller_owned_temp_outputs_only:true}
' "$products" >/dev/null

jq -e '.schema=="gooo/content-addressed-evidence-projector/exact-pair-comparison/v1" and .semantic_root_equal==true and .canonical_evidence_equal==true and .inclusion_proofs_verified==true and .replay_equal==true and .scenario_identity_equal==true and .fixture_digest_equal==true and .contract_digest_equal==true and .toolchain_equal==true and .runner_equal==true and .job_equal==true' "$pair" >/dev/null

echo "v0.50 artifact preflight passed: report, semantic denominator, parent receipt, primary gate, exact pair, and candidate-only package verified"
