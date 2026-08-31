#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: conformance.sh REPORT_BINARY REPOSITORY_ROOT ARTIFACT_ROOT" >&2
  exit 64
fi

binary=$(realpath "$1")
repository=$(realpath "$2")
artifact=$(realpath "$3")
probe=$(mktemp -d)
mkdir -p "$probe"

jq -e '
  .total_cells == 16 and
  .denominator_migration == {from:12,to:16,add:4,retire:0,split:0,append_only:true} and
  (.cells|map(.id)) == [
    "CORE_SEMANTIC_AUTHORITY","RESOLUTION_DESCENT","CAUSAL_CI_SELECTION","META_RESOURCE_BUDGET",
    "DENOMINATOR_EVOLUTION","REFLEXIVE_LOOP","IMMUTABLE_INPUT_INTEGRATION","SEMANTIC_MERGE_ADVICE",
    "DESIGN_CONSUMER_PATH","OPENTOFU_PLAN_PATH","RELEASE_PROMOTION","EXTERNAL_UTILITY_EVIDENCE",
    "COUNTERFACTUAL_CHANGE_RELEASE","VERIFICATION_REUSE_RELEASE","SEMANTIC_DRIFT_RELEASE","SEMANTIC_DRIFT_DEVELOPMENT_PROCESS"
  ] and
  .proof_totals == {FOUNDATION:4,COHERENCE:7,REGRESSION:5} and
  .indicator_totals == {DRIVER:4,OUTCOME:7,GUARDRAIL:5} and
  (.cells|map(select(.id=="COUNTERFACTUAL_CHANGE_RELEASE" and .release_key=="counterfactual_change_release"))|length)==1 and
  (.cells|map(select(.id=="VERIFICATION_REUSE_RELEASE" and .release_key=="verification_reuse_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_RELEASE" and .release_key=="semantic_drift_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and .release_key==null))|length)==1
' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null

jq -e '
  .releases.counterfactual_change_release.release_id == 379663025 and .releases.counterfactual_change_release.tag_object_sha == "b9ddb3bf434988508fa848ed0e3891a38092d09d" and
  .releases.verification_reuse_release.release_id == 379662322 and .releases.verification_reuse_release.tag_object_sha == "3d9bf3374b4ad7e649499ff4a2538b9ff16fab7a" and
  .releases.semantic_drift_release.release_id == 379664434 and .releases.semantic_drift_release.tag_object_sha == "537e5bb79ba4fa34fbe224aa2f40a62b06a35780" and
  (.releases.counterfactual_change_release.assets|map(.id)) == [537808326,537808327,537808330] and
  (.releases.verification_reuse_release.assets|map(.id)) == [537806848,537806851,537806849] and
  (.releases.semantic_drift_release.assets|map(.id)) == [537811623] and
  (.counterexamples|map(.counterexample_id)|sort) == ["counterfactual_change_v0.1.0_mutable","counterfactual_change_v0.1.1_mutable","semantic_drift_v0.1.0_mutable","verification_reuse_v0.1.1_mutable"] and
  all(.counterexamples[]; .immutable==false and .append_only==true and .reason=="RELEASE_API_IMMUTABLE_FALSE")
' "$repository/contracts/release-locks-v1.json" >/dev/null

jq -e '
  .denominator_migration == {from:12,to:16,add:4,retire:0,split:0,append_only:true} and
  (.state_transition_events|length) == 1 and
  .state_transition_events[0].cell_id == "CORE_SEMANTIC_AUTHORITY" and
  .state_transition_events[0].from_state == "UNKNOWN" and
  .state_transition_events[0].to_state == "REFUTED" and
  .state_transition_events[0].append_only == true and
  .state_transition_events[0].prior_record.state == "UNKNOWN" and
  .state_transition_events[0].observed_error_digest == "sha256:37dedce852118e15bfe824d15fcb11979e062854c83f1ff22c08534f8a37b34a" and
  (.refutation_resolution_events|length) == 1 and
  .refutation_resolution_events[0].event_id == "CORE_SEMANTIC_AUTHORITY-BEFORE-DIGEST-RESOLVED-v0.8" and
  .refutation_resolution_events[0].append_only == true and
  .refutation_resolution_events[0].from_refutation_reason == "BEFORE_DIGEST_REFERENCE_ERROR" and
  .refutation_resolution_events[0].resolution == "RESOLVED_BY_EXECUTABLE_GUARDIAN_SCOPE_ADOPTION" and
  .refutation_resolution_events[0].previous_refutation.reason == "BEFORE_DIGEST_REFERENCE_ERROR" and
  .refutation_resolution_events[0].previous_refutation.observed_error.message == "ReferenceError: beforeDigest is not defined" and
  .refutation_resolution_events[0].resolved_by.dev_commit == "e440cbc99f24ceb8385f1b89c70f8cdada10cdbb" and
  .refutation_resolution_events[0].resolved_by.dev_run.ci_number == 3408 and
  .refutation_resolution_events[0].resolved_by.dev_run.run_id == 33358898970 and
  .refutation_resolution_events[0].resolved_by.dev_run.conclusion == "success" and
  .refutation_resolution_events[0].resolved_by.proof_artifact.artifact_id == 9746186091 and
  .refutation_resolution_events[0].resolved_by.proof_artifact.size_bytes == 11258 and
  .refutation_resolution_events[0].resolved_by.proof_artifact.sha256 == "sha256:f4e183581d4a556acad66cc2e73fa028d78ae61b209b3913904496d723bfc1af" and
  .refutation_resolution_events[0].resolved_by.receipt_schema_migration.target_commit_sha == "977e622db99c16fbe37db5912b07f403cd09cdb2" and
  .refutation_resolution_events[0].resolved_by.receipt_schema_migration.release_asset_sha256 == "sha256:e4a2cb8acd608141bdcdb66db6f6369a9480fc691d8a67b3572dd711d02dadf3" and
  .refutation_resolution_events[0].resolved_by.receipt_schema_migration.source_artifact_id == 9745614408 and
  .refutation_resolution_events[0].resolved_by.receipt_schema_migration.adoption_proposal_sha256 == "sha256:f55a204da6e258f1345a52e5e9f164226eff4b6cafa8ba3a65daf97f2247e451" and
  (.core_refutation_observation_events|length) == 1 and
  .core_refutation_observation_events[0].event_id == "CORE_SEMANTIC_AUTHORITY-CI-TIME-CONTRADICTION-v0.9" and
  .core_refutation_observation_events[0].cell_id == "CORE_SEMANTIC_AUTHORITY" and
  .core_refutation_observation_events[0].append_only == true and
  .core_refutation_observation_events[0].state == "REFUTED" and
  .core_refutation_observation_events[0].classification == "KNOWN_VERIFICATION_CONTRADICTION" and
  .core_refutation_observation_events[0].candidate.pull_request == 615 and
  .core_refutation_observation_events[0].candidate.state == "OPEN" and
  .core_refutation_observation_events[0].candidate.merged == false and
  .core_refutation_observation_events[0].candidate.head_sha == "7087f0c" and
  .core_refutation_observation_events[0].candidate.checks == {success:85,skipped:13,failure:2} and
  .core_refutation_observation_events[0].candidate.dev_main_unchanged == true and
  .core_refutation_observation_events[0].expected_guardian.code == "CI-ROOT-OF-TRUST-001" and
  .core_refutation_observation_events[0].expected_guardian.run_id == 33365728402 and
  .core_refutation_observation_events[0].expected_guardian.job_id == 99405865143 and
  .core_refutation_observation_events[0].expected_guardian.artifact_id == 9748206947 and
  .core_refutation_observation_events[0].unexpected_time_contradiction.decision == "KNOWN_VERIFICATION_CONTRADICTION" and
  .core_refutation_observation_events[0].unexpected_time_contradiction.reason == "OPERATION_DURATION_NEGATIVE" and
  .core_refutation_observation_events[0].unexpected_time_contradiction.attempts == [{attempt:1,job_id:99405870188,artifact_id:9748462083,head_sha:"7087f0c"},{attempt:2,job_id:99408612206,artifact_id:9748520364,head_sha:"7087f0c"}] and
  .core_refutation_observation_events[0].source_observations.ci_run_id == 33365730047 and
  .core_refutation_observation_events[0].source_observations.ci_completed == true and
  .core_refutation_observation_events[0].source_observations.opentofu_run_id == 33365730033 and
  .core_refutation_observation_events[0].source_observations.opentofu_completed == true and
  .core_refutation_observation_events[0].source_observations.contradiction_reproduced == true and
  .core_refutation_observation_events[0].refutation.stage == "CI_EFFORT_OBSERVATION" and
  .core_refutation_observation_events[0].refutation.step == "DERIVE_OPERATION_DURATION" and
  .core_refutation_observation_events[0].refutation.reason == "OPERATION_DURATION_NEGATIVE" and
  .core_refutation_observation_events[0].refutation.next_operation == "PUBLISH_CI_TIME_CAUSALITY_PROTOCOL_AND_ADOPT_EXACT_CLOCK_DOMAIN_SEMANTICS" and
  .core_refutation_observation_events[0].refutation.unknown_class == null and
  .core_refutation_observation_events[0].preservation.pull_request_unmerged == true and
  .core_refutation_observation_events[0].preservation.dev_main_unchanged == true and
  .core_refutation_observation_events[0].preservation.prior_protected_path_event_preserved == true and
  (.process_deviations|length) == 1 and
  .process_deviations[0].deviation_id == "SEMANTIC_DRIFT_DIRECT_TO_MAIN-v0.10" and
  .process_deviations[0].cell_id == "SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and
  .process_deviations[0].append_only == true and
  .process_deviations[0].state == "REFUTED" and
  .process_deviations[0].stage == "DEVELOPMENT_PROCESS" and
  .process_deviations[0].step == "TRACE_SUBSTANTIVE_IMPLEMENTATION_COMMIT" and
  .process_deviations[0].reason == "SUBSTANTIVE_IMPLEMENTATION_LANDED_DIRECTLY_ON_MAIN" and
  .process_deviations[0].next_operation == "REQUIRE_PULL_REQUEST_FOR_SUBSTANTIVE_IMPLEMENTATION" and
  .process_deviations[0].observed.repository == "kimjooyoon/gooo-semantic-drift" and
  .process_deviations[0].observed.commit_sha == "e83e42611eeed30100018a98c1f1835e1f17b821" and
  .process_deviations[0].observed.parent_count == 0 and
  .process_deviations[0].observed.main_ref_after == "1cfff53e4ef48052fb25bf8c56a113d6835726a4" and
  .process_deviations[0].observed.pull_requests == [] and
  ((.cells[] | select(.cell_id == "SEMANTIC_DRIFT_DEVELOPMENT_PROCESS")) as $process |
    $process.state == "REFUTED" and
    $process.release_key == null and
    $process.refutation.stage == "DEVELOPMENT_PROCESS" and
    $process.refutation.step == "TRACE_SUBSTANTIVE_IMPLEMENTATION_COMMIT" and
    $process.refutation.reason == "SUBSTANTIVE_IMPLEMENTATION_LANDED_DIRECTLY_ON_MAIN" and
    $process.refutation.next_operation == "REQUIRE_PULL_REQUEST_FOR_SUBSTANTIVE_IMPLEMENTATION" and
    ($process.refutation.blocked_by|length) == 3) and
  .optional_dependencies[0].id == "gooo-receipt-schema-migration-v0.3" and
  .optional_dependencies[0].status == "UNRELEASED" and
  .optional_dependencies[0].required == false and
  .optional_dependencies[0].gate == false and
  (.optional_dependencies | map(select(.id == "gooo-ci-time-protocol-v0.1.0" and .status == "UNRELEASED" and .release_api == "NOT_FOUND" and .tag_api == "NOT_FOUND" and .required == false and .gate == false)) | length) == 1 and
  ((.cells[] | select(.cell_id == "CORE_SEMANTIC_AUTHORITY")) as $core |
    $core.state == "REFUTED" and
    ($core | has("unknown") | not) and
    $core.refutation.stage == "CHANGED_PATH_AUTHORIZATION_DISPATCH" and
    $core.refutation.step == "EVALUATE_PROTECTED_PATH_TUPLE_BEFORE_AUTHORIZATION" and
    $core.refutation.reason == "PROTECTED_PATH_GATE_PREEMPTS_FOUNDATION_AUTHORIZATION" and
    $core.refutation.next_operation == "PUBLISH_EXECUTABLE_PROTECTED_PATH_AUTHORIZATION_DISPATCH_AND_ADOPT_GATE_ORDER" and
    ($core.refutation | has("unknown_class") | not) and
    $core.refutation.counterexample.base_sha == "e440cbc99f24ceb8385f1b89c70f8cdada10cdbb" and
    $core.refutation.counterexample.head_sha == "8b47db349315c02933296423b0ae7fa80ffeb1dc" and
    $core.refutation.counterexample.merge_base_sha == "bc5dc21788aa4c7d46d1f8ab516f8218bb423fdc" and
    $core.refutation.counterexample.changed_files_count == 92 and
    $core.refutation.counterexample.protected_kernel_paths_count == 26 and
    $core.refutation.observed_error.message == "CI-ROOT-OF-TRUST-001: protected kernel path changed" and
    $core.refutation.observed_error.run_id == 33359548617 and
    $core.refutation.observed_error.check_run_id == 99388126433 and
    $core.refutation.observed_error.path == ".github" and
    $core.refutation.observed_error.line == 338 and
    $core.refutation.observed_digest.guardian_workflow_path == ".github/workflows/ci-guardian.yml" and
    $core.refutation.observed_digest.guardian_workflow_blob_sha == "d783b29871f75004534e52acc8fc2b50daa808c1" and
    $core.refutation.observed_digest.guardian_artifact_id == 9746232159 and
    $core.refutation.observed_digest.guardian_artifact_size_bytes == 2144 and
    $core.refutation.observed_digest.guardian_artifact_sha256 == "sha256:41ae5d2398a001b16ecd72dba937924897234dd748fdcb5374caee7e70f026a8" and
    $core.refutation.observed_guardian.foundation_bootstrap == null and
    $core.refutation.observed_guardian.foundation_authorization == null and
    $core.refutation.observed_guardian.digests == null and
    $core.refutation.observed_guardian.stage == null)
' "$repository/evidence/assessment-v1.json" >/dev/null

start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$artifact/report-peak-rss" "$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$probe/report.json" \
  -output-markdown "$probe/report.md"
end=$(date +%s%N)
report_wall=$(( (end - start) / 1000000 ))
report_raw=$((end - start))
report_rss=$(cat "$artifact/report-peak-rss")

jq --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" \
  '.timing.report={wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$rss}' \
  "$artifact/runtime.json" > "$probe/runtime.json"
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
  -output-markdown "$artifact/report.md"
end=$(date +%s%N)

jq -e '
  .schema == "gooo/self-improvement-portfolio/report/v1" and
  .profile_id == "self-improvement-portfolio-v1" and
  .summary == {total:16,closed:13,unknown:1,refuted:2} and
  .precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  (.cells|length) == 16 and
  (.cells|map(.id)|length) == (.cells|map(.id)|unique|length) and
  (.cells|map(.activity)|length) == (.cells|map(.activity)|unique|length) and
  (.cells|map(select(.numerator == 1 and .denominator == 1))|length) == 13 and
  (.cells|map(select(.state == "UNKNOWN"))|length) == 1 and
  (.cells|map(select(.state == "REFUTED"))|length) == 2 and
  ([.cells[] | {key:.id,value:.state}] | from_entries) == {
    CORE_SEMANTIC_AUTHORITY:"REFUTED",
    RESOLUTION_DESCENT:"CLOSED",
    CAUSAL_CI_SELECTION:"CLOSED",
    META_RESOURCE_BUDGET:"CLOSED",
    DENOMINATOR_EVOLUTION:"CLOSED",
    REFLEXIVE_LOOP:"CLOSED",
    IMMUTABLE_INPUT_INTEGRATION:"CLOSED",
    SEMANTIC_MERGE_ADVICE:"CLOSED",
    DESIGN_CONSUMER_PATH:"CLOSED",
    OPENTOFU_PLAN_PATH:"CLOSED",
    RELEASE_PROMOTION:"CLOSED",
    EXTERNAL_UTILITY_EVIDENCE:"UNKNOWN",
    COUNTERFACTUAL_CHANGE_RELEASE:"CLOSED",
    VERIFICATION_REUSE_RELEASE:"CLOSED",
    SEMANTIC_DRIFT_RELEASE:"CLOSED",
    SEMANTIC_DRIFT_DEVELOPMENT_PROCESS:"REFUTED"
  } and
  all(.cells[]; if .state == "UNKNOWN" then
    (.unknown|keys|sort) == ["blocked_by","next_operation","reason","stage","step","unknown_class"] and
    (.unknown.blocked_by|length) > 0
  else true end) and
  .bindings == {one_to_one:true,cells:16,activities:16,unique_axes:16,unique_metrics:16,source_bindings:16,ir_bindings:16,generated_artifact_bindings:16,evaluator_bindings:16} and
  .proof_counts.FOUNDATION.denominator == 4 and .proof_counts.COHERENCE.denominator == 7 and .proof_counts.REGRESSION.denominator == 5 and
  .indicator_counts.DRIVER.denominator == 4 and .indicator_counts.OUTCOME.denominator == 7 and .indicator_counts.GUARDRAIL.denominator == 5 and
  .releases == {total:13,verified:13,unknown:0,refuted:0} and
  .policy.aggregate_percentage == false and .policy.aggregate_score == false and
  (.performance.fetch.wall_ms|type) == "number" and (.performance.fetch.duration_ns|type) == "number" and
  (.performance.verify.wall_ms|type) == "number" and (.performance.verify.duration_ns|type) == "number" and
  (.performance.report.wall_ms|type) == "number" and (.performance.report.duration_ns|type) == "number" and
  .authority.runtime_repository_writes == 0 and .authority.caller_owned_temp_output == true and .authority.cross_project_required_gates == 0 and
  .local_execution_counts == {gofmt:0,build:0,test:0,vet:0,conformance:0} and
  (has("percentage")|not) and (has("score")|not)
' "$artifact/report.json" >/dev/null

jq -S -n --argjson report "$(cat "$artifact/report.json")" --argjson wall "$report_wall" --argjson raw "$((end - start))" \
  '{schema:"gooo/self-improvement-portfolio/conformance/v1",tests:{executed:1,reused:0,skipped:0},report_decision:$report.decision,summary:$report.summary,report_generation:{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:($report.performance.report.peak_rss_kib|tonumber)},repository_writes:$report.authority.runtime_repository_writes}' \
  > "$artifact/conformance.json"
