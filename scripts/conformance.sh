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
  .total_cells == 19 and
  .denominator_migration == {from:18,to:19,add:1,retire:0,split:0,append_only:true} and
  (.cells|map(.id)) == [
    "CORE_SEMANTIC_AUTHORITY","RESOLUTION_DESCENT","CAUSAL_CI_SELECTION","META_RESOURCE_BUDGET",
    "DENOMINATOR_EVOLUTION","REFLEXIVE_LOOP","IMMUTABLE_INPUT_INTEGRATION","SEMANTIC_MERGE_ADVICE",
    "DESIGN_CONSUMER_PATH","OPENTOFU_PLAN_PATH","RELEASE_PROMOTION","EXTERNAL_UTILITY_EVIDENCE",
    "COUNTERFACTUAL_CHANGE_RELEASE","VERIFICATION_REUSE_RELEASE","SEMANTIC_DRIFT_RELEASE","SEMANTIC_DRIFT_DEVELOPMENT_PROCESS","IMPROVEMENT_FRONTIER_RELEASE","AUTHORITY_BOOTSTRAP_RELEASE","OPENTOFU_ENVELOPE_RELEASE"
  ] and
  .proof_totals == {FOUNDATION:4,COHERENCE:10,REGRESSION:5} and
  .indicator_totals == {DRIVER:4,OUTCOME:10,GUARDRAIL:5} and
  (.cells|map(select(.id=="COUNTERFACTUAL_CHANGE_RELEASE" and .release_key=="counterfactual_change_release"))|length)==1 and
  (.cells|map(select(.id=="VERIFICATION_REUSE_RELEASE" and .release_key=="verification_reuse_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_RELEASE" and .release_key=="semantic_drift_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and .release_key==null))|length)==1 and
  (.cells|map(select(.id=="IMPROVEMENT_FRONTIER_RELEASE" and .release_key=="improvement_frontier_release"))|length)==1 and
  (.cells|map(select(.id=="AUTHORITY_BOOTSTRAP_RELEASE" and .release_key=="authority_bootstrap_release"))|length)==1 and
  (.cells|map(select(.id=="OPENTOFU_ENVELOPE_RELEASE" and .release_key=="opentofu_envelope_release"))|length)==1
' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null

jq -e '
  .releases.counterfactual_change_release.release_id == 379663025 and .releases.counterfactual_change_release.tag_object_sha == "b9ddb3bf434988508fa848ed0e3891a38092d09d" and
  .releases.verification_reuse_release.release_id == 379662322 and .releases.verification_reuse_release.tag_object_sha == "3d9bf3374b4ad7e649499ff4a2538b9ff16fab7a" and
  .releases.semantic_drift_release.release_id == 379664434 and .releases.semantic_drift_release.tag_object_sha == "537e5bb79ba4fa34fbe224aa2f40a62b06a35780" and
  .releases.improvement_frontier_release.release_id == 379728340 and .releases.improvement_frontier_release.tag_object_sha == "72e59658ff08c47c7e7accd8b3af470a87da428d" and
  .releases.improvement_frontier_release.target_commit_sha == "5749a883b85cc4ede1e53d124f1e3685b23189bd" and
  .releases.improvement_frontier_release.source_run.run_id == 33390644439 and .releases.improvement_frontier_release.source_run.job_id == 99483229767 and
  .releases.improvement_frontier_release.source_run.artifact_ids == [9757307658] and
  .releases.improvement_frontier_release.protocol_receipt.schema == "gooo/improvement-frontier/ci-runtime/v1" and
  .releases.improvement_frontier_release.protocol_receipt.ci_run_id == "33390644439" and .releases.improvement_frontier_release.protocol_receipt.ci_job_id == "99483229767" and
  .releases.improvement_frontier_release.protocol_receipt.build_wall_ms == 3950 and .releases.improvement_frontier_release.protocol_receipt.test_wall_ms == 1770 and .releases.improvement_frontier_release.protocol_receipt.peak_rss_kib == 282632 and
  .releases.improvement_frontier_release.protocol_receipt.tests == {discovered:5,executed:5,reused:0,skipped:0,not_observed:0} and
  .releases.improvement_frontier_release.protocol_receipt.product_authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  .releases.authority_bootstrap_release.release_id == 379750047 and .releases.authority_bootstrap_release.tag_object_sha == "c210a109b513b528a2f690d29bf279e794e260a7" and
  .releases.authority_bootstrap_release.target_commit_sha == "e7e6dc0afde6536bb39f94fdfc7ce1e97e4bbefa" and
  .releases.authority_bootstrap_release.source_run.run_id == 33393255047 and .releases.authority_bootstrap_release.source_run.job_id == 99491647091 and
  .releases.authority_bootstrap_release.source_run.artifact_ids == [9758302892] and
  .releases.authority_bootstrap_release.post_main_validation.run_id == 33393255004 and .releases.authority_bootstrap_release.post_main_validation.job_id == 99491646530 and
  .releases.authority_bootstrap_release.protocol_receipt.receipt_id == "bootstrap:sha256:8b50736fba55e5543a0bd85343e42471a781ae36c624fb83c90754059e938ac7" and
  .releases.authority_bootstrap_release.protocol_receipt.decision == "UNKNOWN" and
  .releases.authority_bootstrap_release.protocol_receipt.choice == "FOUNDATION" and
  .releases.authority_bootstrap_release.protocol_receipt.immutable == false and
  .releases.authority_bootstrap_release.protocol_receipt.digest == "sha256:5769342e877e09c78a91e22227d18665a6ea1f07a207f317142bc5a205c6a2e8" and
  .releases.opentofu_envelope_release.release_id == 379769579 and .releases.opentofu_envelope_release.tag_object_sha == "1d8e07c49b700b7e72ec9c413157d851188c09b6" and
  .releases.opentofu_envelope_release.target_commit_sha == "6b482d402f4ceff8a8b23205cce8db5154305382" and
  .releases.opentofu_envelope_release.source_run.run_id == 33395964320 and .releases.opentofu_envelope_release.source_run.job_id == 99500428082 and
  .releases.opentofu_envelope_release.source_run.artifact_ids == [9759323399] and
  .releases.opentofu_envelope_release.pre_merge_validation.run_id == 33395904751 and .releases.opentofu_envelope_release.pre_merge_validation.job_id == 99500238300 and
  .releases.opentofu_envelope_release.source_artifact.artifact_id == 9759323399 and .releases.opentofu_envelope_release.source_artifact.size_bytes == 78041 and
  .releases.opentofu_envelope_release.source_artifact.sha256 == "sha256:74fafb9f3a74485d16382a02413279efd1b12b5f111012bef9f61fa2edfcff0e" and
  .releases.opentofu_envelope_release.protocol_observation.activities == 12 and .releases.opentofu_envelope_release.protocol_observation.cells == 12 and
  .releases.opentofu_envelope_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.opentofu_envelope_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.opentofu_envelope_release.protocol_observation.case_totals == {CLOSED:3,UNKNOWN:3,REFUTED:3} and
  .releases.opentofu_envelope_release.protocol_observation.improvement == "UNKNOWN" and
  .releases.opentofu_envelope_release.protocol_observation.toolchain == {go:"1.27.0",opentofu:"1.12.6"} and
  .releases.opentofu_envelope_release.protocol_observation.timing == {build_wall_ms:60,test_wall_ms:53,conformance_wall_ms:190,peak_rss_kib:79436} and
  .releases.opentofu_envelope_release.protocol_observation.tests == {discovered:9,executed:9,reused:0,skipped:0,not_observed:0} and
  .releases.opentofu_envelope_release.protocol_observation.inventory == {directories:7,files:8,physical_lines:1186,go_files:0,go_lines:0,gooo_files:1,gooo_lines:29,root_readme_excluded:true} and
  .releases.opentofu_envelope_release.protocol_observation.generated_artifacts == {"dossier.md":"sha256:050abdece8bd4e1a4a774c4653510fc928e4c31bb45bd2efefcde6b35a832259","intent.tf.json":"sha256:125d7e976eecce0cc1a5d25d5571182db9d69acc8427807a1d786a36f6ca8886"} and
  .releases.opentofu_envelope_release.protocol_observation.identity == {source:"sha256:fffcff1afb76789beff6fd05e30680827e49c1132eec82b8069f7b9243fc6158",graph:"sha256:b057638f2bb1d0dc0852ff68c574535ded91b36bf566cc2714929a2a93d87c98",artifact:"sha256:125d7e976eecce0cc1a5d25d5571182db9d69acc8427807a1d786a36f6ca8886",plan_receipt:"sha256:4b01678ff1602376267b366aac2100332dfeb63b19c0d2b689c6ada81256a4c5",validation:"sha256:125d7e976eecce0cc1a5d25d5571182db9d69acc8427807a1d786a36f6ca8886",replay:"sha256:050abdece8bd4e1a4a774c4653510fc928e4c31bb45bd2efefcde6b35a832259"} and
  .releases.opentofu_envelope_release.protocol_observation.authority.repository_writes == 0 and
  .releases.opentofu_envelope_release.protocol_observation.authority.local_test_executions == 0 and
  .releases.opentofu_envelope_release.protocol_observation.authority.cross_project_required_gates == 0 and
  (.releases.counterfactual_change_release.assets|map(.id)) == [537808326,537808327,537808330] and
  (.releases.verification_reuse_release.assets|map(.id)) == [537806848,537806851,537806849] and
  (.releases.semantic_drift_release.assets|map(.id)) == [537811623] and
  (.releases.improvement_frontier_release.assets|map(.id)) == [537940229,537940232] and
  (.releases.authority_bootstrap_release.assets|map(.id)) == [537976435,537976439,537976449,537976437,537976436,537976438] and
  (.releases.opentofu_envelope_release.assets|map(.id)) == [538012631,538012630] and
  (.counterexamples|map(.counterexample_id)|sort) == ["counterfactual_change_v0.1.0_mutable","counterfactual_change_v0.1.1_mutable","opentofu_envelope_v0.1.0_failed_release_immutability","semantic_drift_v0.1.0_mutable","verification_reuse_v0.1.1_mutable"] and
  all(.counterexamples[0:4][]; .immutable==false and .append_only==true and .reason=="RELEASE_API_IMMUTABLE_FALSE") and
  .counterexamples[4].immutable == false and .counterexamples[4].append_only == true and .counterexamples[4].reason == "FAILED_RELEASE_IMMUTABILITY" and
  (.counterexample_runs|length) == 8 and
  (.counterexample_runs|map(.run_id)) == [33390048056,33390048173,33390167631,33390171403,33390257810,33390263187,33394717115,33394727232] and
  all(.counterexample_runs[]; .append_only==true and .conclusion=="failure") and
  all(.counterexample_runs[0:6][]; .job_name=="conformance") and
  all(.counterexample_runs[6:][]; .job_name=="envelope" and .reason=="FAILED_CI_VALIDATION")
' "$repository/contracts/release-locks-v1.json" >/dev/null

jq -e '
  .denominator_migration == {from:18,to:19,add:1,retire:0,split:0,append_only:true} and
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
  (.cells|length) == 18 and
  ((.cells[] | select(.cell_id == "IMPROVEMENT_FRONTIER_RELEASE")) as $frontier |
    $frontier.state == "CLOSED" and
    $frontier.release_key == "improvement_frontier_release" and
    ($frontier.evidence | index("release:379728340:immutable=true")) != null and
    ($frontier.evidence | index("tag-object:72e59658ff08c47c7e7accd8b3af470a87da428d:target=5749a883b85cc4ede1e53d124f1e3685b23189bd")) != null and
    ($frontier.evidence | index("source-actions:run=33390644439:job=99483229767:success")) != null and
    ($frontier.evidence | index("source-actions-artifact:9757307658")) != null and
    ($frontier.evidence | index("asset:537940229:1024:sha256:562db1b6f224a3b732f9b8bb57f1efdcf33d6653e239ffb021fe3e7d9cf2baf4")) != null and
    ($frontier.evidence | index("asset:537940232:25799:sha256:66ac3b7d659c470544b8bd24d9c79ee50d2d250b2f6162cb5fb79b05a9000388")) != null and
    ($frontier.evidence | index("receipt:gooo/improvement-frontier/ci-runtime/v1:tests=5/5/0/0/0:build=3950:test=1770:peak_rss_kib=282632:authority=0/0/0")) != null) and
  ((.cells[] | select(.cell_id == "AUTHORITY_BOOTSTRAP_RELEASE")) as $authority |
    $authority.state == "CLOSED" and
    $authority.release_key == "authority_bootstrap_release" and
    ($authority.evidence | index("release:379750047:immutable=true")) != null and
    ($authority.evidence | index("tag-object:c210a109b513b528a2f690d29bf279e794e260a7:target=e7e6dc0afde6536bb39f94fdfc7ce1e97e4bbefa")) != null and
    ($authority.evidence | index("source-actions:run=33393255047:job=99491647091:success")) != null and
    ($authority.evidence | index("source-actions:required-validation-run=33393255004:job=99491646530:success")) != null and
    ($authority.evidence | index("source-actions-artifact:9758302892:5866:sha256:c17b2dfdeb77618fe0f0d2ebd0ee7f786cbd0977113c79f585dd98dff5b8c86d")) != null and
    ($authority.evidence | index("asset:537976435:2013:sha256:0f47a1c5007b9b48959e9565acf37c3c90ec8de5607c1dffc2343151e42984da")) != null and
    ($authority.evidence | index("asset:537976439:1243:sha256:694675761099f4b11b713e6766951ee815c3fad2706d1f3f2dcd88ae8290d8ac")) != null and
    ($authority.evidence | index("asset:537976449:5474:sha256:6a3de849fef78d9fd45224e4bdbe030d8bf7e03691b61801b8593acef9e1ff4b")) != null and
    ($authority.evidence | index("asset:537976437:1568:sha256:e1e8d286600728ddab88f53bc24850e45a67a9cdeb02d241c10c84d99ccae15f")) != null and
    ($authority.evidence | index("asset:537976436:791:sha256:fbff7ae34049d6d271cd7b46b471e4f7fc9b0616d3167301bcd094338c84d30b")) != null and
    ($authority.evidence | index("asset:537976438:4608:sha256:d05050c11ca5c4b35737ee12f233cbf0d9330bcd5b582526b13b36d5dd49cb40")) != null and
    ($authority.evidence | index("bootstrap-receipt:decision=UNKNOWN:immutable=false:digest=sha256:5769342e877e09c78a91e22227d18665a6ea1f07a207f317142bc5a205c6a2e8")) != null) and
  ((.cells[] | select(.cell_id == "OPENTOFU_ENVELOPE_RELEASE")) as $envelope |
    $envelope.state == "CLOSED" and
    $envelope.release_key == "opentofu_envelope_release" and
    ($envelope.evidence | index("release:379769579:immutable=true")) != null and
    ($envelope.evidence | index("tag-object:1d8e07c49b700b7e72ec9c413157d851188c09b6:target=6b482d402f4ceff8a8b23205cce8db5154305382")) != null and
    ($envelope.evidence | index("source-actions:pr-run=33395904751:job=99500238300:success")) != null and
    ($envelope.evidence | index("source-actions:post-main-run=33395964320:job=99500428082:success")) != null and
    ($envelope.evidence | index("source-actions-artifact:9759323399:78041:sha256:74fafb9f3a74485d16382a02413279efd1b12b5f111012bef9f61fa2edfcff0e")) != null and
    ($envelope.evidence | index("asset:538012631:17829:sha256:dc8a466ecc4ea2f5c127dcc59985252ba8a01a7ae6eb8fb1caa63f7f595fcd31")) != null and
    ($envelope.evidence | index("asset:538012630:109:sha256:73eabf693676e918d42dae77f78d901045cd4a014387ea95917b9b9b29a00b55")) != null and
    ($envelope.evidence | index("upstream-facts:activities=12:cells=12:proof=4/4/4:indicator=4/4/4:cases=3/3/3:improvement=UNKNOWN:go=1.27.0:opentofu=1.12.6:build=60:test=53:conformance=190:peak_rss_kib=79436:tests=9/0/0/0:authority=0/0/0")) != null and
    ($envelope.evidence | index("upstream-inventory:dirs=7:files=8:lines=1186:go=0/0:gooo=1/29:root_readme_excluded=true")) != null and
    ($envelope.evidence | index("upstream-cases:CLOSED=3:UNKNOWN=3:REFUTED=3:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($envelope.evidence | index("counterexample-release:379762192:immutable=false:tag-object=6aca4fde71d6fdd8800000c7fb0f9b687a67423e:target=1a908f0c7504654b6ead83beebb0caff1ad16374:reason=FAILED_RELEASE_IMMUTABILITY")) != null and
    ($envelope.evidence | index("counterexample-run:33394717115:job=99496382005:failure:reason=FAILED_CI_VALIDATION")) != null and
    ($envelope.evidence | index("counterexample-run:33394727232:job=99496415701:failure:reason=FAILED_CI_VALIDATION")) != null) and
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
  .summary == {total:19,closed:16,unknown:1,refuted:2} and
  .precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  (.cells|length) == 19 and
  (.cells|map(.id)|length) == (.cells|map(.id)|unique|length) and
  (.cells|map(.activity)|length) == (.cells|map(.activity)|unique|length) and
  (.cells|map(select(.numerator == 1 and .denominator == 1))|length) == 16 and
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
    SEMANTIC_DRIFT_DEVELOPMENT_PROCESS:"REFUTED",
    IMPROVEMENT_FRONTIER_RELEASE:"CLOSED",
    AUTHORITY_BOOTSTRAP_RELEASE:"CLOSED",
    OPENTOFU_ENVELOPE_RELEASE:"CLOSED"
  } and
  all(.cells[]; if .state == "UNKNOWN" then
    (.unknown|keys|sort) == ["blocked_by","next_operation","reason","stage","step","unknown_class"] and
    (.unknown.blocked_by|length) > 0
  else true end) and
  .bindings == {one_to_one:true,cells:19,activities:19,unique_axes:19,unique_metrics:19,source_bindings:19,ir_bindings:19,generated_artifact_bindings:19,evaluator_bindings:19} and
  .proof_counts.FOUNDATION.denominator == 4 and .proof_counts.COHERENCE.denominator == 10 and .proof_counts.REGRESSION.denominator == 5 and
  .indicator_counts.DRIVER.denominator == 4 and .indicator_counts.OUTCOME.denominator == 10 and .indicator_counts.GUARDRAIL.denominator == 5 and
  .releases == {total:16,verified:16,unknown:0,refuted:0} and
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
