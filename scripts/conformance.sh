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
  .total_cells == 23 and
  .denominator_migration == {from:22,to:23,add:1,retire:0,split:0,append_only:true} and
  (.cells|map(.id)) == [
    "CORE_SEMANTIC_AUTHORITY","RESOLUTION_DESCENT","CAUSAL_CI_SELECTION","META_RESOURCE_BUDGET",
    "DENOMINATOR_EVOLUTION","REFLEXIVE_LOOP","IMMUTABLE_INPUT_INTEGRATION","SEMANTIC_MERGE_ADVICE",
    "DESIGN_CONSUMER_PATH","OPENTOFU_PLAN_PATH","RELEASE_PROMOTION","EXTERNAL_UTILITY_EVIDENCE",
    "COUNTERFACTUAL_CHANGE_RELEASE","VERIFICATION_REUSE_RELEASE","SEMANTIC_DRIFT_RELEASE","SEMANTIC_DRIFT_DEVELOPMENT_PROCESS","IMPROVEMENT_FRONTIER_RELEASE","AUTHORITY_BOOTSTRAP_RELEASE","OPENTOFU_ENVELOPE_RELEASE","IMPROVEMENT_PROPOSER_RELEASE","TEST_FRONTIER_RELEASE","CHANGE_BUNDLE_RELEASE","UTILITY_TRIAL_PROTOCOL_RELEASE"
  ] and
  .proof_totals == {FOUNDATION:4,COHERENCE:14,REGRESSION:5} and
  .indicator_totals == {DRIVER:4,OUTCOME:14,GUARDRAIL:5} and
  (.cells|map(select(.id=="COUNTERFACTUAL_CHANGE_RELEASE" and .release_key=="counterfactual_change_release"))|length)==1 and
  (.cells|map(select(.id=="VERIFICATION_REUSE_RELEASE" and .release_key=="verification_reuse_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_RELEASE" and .release_key=="semantic_drift_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and .release_key==null))|length)==1 and
  (.cells|map(select(.id=="IMPROVEMENT_FRONTIER_RELEASE" and .release_key=="improvement_frontier_release"))|length)==1 and
  (.cells|map(select(.id=="AUTHORITY_BOOTSTRAP_RELEASE" and .release_key=="authority_bootstrap_release"))|length)==1 and
  (.cells|map(select(.id=="OPENTOFU_ENVELOPE_RELEASE" and .release_key=="opentofu_envelope_release"))|length)==1 and
  (.cells|map(select(.id=="IMPROVEMENT_PROPOSER_RELEASE" and .release_key=="improvement_proposer_release"))|length)==1 and
  (.cells|map(select(.id=="TEST_FRONTIER_RELEASE" and .release_key=="test_frontier_release"))|length)==1 and
  (.cells|map(select(.id=="CHANGE_BUNDLE_RELEASE" and .release_key=="change_bundle_release"))|length)==1 and
  (.cells|map(select(.id=="UTILITY_TRIAL_PROTOCOL_RELEASE" and .release_key=="utility_trial_protocol_release"))|length)==1
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
  .releases.improvement_proposer_release.release_id == 379780599 and .releases.improvement_proposer_release.tag_object_sha == "2ed70c6fae93c21b0c4839d4fa2ff0f4da3ebc59" and
  .releases.improvement_proposer_release.target_commit_sha == "6757651d5b6abae7dfb7c7a3ec7a0cab103e3279" and
  .releases.improvement_proposer_release.source_run.run_id == 33397372252 and .releases.improvement_proposer_release.source_run.job_id == 99505021461 and
  .releases.improvement_proposer_release.source_run.artifact_ids == [9759855868] and
  .releases.improvement_proposer_release.release_run.run_id == 33397566380 and .releases.improvement_proposer_release.release_run.job_id == 99505669083 and
  .releases.improvement_proposer_release.source_artifact.artifact_id == 9759855868 and .releases.improvement_proposer_release.source_artifact.size_bytes == 2916595 and
  .releases.improvement_proposer_release.source_artifact.sha256 == "sha256:79c6a8acf82e1e94e1529b7c43e0aef7f922ea7bc77c79ab13758a033cfade20" and
  .releases.improvement_proposer_release.protocol_observation.fixed_artifacts == ["proposal.json","candidate-events.ndjson","semantic-ir.json","generated-evaluator.go","replay-receipt.json","human-dossier.md"] and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|length) == 9 and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|map(select(.state=="CLOSED"))|length) == 3 and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|map(select(.state=="UNKNOWN"))|length) == 3 and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|map(select(.state=="REFUTED"))|length) == 3 and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|map(.candidates[]?.causal_source_cells[]?)|unique|sort) == ["cell-03","cell-05"] and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|map(.unknowns[]?.unknown_class)|unique|sort) == ["DEPENDENCY_BLOCKED","DIRECT_MISSING","STALE_INPUT"] and
  (.releases.improvement_proposer_release.protocol_observation.case_facts|map(.refutations[]?)|unique|sort) == ["KNOWN_EVIDENCE_CONTRADICTION:capability.contradiction","capability-record-refuted:KNOWN_CAPABILITY_COUNTEREXAMPLE","utility-record-refuted:UTILITY_EVIDENCE_REFUTED"] and
  .releases.improvement_proposer_release.protocol_observation.case_totals == {normal:3,unknown:3,refuted:3,CLOSED:3,UNKNOWN:3,REFUTED:3} and
  .releases.improvement_proposer_release.protocol_observation.authority == {cross_project_required_gates:0,local_test_executions:0,merge_operations:0,pull_request_creations:0,repository_writes:0} and
  (.releases.improvement_proposer_release.assets|map(.id)) == [538032347,538032342,538032346,538032343] and
  (.releases.improvement_proposer_release.pull_requests|map(.number)) == [1,2,3,4] and
  all(.releases.improvement_proposer_release.pull_requests[]; .merged==true) and
  .releases.test_frontier_release.release_id == 379783807 and .releases.test_frontier_release.tag_object_sha == "398577621c42eb7450416bdf086b9304c8c1e42a" and
  .releases.test_frontier_release.target_commit_sha == "f8e1f8aebb67abbda237073893a4a855a8659df5" and
  .releases.test_frontier_release.source_run.run_id == 33398482775 and .releases.test_frontier_release.source_run.job_id == 99508698139 and
  .releases.test_frontier_release.source_run.artifact_ids == [9760281954] and
  .releases.test_frontier_release.release_run.run_id == 33398545885 and .releases.test_frontier_release.release_run.job_id == 99508911340 and
  .releases.test_frontier_release.source_artifact.artifact_id == 9760281954 and .releases.test_frontier_release.source_artifact.size_bytes == 2777788 and
  .releases.test_frontier_release.source_artifact.sha256 == "sha256:91f33f285012e6a95861b30f2f7fb259f80165dba99d6087cc261d891619d614" and
  .releases.test_frontier_release.release_manifest.schema == "gooo/test-frontier/release-manifest/v1" and
  .releases.test_frontier_release.release_manifest.tag_object_sha == "398577621c42eb7450416bdf086b9304c8c1e42a" and
  .releases.test_frontier_release.release_manifest.source_asset_digest == "sha256:1ef4c6a13288cb8198734e8fde252d470169b2b4f0d09006fdf467d5317917f8" and
  .releases.test_frontier_release.protocol_observation.fixed_denominator == 12 and .releases.test_frontier_release.protocol_observation.activities == 12 and .releases.test_frontier_release.protocol_observation.cells == 12 and
  .releases.test_frontier_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.test_frontier_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.test_frontier_release.protocol_observation.case_totals == {normal:3,unknown:3,refuted:4,CLOSED:3,UNKNOWN:3,REFUTED:4} and
  .releases.test_frontier_release.protocol_observation.precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .releases.test_frontier_release.protocol_observation.tests == {total:40,executed:9,reused:16,skipped:10,not_observed:5,sum_is_exactly_total:true} and
  .releases.test_frontier_release.protocol_observation.invalidated_edge_count == 20 and .releases.test_frontier_release.protocol_observation.output_artifacts == 31 and
  .releases.test_frontier_release.protocol_observation.runtime == {go:"1.27.0",build_wall_ms:5820,test_wall_ms:7680,conformance_wall_ms:0,peak_rss_kib:274908} and
  .releases.test_frontier_release.protocol_observation.inventory == {directories:14,files:33,physical_lines:2563,go_files:8,go_lines:1637,gooo_files:1,gooo_lines:15,root_readme_excluded:true} and
  .releases.test_frontier_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  .releases.test_frontier_release.protocol_observation.improvement == null and
  (.releases.test_frontier_release.protocol_observation.case_facts|length) == 10 and
  (.releases.test_frontier_release.protocol_observation.case_facts|map(select(.state=="CLOSED"))|length) == 3 and
  (.releases.test_frontier_release.protocol_observation.case_facts|map(select(.state=="UNKNOWN"))|length) == 3 and
  (.releases.test_frontier_release.protocol_observation.case_facts|map(select(.state=="REFUTED"))|length) == 4 and
  (.releases.test_frontier_release.assets|map(.id)) == [538036992,538036991,538036990] and
  (.releases.test_frontier_release.pull_requests|map(.number)) == [1,2,3,4] and
  all(.releases.test_frontier_release.pull_requests[]; .merged==true) and
  .releases.change_bundle_release.release_id == 379788730 and .releases.change_bundle_release.tag_object_sha == "09885ac7480d1ee2e350e907f5dc408b35188f47" and
  .releases.change_bundle_release.target_commit_sha == "a93c41a28b5718f110b8679556b169f2b11c75b5" and
  .releases.change_bundle_release.source_run.run_id == 33398653367 and .releases.change_bundle_release.source_run.job_id == 99509422788 and
  .releases.change_bundle_release.source_run.job_name == "audit" and .releases.change_bundle_release.source_run.artifact_ids == [9760351466] and
  .releases.change_bundle_release.release_run.run_id == 33398653367 and .releases.change_bundle_release.release_run.job_id == 99509268842 and
  .releases.change_bundle_release.release_run.job_name == "release" and .releases.change_bundle_release.release_run.artifact_ids == [] and
  .releases.change_bundle_release.source_artifact.artifact_id == 9760351466 and .releases.change_bundle_release.source_artifact.size_bytes == 735 and
  .releases.change_bundle_release.source_artifact.sha256 == "sha256:30b54d122e4e32f47fecc74f93345e7f9a04a15c1c757f4f83cad36e2ba5f762" and
  .releases.change_bundle_release.release_manifest.schema == "gooo/change-bundle/release-manifest/v1" and
  .releases.change_bundle_release.release_manifest.commit_sha == "a93c41a28b5718f110b8679556b169f2b11c75b5" and
  .releases.change_bundle_release.release_manifest.tag_object_sha == "09885ac7480d1ee2e350e907f5dc408b35188f47" and
  .releases.change_bundle_release.protocol_observation.fixed_denominator == 12 and .releases.change_bundle_release.protocol_observation.activities == 12 and .releases.change_bundle_release.protocol_observation.cells == 12 and
  .releases.change_bundle_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.change_bundle_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.change_bundle_release.protocol_observation.case_totals == {CLOSED:3,UNKNOWN:3,REFUTED:6} and
  .releases.change_bundle_release.protocol_observation.bundle == {files:15,bytes:17527} and
  .releases.change_bundle_release.protocol_observation.change == {changed_paths:1,changed_hunks:1} and
  .releases.change_bundle_release.protocol_observation.replay == {comparisons:13,mismatches:0} and
  .releases.change_bundle_release.protocol_observation.rollback == {comparisons:1,mismatches:0} and
  .releases.change_bundle_release.protocol_observation.runtime == {go:"1.27.0",build_wall_ms:224,test_wall_ms:2414,conformance_wall_ms:5,peak_rss_kib:112032} and
  .releases.change_bundle_release.protocol_observation.tests == {executed:16,reused:0,skipped:0,not_observed:0} and
  .releases.change_bundle_release.protocol_observation.inventory == {files:22,directories:14,go_lines:2049,gooo_lines:18,root_readme_excluded:true} and
  .releases.change_bundle_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  (.releases.change_bundle_release.assets|map(.id)) == [538044874,538044878,538044876,538044877,538044875] and
  (.releases.change_bundle_release.pull_requests|map(.number)) == [1,2] and
  all(.releases.change_bundle_release.pull_requests[]; .merged==true) and
  .releases.utility_trial_protocol_release.release_id == 379863199 and .releases.utility_trial_protocol_release.tag_object_sha == "5a42a68fb1f9a54eaa33097fb6eeca4db421bf05" and
  .releases.utility_trial_protocol_release.target_commit_sha == "5500f00ec67b75fadf450110acefca713c5b5733" and
  .releases.utility_trial_protocol_release.source_run.run_id == 33409188187 and .releases.utility_trial_protocol_release.source_run.job_id == 99544202999 and
  .releases.utility_trial_protocol_release.source_run.job_name == "immutable-v0.1.1-release" and .releases.utility_trial_protocol_release.source_run.artifact_ids == [9764422074] and
  .releases.utility_trial_protocol_release.release_run.run_id == 33409188187 and .releases.utility_trial_protocol_release.release_run.job_id == 99544202999 and
  .releases.utility_trial_protocol_release.pre_merge_validation.run_id == 33409087319 and .releases.utility_trial_protocol_release.pre_merge_validation.job_id == 99543871814 and
  .releases.utility_trial_protocol_release.post_main_validation.run_id == 33409165999 and .releases.utility_trial_protocol_release.post_main_validation.job_id == 99544131261 and
  .releases.utility_trial_protocol_release.source_artifact.artifact_id == 9764422074 and .releases.utility_trial_protocol_release.source_artifact.size_bytes == 2764537 and
  .releases.utility_trial_protocol_release.source_artifact.sha256 == "sha256:a690b16b4ec7f6271eee23bffa52f1209ab238cfd21ff15f75f7f61a5e93adee" and
  .releases.utility_trial_protocol_release.release_audit.schema == "gooo/utility-trial/release-audit/v1" and
  .releases.utility_trial_protocol_release.release_audit.v0_1_0_preserved.release_id == 379850805 and
  .releases.utility_trial_protocol_release.protocol_observation.activities == 12 and .releases.utility_trial_protocol_release.protocol_observation.cells == 12 and
  .releases.utility_trial_protocol_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.utility_trial_protocol_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.utility_trial_protocol_release.protocol_observation.case_totals == {CLOSED:3,UNKNOWN:3,REFUTED:6} and
  .releases.utility_trial_protocol_release.protocol_observation.protocol_ready == "CLOSED" and .releases.utility_trial_protocol_release.protocol_observation.utility == "UNKNOWN" and
  .releases.utility_trial_protocol_release.protocol_observation.external_evidence == 0 and .releases.utility_trial_protocol_release.protocol_observation.eligible_pairs == 0 and
  .releases.utility_trial_protocol_release.protocol_observation.process == "REFUTED" and .releases.utility_trial_protocol_release.protocol_observation.score == "NOT_COMBINED" and
  .releases.utility_trial_protocol_release.protocol_observation.denominator_migration.operation == "NONE" and .releases.utility_trial_protocol_release.protocol_observation.denominator_migration.delta == 0 and
  .releases.utility_trial_protocol_release.protocol_observation.runtime == {go:"1.27.0",build_wall_ms:6690,test_wall_ms:8238,conformance_wall_ms:9,build_peak_rss_kib:268608,test_peak_rss_kib:264144,conformance_peak_rss_kib:7128} and
  .releases.utility_trial_protocol_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  (.releases.utility_trial_protocol_release.assets|map(.id)) == [538178108,538178107] and
  (.releases.utility_trial_protocol_release.pull_requests|map(.number)) == [3] and
  all(.releases.utility_trial_protocol_release.pull_requests[]; .merged==true) and
  (.failed_release_triggers|length) == 1 and
  .failed_release_triggers[0].counterexample_id == "improvement_proposer_v0.1.0_failed_release_trigger" and
  .failed_release_triggers[0].release_api_status == 404 and .failed_release_triggers[0].release_absent == true and
  .failed_release_triggers[0].tag_object_sha == "9acc18c4f021a42fbd41f2c67f22bb1df1152187" and
  .failed_release_triggers[0].target_commit_sha == "2007b49fdf60765b1868636da75b980f0c16db28" and
  .failed_release_triggers[0].failed_run.run_id == 33396465907 and .failed_release_triggers[0].failed_run.job_id == 99502048200 and
  .failed_release_triggers[0].reason == "FAILED_RELEASE_TRIGGER" and .failed_release_triggers[0].append_only == true and
  (.counterexamples|map(.counterexample_id)|sort) == ["change_bundle_v0.1.0_platform_immutability","counterfactual_change_v0.1.0_mutable","counterfactual_change_v0.1.1_mutable","opentofu_envelope_v0.1.0_failed_release_immutability","semantic_drift_v0.1.0_mutable","test_frontier_v0.1.0_platform_immutability","utility_trial_v0.1.0_release_history_rewrite","verification_reuse_v0.1.1_mutable"] and
  all(.counterexamples[0:4][]; .immutable==false and .append_only==true and .reason=="RELEASE_API_IMMUTABLE_FALSE") and
  .counterexamples[4].immutable == false and .counterexamples[4].append_only == true and .counterexamples[4].reason == "FAILED_RELEASE_IMMUTABILITY" and
  .counterexamples[5].immutable == false and .counterexamples[5].append_only == true and .counterexamples[5].reason == "SELF_ASSERTED_IMMUTABILITY_CONTRADICTED_BY_PLATFORM" and
  .counterexamples[5].self_asserted_immutable == true and .counterexamples[5].platform_immutable == false and
  .counterexamples[5].direct_main_observation.commit_sha == "7281ead57069050b73538fa247953a4d1d6d1822" and .counterexamples[5].direct_main_observation.changed_paths == [".github/workflows/release.yml"] and .counterexamples[5].direct_main_observation.pull_requests == [] and
  .counterexamples[5].failed_release_audit.run_id == 33396179603 and .counterexamples[5].failed_release_audit.job_id == 99501127520 and .counterexamples[5].failed_release_audit.conclusion == "failure" and
  (.counterexamples[5].assets|map(.id)) == [538014107,538014106,538014109] and
  .counterexamples[6].immutable == false and .counterexamples[6].append_only == true and .counterexamples[6].reason == "SELF_ASSERTED_IMMUTABILITY_CONTRADICTED_BY_PLATFORM" and
  .counterexamples[6].self_asserted_immutable == true and .counterexamples[6].platform_immutable == false and
  .counterexamples[6].development_process.state == "REFUTED" and .counterexamples[6].development_process.classification == "DEVELOPMENT_PROCESS_DIRECT_MAIN" and
  (.counterexamples[6].development_process.commits|map(.commit_sha)) == ["5e370da7a36ac1cae339825a6c4c9cc52c3e76b6","51600eac0abc92edb0883b5cff15b31d27a006d6","3d53c9ada1371b8c97eb0ca582715f0d47486bc9"] and
  all(.counterexamples[6].development_process.commits[]; .pull_requests == []) and
  (.counterexamples[6].assets|map(.id)) == [538025186,538025184,538025183,538025185,538025187] and
  .counterexamples[7].immutable == false and .counterexamples[7].append_only == true and .counterexamples[7].historical_release == true and
  .counterexamples[7].reason == "RELEASE_HISTORY_REWRITE_PROCESS" and .counterexamples[7].release_id == 379848683 and .counterexamples[7].release_api_status == 404 and
  .counterexamples[7].failed_release_audit.run_id == 33407273856 and .counterexamples[7].failed_release_audit.job_id == 99537841162 and
  .counterexamples[7].failed_release_audit.artifact_id == 9763659711 and .counterexamples[7].failed_release_audit.artifact_size_bytes == 2708572 and
  .counterexamples[7].failed_release_audit.artifact_sha256 == "sha256:46e54370a7215ea3eb0dd368f55eb035cc50e270d330b231656a9cf052fd6f99" and
  (.counterexamples[7].assets|map(.id)) == [538154567,538154571] and
  .counterexamples[7].current_historical_release.release_id == 379850805 and .counterexamples[7].current_historical_release.immutable == true and
  .counterexamples[7].current_historical_release.tag_object_sha == "e30bca521d127d929043557198557710d35afcd2" and
  .counterexamples[7].current_historical_release.target_commit_sha == "6521e699f1e1180b7e942ae18d0948383c3d544e" and
  (.counterexample_runs|length) == 8 and
  (.counterexample_runs|map(.run_id)) == [33390048056,33390048173,33390167631,33390171403,33390257810,33390263187,33394717115,33394727232] and
  all(.counterexample_runs[]; .append_only==true and .conclusion=="failure") and
  all(.counterexample_runs[0:6][]; .job_name=="conformance") and
  all(.counterexample_runs[6:][]; .job_name=="envelope" and .reason=="FAILED_CI_VALIDATION")
' "$repository/contracts/release-locks-v1.json" >/dev/null

jq -e '
  .denominator_migration == {from:22,to:23,add:1,retire:0,split:0,append_only:true} and
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
  (.process_deviations|length) == 3 and
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
  ((.process_deviations[] | select(.deviation_id == "CHANGE_BUNDLE_DIRECT_TO_MAIN-v0.1.1")) as $bundle_process |
    $bundle_process.cell_id == "SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and
    $bundle_process.append_only == true and
    $bundle_process.state == "REFUTED" and
    $bundle_process.stage == "DEVELOPMENT_PROCESS" and
    $bundle_process.reason == "DEVELOPMENT_PROCESS_DIRECT_MAIN" and
    $bundle_process.classification == "DEVELOPMENT_PROCESS_DIRECT_MAIN" and
    $bundle_process.observed.repository == "kimjooyoon/gooo-change-bundle" and
    $bundle_process.observed.after_pull_request == 1 and
    ($bundle_process.observed.commits|map(.commit_sha)) == ["5e370da7a36ac1cae339825a6c4c9cc52c3e76b6","51600eac0abc92edb0883b5cff15b31d27a006d6","3d53c9ada1371b8c97eb0ca582715f0d47486bc9"] and
    all($bundle_process.observed.commits[]; .pull_requests == []) and
    ($bundle_process.blocked_by|length) == 3) and
  ((.process_deviations[] | select(.deviation_id == "UTILITY_TRIAL_RELEASE_HISTORY_REWRITE-v0.1.0")) as $utility_process |
    $utility_process.cell_id == "SEMANTIC_DRIFT_DEVELOPMENT_PROCESS" and
    $utility_process.append_only == true and $utility_process.state == "REFUTED" and
    $utility_process.stage == "DEVELOPMENT_PROCESS" and $utility_process.step == "COMPARE_INITIAL_AND_CURRENT_RELEASE_IDENTITIES" and
    $utility_process.reason == "RELEASE_HISTORY_REWRITE_PROCESS" and $utility_process.classification == "RELEASE_HISTORY_REWRITE_PROCESS" and
    $utility_process.observed.repository == "kimjooyoon/gooo-utility-trial" and $utility_process.observed.initial_release_id == 379848683 and
    $utility_process.observed.initial_immutable == false and $utility_process.observed.failed_run_id == 33407273856 and
    $utility_process.observed.failed_artifact_id == 9763659711 and $utility_process.observed.current_release_id == 379850805 and
    $utility_process.observed.current_immutable == true and ($utility_process.blocked_by|length) == 3) and
  (.cells|length) == 23 and
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
  ((.cells[] | select(.cell_id == "IMPROVEMENT_PROPOSER_RELEASE")) as $proposer |
    $proposer.state == "CLOSED" and
    $proposer.release_key == "improvement_proposer_release" and
    ($proposer.evidence | index("release:379780599:immutable=true")) != null and
    ($proposer.evidence | index("tag-object:2ed70c6fae93c21b0c4839d4fa2ff0f4da3ebc59:target=6757651d5b6abae7dfb7c7a3ec7a0cab103e3279")) != null and
    ($proposer.evidence | index("release-actions:run=33397566380:job=99505669083:success")) != null and
    ($proposer.evidence | index("post-main-actions:run=33397372252:job=99505021461:success")) != null and
    ($proposer.evidence | index("post-main-actions-artifact:9759855868:2916595:sha256:79c6a8acf82e1e94e1529b7c43e0aef7f922ea7bc77c79ab13758a033cfade20")) != null and
    ($proposer.evidence | index("upstream-fixed-artifacts:proposal.json,candidate-events.ndjson,semantic-ir.json,generated-evaluator.go,replay-receipt.json,human-dossier.md")) != null and
    ($proposer.evidence | index("upstream-cases:CLOSED=3:UNKNOWN=3:REFUTED=3:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($proposer.evidence | index("upstream-v0.1.0-no-release:tag-object=9acc18c4f021a42fbd41f2c67f22bb1df1152187:target=2007b49fdf60765b1868636da75b980f0c16db28:failed-run=33396465907:job=99502048200:reason=FAILED_RELEASE_TRIGGER")) != null) and
  ((.cells[] | select(.cell_id == "CHANGE_BUNDLE_RELEASE")) as $bundle |
    $bundle.state == "CLOSED" and
    $bundle.release_key == "change_bundle_release" and
    ($bundle.evidence | index("release:379788730:immutable=true")) != null and
    ($bundle.evidence | index("tag-object:09885ac7480d1ee2e350e907f5dc408b35188f47:target=a93c41a28b5718f110b8679556b169f2b11c75b5")) != null and
    ($bundle.evidence | index("release-actions:run=33398653367:release-job=99509268842:audit-job=99509422788:success")) != null and
    ($bundle.evidence | index("audit-artifact:9760351466:735:sha256:30b54d122e4e32f47fecc74f93345e7f9a04a15c1c757f4f83cad36e2ba5f762")) != null and
    ($bundle.evidence | index("upstream-facts:activities=12:cells=12:proof=4/4/4:indicator=4/4/4:cases=CLOSED=3:UNKNOWN=3:REFUTED=6:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($bundle.evidence | index("upstream-bundle:files=15:bytes=17527:changed_paths=1:changed_hunks=1:replay=13/0:rollback=1/0")) != null and
    ($bundle.evidence | index("upstream-runtime:go=1.27.0:build=224:test=2414:conformance=5:peak_rss_kib=112032:tests=16/0/0/0:authority=0/0/0")) != null and
    ($bundle.evidence | index("upstream-inventory:files=22:directories=14:go_lines=2049:gooo_lines=18:root_readme_excluded=true")) != null and
    ($bundle.evidence | index("asset:538044874:641:sha256:1fb8dcd44e0758555acefc75a4e9aabe83806cbe41d69f0e43d38cc5fadd0e03")) != null and
    ($bundle.evidence | index("asset:538044878:6267:sha256:42dd203bd20438db7cc15abbbfe6fa19542cc2bf0de26cbe6db056150e1bb2f6")) != null and
    ($bundle.evidence | index("asset:538044876:30148:sha256:60f6fbedb897467bbf499097a2abebe56e047c9f1da920000daa34f2f675fb5b")) != null and
    ($bundle.evidence | index("asset:538044877:848:sha256:1920afc524309326cba26109c93d764b4effb5dd4bf717340db654131ecbfc15")) != null and
    ($bundle.evidence | index("asset:538044875:371:sha256:82b7d8c1f177bc36806f5678d27f1db50114b49d279fb14c673ffdc5fe59a196")) != null and
    ($bundle.evidence | index("v0.1.0-counterexample:release=379775534:immutable=false:tag-object=ea288b0f07b89faca3ba3725a54c316771ccd9cf:target=2d98537d1d6d4ff96fc70c98247660990b78191c:reason=SELF_ASSERTED_IMMUTABILITY_CONTRADICTED_BY_PLATFORM")) != null and
    ($bundle.evidence | index("development-process:DEVELOPMENT_PROCESS_DIRECT_MAIN:commits=5e370da7a36ac1cae339825a6c4c9cc52c3e76b6,51600eac0abc92edb0883b5cff15b31d27a006d6,3d53c9ada1371b8c97eb0ca582715f0d47486bc9:pull_requests=[]")) != null) and
  ((.cells[] | select(.cell_id == "UTILITY_TRIAL_PROTOCOL_RELEASE")) as $utility |
    $utility.state == "CLOSED" and $utility.release_key == "utility_trial_protocol_release" and
    ($utility.evidence | index("release:379863199:immutable=true")) != null and
    ($utility.evidence | index("tag-object:5a42a68fb1f9a54eaa33097fb6eeca4db421bf05:target=5500f00ec67b75fadf450110acefca713c5b5733")) != null and
    ($utility.evidence | index("pr-merge:3:5500f00ec67b75fadf450110acefca713c5b5733")) != null and
    ($utility.evidence | index("pre-merge-actions:run=33409087319:job=99543871814:success")) != null and
    ($utility.evidence | index("post-main-actions:run=33409165999:job=99544131261:success")) != null and
    ($utility.evidence | index("release-actions:run=33409188187:job=99544202999:success")) != null and
    ($utility.evidence | index("audit-artifact:9764422074:2764537:sha256:a690b16b4ec7f6271eee23bffa52f1209ab238cfd21ff15f75f7f61a5e93adee")) != null and
    ($utility.evidence | index("upstream-result:protocol_ready=CLOSED:utility=UNKNOWN:external_evidence=0:eligible_pairs=0:process=REFUTED:score=NOT_COMBINED:denominator_migration=NONE")) != null and
    ($utility.evidence | index("asset:538178108:24089:sha256:5e2cf1eb96debfe0540a950ebf4975cbff8ab9ead4695b27493b5d6362ce5edf")) != null and
    ($utility.evidence | index("asset:538178107:104:sha256:4983b05ca18df365c41255969729cdff9cfe3c11b08257a20203908ada7cb490")) != null and
    ($utility.evidence | index("v0.1.0-history-rewrite:initial-release=379848683:immutable=false:failed-run=33407273856:artifact=9763659711:current-release=379850805:immutable=true")) != null and
    ($utility.evidence | index("v0.1.0-history-assets:initial=538154567,538154571:current=538157619,538157605:tag-object=e30bca521d127d929043557198557710d35afcd2:target=6521e699f1e1180b7e942ae18d0948383c3d544e")) != null and
    ($utility.evidence | index("process:RELEASE_HISTORY_REWRITE_PROCESS=REFUTED:score_included=false")) != null) and
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
  .summary == {total:23,closed:20,unknown:1,refuted:2} and
  .precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  (.cells|length) == 23 and
  (.cells|map(.id)|length) == (.cells|map(.id)|unique|length) and
  (.cells|map(.activity)|length) == (.cells|map(.activity)|unique|length) and
  (.cells|map(select(.numerator == 1 and .denominator == 1))|length) == 20 and
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
    OPENTOFU_ENVELOPE_RELEASE:"CLOSED",
    IMPROVEMENT_PROPOSER_RELEASE:"CLOSED",
    TEST_FRONTIER_RELEASE:"CLOSED",
    CHANGE_BUNDLE_RELEASE:"CLOSED",
    UTILITY_TRIAL_PROTOCOL_RELEASE:"CLOSED"
  } and
  all(.cells[]; if .state == "UNKNOWN" then
    (.unknown|keys|sort) == ["blocked_by","next_operation","reason","stage","step","unknown_class"] and
    (.unknown.blocked_by|length) > 0
  else true end) and
  .bindings == {one_to_one:true,cells:23,activities:23,unique_axes:23,unique_metrics:23,source_bindings:23,ir_bindings:23,generated_artifact_bindings:23,evaluator_bindings:23} and
  .proof_counts.FOUNDATION.denominator == 4 and .proof_counts.COHERENCE.denominator == 14 and .proof_counts.REGRESSION.denominator == 5 and
  .indicator_counts.DRIVER.denominator == 4 and .indicator_counts.OUTCOME.denominator == 14 and .indicator_counts.GUARDRAIL.denominator == 5 and
  .releases == {total:20,verified:20,unknown:0,refuted:0} and
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
