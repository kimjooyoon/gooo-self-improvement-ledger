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

echo "conformance: verify profile contract"
jq -e '
  .total_cells == 50 and
  .denominator_migration == {from:49,to:50,add:1,retire:0,split:0,append_only:true} and
  (.cells|map(.id)|.[0:38]) == [
    "CORE_SEMANTIC_AUTHORITY","RESOLUTION_DESCENT","CAUSAL_CI_SELECTION","META_RESOURCE_BUDGET",
    "DENOMINATOR_EVOLUTION","REFLEXIVE_LOOP","IMMUTABLE_INPUT_INTEGRATION","SEMANTIC_MERGE_ADVICE",
    "DESIGN_CONSUMER_PATH","OPENTOFU_PLAN_PATH","RELEASE_PROMOTION","EXTERNAL_UTILITY_EVIDENCE",
    "COUNTERFACTUAL_CHANGE_RELEASE","VERIFICATION_REUSE_RELEASE","SEMANTIC_DRIFT_RELEASE","SEMANTIC_DRIFT_DEVELOPMENT_PROCESS","IMPROVEMENT_FRONTIER_RELEASE","AUTHORITY_BOOTSTRAP_RELEASE","OPENTOFU_ENVELOPE_RELEASE","IMPROVEMENT_PROPOSER_RELEASE","TEST_FRONTIER_RELEASE","CHANGE_BUNDLE_RELEASE","UTILITY_TRIAL_PROTOCOL_RELEASE","REFLEXIVE_MODERN_CYCLE_RELEASE","EXPERIENCE_MEMORY_RELEASE","SEMANTIC_DRIFT_GUARD_RELEASE","SEMANTIC_AUTHORITY_CENSUS_RELEASE","REFLEXIVE_LEARNING_DRIFT_CYCLE_RELEASE","UNKNOWN_RESOLUTION_LATTICE_RELEASE","SELF_REPAIR_INTEGRATION_RELEASE","OPENTOFU_DURABLE_SEMANTIC_ENVELOPE_RELEASE","LANGUAGE_DELTA_FORGE_DURABLE_RELEASE","OPENTOFU_GENERATED_SERVICE_PROJECT_DURABLE_RELEASE","REFLEXIVE_COMPILER_PHASE_DURABLE_RELEASE","CAUSAL_VERIFICATION_RUNNER_DURABLE_RELEASE","EXECUTABLE_EVOLUTION_TRIAL_COUNTEREXAMPLE_DURABLE_RELEASE","REFLEXIVE_COMPILER_GRAPH_TOPOLOGY_SELF_IMPROVEMENT_DURABLE_RELEASE","EXECUTABLE_EVOLUTION_TRIAL_CLOSED_LOOP_DURABLE_RELEASE"
  ] and .cells[38].id == "STRUCTURAL_LEDGER_APPEND_PLANNER_DURABLE_RELEASE" and
  .cells[39].id == "EXPLANATION_CARRYING_COMPILER_DURABLE_RELEASE" and
  .cells[40].id == "TWO_GENERATION_BOOTSTRAP_DURABLE_RELEASE" and
  .cells[41].id == "HYGIENIC_ORIGIN_RESOLVER_DURABLE_RELEASE" and
  .cells[42].id == "CAPABILITY_EFFECT_CHECKER_DURABLE_RELEASE" and
  .cells[43].id == "DETERMINISTIC_MODULE_LINKER_DURABLE_RELEASE" and
  .cells[44].id == "SEMANTIC_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE" and
  .cells[45].id == "DIFFERENTIAL_SEMANTICS_RUNTIME_DURABLE_RELEASE" and
  .cells[46].id == "STAGED_QUASIQUOTE_DURABLE_RELEASE" and
  .cells[47].id == "ERROR_DIRECTED_EVOLUTION_PLANNER_DURABLE_RELEASE" and
  .cells[48].id == "INCREMENTAL_MODULE_COMPILER_DURABLE_RELEASE" and
  .cells[49].id == "SELF_REWRITE_SANDBOX_DURABLE_RELEASE" and
  .proof_totals == {FOUNDATION:4,COHERENCE:41,REGRESSION:5} and
  .indicator_totals == {DRIVER:4,OUTCOME:41,GUARDRAIL:5} and
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
  (.cells|map(select(.id=="UTILITY_TRIAL_PROTOCOL_RELEASE" and .release_key=="utility_trial_protocol_release"))|length)==1 and
  (.cells|map(select(.id=="REFLEXIVE_MODERN_CYCLE_RELEASE" and .release_key=="reflexive_modern_cycle_release"))|length)==1 and
  (.cells|map(select(.id=="EXPERIENCE_MEMORY_RELEASE" and .release_key=="experience_memory_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_DRIFT_GUARD_RELEASE" and .release_key=="semantic_drift_guard_release"))|length)==1 and
  (.cells|map(select(.id=="SEMANTIC_AUTHORITY_CENSUS_RELEASE" and .release_key=="semantic_authority_census_release"))|length)==1 and
  (.cells|map(select(.id=="REFLEXIVE_LEARNING_DRIFT_CYCLE_RELEASE" and .release_key=="reflexive_learning_drift_cycle_release"))|length)==1 and
  (.cells|map(select(.id=="UNKNOWN_RESOLUTION_LATTICE_RELEASE" and .release_key=="unknown_resolution_lattice_release"))|length)==1 and
  (.cells|map(select(.id=="SELF_REPAIR_INTEGRATION_RELEASE" and .release_key=="self_repair_integration_release"))|length)==1 and
  (.cells|map(select(.id=="OPENTOFU_DURABLE_SEMANTIC_ENVELOPE_RELEASE" and .release_key=="opentofu_durable_semantic_envelope_release"))|length)==1 and
  (.cells|map(select(.id=="LANGUAGE_DELTA_FORGE_DURABLE_RELEASE" and .release_key=="language_delta_forge_durable_release"))|length)==1 and
  (.cells|map(select(.id=="OPENTOFU_GENERATED_SERVICE_PROJECT_DURABLE_RELEASE" and .release_key=="opentofu_generated_service_project_durable_release"))|length)==1 and
  (.cells|map(select(.id=="REFLEXIVE_COMPILER_PHASE_DURABLE_RELEASE" and .release_key=="reflexive_compiler_phase_durable_release"))|length)==1 and
  (.cells|map(select(.id=="CAUSAL_VERIFICATION_RUNNER_DURABLE_RELEASE" and .release_key=="causal_verification_runner_durable_release"))|length)==1 and
  (.cells|map(select(.id=="EXECUTABLE_EVOLUTION_TRIAL_COUNTEREXAMPLE_DURABLE_RELEASE" and .release_key=="executable_evolution_trial_counterexample_durable_release"))|length)==1 and
  (.cells|map(select(.id=="REFLEXIVE_COMPILER_GRAPH_TOPOLOGY_SELF_IMPROVEMENT_DURABLE_RELEASE" and .release_key=="reflexive_compiler_graph_topology_self_improvement_durable_release"))|length)==1 and
  (.cells|map(select(.id=="EXECUTABLE_EVOLUTION_TRIAL_CLOSED_LOOP_DURABLE_RELEASE" and .release_key=="executable_evolution_trial_closed_loop_durable_release" and .ordinal==38 and .activity=="AdoptExecutableEvolutionTrialClosedLoop" and .proof=="COHERENCE" and .indicator=="OUTCOME"))|length)==1 and
  (.cells|map(select(.id=="STRUCTURAL_LEDGER_APPEND_PLANNER_DURABLE_RELEASE" and .release_key=="structural_ledger_append_planner_durable_release" and .ordinal==39 and .activity=="AdoptStructuralLedgerAppendPlannerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1 and
  (.cells|map(select(.id=="EXPLANATION_CARRYING_COMPILER_DURABLE_RELEASE" and .release_key=="explanation_carrying_compiler_durable_release" and .ordinal==40 and .activity=="AdoptExplanationCarryingCompilerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1 and
  (.cells|map(select(.id=="TWO_GENERATION_BOOTSTRAP_DURABLE_RELEASE" and .release_key=="two_generation_bootstrap_durable_release" and .ordinal==41 and .activity=="AdoptTwoGenerationBootstrapDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="HYGIENIC_ORIGIN_RESOLVER_DURABLE_RELEASE" and .release_key=="hygienic_origin_resolver_durable_release" and .ordinal==42 and .activity=="AdoptHygienicOriginResolverDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1 and
  (.cells|map(select(.id=="CAPABILITY_EFFECT_CHECKER_DURABLE_RELEASE" and .release_key=="capability_effect_checker_durable_release" and .ordinal==43 and .activity=="AdoptCapabilityEffectCheckerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1 and
  (.cells|map(select(.id=="DETERMINISTIC_MODULE_LINKER_DURABLE_RELEASE" and .release_key=="deterministic_module_linker_durable_release" and .ordinal==44 and .activity=="AdoptDeterministicModuleLinkerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="SEMANTIC_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE" and .release_key=="semantic_counterexample_reducer_durable_release" and .ordinal==45 and .activity=="AdoptSemanticCounterexampleReducerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="DIFFERENTIAL_SEMANTICS_RUNTIME_DURABLE_RELEASE" and .release_key=="differential_semantics_runtime_durable_release" and .ordinal==46 and .activity=="AdoptDifferentialSemanticsRuntimeDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="STAGED_QUASIQUOTE_DURABLE_RELEASE" and .release_key=="staged_quasiquote_durable_release" and .ordinal==47 and .activity=="AdoptStagedQuasiquoteDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="ERROR_DIRECTED_EVOLUTION_PLANNER_DURABLE_RELEASE" and .release_key=="error_directed_evolution_planner_durable_release" and .ordinal==48 and .activity=="AdoptErrorDirectedEvolutionPlannerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="INCREMENTAL_MODULE_COMPILER_DURABLE_RELEASE" and .release_key=="incremental_module_compiler_durable_release" and .ordinal==49 and .activity=="AdoptIncrementalModuleCompilerDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
  and (.cells|map(select(.id=="SELF_REWRITE_SANDBOX_DURABLE_RELEASE" and .release_key=="self_rewrite_sandbox_durable_release" and .ordinal==50 and .activity=="AdoptSelfRewriteSandboxDurableRelease" and .proof=="COHERENCE" and .indicator=="OUTCOME" and .metric_denominator==1))|length)==1
' "$repository/contracts/self-improvement-portfolio-v1.json" >/dev/null
echo "conformance: profile contract passed"

echo "conformance: verify preserved v0.43 candidate-stage planner refutations"
jq -e '
  .schema == "gooo/ledger-append-planner/candidate-operational-history/v1" and
  .transaction_id == "incremental-module-compiler-durable-release-v0.43.0" and
  .semantic_cell_adoption_state == "CLOSED" and .portfolio_decision == "REFUTED" and
  .selected_final_authority.run_id == 33486099504 and
  .selected_final_authority.output_artifact_id == 9791811978 and
  (.events|length) == 2 and
  (.events|map(.run_id)) == [33485864986,33485874832] and
  all(.events[]; .selected == false and .decision == "REFUTED" and .repository_writes == 0 and .local_execution_counts == {go_test:0,go_build:0,go_vet:0,conformance:0} and (.reasons|length)==5 and all(.reasons[]; .stage=="VERIFY")) and
  .events[0].output_debug_artifact == {id:9791723768,size_bytes:5976,digest:"sha256:a3ee5a924e63330ff4913b7b66007a3efff35302e2ab4030f75ee49da6392262"} and
  .events[1].output_debug_artifact == {id:9791729823,size_bytes:5976,digest:"sha256:a5a464f8fdcaacf6d246810a059620b723514866b4e527b3961c4298408768d9"}
' "$repository/evidence/planner-v043-candidate-history.json" >/dev/null
echo "conformance: candidate-stage planner refutations preserved"

echo "conformance: verify preserved v0.44 candidate-stage planner history"
jq -e '
  .schema == "gooo/ledger-append-planner/candidate-operational-history/v1" and
  .transaction_id == "self-rewrite-sandbox-durable-release-v0.44.0" and
  .semantic_cell_adoption_state == "CLOSED" and .portfolio_decision == "REFUTED" and
  .selected_final_authority.run_id == 33488925074 and
  .selected_final_authority.job_id == 99795503759 and
  .selected_final_authority.output_artifact_id == 9792923641 and
  .selected_final_authority.output_artifact_size_bytes == 380704 and
  .selected_final_authority.output_artifact_digest == "sha256:e9aa3fdb253eae025dddc923369fb22d19c143efc7e1d7f25c5a7d0bacd84139" and
  (.events|length) == 3 and
  .events[0].run_id == 33488777592 and .events[0].selected == false and .events[0].decision == "UNKNOWN" and
  .events[0].output_debug_artifact == {id:9792866068,size_bytes:5015,digest:"sha256:d7ef99c1c3bad26bc3fbbb456259153d5222dc0fd975bc24c0d7cabff2e12c54"} and
  .events[1].run_id == 33488868111 and .events[1].selected == false and .events[1].decision == "REFUTED" and
  .events[1].output_debug_artifact == {id:9792901866,size_bytes:5114,digest:"sha256:b05800eae47fb66bea9f13ee54ff865b3c7e64d98128dec793df94f7494d5a6f"} and
  .events[2].run_id == 33488925074 and .events[2].selected == true and .events[2].decision == "CLOSED" and .events[2].portfolio_decision == "REFUTED" and
  .events[2].metrics == {exact_files_planned:7,exact_files_changed:7,ast_nodes_added:5,replay_mismatches:0,repository_writes:0} and
  all(.events[]; .repository_writes == 0 and .local_execution_counts == {go_test:0,go_build:0,go_vet:0,conformance:0})
' "$repository/evidence/planner-v044-candidate-history.json" >/dev/null
echo "conformance: v0.44 candidate-stage planner history preserved"

echo "conformance: verify authoring operational history"
jq -e '
  .schema == "gooo/self-improvement-ledger/authoring-operational-history/v1" and
  .event_id == "v0.44-authoring-local-static-checks" and
  .state == "OPERATIONAL_REFUTED" and
  .reason == "LOCAL_AUTHORING_STATIC_CHECKS_EXECUTED_OUTSIDE_GITHUB_ACTIONS" and
  .checks.bash_syntax.executions == 3 and
  .checks.workflow_yaml_parse.executions == 4 and
  .checks.workflow_yaml_parse.successful_executions == 3 and
  .checks.workflow_yaml_parse.failed_executions == 1 and
  .checks.json_static_parse.batch_executions == 3 and
  .checks.git_diff_check.executions == 3 and
  .product_runtime_authority == {verification:"GITHUB_ACTIONS",local_go_run_compile:0,local_go_build:0,local_go_test:0,local_go_vet:0,local_go_conformance:0,local_go_integration:0,repository_writes:0}
' "$repository/evidence/authoring-operational-history-v1.json" >/dev/null
echo "conformance: authoring operational history preserved"

echo "conformance: verify staged quasiquote release lock"
jq -e '
  .releases.staged_quasiquote_durable_release.release_id == 380175121 and
  .releases.staged_quasiquote_durable_release.repository == "kimjooyoon/gooo-staged-quasiquote-slice" and
  .releases.staged_quasiquote_durable_release.tag == "v0.1.0" and
  .releases.staged_quasiquote_durable_release.tag_object_sha == "f3041976c533b87d0110598c06bb7e320abe30ee" and
  .releases.staged_quasiquote_durable_release.target_commit_sha == "a6dbb1f696feacaf6702aafd1b759a09c70bd917" and
  .releases.staged_quasiquote_durable_release.immutable == true and
  ([.releases.staged_quasiquote_durable_release.assets[] | {id,name,size_bytes,sha256}] | sort_by(.id)) ==
  ([{id:538825432,name:"gooo-staged-quasiquote-slice-v0.1.0-contract.gooo",size_bytes:10029,sha256:"sha256:fa0c1735c4ba26a6ab1b459a96f41087e8e27fd62b5e627f8bba467fb80f84de"},{id:538825434,name:"gooo-staged-quasiquote-slice-v0.1.0-manifest.json",size_bytes:251,sha256:"sha256:e3b922b930ec5ad21b045cdc9cec65e0639610dce77e36b95e6836d966e5016f"},{id:538825435,name:"SHA256SUMS",size_bytes:590,sha256:"sha256:f87253473d129ceae0eaf7adcaebea8fb1be6d3282ae9a73fd64b58606f01012"},{id:538825436,name:"gooo-staged-quasiquote-slice-v0.1.0-terminal-record-schema.json",size_bytes:1378,sha256:"sha256:75b98b3d6945c6fac581d14824cf9a36b4a4bbac47cbd8d6a5eff69471c33ebf"},{id:538825438,name:"gooo-staged-quasiquote-slice-v0.1.0-oracle-lock.json",size_bytes:793,sha256:"sha256:d9b6981e40aa70b6f26b2c33134aa7c1fe0a3d34b2b34f9800d4b8300614b8ae"},{id:538825447,name:"gooo-staged-quasiquote-slice-v0.1.0.tar.gz",size_bytes:21644,sha256:"sha256:11abe1335a8f52120b9201365c6943087f02f313061acc4134aeae477f6ba87d"}] | sort_by(.id))
' "$repository/contracts/release-locks-v1.json" >/dev/null

echo "conformance: verify error-directed evolution planner release lock"
jq -e '
  .releases.error_directed_evolution_planner_durable_release.release_id == 380175481 and
  .releases.error_directed_evolution_planner_durable_release.repository == "kimjooyoon/gooo-error-directed-evolution-planner" and
  .releases.error_directed_evolution_planner_durable_release.tag == "v0.1.1" and
  .releases.error_directed_evolution_planner_durable_release.tag_object_sha == "e44041e4cd7d42cc716048b2dc94fb23d9b36fec" and
  .releases.error_directed_evolution_planner_durable_release.target_commit_sha == "72350a2cbc53190cadc9cc5e4ac9f60875418289" and
  .releases.error_directed_evolution_planner_durable_release.immutable == true and
  ([.releases.error_directed_evolution_planner_durable_release.assets[] | {id,name,size_bytes,sha256}] | sort_by(.id)) ==
  ([{id:538826659,name:"gooo-error-directed-evolution-planner-linux-amd64-v0.1.1.tar.gz",size_bytes:2763054,sha256:"sha256:5e457e61466c58e2c2fede1cdf9ab94645c4f19648ccdfb397f1e2f8275489f9"},{id:538826660,name:"gooo-error-directed-evolution-planner-source-v0.1.1.tar.gz",size_bytes:27388,sha256:"sha256:5a753a6f75a9ebe78e857a373890d2be307ccb4c9f91b4939110c71bda9e8594"},{id:538826661,name:"SHA256SUMS",size_bytes:522,sha256:"sha256:bba3d5ff2832d0cb15e8d9488853c9b7dd9a7b0dfc8361826d5073623856cd1e"},{id:538826662,name:"release-manifest-v0.1.1.json",size_bytes:834,sha256:"sha256:212873c68d9b6a8c7f9fc21a51057ed631832144cd9d2825252dd3263fb1de44"},{id:538826664,name:"planner-report-v0.1.1.json",size_bytes:67823,sha256:"sha256:8ec628e0b7fd84cd893b6801a622b207693db68c9c8890386d5382417aad094b"},{id:538826671,name:"version.json",size_bytes:373,sha256:"sha256:a70099e31a7703dd955626e404bce46fc1bd6699ce882a0c3319100ab975eaf4"}] | sort_by(.id))
' "$repository/contracts/release-locks-v1.json" >/dev/null

echo "conformance: verify incremental module compiler release lock"
jq -e '
  .releases.incremental_module_compiler_durable_release == {
    repository:"kimjooyoon/gooo-incremental-module-compiler",
    tag:"v0.1.3",
    release_id:380177397,
    release_url:"https://github.com/kimjooyoon/gooo-incremental-module-compiler/releases/tag/v0.1.3",
    target_commit_sha:"336669ce954917fc0d34b0b190da8ab5487ab095",
    tag_object_sha:"985f914ae5beb0e2d2c9c48a39da0a1897c4af3a",
    immutable:true,
    assets:[
      {id:538832233,name:"gooo-ci-evidence-v0.1.3.tar.gz",size_bytes:9473,sha256:"sha256:704329d78a0468b2cf3292d10fc8cce73a5a9542d1f30daf067c39baffba9dc6",download_url:"https://github.com/kimjooyoon/gooo-incremental-module-compiler/releases/download/v0.1.3/gooo-ci-evidence-v0.1.3.tar.gz",role:"release-ci-evidence"},
      {id:538832237,name:"gooo-incremental-module-compiler-v0.1.3.tar.gz",size_bytes:31899,sha256:"sha256:16e23ecf2562cac1e6dde050e7e3789a80976209623bb39663f613d8c18f9a11",download_url:"https://github.com/kimjooyoon/gooo-incremental-module-compiler/releases/download/v0.1.3/gooo-incremental-module-compiler-v0.1.3.tar.gz",role:"release-source"},
      {id:538832232,name:"release-manifest-v0.1.3.json",size_bytes:33195,sha256:"sha256:2533b316ba05c110d465c8dd051874e9499e62aa11ee3bd5a18c2cb19398aae1",download_url:"https://github.com/kimjooyoon/gooo-incremental-module-compiler/releases/download/v0.1.3/release-manifest-v0.1.3.json",role:"release-manifest"},
      {id:538832236,name:"SHA256SUMS-v0.1.3",size_bytes:434,sha256:"sha256:6310ca6099b0c14add8355e10d9a259205f50903fb136f507bee1247e6f7359f",download_url:"https://github.com/kimjooyoon/gooo-incremental-module-compiler/releases/download/v0.1.3/SHA256SUMS-v0.1.3",role:"release-checksums"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: incremental module compiler release lock passed"

echo "conformance: verify self-rewrite sandbox release lock"
jq -e '
  .releases.self_rewrite_sandbox_durable_release == {
    repository:"kimjooyoon/gooo-self-rewrite-sandbox",
    tag:"v0.1.1",
    release_id:380237396,
    release_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/tag/v0.1.1",
    target_commit_sha:"bccfd3a740f3d9c254d715e01a61a7554e96568a",
    tag_object_sha:"7afaab763564e356e454db4d63d22ffa7ba53f14",
    immutable:true,
    assets:[
      {id:539057455,name:"gooo-self-rewrite-sandbox-linux-amd64-v0.1.1.tar.gz",size_bytes:2825115,sha256:"sha256:313d243bd9e7cba3479511a10472882b05d5b954a3082f109aacd82297b471d8",download_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/download/v0.1.1/gooo-self-rewrite-sandbox-linux-amd64-v0.1.1.tar.gz",role:"release-binary"},
      {id:539057461,name:"gooo-self-rewrite-sandbox-source-v0.1.1.tar.gz",size_bytes:23210,sha256:"sha256:16ac09b679257fc77dce92d538d79e8676eea088ef499bc73c10290a4b1e5b1b",download_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/download/v0.1.1/gooo-self-rewrite-sandbox-source-v0.1.1.tar.gz",role:"release-source"},
      {id:539057456,name:"release-manifest-v0.1.1.json",size_bytes:790,sha256:"sha256:d7a4615beb26b9e27883f4d46620215f78548d1eec646fe5cf156446592b3383",download_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/download/v0.1.1/release-manifest-v0.1.1.json",role:"release-manifest"},
      {id:539057458,name:"release-report-v0.1.1.json",size_bytes:40509,sha256:"sha256:d5072d9ba452636a0023513f346cecc879b25fbb7730f26932950f8037d93d38",download_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/download/v0.1.1/release-report-v0.1.1.json",role:"release-report"},
      {id:539057459,name:"SHA256SUMS",size_bytes:498,sha256:"sha256:37b2f03ea77842bd81503435f0a069d10c2c61e0f5446ecadcaf0f0841de7570",download_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/download/v0.1.1/SHA256SUMS",role:"release-checksums"},
      {id:539057471,name:"version.json",size_bytes:294,sha256:"sha256:32e1ed0dd02ef58c148feb74705384d961915197e047f7639f7ec339c6c56008",download_url:"https://github.com/kimjooyoon/gooo-self-rewrite-sandbox/releases/download/v0.1.1/version.json",role:"release-version"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: self-rewrite sandbox release lock passed"

echo "conformance: verify preserved release transport failure envelope"
jq -e '
  .schema == "gooo/self-improvement-ledger/release-transport-envelope/v1" and
  .event_type == "RELEASE_TRANSPORT_FAILURE" and
  .semantic_state == {total_cells:46,closed:43,unknown:1,refuted:2} and
  .preserved_failure == {
    tag:"v0.40.0",
    release_id:380259706,
    immutable:true,
    asset_count:0,
    tag_object_sha:"ca691484122c408d60b694ed7a5a9179a4a613d5",
    target_commit_sha:"7883b07a3ebc0101acc516a4a5662f01296c63a9",
    state:"REFUTED",
    reason:"RELEASE_PUBLISHED_BEFORE_ASSET_UPLOAD",
    preserved:true,
    mutation_policy:"NO_DELETE_NO_OVERWRITE"
  } and
  .correction == {
    workflow:".github/workflows/release-transport.yml",
    target_tag:"v0.40.1",
    ordering:["DRAFT_RELEASE_CREATE","EXACT_ASSET_UPLOAD","PUBLISH_RELEASE","API_IMMUTABLE_VERIFY"],
    source:"SUCCESSFUL_MAIN_GITHUB_ACTIONS_ARTIFACT",
    semantic_cell_additions:0
  } and
  .authority == {verification:"GITHUB_ACTIONS",local_go_test:0,local_go_build:0,local_go_vet:0,local_conformance:0,repository_writes:0}
' "$repository/evidence/release-transport-v1.json" >/dev/null
echo "conformance: preserved release transport failure envelope passed"

echo "conformance: verify release lock contract"
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
  .releases.reflexive_modern_cycle_release.release_id == 379879740 and .releases.reflexive_modern_cycle_release.tag_object_sha == "e54e08feacb3ea4da67b5aa5e404a4ce0b605895" and
  .releases.reflexive_modern_cycle_release.target_commit_sha == "ed8ff02c7d8f56d8d9474b68036ea80cdc105261" and
  .releases.reflexive_modern_cycle_release.source_run.run_id == 33410813438 and .releases.reflexive_modern_cycle_release.source_run.job_id == 99549616696 and
  .releases.reflexive_modern_cycle_release.source_run.job_name == "conformance" and .releases.reflexive_modern_cycle_release.source_run.artifact_ids == [9765064827] and
  .releases.reflexive_modern_cycle_release.source_artifact.artifact_id == 9765064827 and .releases.reflexive_modern_cycle_release.source_artifact.size_bytes == 2122874 and
  .releases.reflexive_modern_cycle_release.source_artifact.sha256 == "sha256:9a800498dca302d6cf9b2c9574d8adc69075f88c6c112db36d25aab34caa04c5" and
  .releases.reflexive_modern_cycle_release.release_manifest.schema == "gooo/reflexive-loop/release-manifest/v1" and
  .releases.reflexive_modern_cycle_release.release_manifest.version == "v0.3.1" and
  .releases.reflexive_modern_cycle_release.release_manifest.tag.kind == "annotated" and
  .releases.reflexive_modern_cycle_release.release_manifest.tag.tag_object_sha == "e54e08feacb3ea4da67b5aa5e404a4ce0b605895" and
  .releases.reflexive_modern_cycle_release.release_manifest.tag.target_commit_sha == "ed8ff02c7d8f56d8d9474b68036ea80cdc105261" and
  .releases.reflexive_modern_cycle_release.release_manifest.post_main.conformance_run_id == 33410813438 and
  .releases.reflexive_modern_cycle_release.release_manifest.preserved_prior_release.release_id == 379458203 and
  .releases.reflexive_modern_cycle_release.release_manifest.preserved_prior_release.immutable == true and
  .releases.reflexive_modern_cycle_release.release_manifest.preserved_prior_release.target_commit_sha == "75d655f04a0833b8cf40afa76f4a9703a3ba04fa" and
  .releases.reflexive_modern_cycle_release.protocol_observation.fixed_denominator == 12 and
  .releases.reflexive_modern_cycle_release.protocol_observation.activities == 12 and
  .releases.reflexive_modern_cycle_release.protocol_observation.cells == 12 and
  .releases.reflexive_modern_cycle_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.reflexive_modern_cycle_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.reflexive_modern_cycle_release.protocol_observation.case_totals == {normal:3,unknown:3,refuted:4,CLOSED:3,UNKNOWN:3,REFUTED:4} and
  .releases.reflexive_modern_cycle_release.protocol_observation.precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.after_oracle_failures == 0 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.before_oracle_failures == 1 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.tests_total == 4 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.tests_executed == 2 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.tests_reused == 1 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.tests_skipped == 1 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.tests_not_observed == 0 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.replay_comparisons == 19 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.replay_mismatches == 0 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.rollback_comparisons == 1 and
  .releases.reflexive_modern_cycle_release.protocol_observation.normal_candidate_metrics.rollback_mismatches == 0 and
  .releases.reflexive_modern_cycle_release.protocol_observation.performance == {build_wall_ms:7436,build_peak_rss_kib:270260,conformance_wall_ms:8844,conformance_peak_rss_kib:14524} and
  .releases.reflexive_modern_cycle_release.protocol_observation.inventory == {directories:16,files:44,go_physical_lines:0,gooo_physical_lines:93,root_readme_excluded:true} and
  .releases.reflexive_modern_cycle_release.protocol_observation.authority == {apply_authorized:false,commit_authorized:false,cross_project_required_gates:0,local_test_executions:0,merge_authorized:false,pull_request_authorized:false,push_authorized:false,repository_writes:0} and
  (.releases.reflexive_modern_cycle_release.assets|map(.id)) == [538205028,538205030,538205039,538205026] and
  .releases.experience_memory_release.release_id == 379896833 and
  .releases.experience_memory_release.immutable == true and
  .releases.experience_memory_release.tag_object_sha == "9b889fc3dd5b663b5ac1ce7cd975fc89030c4a46" and
  .releases.experience_memory_release.target_commit_sha == "79fd6edc588ea26279dbe735e5f6e250132f7730" and
  .releases.experience_memory_release.source_run.run_id == 33414536312 and
  .releases.experience_memory_release.source_run.job_id == 99561917616 and
  .releases.experience_memory_release.source_run.conclusion == "success" and
  .releases.experience_memory_release.source_artifact.artifact_id == 9766475762 and
  .releases.experience_memory_release.source_artifact.size_bytes == 15798 and
  .releases.experience_memory_release.source_artifact.sha256 == "sha256:0aaec4dc2f9a3822c8c3f275f178dde929c7abb87b733544b1f36e2d3b9f26fb" and
  .releases.experience_memory_release.release_run.run_id == 33414620023 and
  .releases.experience_memory_release.release_run.job_id == 99562201563 and
  .releases.experience_memory_release.release_run.conclusion == "success" and
  .releases.experience_memory_release.manifest_file.asset_id == 538237752 and
  .releases.experience_memory_release.manifest_file.size_bytes == 555 and
  .releases.experience_memory_release.manifest_file.sha256 == "sha256:34e97b1cb9fd2ee520cea5b82acd9ee44272abb7392c8a32ce51a144f397ada1" and
  .releases.experience_memory_release.manifest_file.content == {schema:"gooo/experience-memory/release-manifest/v1",tag:"v0.1.0",commit_sha:"79fd6edc588ea26279dbe735e5f6e250132f7730",immutable:true,assets:[{digest:"sha256:177f7c872d4e704f5eba6dd96c43e28bfcab2a714b032188c511f3e7872e5d6d",kind:"source",name:"gooo-experience-memory-v0.1.0.tar.gz"},{digest:"sha256:27afa525ccaa5ebdf738fef99615998b51bed85d865ccd6e9367036a46a961f6",kind:"ci-evidence",name:"gooo-experience-memory-evidence-v0.1.0.tar.gz"}]} and
  .releases.experience_memory_release.checksum_file.asset_id == 538237754 and
  .releases.experience_memory_release.checksum_file.size_bytes == 229 and
  .releases.experience_memory_release.checksum_file.sha256 == "sha256:237c96b9bd3eed13676f0a8a4f0de37c71d75646b6a51a762ba5ca9aa1afb6ca" and
  .releases.experience_memory_release.checksum_file.bindings == {"gooo-experience-memory-v0.1.0.tar.gz":"sha256:177f7c872d4e704f5eba6dd96c43e28bfcab2a714b032188c511f3e7872e5d6d","gooo-experience-memory-evidence-v0.1.0.tar.gz":"sha256:27afa525ccaa5ebdf738fef99615998b51bed85d865ccd6e9367036a46a961f6"} and
  .releases.experience_memory_release.evidence_manifest.schema == "gooo/experience-memory/evidence-manifest/v1" and
  .releases.experience_memory_release.evidence_manifest.subject_sha == "10210e2a1d7bf803ed5be5c187ead9300e88d5e6" and
  .releases.experience_memory_release.evidence_manifest.bytes == 1565 and
  .releases.experience_memory_release.evidence_manifest.sha256 == "sha256:f9105286cdd402372dfe4a65abde56c74d36b6246f5f3b60ce535cb2a35ec0be" and
  .releases.experience_memory_release.protocol_observation.fixed_denominator == 12 and
  .releases.experience_memory_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.experience_memory_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.experience_memory_release.protocol_observation.case_totals == {normal:4,unknown:4,refuted:4,CLOSED:4,UNKNOWN:4,REFUTED:4} and
  .releases.experience_memory_release.protocol_observation.precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .releases.experience_memory_release.protocol_observation.metrics == {attempts_observed:2,memory_records:1,candidate_count:5,known_refuted_recurrences_before:1,known_refuted_recurrences_after:0,avoided_refuted_candidates:1,new_unknown_candidates:2,replay_comparisons:2,replay_mismatches:0,peak_rss_kib:7256,wall_ms:1,go_physical_lines:1578,go_files:9,gooo_physical_lines:16,gooo_files:1,descendant_dirs:13,tests:{total:2,executed:2,reused:0,skipped:0,not_observed:0}} and
  .releases.experience_memory_release.protocol_observation.inventory == {go_physical_lines:1578,go_files:9,gooo_physical_lines:16,gooo_files:1,descendant_dirs:13,regular_files_root_readme_excluded:34} and
  .releases.experience_memory_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  .releases.experience_memory_release.process_observations.append_only == true and
  .releases.experience_memory_release.process_observations.score_included == false and
  .releases.experience_memory_release.process_observations.failed_release_workflow.run_id == 33413752929 and
  .releases.experience_memory_release.process_observations.failed_release_workflow.job_id == 99559373690 and
  .releases.experience_memory_release.process_observations.failed_release_workflow.failed_step == "Confirm tag is annotated and build source asset" and
  (.releases.experience_memory_release.process_observations.operational_pull_requests|map(.number)) == [2,3] and
  all(.releases.experience_memory_release.process_observations.operational_pull_requests[]; .merged == true) and
  (.releases.experience_memory_release.assets|map(.id)) == [538237751,538237753,538237752,538237754] and
  .releases.semantic_drift_guard_release.repository == "kimjooyoon/gooo-semantic-drift-guard" and
  .releases.semantic_drift_guard_release.tag == "v0.1.1" and
  .releases.semantic_drift_guard_release.release_id == 379915376 and
  .releases.semantic_drift_guard_release.immutable == true and
  .releases.semantic_drift_guard_release.target_commit_sha == "15b6c1dcce26feb5f64d562140708f7cb27390aa" and
  .releases.semantic_drift_guard_release.tag_object_sha == "1e1cf4882347ccd69c14c4aa96e63c096709d512" and
  .releases.semantic_drift_guard_release.source_run.run_id == 33416441475 and
  .releases.semantic_drift_guard_release.source_run.job_id == 99568101328 and
  .releases.semantic_drift_guard_release.source_run.job_name == "conformance" and
  .releases.semantic_drift_guard_release.source_run.conclusion == "success" and
  .releases.semantic_drift_guard_release.source_run.artifact_ids == [9767194212] and
  .releases.semantic_drift_guard_release.source_artifact == {run_id:33416441475,artifact_id:9767194212,name:"gooo-semantic-drift-guard-conformance",size_bytes:44290,sha256:"sha256:f6bd1319019ec14d836b4e4bcc31533bc2614768b85bdb1c73deea3e37c89171"} and
  .releases.semantic_drift_guard_release.release_run.run_id == 33416657453 and
  .releases.semantic_drift_guard_release.release_run.job_id == 99568816492 and
  .releases.semantic_drift_guard_release.release_run.job_name == "release" and
  .releases.semantic_drift_guard_release.release_run.conclusion == "success" and
  .releases.semantic_drift_guard_release.pull_request.number == 2 and
  .releases.semantic_drift_guard_release.pull_request.merged == true and
  .releases.semantic_drift_guard_release.pull_request.merge_commit_sha == "15b6c1dcce26feb5f64d562140708f7cb27390aa" and
  .releases.semantic_drift_guard_release.release_workflow == {path:".github/workflows/release.yml",immutable_releases_enabled:true,tag_pattern:"v*.*.*",annotated_tag_required:true,release_exists_guard:true,post_publish_immutable_check:true,release_metadata_file:"release-metadata.txt"} and
  .releases.semantic_drift_guard_release.ruleset == {id:21943064,name:"Immutable v release tags",target:"tag",enforcement:"active",conditions:{ref_name:{include:["refs/tags/v*"]}},rules:[{type:"deletion"},{type:"non_fast_forward"}]} and
  .releases.semantic_drift_guard_release.protocol_observation.schema == "gooo/semantic-drift-guard/report/v1" and
  .releases.semantic_drift_guard_release.protocol_observation.fixed_denominator == 12 and
  .releases.semantic_drift_guard_release.protocol_observation.case_total == 10 and
  .releases.semantic_drift_guard_release.protocol_observation.case_totals == {normal:1,unknown:4,refuted:5,CLOSED:1,UNKNOWN:4,REFUTED:5} and
  .releases.semantic_drift_guard_release.protocol_observation.precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .releases.semantic_drift_guard_release.protocol_observation.canonical_graph_binding == {source_to_ir_to_generated:true,description:"source→IR→generated Go canonical graph binding"} and
  .releases.semantic_drift_guard_release.protocol_observation.normal_metrics == {releases_compared:2,source_files:2,ir_nodes:24,generated_files:2,semantic_relations_before:12,semantic_relations_after:12,equivalent_changes:1,semantic_drift_changes:0,unknown_bindings:0,replay_comparisons:1,replay_mismatches:0,peak_rss_kib:12246,wall_ms:1,build_ms:4654,test_ms:1993,tests:{total:12,executed:12,reused:0,skipped:0,not_observed:0}} and
  .releases.semantic_drift_guard_release.protocol_observation.inventory == {go_physical_lines:1772,go_files:13,gooo_physical_lines:85,gooo_files:6,descendant_dirs:24,descendant_files:45,root_readme_excluded:true} and
  .releases.semantic_drift_guard_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  .releases.semantic_drift_guard_release.process_observations.append_only == true and
  .releases.semantic_drift_guard_release.process_observations.score_included == false and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.release_id == 379905110 and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.immutable == false and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.tag_object_sha == "1af22b91e82ba97203bd7270ae64b2e487a1a4e5" and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.target_commit_sha == "32c52a412f3e07451d8c4e0aa0428bc5b33bd214" and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.reason == "LEGACY_TAG_OBJECT_LITERAL_DEFECT" and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.faulty_release_metadata == "release_tag=v0.1.0\ntarget_commit=32c52a412f3e07451d8c4e0aa0428bc5b33bd214\ntag_object=v0.1.0^{tag}" and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.faulty_asset == {id:538253208,name:"evidence-v0.1.0.tar.gz",size_bytes:6642,sha256:"sha256:c62afed0b028da17b67f2398fd38b54bd7279c36f18eac1c825f6ca9a09ad612"} and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.faulty_checksum_asset == {id:538253206,name:"evidence-v0.1.0.tar.gz.sha256",size_bytes:113,sha256:"sha256:94d970c65a129b9580c3655904454854b3ebc8616451ff57c088d479519b3895"} and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.correction_asset == {id:538262313,name:"evidence-v0.1.0-annotated.tar.gz",size_bytes:10546,sha256:"sha256:598c5d20eaa1b9c39471043087ebc9640bd8e4ba4c951eea803aeb9933f61d59"} and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.correction_checksum_asset == {id:538262314,name:"evidence-v0.1.0-annotated.tar.gz.sha256",size_bytes:163,sha256:"sha256:d4e5376d0a4182d9a7ab39fe938a3637b6c1a8c9d7f29b25c49875a68d254744"} and
  .releases.semantic_drift_guard_release.process_observations.legacy_v0_1_0.correction_release_metadata == "release_tag=v0.1.0\ntarget_commit=32c52a412f3e07451d8c4e0aa0428bc5b33bd214\ntag_object=1af22b91e82ba97203bd7270ae64b2e487a1a4e5" and
  (.releases.semantic_drift_guard_release.assets|map(.id)) == [538271587,538271586] and
  (.releases.semantic_drift_guard_release.assets|map(.size_bytes)) == [6651,113] and
  (.releases.semantic_drift_guard_release.assets|map(.sha256)) == ["sha256:83ea0adf7b59b08147eb24ef16483682d8f21d204dc93ed337d39900ae9e09ec","sha256:61e49e62af005dff6a27f43bf20be43d257095bee1b552ab89a433fbe5db111b"] and
  .releases.reflexive_learning_drift_cycle_release.repository == "kimjooyoon/gooo-reflexive-loop" and
  .releases.reflexive_learning_drift_cycle_release.tag == "v0.4.0" and
  .releases.reflexive_learning_drift_cycle_release.release_id == 379940049 and
  .releases.reflexive_learning_drift_cycle_release.immutable == true and
  .releases.reflexive_learning_drift_cycle_release.target_commit_sha == "134d9043e8808147ed2f7252527e809d3eafad44" and
  .releases.reflexive_learning_drift_cycle_release.tag_object_sha == "89f6d283791f917c2fe789fa05016a0f33df21d2" and
  .releases.reflexive_learning_drift_cycle_release.source_run.run_id == 33420406673 and
  .releases.reflexive_learning_drift_cycle_release.source_run.job_id == 99581097777 and
  .releases.reflexive_learning_drift_cycle_release.source_run.job_name == "conformance" and
  .releases.reflexive_learning_drift_cycle_release.source_run.head_sha == "134d9043e8808147ed2f7252527e809d3eafad44" and
  .releases.reflexive_learning_drift_cycle_release.source_run.conclusion == "success" and
  .releases.reflexive_learning_drift_cycle_release.source_run.artifact_ids == [9768699219] and
  .releases.reflexive_learning_drift_cycle_release.source_artifact == {run_id:33420406673,artifact_id:9768699219,name:"gooo-reflexive-loop-evidence",size_bytes:3624947,sha256:"sha256:11f3fffb4c6ee93307e46b5c1fdb8013fe5829983e069d823d896dc77e84a6c2"} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.schema == "gooo/reflexive-loop/release-manifest/v1" and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.version == "v0.4.0" and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.repository == "kimjooyoon/gooo-reflexive-loop" and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.release == {tag:"v0.4.0",target_commit_sha:"134d9043e8808147ed2f7252527e809d3eafad44",annotated:true,immutable_required:true} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.implementation == {pull_request:7,correction_pull_request:8,merged_main_commit:"134d9043e8808147ed2f7252527e809d3eafad44"} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.workflow == {run_id:33420406673,job_id:99581097777,url:"https://github.com/kimjooyoon/gooo-reflexive-loop/actions/runs/33420406673",branch:"main",go_version:"go1.27.0",conformance:"passed"} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence_artifact == {name:"gooo-reflexive-loop-evidence",id:9768699219,size_bytes:3624947,digest:"sha256:11f3fffb4c6ee93307e46b5c1fdb8013fe5829983e069d823d896dc77e84a6c2"} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.assets == {source:{name:"gooo-reflexive-loop-v0.4.0-source.tar.gz",size_bytes:96363,digest:"sha256:fc8f5e551bb335d0a9133623c2fdc4549f634a93645b41b8fbb7c0acc98ab957"},evidence:{name:"gooo-reflexive-loop-v0.4.0-evidence.tar.gz",size_bytes:2468418,digest:"sha256:1bac0c50f4508922b5351df3a541f4daa115c60867ca106d11d4593e7c58b5ce"}} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.schema == "gooo/reflexive-loop/learning-drift-gated/conformance/v1" and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.version == "v0.4.0" and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.scenario_counts == {CLOSED:3,REFUTED:5,UNKNOWN:4} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.denominator == {cells:12,fixed:true} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.normal_report_digest == "sha256:c1c8686b4e9c96acfe665ead2fd176b2314642f93de428039b0b4a32a59bd6fd" and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.normal == {decision:"CLOSED",repository_unchanged:true,external_utility_state:"UNKNOWN",metrics:{cycles:2,candidate_count:5,known_refuted_recurrences_before:1,known_refuted_recurrences_after:0,attempts_observed:2,avoided_refuted_candidates:1,refuted_candidates:1,unknown_candidates:2,replay_comparisons:16,replay_mismatches:0,rollback_comparisons:1,rollback_mismatches:0,tests_total:4,tests_executed:2,tests_reused:1,tests_skipped:1,tests_not_observed:0,build_wall_ms:520,build_peak_rss_kib:91448,test_wall_ms:0,test_peak_rss_kib:7116,conformance_wall_ms:4291,conformance_peak_rss_kib:14300,go_files:0,go_physical_lines:0,gooo_files:8,gooo_physical_lines:136,directories:18,files:56,output_artifact_files:375,output_artifact_bytes:1327231,patch_paths:1,patch_hunks:1,patch_bytes:1119,repository_writes:0,local_test_executions:0,cross_project_required_gates:0}} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.authority == {repository_writes:0,pull_request_authorized:false,push_authorized:false,commit_authorized:false,merge_authorized:false,apply_authorized:false,local_test_executions:0,cross_project_required_gates:0} and
  .releases.reflexive_learning_drift_cycle_release.release_manifest.evidence.utility_inference == false and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.schema == "gooo/reflexive-loop/learning-drift-gated/conformance/v1" and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.version == "v0.4.0" and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.denominator == {cells:12,fixed:true} and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.cases == {CLOSED:3,UNKNOWN:4,REFUTED:5} and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.normal == {decision:"CLOSED",normal_report_digest:"sha256:c1c8686b4e9c96acfe665ead2fd176b2314642f93de428039b0b4a32a59bd6fd",repository_unchanged:true,external_utility_state:"UNKNOWN",metrics:{cycles:2,candidates:5,recurrence_before:1,recurrence_after:0,attempts:2,avoided_refuted:1,refuted:1,unknown:2,replay:{comparisons:16,mismatches:0},rollback:{comparisons:1,mismatches:0},tests:{total:4,executed:2,reused:1,skipped:1,not_observed:0},build:{wall_ms:520,peak_rss_kib:91448},test:{wall_ms:0,peak_rss_kib:7116},conformance:{wall_ms:4291,peak_rss_kib:14300},inventory:{go_files:0,go_lines:0,gooo_files:8,gooo_lines:136,directories:18,files:56,root_readme_excluded:true},output_artifacts:{files:375,bytes:1327231},patch:{paths:1,hunks:1,bytes:1119}}} and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0,apply:0,commit:0,push:0,pull_request:0,merge:0} and
  .releases.reflexive_learning_drift_cycle_release.protocol_observation.utility_inference == false and
  (.releases.reflexive_learning_drift_cycle_release.assets|map(.id)) == [538319772,538319775,538319768,538319776] and
  (.releases.reflexive_learning_drift_cycle_release.assets|map(.size_bytes)) == [2468418,6537,96363,323] and
  (.releases.reflexive_learning_drift_cycle_release.assets|map(.sha256)) == ["sha256:1bac0c50f4508922b5351df3a541f4daa115c60867ca106d11d4593e7c58b5ce","sha256:b3de9c74872b8b8ec4fac51393a4ee54256c1f97ab9f8f47effdc68971013977","sha256:fc8f5e551bb335d0a9133623c2fdc4549f634a93645b41b8fbb7c0acc98ab957","sha256:e55c31a6c66eb82cfcf2d8b39182e07fd39f35f45a7bddfd17407025bda59dc0"] and
  .releases.semantic_authority_census_release.repository == "kimjooyoon/gooo-semantic-authority-census" and
  .releases.semantic_authority_census_release.tag == "v0.1.0" and
  .releases.semantic_authority_census_release.release_id == 379947813 and
  .releases.semantic_authority_census_release.immutable == true and
  .releases.semantic_authority_census_release.target_commit_sha == "0451a1f5813e51a2d09145d7516170c7802f9fd5" and
  .releases.semantic_authority_census_release.tag_object_sha == "c81ff9b843dce716c57fe2ab542bde52e922ab2b" and
  .releases.semantic_authority_census_release.source_run.run_id == 33421788389 and
  .releases.semantic_authority_census_release.source_run.job_id == 99585671364 and
  .releases.semantic_authority_census_release.source_run.job_name == "census" and
  .releases.semantic_authority_census_release.source_run.conclusion == "success" and
  .releases.semantic_authority_census_release.source_run.artifact_ids == [9769198151] and
  .releases.semantic_authority_census_release.source_artifact == {run_id:33421788389,artifact_id:9769198151,name:"semantic-authority-census",size_bytes:2612519,sha256:"sha256:a77d6e089b61fcb6546385af9e91f47011cfe2d070cadec26f3ad66f35e79d35"} and
  .releases.semantic_authority_census_release.release_run.run_id == 33421919840 and
  .releases.semantic_authority_census_release.release_run.job_id == 99586108117 and
  .releases.semantic_authority_census_release.release_run.job_name == "release" and
  .releases.semantic_authority_census_release.release_run.conclusion == "success" and
  .releases.semantic_authority_census_release.release_run.artifact_ids == [9769259042] and
  .releases.semantic_authority_census_release.release_artifact == {run_id:33421919840,artifact_id:9769259042,name:"semantic-authority-release",size_bytes:2577787,sha256:"sha256:347c8f66d0f69f13244be95ea62116beabadf597e49480138e0b16bb6b0c3472"} and
  .releases.semantic_authority_census_release.pull_request.number == 1 and
  .releases.semantic_authority_census_release.pull_request.merged == true and
  .releases.semantic_authority_census_release.pull_request.merge_commit_sha == "0451a1f5813e51a2d09145d7516170c7802f9fd5" and
  .releases.semantic_authority_census_release.release_manifest == {schema:"gooo/semantic-authority-release/v1",tag:"v0.1.0",tag_object:"c81ff9b843dce716c57fe2ab542bde52e922ab2b",target:"0451a1f5813e51a2d09145d7516170c7802f9fd5",run_id:"33421919840",assets:{source:"sha256:3bd78b1b7cb5330dc901003b2d23abee9b95abfe23d1ad0d754d1bdb63471866",evidence:"sha256:e68c93214ef99e65ffd818bf384668c34e8332aa7b4481d6cc70b747afaaf0e3"}} and
  .releases.semantic_authority_census_release.protocol_observation.schema == "gooo/semantic-authority-conformance/v1" and
  .releases.semantic_authority_census_release.protocol_observation.score == "NOT_COMBINED" and
  .releases.semantic_authority_census_release.protocol_observation.denominator == {cells:12,proof:{FOUNDATION:4,COHERENCE:4,REGRESSION:4},indicator:{DRIVER:4,OUTCOME:4,GUARDRAIL:4}} and
  .releases.semantic_authority_census_release.protocol_observation.cases == {CLOSED:3,UNKNOWN:3,REFUTED:3} and
  .releases.semantic_authority_census_release.protocol_observation.exact_pair == {obligations:3,generated_bound:{before:2,after:3,delta:1},handwritten_go:{before:1,after:0,delta:-1}} and
  .releases.semantic_authority_census_release.protocol_observation.execution == {compile_wall_ms:5184,build_wall_ms:751,test_wall_ms:2209,conformance_wall_ms:8306,peak_rss_kib:270708,tests_total:4,tests_executed:4,tests_reused:0,tests_skipped:0,tests_not_observed:0,replay_comparisons:9,replay_mismatches:0} and
  .releases.semantic_authority_census_release.protocol_observation.inventory == {go_files:6,go_physical_lines:817,gooo_files:4,gooo_physical_lines:28,regular_files_excluding_root_readme:29,descendant_dirs:12,output_artifact_files:58} and
  .releases.semantic_authority_census_release.protocol_observation.authority == {repository_write_authority:0,net_repository_changes:0,local_test_executions:0,infrastructure_mutations:0,provider_install_attempts:0,network_mutation_attempts:0} and
  .releases.semantic_authority_census_release.protocol_observation.bootstrap == {compiler:"HANDWRITTEN_GO",evaluator:"HANDWRITTEN_GO",core_semantic_authority_closed:false} and
  (.releases.semantic_authority_census_release.assets|map(.id)) == [538335233,538335235,538335234,538335236] and
  (.releases.semantic_authority_census_release.assets|map(.size_bytes)) == [2563982,413,263,14360] and
  (.releases.semantic_authority_census_release.assets|map(.sha256)) == ["sha256:e68c93214ef99e65ffd818bf384668c34e8332aa7b4481d6cc70b747afaaf0e3","sha256:9c403c7b607c91f1cddced37611875544f047899610be293c96b6475b269b260","sha256:9ae4216b45722c43f62720a3e3d13048905e3291d7ee595d3fe6ab0f78f11411","sha256:3bd78b1b7cb5330dc901003b2d23abee9b95abfe23d1ad0d754d1bdb63471866"] and
  .releases.unknown_resolution_lattice_release.repository == "kimjooyoon/gooo-resolution-lattice" and
  .releases.unknown_resolution_lattice_release.tag == "v0.2.0" and
  .releases.unknown_resolution_lattice_release.release_id == 379967493 and
  .releases.unknown_resolution_lattice_release.immutable == true and
  .releases.unknown_resolution_lattice_release.target_commit_sha == "fac2f5c0688c62fd31912a310e0fae77bc198258" and
  .releases.unknown_resolution_lattice_release.tag_object_sha == "2f452efe6b05b50760500da1a4bea7d323e9c11d" and
  .releases.unknown_resolution_lattice_release.source_run.run_id == 33424634161 and
  .releases.unknown_resolution_lattice_release.source_run.job_id == 99595118419 and
  .releases.unknown_resolution_lattice_release.source_run.head_sha == "8c169cc8d821fb0b68ce28cc519d49935a241b8e" and
  .releases.unknown_resolution_lattice_release.source_run.conclusion == "success" and
  .releases.unknown_resolution_lattice_release.source_run.artifact_ids == [9770260397] and
  .releases.unknown_resolution_lattice_release.source_artifact == {run_id:33424634161,artifact_id:9770260397,name:"gooo-resolution-lattice-evidence-33424634161",size_bytes:23723,sha256:"sha256:f80e798ca1893937ba49b86e40ad1ac7f2035e9d666acacb71c28fa6109bb294"} and
  .releases.unknown_resolution_lattice_release.post_main_validation.run_id == 33425091977 and
  .releases.unknown_resolution_lattice_release.post_main_validation.job_id == 99596614819 and
  .releases.unknown_resolution_lattice_release.post_main_validation.head_sha == "2c7bdc1b5024616cbc70aa55c3726dc22cda048e" and
  .releases.unknown_resolution_lattice_release.post_main_validation.conclusion == "success" and
  .releases.unknown_resolution_lattice_release.post_main_validation.artifact_ids == [9770452642] and
  .releases.unknown_resolution_lattice_release.post_main_artifact == {run_id:33425091977,artifact_id:9770452642,name:"gooo-resolution-lattice-evidence-33425091977",size_bytes:23723,sha256:"sha256:7f3edacdfb5f58a9391ceb10b90de139368a0f537fffa86648eeaf62f9f5dc0e"} and
  .releases.unknown_resolution_lattice_release.release_run.run_id == 33425271313 and
  .releases.unknown_resolution_lattice_release.release_run.job_id == 99597213464 and
  .releases.unknown_resolution_lattice_release.release_run.head_sha == "0f0ec4e696cbd6df756051e908f0d9c86d48ba72" and
  .releases.unknown_resolution_lattice_release.release_run.conclusion == "success" and
  .releases.unknown_resolution_lattice_release.release_run.artifact_ids == [] and
  .releases.unknown_resolution_lattice_release.release_manifest == {schema:"gooo/resolution-lattice/release-manifest/v1",tag:"v0.2.0",commit:"fac2f5c0688c62fd31912a310e0fae77bc198258",go_version:"go1.27.0",immutable:true} and
  .releases.unknown_resolution_lattice_release.protocol_observation.ladder == ["PROJECT","ARTIFACT","ACTIVITY","PREDICATE","FIELD"] and
  .releases.unknown_resolution_lattice_release.protocol_observation.fixed_denominator == 12 and
  .releases.unknown_resolution_lattice_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.unknown_resolution_lattice_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.unknown_resolution_lattice_release.protocol_observation.case_totals == {normal:1,unknown:4,refuted:5,CLOSED:1,UNKNOWN:4,REFUTED:5} and
  .releases.unknown_resolution_lattice_release.protocol_observation.unknown_classes == ["DIRECT_MISSING","DEPENDENCY_BLOCKED","DECISION_UNKNOWN","CAUSALITY_UNPROVEN"] and
  .releases.unknown_resolution_lattice_release.protocol_observation.fixed_point_only == true and
  .releases.unknown_resolution_lattice_release.protocol_observation.top_unknown_decision == "FAIL_CLOSED" and
  .releases.unknown_resolution_lattice_release.protocol_observation.top_unknown_reason == "FEEDBACK_COVERAGE_DECISION_UNKNOWN" and
  .releases.unknown_resolution_lattice_release.protocol_observation.contradiction_priority == "REFUTED" and
  .releases.unknown_resolution_lattice_release.protocol_observation.receipts == {expected:6,observed:6,verified:"6/6"} and
  .releases.unknown_resolution_lattice_release.protocol_observation.identity == {comparisons:16,mismatches:0} and
  .releases.unknown_resolution_lattice_release.protocol_observation.normal_exact_pairs == [{metric:"unidentified_cause_frontier_count",before:4,after:2,delta:-2},{metric:"minimum_cause_reach_stage_count",before:5,after:3,delta:-2}] and
  .releases.unknown_resolution_lattice_release.protocol_observation.tests == {total:10,executed:10,reused:0,skipped:0,not_observed:0} and
  .releases.unknown_resolution_lattice_release.protocol_observation.inventory == {go_files:5,go_lines:1335,gooo_files:1,gooo_lines:27,directories:14,files:23,root_readme_excluded:true} and
  .releases.unknown_resolution_lattice_release.protocol_observation.output_artifacts == {files:22,bytes:67397} and
  .releases.unknown_resolution_lattice_release.protocol_observation.authority == {repository_writes:0,direct_main_writes:0,local_test_executions:0,provider_install_attempts:0,network_mutation_attempts:0,infrastructure_mutations:0} and
  .releases.unknown_resolution_lattice_release.protocol_observation.utility_inference == false and
  (.releases.unknown_resolution_lattice_release.assets|map(.id)) == [538371288,538371290,538371285] and
  (.releases.unknown_resolution_lattice_release.assets|map(.size_bytes)) == [23967,186,103] and
  (.releases.unknown_resolution_lattice_release.assets|map(.sha256)) == ["sha256:f16f43175104a42eb20fd8f701fa8296c289ce69929ff1861269cb3b00ebbc75","sha256:c178b312da828be4589352fbc195853ccaa08e48adacf7f5522c4a06df65f9fd","sha256:8a9b8575cdd5abae5ebba2d1e33a6e93f6b6bfcd7d3ac6855529c74652454549"] and
  .releases.self_repair_integration_release.repository == "kimjooyoon/gooo-self-repair-example" and
  .releases.self_repair_integration_release.tag == "v0.2.1" and
  .releases.self_repair_integration_release.release_id == 379971030 and
  .releases.self_repair_integration_release.immutable == true and
  .releases.self_repair_integration_release.target_commit_sha == "28f3589d69796b4630b2e066c6a5c45ac8468096" and
  .releases.self_repair_integration_release.tag_object_sha == "b8318c1645bc76286eb5c404b771118b6ce1e07b" and
  .releases.self_repair_integration_release.post_main_validation.run_id == 33425759488 and
  .releases.self_repair_integration_release.post_main_validation.job_id == 99598796427 and
  .releases.self_repair_integration_release.post_main_validation.head_sha == "28f3589d69796b4630b2e066c6a5c45ac8468096" and
  .releases.self_repair_integration_release.post_main_validation.conclusion == "success" and
  .releases.self_repair_integration_release.post_main_validation.artifact_ids == [9770678796] and
  .releases.self_repair_integration_release.post_main_artifact == {run_id:33425759488,artifact_id:9770678796,name:"self-repair-artifacts-28f3589d69796b4630b2e066c6a5c45ac8468096",size_bytes:14701,sha256:"sha256:870a731cf484535e2b1218e1d7eee37a0ccdd9c7ad194ff19030ab31e42c7514"} and
  .releases.self_repair_integration_release.release_run.run_id == 33425908089 and
  .releases.self_repair_integration_release.release_run.job_id == 99599283424 and
  .releases.self_repair_integration_release.release_run.head_sha == "28f3589d69796b4630b2e066c6a5c45ac8468096" and
  .releases.self_repair_integration_release.release_run.conclusion == "success" and
  .releases.self_repair_integration_release.release_run.artifact_ids == [] and
  (.releases.self_repair_integration_release.pull_requests|map(.number)) == [3,4] and
  all(.releases.self_repair_integration_release.pull_requests[]; .merged == true) and
  .releases.self_repair_integration_release.historical_process == {state:"REFUTED",classification:"DEVELOPMENT_PROCESS_DIRECT_MAIN",direct_main_push_count:1,offending_commit:"5dca56d238751739beba3fafe9a9018c0bb18ce4",parent_sha:"c460fd7b568adef24cfa85433b0022b450a51288",changed_paths:[".github/workflows/release.yml"],historical_violation_count:1,current_guard_state:"CLOSED",current_pr_associated_path:1,repository_direct_writes_after_guard:0} and
  .releases.self_repair_integration_release.release_manifest == {schema:"gooo.self-repair.release-manifest.v1",tag:"v0.2.1",commit:"28f3589d69796b4630b2e066c6a5c45ac8468096",immutable:true} and
  .releases.self_repair_integration_release.protocol_observation.schema == "gooo/self-repair/repair-manifest.v2" and
  .releases.self_repair_integration_release.protocol_observation.fixed_denominator == 12 and
  .releases.self_repair_integration_release.protocol_observation.activities == 12 and
  .releases.self_repair_integration_release.protocol_observation.claims == {CLOSED:3,UNKNOWN:3,REFUTED:3} and
  .releases.self_repair_integration_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.self_repair_integration_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.self_repair_integration_release.protocol_observation.cycles == {attempts:2,candidates:5,known_refuted_recurrence:"1->0",avoided_refuted_candidates:1,unknown_candidates:2,replay:{comparisons:2,mismatches:0}} and
  .releases.self_repair_integration_release.protocol_observation.tests == {total:3,executed:3,reused:0,skipped:0,not_observed:0} and
  .releases.self_repair_integration_release.protocol_observation.runtime == {go:"1.27.x",build_wall_ms:250,test_wall_ms:240,conformance_wall_ms:13757,peak_rss_kib:90856} and
  .releases.self_repair_integration_release.protocol_observation.inventory == {go_files:8,go_lines:1547,gooo_files:2,gooo_lines:16,directories:15,files:25,root_readme_excluded:true} and
  .releases.self_repair_integration_release.protocol_observation.output_artifacts == {files:12,bytes:38440} and
  .releases.self_repair_integration_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and
  .releases.self_repair_integration_release.protocol_observation.external_utility == {state:"UNKNOWN",reason:"RESOURCE_AXES_CROSS",direct_exact_pair:true} and
  .releases.self_repair_integration_release.protocol_observation.core_semantic_authority == "CLOSED" and
  .releases.self_repair_integration_release.protocol_observation.development_process_authority == "REFUTED" and
  (.releases.self_repair_integration_release.assets|map(.id)) == [538378587,538378586,538378585] and
  (.releases.self_repair_integration_release.assets|map(.size_bytes)) == [30698,134,104] and
  (.releases.self_repair_integration_release.assets|map(.sha256)) == ["sha256:7d505a14cfd11c0d6a57cb14ec8de2f51c946285b18d1af8bce1d6ff476b4582","sha256:3655571de02ba889fe83676d700e43befbf6130730079a26bed6aa6b65adcdd3","sha256:fd70f404c9238fb6fd2ace7cf36b19ed0ce7d89d15fc794ce96ee4d5333f5d1f"] and
  .releases.opentofu_durable_semantic_envelope_release.release_id == 380009987 and
  .releases.opentofu_durable_semantic_envelope_release.tag_object_sha == "8f913ac3bcef39a5105280a6a05114b7abc3ac87" and
  .releases.opentofu_durable_semantic_envelope_release.target_commit_sha == "b482afd68a864400a209cb4f439e727cfdfe2eda" and
  .releases.opentofu_durable_semantic_envelope_release.source_run.run_id == 33432375475 and
  .releases.opentofu_durable_semantic_envelope_release.source_run.job_id == 99620555197 and
  .releases.opentofu_durable_semantic_envelope_release.source_run.head_sha == "b482afd68a864400a209cb4f439e727cfdfe2eda" and
  .releases.opentofu_durable_semantic_envelope_release.source_run.conclusion == "success" and
  .releases.opentofu_durable_semantic_envelope_release.source_run.artifact_ids == [9773097414] and
  .releases.opentofu_durable_semantic_envelope_release.source_artifact == {run_id:33432375475,artifact_id:9773097414,name:"gooo-opentofu-envelope-evidence-b482afd68a864400a209cb4f439e727cfdfe2eda",size_bytes:99611,sha256:"sha256:f04619dbd77314bdf84ba2d5c1b9edd4b9a09b533a8a26c2185ec3b786804157"} and
  .releases.opentofu_durable_semantic_envelope_release.release_run.run_id == 33432449551 and
  .releases.opentofu_durable_semantic_envelope_release.release_run.job_id == 99620801430 and
  .releases.opentofu_durable_semantic_envelope_release.release_run.head_sha == "b482afd68a864400a209cb4f439e727cfdfe2eda" and
  .releases.opentofu_durable_semantic_envelope_release.release_run.conclusion == "success" and
  .releases.opentofu_durable_semantic_envelope_release.release_run.artifact_ids == [] and
  (.releases.opentofu_durable_semantic_envelope_release.pull_requests|map(.number)) == [10] and
  all(.releases.opentofu_durable_semantic_envelope_release.pull_requests[]; .merged == true) and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.schema == "gooo/opentofu-envelope/release-manifest/v1" and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.release == {tag:"v0.1.9",commit_sha:"b482afd68a864400a209cb4f439e727cfdfe2eda",id:380009987,immutable_expected:true,asset_count_before:0,asset_count_after:4,url:"https://github.com/kimjooyoon/gooo-opentofu-envelope/releases/tag/v0.1.9",predecessor_chain:[{tag:"v0.1.3",release_id:379957493,release_present:true,immutable:true,asset_count:0},{tag:"v0.1.4",release_id:null,release_present:false,target_commit_sha:"480e23a159b533be23811667b68b09562ad4c4f8",tag_object_sha:"074d8c01282f20efb55460a69a5177a378878f90",asset_count:0,failed_trigger_counterexample:true,failed_trigger_run_ids:[33429443119,33429524144,33429601185]},{tag:"v0.1.5",release_id:null,release_present:false,target_commit_sha:"bdee16c2506c0efdb3c5562f0d4126a293afc26f",tag_object_sha:"1140c6701c65275bdf6e2cd7e801c9f8191b83ed",asset_count:0,failed_trigger_counterexample:true,failed_trigger_run_ids:[33430206446,33430284845,33430367725,33430500643]},{tag:"v0.1.6",release_id:null,release_present:false,target_commit_sha:"744e32655c6a6d1adf8c31d334814b555bce1a69",tag_object_sha:"cbe70a19dbf547868f907cb51954b66a0f774e66",asset_count:0,failed_trigger_counterexample:true,failed_trigger_run_ids:[33431118426]},{tag:"v0.1.7",release_id:null,release_present:false,target_commit_sha:"a1682d56ec5d5c6ce5aaf1263a157a981d0e7e79",tag_object_sha:"1c3a06733538dc5f4ae3ec143c838984615e68d1",asset_count:0,failed_trigger_counterexample:true,failed_trigger_run_ids:[33431644645]},{tag:"v0.1.8",release_id:380007644,release_present:true,immutable:false,draft:true,target_commit_sha:"4d04baa3dc0157a27f4fca2c3f4e3a9f929953c9",tag_object_sha:"79a59ed5edb82a0d7d234525f897207ed3a59247",asset_count:0,failed_trigger_counterexample:true,failed_trigger_run_ids:[33432034362]}]} and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.denominator == {target_cells:12,binding_edges:14,expected_user_path_steps:5,proof_counts:{COHERENCE:4,FOUNDATION:4,REGRESSION:4},indicator_counts:{DRIVER:4,GUARDRAIL:4,OUTCOME:4}} and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.main_ci.artifact_id == 9773097414 and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.main_ci.artifact_digest == "sha256:f04619dbd77314bdf84ba2d5c1b9edd4b9a09b533a8a26c2185ec3b786804157" and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.authority.global_core_authority_claim == "NOT_MADE" and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.authority.semantic_graph_authority == {scope:"GOOO_SEMANTIC_GRAPH_ONLY",state:"CLOSED"} and
  .releases.opentofu_durable_semantic_envelope_release.release_manifest.authority.external_utility.state == "UNKNOWN" and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.schema == "gooo/opentofu-envelope/observation/v2" and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.fixed_denominator == 12 and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.activities == 12 and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.paths == 5 and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.edges == 14 and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.case_totals == {CLOSED:3,UNKNOWN:3,REFUTED:3} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.replay == {comparisons:2,mismatches:0} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.tests == {total:9,executed:9,reused:0,skipped:0,not_observed:0} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.runtime == {go:"1.27.0",opentofu:"1.12.6",build_wall_ms:214,test_wall_ms:45,conformance_wall_ms:324,peak_rss_kib:76084} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.inventory == {directories:7,files:15,physical_lines:2401,go_files:0,go_lines:0,gooo_files:1,gooo_lines:39,root_readme_excluded:true} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.output_artifacts == {files:3,bytes:8118} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.authority == {repository_writes:0,remote_mutations:0,direct_main_writes:0,tag_mutations:0,local_test_executions:0,cross_project_required_gates:0} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.semantic_graph_authority == {scope:"GOOO_SEMANTIC_GRAPH_ONLY",state:"CLOSED"} and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.utility == "UNKNOWN" and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.global_core_authority_claim == "NOT_MADE" and
  .releases.opentofu_durable_semantic_envelope_release.protocol_observation.validation == {official_opentofu_valid:true,error_count:0,warning_count:0} and
  (.releases.opentofu_durable_semantic_envelope_release.assets|map(.id)) == [538450808,538450812,538450816,538450823] and
  (.releases.opentofu_durable_semantic_envelope_release.assets|map(.size_bytes)) == [13344,55115,263,30885] and
  (.releases.opentofu_durable_semantic_envelope_release.assets|map(.sha256)) == ["sha256:79b549e7471f983e1f3a9f8f19ff73b5c759bac532ad86d8c3d2738885223f6d","sha256:a1352aa6cdeeefc0112884673ce672e920033b6d13d7d8e69ffbf270632df2e1","sha256:efb3cebd7bcdf2dcc1a1a2279817be1286def7e7387b33f2afc505b3eb7129c6","sha256:e33609eee44163d3201d125900d57ea12f183ebb561522e86e930d7f3805338f"] and
  .releases.opentofu_durable_semantic_envelope_release.historical_provenance["v0.1.3"] == {release_id:379957493,release_present:true,immutable:true,asset_count:0} and
  .releases.opentofu_durable_semantic_envelope_release.historical_provenance["v0.1.4"] == {release_present:false,asset_count:0,failed:true,failed_trigger_run_ids:[33429443119,33429524144,33429601185]} and
  .releases.opentofu_durable_semantic_envelope_release.historical_provenance["v0.1.5"] == {release_present:false,asset_count:0,failed:true,failed_trigger_run_ids:[33430206446,33430284845,33430367725,33430500643]} and
  .releases.opentofu_durable_semantic_envelope_release.historical_provenance["v0.1.6"] == {release_present:false,asset_count:0,failed:true,failed_trigger_run_ids:[33431118426]} and
  .releases.opentofu_durable_semantic_envelope_release.historical_provenance["v0.1.7"] == {release_present:false,asset_count:0,failed:true,failed_trigger_run_ids:[33431644645]} and
  .releases.opentofu_durable_semantic_envelope_release.historical_provenance["v0.1.8"] == {release_id:380007644,release_present:true,draft:true,immutable:false,asset_count:0,failed:true,failed_trigger_run_ids:[33432034362]} and
  .releases.language_delta_forge_durable_release.release_id == 380033725 and
  .releases.language_delta_forge_durable_release.tag_object_sha == "5d68c5f2f699f9d73bcf2e87121204512dfd64fc" and
  .releases.language_delta_forge_durable_release.target_commit_sha == "30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45" and
  .releases.language_delta_forge_durable_release.source_run.run_id == 33436391757 and
  .releases.language_delta_forge_durable_release.source_run.job_id == 99633759904 and
  .releases.language_delta_forge_durable_release.source_run.head_sha == "30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45" and
  .releases.language_delta_forge_durable_release.source_run.conclusion == "success" and
  .releases.language_delta_forge_durable_release.source_run.artifact_ids == [9774550869] and
  .releases.language_delta_forge_durable_release.source_artifact == {run_id:33436391757,artifact_id:9774550869,name:"language-delta-forge-30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45",size_bytes:27490,sha256:"sha256:a2f9a55ebb3870f2093e0f3b11439a523c899fac968efb0c449b6c5c6dc486cd"} and
  .releases.language_delta_forge_durable_release.release_run.run_id == 33436456556 and
  .releases.language_delta_forge_durable_release.release_run.job_id == 99633967202 and
  .releases.language_delta_forge_durable_release.release_run.head_sha == "30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45" and
  .releases.language_delta_forge_durable_release.release_run.conclusion == "success" and
  .releases.language_delta_forge_durable_release.release_run.artifact_ids == [9774576485] and
  .releases.language_delta_forge_durable_release.release_artifact == {run_id:33436456556,artifact_id:9774576485,name:"durable-language-delta-forge-v0.1.2",size_bytes:58715,sha256:"sha256:bcf1519c02234b44b69490378723c82fa9e9f83d64b65c2c24138d9ce341013b"} and
  .releases.language_delta_forge_durable_release.release_manifest == {schema:"gooo/language-delta-forge/release-manifest/v2",tag:"v0.1.2",commit:"30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45",expected_asset_count:4,expected_asset_names:["checksums.txt","gooo-language-delta-forge-v0.1.2-contracts.tar.gz","gooo-language-delta-forge-v0.1.2.tar.gz","release-manifest-v0.1.2.json"],assets:[{name:"gooo-language-delta-forge-v0.1.2.tar.gz",size:26671,sha256:"77424f9465322c37ab87efcb920f936e6ddf3e02c2b7e59657fae82ff05283ba"},{name:"gooo-language-delta-forge-v0.1.2-contracts.tar.gz",size:7542,sha256:"e14fc1d338ea85a51f1d6f43997e0e1c74d9be2ddc9eaa97d22d98ebfb5ff2d4"}]} and
  .releases.language_delta_forge_durable_release.protocol_observation == {schema:"gooo/language-delta-forge/conformance-report/v1",state:"CLOSED",fixed_denominator:18,program:{proof_totals:{FOUNDATION:6,COHERENCE:6,REGRESSION:6},indicator_totals:{DRIVER:6,OUTCOME:6,GUARDRAIL:6}},cases:{denominator:9,state_totals:{CLOSED:3,UNKNOWN:3,REFUTED:3},proof_totals:{FOUNDATION:3,COHERENCE:3,REGRESSION:3},indicator_totals:{DRIVER:3,OUTCOME:3,GUARDRAIL:3}},candidate_bundles:10,generated_json:11,representative_delta:{added:2,retired:1,split:1},rollback:{added:2,retired:1,split:1},runtime:{go:"1.27.0",compile_wall_ms:173,build_wall_ms:199,test_wall_ms:163,conformance_wall_ms:8,peak_rss_kib:95004},tests:{discovered:3,executed:3,reused:0,skipped:0,not_observed:0},inventory:{files:27,directories:13,go_files:9,go_lines:1884,gooo_files:1,gooo_lines:51,physical_lines:2610,root_readme_excluded:true},output_artifacts:25,authority:{repository_writes:0,protected_core_adoption:0,automatic_merge:false,separate_authority_step:true,external_utility:"NOT_CLAIMED",global_core_authority_claim:"NOT_MADE"}} and
  (.releases.language_delta_forge_durable_release.assets|map(.id)) == [538495830,538495829,538495828,538495832] and
  (.releases.language_delta_forge_durable_release.assets|map(.size_bytes)) == [240,7542,26671,736] and
  (.releases.language_delta_forge_durable_release.assets|map(.sha256)) == ["sha256:cd99462d4d6635ba03024ef3e03ea600dbe65f22ad416f379583f86fa6af7876","sha256:e14fc1d338ea85a51f1d6f43997e0e1c74d9be2ddc9eaa97d22d98ebfb5ff2d4","sha256:77424f9465322c37ab87efcb920f936e6ddf3e02c2b7e59657fae82ff05283ba","sha256:0c467b96e4b91915139aa0d5990b49c8ca5a038a2ac965d43a4a5656e511064a"] and
  .releases.opentofu_generated_service_project_durable_release.release_id == 380037012 and
  .releases.opentofu_generated_service_project_durable_release.tag_object_sha == "06ab6ccc2f75cf0602715811f51a7a3097d23277" and
  .releases.opentofu_generated_service_project_durable_release.target_commit_sha == "bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787" and
  .releases.opentofu_generated_service_project_durable_release.source_run.run_id == 33436975864 and
  .releases.opentofu_generated_service_project_durable_release.source_run.job_id == 99635653831 and
  .releases.opentofu_generated_service_project_durable_release.source_run.head_sha == "bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787" and
  .releases.opentofu_generated_service_project_durable_release.source_run.conclusion == "success" and
  .releases.opentofu_generated_service_project_durable_release.source_run.artifact_ids == [9774763580] and
  .releases.opentofu_generated_service_project_durable_release.source_artifact == {run_id:33436975864,artifact_id:9774763580,name:"gooo-generated-service-project-evidence-bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787",size_bytes:16278,sha256:"sha256:8e2bd75365b7e0e92ee8276cadbfc0d03842145a7bf5fd52efd1a33e2973de06"} and
  .releases.opentofu_generated_service_project_durable_release.release_run.run_id == 33437056751 and
  .releases.opentofu_generated_service_project_durable_release.release_run.job_id == 99635914331 and
  .releases.opentofu_generated_service_project_durable_release.release_run.head_sha == "bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787" and
  .releases.opentofu_generated_service_project_durable_release.release_run.conclusion == "success" and
  .releases.opentofu_generated_service_project_durable_release.release_run.artifact_ids == [] and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.schema == "gooo/opentofu-envelope/release-manifest/v2" and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.version == 2 and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.source_identity == {all_checks:true,main_ci_head_sha:"bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787",main_ci_observation_source_sha:"a4e5fb7f93e0d2df065cda3d2a4ba177db8cae6049ad2de06b4a42b97c8089fd",service_contract_source_sha:"a4e5fb7f93e0d2df065cda3d2a4ba177db8cae6049ad2de06b4a42b97c8089fd",source_sha256:"a4e5fb7f93e0d2df065cda3d2a4ba177db8cae6049ad2de06b4a42b97c8089fd",tag_commit_sha:"bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787"} and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.release == {tag:"v0.2.1",commit_sha:"bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787",id:380037012,immutable_expected:true,asset_count_before:0,asset_count_after:4,url:"https://github.com/kimjooyoon/gooo-opentofu-envelope/releases/tag/v0.2.1",required_assets:["evidence-v0.2.1.tar.gz","manifest-v0.2.1.json","SHA256SUMS","source-v0.2.1.tar.gz"]} and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.denominator == {target_cells:12,binding_edges:14,expected_user_path_steps:6} and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.main_ci == {artifact_digest:"sha256:8e2bd75365b7e0e92ee8276cadbfc0d03842145a7bf5fd52efd1a33e2973de06",artifact_id:9774763580,artifact_name:"gooo-generated-service-project-evidence-bdc5c2cdacb5865f59efd2eb496d58eeb0bd2787",consumer_sha256:"d44b7a561e40ef8ecd8d330ad0e685b2baa1d6ba936c7e8cdcaa74b134dd3802",observation_sha256:"285de6f94b65081bfd4006afada7320e24ec7103c49345b6c283a06011e0edb8",run_id:33436975864,url:"https://github.com/kimjooyoon/gooo-opentofu-envelope/actions/runs/33436975864"} and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.generated_outputs.count == 5 and .releases.opentofu_generated_service_project_durable_release.release_manifest.generated_outputs.bytes == 9019 and
  .releases.opentofu_generated_service_project_durable_release.release_manifest.inventory == {regular_files:22,subfolders:7,go_physical_files:0,go_physical_lines:0,gooo_physical_files:1,gooo_physical_lines:46,root_readme_excluded:true} and
  .releases.opentofu_generated_service_project_durable_release.protocol_observation == {schema:"gooo/opentofu-envelope/project-observation/v1",state:"CLOSED",fixed_denominator:12,activities:12,paths:6,edges:14,proof_totals:{FOUNDATION:4,COHERENCE:4,REGRESSION:4},indicator_totals:{DRIVER:4,OUTCOME:4,GUARDRAIL:4},cases:{denominator:6,normal:2,unknown:2,refuted:2,precedence:["REFUTED","UNKNOWN","CLOSED"]},generated_outputs:{files:5,bytes:9019},project:{resources:3,modules:0,capabilities:1,endpoints:2,relations:{bound:2,unbound:2,refuted:2}},runtime:{compile_wall_ms:106,build_wall_ms:56,test_wall_ms:56,conformance_wall_ms:46,tofu_validate_wall_ms:30,peak_rss_kib:75304},tests:{total:6,executed:6,reused:0,unknown:2,refuted:2},tofu:{validate:1,init:0,plan:0,apply:0,destroy:0,provider_install:0},inventory:{files:22,directories:7,go_files:0,go_lines:0,gooo_files:1,gooo_lines:46,root_readme_excluded:true},authority:{repository_writes:0,local_tests:0,local_build:0,direct_main_writes:0,tag_mutations:0,scope:"GENERATED_OPENTOFU_SERVICE_PROJECT_ONLY",utility:"UNKNOWN",improvement:"UNKNOWN",global_core:"NOT_MADE"}} and
  .releases.opentofu_generated_service_project_durable_release.historical_provenance["v0.2.0"] == {state:"REFUTED",tag:"v0.2.0",release_present:false,release_api_endpoint:"repos/kimjooyoon/gooo-opentofu-envelope/releases/tags/v0.2.0",release_api_status:404,asset_count:0,tag_object_sha:"9dfdee84d61f3acbe899b5ad57fd8f35f8159210",target_commit_sha:"c9f5de0b33fee1ca8546a627a8a94242b99c0733",failed_release_run_id:33435908822,failed_release_job_id:99632154067,failure_reason:"v0.1.5 target in the v0.2.0 release contract contained one extra trailing character"} and
  .releases.opentofu_generated_service_project_durable_release.ledger_consumer_observation == {append_only:true,local_validation_executions:1,inspection_only:false,artifact_schema_assertion_replays:1,local_go_test:0,local_go_build:0,local_go_vet:0,local_go_conformance:0,process_state:"REFUTED",reason:"one diagnostic replay of the artifact assertion step after CI failures; no local Go execution"} and
  (.releases.opentofu_generated_service_project_durable_release.assets|map(.id)) == [538501631,538501634,538501658,538501664] and
  (.releases.opentofu_generated_service_project_durable_release.assets|map(.size_bytes)) == [10011,15336,263,26719] and
  (.releases.opentofu_generated_service_project_durable_release.assets|map(.sha256)) == ["sha256:9f45cf78ef9339d3d694a30fb21131151d8ec61e4eb62455f2848e0d78180832","sha256:f17271a11b98c48114a740faea96efc3c89f2a5c2746f8efe52d76688ea7ac9f","sha256:bba568c5f8bbba841976d1f6b9b6c9118e9049d3ed014323770456851e8906e1","sha256:cdab3d87acf7aad4889ee41027df75f4fbcfd9dc4afe8e23a5a66504ed35dd70"] and
  .releases.reflexive_compiler_phase_durable_release.release_id == 380040917 and
  .releases.reflexive_compiler_phase_durable_release.tag_object_sha == "8db85557f66d4bb61a4fc1816b3a20dab2c40f0c" and
  .releases.reflexive_compiler_phase_durable_release.target_commit_sha == "dabbe38badebefdf2979d8862c26a647b0dd15c0" and
  .releases.reflexive_compiler_phase_durable_release.source_run.run_id == 33437644781 and
  .releases.reflexive_compiler_phase_durable_release.source_run.job_id == 99637878450 and
  .releases.reflexive_compiler_phase_durable_release.source_run.head_sha == "dabbe38badebefdf2979d8862c26a647b0dd15c0" and
  .releases.reflexive_compiler_phase_durable_release.source_run.conclusion == "success" and
  .releases.reflexive_compiler_phase_durable_release.source_run.artifact_ids == [9775010906] and
  .releases.reflexive_compiler_phase_durable_release.source_artifact == {run_id:33437644781,artifact_id:9775010906,name:"reflexive-conformance-dabbe38badebefdf2979d8862c26a647b0dd15c0",size_bytes:19269921,sha256:"sha256:99934e633fc823b236077fb02f2dee2e0447c40686243cd6e647ca9e30be874c"} and
  .releases.reflexive_compiler_phase_durable_release.release_run.run_id == 33437664492 and
  .releases.reflexive_compiler_phase_durable_release.release_run.job_id == 99637944818 and
  .releases.reflexive_compiler_phase_durable_release.release_run.head_sha == "dabbe38badebefdf2979d8862c26a647b0dd15c0" and
  .releases.reflexive_compiler_phase_durable_release.release_run.event == "workflow_dispatch" and
  .releases.reflexive_compiler_phase_durable_release.release_run.conclusion == "success" and
  .releases.reflexive_compiler_phase_durable_release.release_run.artifact_ids == [] and
  .releases.reflexive_compiler_phase_durable_release.release_manifest == {schema:"gooo/reflexive-release-manifest/v1",version:"0.1.1",tag:"v0.1.1",commit:"dabbe38badebefdf2979d8862c26a647b0dd15c0",assets:[{name:"gooo-reflexive-compiler-slice-source-v0.1.1.tar.gz",digest:"sha256:ae6fef819ab034eb614e7a9e8b54ba18afab399ad2e730085ea221c2363fc38c"},{name:"gooo-reflexive-compiler-slice-linux-amd64-v0.1.1.tar.gz",digest:"sha256:c4ad5900be6a479ab55e18a1bd939cc09389f305f6e6941064c1c6a229399387"},{name:"release-report-v0.1.1.json",digest:"sha256:cce11611c7ca561a0ba97004db610808ab924dfc465fd49371a7314cc57e963d"},{name:"version.json",digest:"sha256:363fc9e1d352091fb8cc79ff0a80ae464a526eb0fe8c055122320e1c0a0f0eef"}]} and
  .releases.reflexive_compiler_phase_durable_release.protocol_observation == {schema:"gooo/reflexive-compiler-denominator/v1",scope:"ONE_COMPILER_PHASE_ONLY",phase:"reflexive.normalize.v1",operations:[{name:"NormalizeSource",input:"Source",output:"SemanticIR"},{name:"EmitBackend",input:"SemanticIR",output:"GeneratedBackend"},{name:"VerifyReplay",input:"Evidence",output:"Evidence"}],cases:{denominator:3,CLOSED:1,UNKNOWN:1,REFUTED:1,precedence:["REFUTED","UNKNOWN","CLOSED"]},unknown:{stage:"NORMALIZE",step:"REQUIRE_DECLARED_ENTITY",reason:"REQUIRED_ENTITY_MISSING",unknown_class:"DIRECT_MISSING",next_operation:"ADD_REQUIRED_ENTITY",blocked_by:["gooo://reflexive/input/required"]},refutation:{stage:"NORMALIZE",step:"CHECK_STABLE_ID_UNIQUENESS",reason:"DUPLICATE_STABLE_ID",counterexample:"gooo://reflexive/input/duplicate"},replay:{decision_matches:3,digest_mismatches:0,ir_mismatches:0,generated_mismatches:0},rollback:{possible:3,baseline_retained:3,candidate_separate:3},outputs:{files:21,bytes:32273},runtime:{peak_rss_bytes:7221248,compile_wall_ms:58,build_wall_ms:5388,test_wall_ms:2093,conformance_wall_ms:2614},tests:{total:3,executed:3,reused:0,failed:0,unknown:1},inventory:{go_files:8,go_physical_lines:1096,gooo_files:4,gooo_physical_lines:33,regular_files:24,subdirectories:14,root_readme_excluded:true},authority:{local_test_executions:0,repository_writes:0,external_mutations:"NOT_OBSERVED",proof_choice:"NOT_OBSERVED",indicator:"NOT_OBSERVED"},state:{global_self_hosting:"UNKNOWN",external_utility:"UNKNOWN",whole_language_improvement:"UNKNOWN"}} and
  .releases.reflexive_compiler_phase_durable_release.historical_provenance["v0.1.0"] == {state:"NON_DURABLE",tag:"v0.1.0",release_id:380032434,immutable:false,tag_object_sha:"f89b47fedab983b9c3cef0b9be03da65eadff3de",target_commit_sha:"57f5ef6ce407f51cd36da163b2b267e876c31e33"} and
  (.releases.reflexive_compiler_phase_durable_release.assets|map(.id)) == [538508362,538508360,538508364,538508363,538508367,538508361] and
  (.releases.reflexive_compiler_phase_durable_release.assets|map(.size_bytes)) == [2589271,19475,795,2898,506,315] and
  (.releases.reflexive_compiler_phase_durable_release.assets|map(.sha256)) == ["sha256:c4ad5900be6a479ab55e18a1bd939cc09389f305f6e6941064c1c6a229399387","sha256:ae6fef819ab034eb614e7a9e8b54ba18afab399ad2e730085ea221c2363fc38c","sha256:cdd3d3f0cb426c1d26ebc83c2b998151301fd6dade7f7b3bde77202ac9a7e0ad","sha256:cce11611c7ca561a0ba97004db610808ab924dfc465fd49371a7314cc57e963d","sha256:1a41949ea027e01ae893dd3872ae32b537a896adaa0df4910628d3a51d73424e","sha256:363fc9e1d352091fb8cc79ff0a80ae464a526eb0fe8c055122320e1c0a0f0eef"] and
  .releases.causal_verification_runner_durable_release.release_id == 380048457 and
  .releases.causal_verification_runner_durable_release.tag_object_sha == "82bb99006232a064725df29a53af5405e222cd42" and
  .releases.causal_verification_runner_durable_release.target_commit_sha == "0c16428762d1d1da1b28fe05c4e051d2cc41967b" and
  .releases.causal_verification_runner_durable_release.source_pull_request == {number:2,base_ref:"main",head_ref:"process-authority-guard",head_sha:"65295c74603e1e8ac418f20ef66b12f2ae935979",merge_commit_sha:"0c16428762d1d1da1b28fe05c4e051d2cc41967b",merged:true} and
  (.releases.causal_verification_runner_durable_release.source_pr_run | {run_id,event,head_branch,head_sha,conclusion,job_id,job_name,artifact_ids}) == {run_id:33438798441,event:"pull_request",head_branch:"process-authority-guard",head_sha:"65295c74603e1e8ac418f20ef66b12f2ae935979",conclusion:"success",job_id:99641659758,job_name:"conformance",artifact_ids:[]} and
  (.releases.causal_verification_runner_durable_release.source_run | {run_id,event,head_branch,head_sha,conclusion,job_id,job_name,artifact_ids}) == {run_id:33438900833,event:"push",head_branch:"main",head_sha:"0c16428762d1d1da1b28fe05c4e051d2cc41967b",conclusion:"success",job_id:99642001168,job_name:"conformance",artifact_ids:[9775474098]} and
  .releases.causal_verification_runner_durable_release.source_artifact == {run_id:33438900833,artifact_id:9775474098,name:"gooo-causal-verification-runner-33438900833",size_bytes:3466163,sha256:"sha256:b3b9b89c820e9aa2f2d48c6686fb4a51bd52ac0b58c2c9ef15bc531191966183"} and
  (.releases.causal_verification_runner_durable_release.release_run | {run_id,event,head_branch,head_sha,conclusion,job_id,job_name,artifact_ids}) == {run_id:33439000856,event:"push",head_branch:"v0.1.1",head_sha:"0c16428762d1d1da1b28fe05c4e051d2cc41967b",conclusion:"success",job_id:99642343892,job_name:"prepare-assets",artifact_ids:[]} and
  .releases.causal_verification_runner_durable_release.release_manifest == {archive:"gooo-causal-verification-runner-v0.1.1.tar.gz",asset_digest:"sha256:fcf40acd1f09805e526b8e9634cd70b8f308e1f2312b0aac8d3253c4038db7fb",asset_size_bytes:38034,commit_sha:"0c16428762d1d1da1b28fe05c4e051d2cc41967b",external_platform_authority:"github_release_api.immutable",release_class:"first_post_guard_durable_release",schema:"gooo/causal-verification-runner/release-manifest/v1",self_asserted_immutable:true,tag:"v0.1.1",tag_object_sha:"82bb99006232a064725df29a53af5405e222cd42"} and
  .releases.causal_verification_runner_durable_release.protocol_observation.schema == "gooo/causal-verification-runner/denominator/v1" and
  .releases.causal_verification_runner_durable_release.protocol_observation.fixed_denominator == 12 and
  .releases.causal_verification_runner_durable_release.protocol_observation.proof_totals == {FOUNDATION:4,COHERENCE:4,REGRESSION:4} and
  .releases.causal_verification_runner_durable_release.protocol_observation.indicator_totals == {DRIVER:4,OUTCOME:4,GUARDRAIL:4} and
  .releases.causal_verification_runner_durable_release.protocol_observation.cases == {denominator:6,CLOSED:2,UNKNOWN:1,REFUTED:3} and
  .releases.causal_verification_runner_durable_release.protocol_observation.unknown == {stage:"AFFECTED_SEMANTIC_PREDICATES",step:"resolve-impact-edge",reason:"UNKNOWN_IMPACT_EDGE",unknown_class:"CAUSAL_EDGE_UNKNOWN",next_operation:"OBTAIN_SEMANTIC_GRAPH_EDGE_PROOF",blocked_by:["edge:edge-component-secret-unknown"]} and
  .releases.causal_verification_runner_durable_release.protocol_observation.fixture_metrics == [{case_id:"safe-reuse",decision:"CLOSED",total:2,selected:1,executed:1,reused:1,oracle:2,fail:0,unknown:0,before_wall_ms:100,after_wall_ms:70,before_peak_rss_kib:200,after_peak_rss_kib:180,avoided_executions:1},{case_id:"transitive-impact",decision:"CLOSED",total:3,selected:2,executed:2,reused:1,oracle:3,fail:0,unknown:0,before_wall_ms:130,after_wall_ms:90,before_peak_rss_kib:220,after_peak_rss_kib:190,avoided_executions:1},{case_id:"unknown-edge-full-fallback",decision:"UNKNOWN",total:2,selected:2,executed:2,reused:0,oracle:2,fail:0,unknown:1,before_wall_ms:120,after_wall_ms:120,before_peak_rss_kib:210,after_peak_rss_kib:210,avoided_executions:0},{case_id:"stale-proof-rejection",decision:"REFUTED",total:2,selected:2,executed:2,reused:0,oracle:2,fail:0,unknown:0,before_wall_ms:110,after_wall_ms:112,before_peak_rss_kib:205,after_peak_rss_kib:208,avoided_executions:0},{case_id:"hidden-counterexample",decision:"REFUTED",total:2,selected:1,executed:1,reused:1,oracle:2,fail:1,unknown:0,before_wall_ms:100,after_wall_ms:65,before_peak_rss_kib:200,after_peak_rss_kib:175,avoided_executions:1},{case_id:"cache-hit-only",decision:"REFUTED",total:2,selected:2,executed:2,reused:0,oracle:2,fail:0,unknown:0,before_wall_ms:100,after_wall_ms:100,before_peak_rss_kib:200,after_peak_rss_kib:200,avoided_executions:0}] and
  .releases.causal_verification_runner_durable_release.protocol_observation.process_guard == {cells:8,cases:3,current_guard:"CLOSED",decision:"REFUTED",direct_main:{bootstrap:1,historical_post_bootstrap:2,post_guard:0},historical_counterexamples:["historical-direct-main-d5c7687","historical-direct-main-4421ae4"]} and
  .releases.causal_verification_runner_durable_release.protocol_observation.outputs == {files:52,bytes:6140304} and
  .releases.causal_verification_runner_durable_release.protocol_observation.runtime == {compile_wall_ms:7220,build_wall_ms:6880,test_wall_ms:2020,conformance_wall_ms:12020,peak_rss_kib:268496} and
  .releases.causal_verification_runner_durable_release.protocol_observation.tests == {total:13,executed:10,reused:3,failed:1,unknown:1} and
  .releases.causal_verification_runner_durable_release.protocol_observation.inventory == {files:52,directories:15,go_files:8,go_physical_lines:2466,gooo_files:1,gooo_physical_lines:59,root_readme_excluded:true} and
  .releases.causal_verification_runner_durable_release.protocol_observation.authority == {repository_writes:0,local_test_executions:0,local_build:0,verification_authority:"GITHUB_ACTIONS"} and
  .releases.causal_verification_runner_durable_release.protocol_observation.state == {utility:"UNKNOWN",global_core:"NOT_MADE"} and
  .releases.causal_verification_runner_durable_release.historical_provenance["v0.1.0"] == {state:"REFUTED",tag:"v0.1.0",release_id:380027888,immutable:true,tag_object_sha:"19c627c8a08af656487b6346854a9e6a9d806e2b",target_commit_sha:"d5c768735b07a1389676964e3a9288487d724b20",post_bootstrap_direct_main_commits:[{commit_sha:"d5c768735b07a1389676964e3a9288487d724b20",pull_requests:[]},{commit_sha:"4421ae44596028c1faa99c19407506fb5265fc1f",pull_requests:[]}],process_state:"REFUTED"} and
  (.releases.causal_verification_runner_durable_release.assets|map(.id)) == [538521941,538521943,538521942] and
  (.releases.causal_verification_runner_durable_release.assets|map(.size_bytes)) == [38034,552,214] and
  (.releases.causal_verification_runner_durable_release.assets|map(.sha256)) == ["sha256:fcf40acd1f09805e526b8e9634cd70b8f308e1f2312b0aac8d3253c4038db7fb","sha256:36d3f52aeb74f32025d0eaa10767e2a6036b5ad42e0636f92b90339af9615eb8","sha256:4297c6c933c4892016df45367015094c9d2fe122a950f7effa9276607df6201f"] and
  .releases.executable_evolution_trial_counterexample_durable_release.release_id == 380086557 and
  .releases.executable_evolution_trial_counterexample_durable_release.tag_object_sha == "c3a87bd320a24e6c4961afc532fd4df6b5d165c3" and
  .releases.executable_evolution_trial_counterexample_durable_release.target_commit_sha == "d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982" and
  .releases.executable_evolution_trial_counterexample_durable_release.immutable == true and
  .releases.executable_evolution_trial_counterexample_durable_release.source_run == {run_id:33445305000,workflow_url:"https://github.com/kimjooyoon/gooo-evolution-trial/actions/runs/33445305000",event:"push",head_branch:"main",head_sha:"d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982",conclusion:"success",job_id:99662940416,job_name:"verify-and-experiment",job_url:"https://github.com/kimjooyoon/gooo-evolution-trial/actions/runs/33445305000/job/99662940416",artifact_ids:[9777794326]} and
  .releases.executable_evolution_trial_counterexample_durable_release.source_artifact == {run_id:33445305000,artifact_id:9777794326,name:"gooo-evolution-trial-33445305000",size_bytes:130085,sha256:"sha256:07c81d12ecf003907678cbbea15d104effd44bdb658893ee426820fdb5b9a13a"} and
  .releases.executable_evolution_trial_counterexample_durable_release.release_run == {run_id:33445379243,workflow_url:"https://github.com/kimjooyoon/gooo-evolution-trial/actions/runs/33445379243",event:"workflow_dispatch",head_branch:"main",head_sha:"d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982",conclusion:"success",job_id:99663170908,job_name:"release",job_url:"https://github.com/kimjooyoon/gooo-evolution-trial/actions/runs/33445379243/job/99663170908",artifact_ids:[9777817257]} and
  .releases.executable_evolution_trial_counterexample_durable_release.release_artifact == {run_id:33445379243,artifact_id:9777817257,name:"gooo-evolution-trial-0.1.0-release-audit",size_bytes:33589,sha256:"sha256:1cf113aaf5a6e629ce2da1f358a5502dba3600ec9f8155b785d72acfd5f20001"} and
  .releases.executable_evolution_trial_counterexample_durable_release.release_manifest == {schema:"gooo/evolution-trial/release-manifest/v1",version:"0.1.0",tag:"v0.1.0",commit:"d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982",assets:[{name:"gooo-evolution-trial-source-v0.1.0.tar.gz",digest:"sha256:b22d716111c7bcbe5dab18a1bb8caee03388579ac394f93a15798ebca5c43bfc"},{name:"upstream-lock-v0.1.0.json",digest:"sha256:b7cff57d0a300af2876cc6da1a2ccf6aad51f1a153ac794761eb76763c1e8330"},{name:"experiment-dossier-v0.1.0.md",digest:"sha256:6d72387f9ee60cc994166595d1cd1c2abc3d72863f05c857bcb1470352b73b5e"},{name:"version.json",digest:"sha256:b5475730a3726c2e2ff89457e8e976d8f5aada46bfcee6218e99cf6689b51b07"}]} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.schema == "gooo/evolution-trial/final-report/v1" and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.experiment == "first-release-to-release-reflexive-normalization-split" and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.decision == "REFUTED" and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.candidate_evolution == {decision:"CLOSED",added_cells:2,retired_cells:1,split_cells:1,rollback_exact_pair:true,graph_before:"sha256:ab965892722b03bf9d4da78a6bf91f018d9609018107a90db6435fc34832549b",graph_after:"sha256:9369abeeccfadba001ed001306281cb6b0e413fe094de6353d8208bcf76c0485",delta:"sha256:826a90daaf19fb0f0b0b51af89c53150219ca624331905a4c913e329b085a6e6",candidate:"sha256:4edd900ea94b1cb461b27d61fb06e72993424eb8ad424b82ac19b78b59318bdb"} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.baseline == {decision:"CLOSED",distribution:{CLOSED:1,UNKNOWN:1,REFUTED:1},failed:0,replay:true,phase_digest:"sha256:8a557cb3b7445f5186f0619b14c82dd215f1950a2d298bafe2cbdc7e54768220",receipt_digest:"sha256:ef560e68b9d88054c6e22e385955a698dd4806f014d7df7142987f5d0973c44d"} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.candidate == {decision:"REFUTED",distribution:{CLOSED:0,UNKNOWN:0,REFUTED:3},failed:3,replay:false,phase_digest:"sha256:0be26e6d653f0200c0300334fdf252b0d6ea0fdec81acdf7ac34801a03cd5ff1",reason:"phase graph must declare exactly three executable activities",semantic_ir:"NOT_OBSERVED",backend:"NOT_OBSERVED",result_digest:"sha256:f8a7d659e13ddb36889d7b2c8ad7d64b5c249399f80d62e23914523ed992758e"} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.causal == {decision:"REFUTED",full_oracle:"CLOSED",full_oracle_digest:"sha256:65bf73d71b57aa3a07fe68a22cddf904e0629c7d2b145f1d9a7e55519025cb6c",candidate_result_digest:"sha256:f8a7d659e13ddb36889d7b2c8ad7d64b5c249399f80d62e23914523ed992758e",metrics:{total:2,selected:1,executed:1,reused:1,full_oracle:2,fail:1,unknown:0,avoided:1}} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.acceptance_predicates == {candidate_compiled_and_generated_ir_backend:false,causal_selection_and_full_oracle_closed:false,closed_unknown_refuted_corpus_preserved:false,exact_semantic_resolution_pair_observed:true,replay_digests_match:false,rollback_possible:true} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.released_tools_executed == {delta_forge:true,reflexive_compiler:true,causal_runner:true,candidate_only:true} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.metrics == {compile_wall_ms:2673,build_wall_ms:609,test_wall_ms:58,conformance_wall_ms:11384,integration_wall_ms:11384,peak_rss_kib:91512,generated_files:110,generated_bytes:377573} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.tests == {total:3,executed:3,reused:0,failed:0,unknown:1} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.inventory == {regular_files:22,directories:11,go_files:9,gooo_files:1,physical_lines:2164,per_language_physical_lines:"NOT_OBSERVED",root_readme_excluded:true} and
  .releases.executable_evolution_trial_counterexample_durable_release.protocol_observation.authority == {repository_writes:0,upstream_writes:0,local_test_executions:0,verification_authority:"GITHUB_ACTIONS"} and
  (.releases.executable_evolution_trial_counterexample_durable_release.assets|map(.id)) == [538589631,538589629,538589628,538589633,538589630,538589627] and
  (.releases.executable_evolution_trial_counterexample_durable_release.assets|map(.size_bytes)) == [2077,28486,764,469,3888,319] and
  (.releases.executable_evolution_trial_counterexample_durable_release.assets|map(.sha256)) == ["sha256:6d72387f9ee60cc994166595d1cd1c2abc3d72863f05c857bcb1470352b73b5e","sha256:b22d716111c7bcbe5dab18a1bb8caee03388579ac394f93a15798ebca5c43bfc","sha256:16d908073ae49566fd7186a8d042758a79d30274e94fe5c5ca7ca20773fc9839","sha256:e1431e654fe65bdb9a325b1da797b0da613e8712ad32c55854d78610f14380b4","sha256:b7cff57d0a300af2876cc6da1a2ccf6aad51f1a153ac794761eb76763c1e8330","sha256:b5475730a3726c2e2ff89457e8e976d8f5aada46bfcee6218e99cf6689b51b07"] and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.release_id == 380102097 and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.tag == "v0.2.0" and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.immutable == true and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.target_commit_sha == "7bdba0c353a73a40111747dbf55512939f6841a0" and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.tag_object_sha == "5852cc52f4ecec7fc835fdb6ed7adc1108459d6a" and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_pull_request == {number:8,base_ref:"main",head_ref:"agent/reflexive-phase-self-improvement",head_sha:"69727313308f5143319b4bb2b95e67b6bdd2735d",merge_commit_sha:"7bdba0c353a73a40111747dbf55512939f6841a0",merged:true} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_pr_run.run_id == 33447973294 and .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_pr_run.job_id == 99671224008 and .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_pr_run.artifact_ids == [9778718602] and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_pr_artifact == {run_id:33447973294,artifact_id:9778718602,name:"reflexive-conformance-8e0f45ce97fad9da11e7bbcf1ef5ad8b129fa1d6",size_bytes:24954557,sha256:"sha256:596a6042d1682097df78e237c7b60541fc05dcc359c05dff749a4bc77debbb75"} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_run.run_id == 33448048024 and .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_run.job_id == 99671456387 and .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_run.artifact_ids == [9778748463] and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.source_artifact == {run_id:33448048024,artifact_id:9778748463,name:"reflexive-conformance-7bdba0c353a73a40111747dbf55512939f6841a0",size_bytes:24954565,sha256:"sha256:be15de0147fb86e12e0ccf1432dfab7628e64fe6ac2201f5739fc7e017da98f7"} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.release_run.run_id == 33448121915 and .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.release_run.job_id == 99671691260 and .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.release_run.artifact_ids == [] and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.release_manifest == {schema:"gooo/reflexive-release-manifest/v1",version:"0.2.0",tag:"v0.2.0",commit:"7bdba0c353a73a40111747dbf55512939f6841a0",assets:[{name:"gooo-reflexive-compiler-slice-source-v0.2.0.tar.gz",digest:"sha256:3ced5c624b50afddf6906c093b80a3a83eebfc52ed2c59051ec427b28931eeba"},{name:"gooo-reflexive-compiler-slice-linux-amd64-v0.2.0.tar.gz",digest:"sha256:039d8db0457cb8ff9d439ac52234c23de6c19b38212d8c32242155d276bd483b"},{name:"release-report-v0.2.0.json",digest:"sha256:6d80a3941a55d4199f6fc3fae4ed2c2429f45d1fd24fb2e3aafecc1125ca2fc7"},{name:"version.json",digest:"sha256:cd55a20257e61a0603bbdc32c47667bf107d3d4dffe31518477ebb9c67a64214"}]} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.historical_provenance["v0.1.0"] == {state:"NON_DURABLE",tag:"v0.1.0",release_id:380032434,immutable:false,tag_object_sha:"f89b47fedab983b9c3cef0b9be03da65eadff3de",target_commit_sha:"57f5ef6ce407f51cd36da163b2b267e876c31e33"} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.schema == "gooo/reflexive-compiler-graph-topology/v1" and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.scope == "ONE_COMPILER_PHASE" and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.topology.before == {id:"reflexive.normalize.v1",digest:"sha256:8a557cb3b7445f5186f0619b14c82dd215f1950a2d298bafe2cbdc7e54768220",activity_roles:["NormalizeSource","EmitBackend","VerifyReplay"],activity_count:3,typed_edge_count:2,valid:true,localization_stages:1} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.topology.after == {id:"reflexive.normalize.v1",digest:"sha256:30b38ad566a350a3d0107f48f79ff43db467a94ce4aaf464ad1970e872b862b3",topology:"reflexive.normalize.v2",activity_roles:["ParseSource","ValidateStableIDs","EmitBackend","VerifyReplay"],activity_count:4,typed_edge_count:3,valid:true,localization_stages:2} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.topology.semantics == "ROLE_EDGE_STAGE_TOPOLOGY_NOT_COUNT" and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.direct_corpus == {before:{CLOSED:1,UNKNOWN:1,REFUTED:1},after:{CLOSED:1,UNKNOWN:1,REFUTED:1},after_cases:3,all_independently_verified:true} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.resolution_pairs == {supported_valid_topology_cardinalities:{before:1,after:2,unit:"valid-topology-cardinalities"},accepted_trial_candidate_cases:{before:0,after:3,unit:"cases"},coarse_localization_stages:{before:1,after:2,unit:"phase-localization-stages"}} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.trial_refutation == {state:"REFUTED",error:"phase graph must declare exactly three executable activities",delta:{added_cells:2,retired_cells:1,split_cells:1},rollback_exact_pair:true,baseline_distribution:{CLOSED:1,UNKNOWN:1,REFUTED:1},candidate_distribution:{CLOSED:0,UNKNOWN:0,REFUTED:3},causal:{total:2,selected:1,executed:1,reused:1,full_oracle:2,failures:1}} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.applied_bundle == {sha256:"sha256:49244a778d6e80c67bb5fb0b99342873ba987916b14febb500524a26a5af3490",candidate:"sha256:4edd900ea94b1cb461b27d61fb06e72993424eb8ad424b82ac19b78b59318bdb",delta:"sha256:826a90daaf19fb0f0b0b51af89c53150219ca624331905a4c913e329b085a6e6",applied_root_phase:"sha256:30b38ad566a350a3d0107f48f79ff43db467a94ce4aaf464ad1970e872b862b3",root_match:true} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.same_digest_conditions == {source_tree:"sha256:09fef83853c981cb5d77f31a31e8d424523fec4eb730423b8b27167c1c5db477",contract:"sha256:a15ac998e85d7fe7a62d112260024da08e433b603af03360f348a194c22d03d2",toolchain:"sha256:76227025cc0bc2be7067aa45d11e09cacfd49c58f498f4c2e4f6a9872a607bf9"} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.closure == {state:"CLOSED",stage:"IMPROVEMENT",step:"RESOLVE_TRIAL_COUNTEREXAMPLE",reason:"GRAPH_SEMANTICS_ACCEPT_SPLIT_CANDIDATE",trial_refutation:"REFUTED",protected_core_adoption:0} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.metrics == {go_files:8,go_lines:1775,gooo_files:4,gooo_lines:48,regular_files:29,directories:14,root_readme_excluded:true,outputs_files:21,outputs_bytes:32289,peak_rss_bytes:7008256,peak_rss_kib:7072,compile_wall_ms:59,build_wall_ms:5248,test_wall_ms:2096,conformance_wall_ms:2538,integration_wall_ms:8228} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.tests == {total:3,executed:3,reused:0,failed:0,unknown:1} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.protocol_observation.authority == {repository_writes:0,upstream_writes:0,local_test_executions:0,verification_authority:"GITHUB_ACTIONS"} and
  .releases.reflexive_compiler_graph_topology_self_improvement_durable_release.ledger_consumer_observation == {append_only:true,local_validation_executions:1,artifact_schema_assertion_replays:1,local_schema_replays:0,local_conformance_replays:0,local_go_test:0,local_go_build:0,local_go_vet:0,process_state:"REFUTED"} and
  (.releases.reflexive_compiler_graph_topology_self_improvement_durable_release.assets|map(.id)) == [538621864,538621862,538621865,538621866,538621870,538621863] and
  (.releases.reflexive_compiler_graph_topology_self_improvement_durable_release.assets|map(.size_bytes)) == [2628138,31726,795,10167,506,315] and
  (.releases.reflexive_compiler_graph_topology_self_improvement_durable_release.assets|map(.sha256)) == ["sha256:039d8db0457cb8ff9d439ac52234c23de6c19b38212d8c32242155d276bd483b","sha256:3ced5c624b50afddf6906c093b80a3a83eebfc52ed2c59051ec427b28931eeba","sha256:3e9a6b8d409725a1b8e99a387ebd33045e64677364df783c083b32472c3ba171","sha256:6d80a3941a55d4199f6fc3fae4ed2c2429f45d1fd24fb2e3aafecc1125ca2fc7","sha256:e7554da06237c2b52eaa15f4a5fa4e16b1edbf6240eacffdaea6000fc73d7464","sha256:cd55a20257e61a0603bbdc32c47667bf107d3d4dffe31518477ebb9c67a64214"] and
  .releases.executable_evolution_trial_closed_loop_durable_release.release_id == 380109530 and
  .releases.executable_evolution_trial_closed_loop_durable_release.tag == "v0.2.0" and
  .releases.executable_evolution_trial_closed_loop_durable_release.release_url == "https://github.com/kimjooyoon/gooo-evolution-trial/releases/tag/v0.2.0" and
  .releases.executable_evolution_trial_closed_loop_durable_release.target_commit_sha == "aa72f7019d1224344802478490d94046d27af58f" and
  .releases.executable_evolution_trial_closed_loop_durable_release.tag_object_sha == "b05e646ac009208e2451473b019b5768a4b20bb8" and
  .releases.executable_evolution_trial_closed_loop_durable_release.immutable == true and
  .releases.executable_evolution_trial_closed_loop_durable_release.source_pull_request == {number:5,base_ref:"main",head_ref:"feature/second-release-v020",head_sha:"7c008ae80333771ca2158dec8a6ecb2a8bd9de58",merge_commit_sha:"aa72f7019d1224344802478490d94046d27af58f",merged:true} and
  .releases.executable_evolution_trial_closed_loop_durable_release.source_pr_run.run_id == 33449309946 and .releases.executable_evolution_trial_closed_loop_durable_release.source_pr_run.job_id == 99675370500 and .releases.executable_evolution_trial_closed_loop_durable_release.source_pr_run.artifact_ids == [9779165344] and
  .releases.executable_evolution_trial_closed_loop_durable_release.source_pr_artifact == {run_id:33449309946,artifact_id:9779165344,name:"gooo-evolution-trial-33449309946",size_bytes:151620,sha256:"sha256:c8d92b7626520f4a3d41a55695969d3fd211ff40a2f8db6ba7a03d5ce6e51608"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.source_run.run_id == 33449393842 and .releases.executable_evolution_trial_closed_loop_durable_release.source_run.job_id == 99675631928 and .releases.executable_evolution_trial_closed_loop_durable_release.source_run.artifact_ids == [9779197222] and
  .releases.executable_evolution_trial_closed_loop_durable_release.source_artifact == {run_id:33449393842,artifact_id:9779197222,name:"gooo-evolution-trial-33449393842",size_bytes:151681,sha256:"sha256:6cbcef44dffa70e1972e3f1c195272a9d45c644e7a1eb9fc61148d591a2ab33e"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.release_run.run_id == 33449476756 and .releases.executable_evolution_trial_closed_loop_durable_release.release_run.job_id == 99675899128 and .releases.executable_evolution_trial_closed_loop_durable_release.release_run.artifact_ids == [9779223480] and
  .releases.executable_evolution_trial_closed_loop_durable_release.release_artifact == {run_id:33449476756,artifact_id:9779223480,name:"gooo-evolution-trial-0.2.0-release-audit",size_bytes:35765,sha256:"sha256:7f8bcab82d8f0c73f61a0ecee169872747118c7989c1ec9648fe4ff206aa7ba6"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.release_manifest == {schema:"gooo/evolution-trial/release-manifest/v1",version:"0.2.0",tag:"v0.2.0",commit:"aa72f7019d1224344802478490d94046d27af58f",assets:[{name:"gooo-evolution-trial-source-v0.2.0.tar.gz",digest:"sha256:984ef2a192221adc8ebeaeb8489e6a1bf450238d16036c045c4382fe19429218"},{name:"upstream-lock-v0.2.0.json",digest:"sha256:28f5457240fb35d3c24c65373f824cb5df918f003245b60cb5389ca3618e4120"},{name:"experiment-dossier-v0.2.0.md",digest:"sha256:7cf59e690e9458eefffcb9cfd536119f6669146bf00aa96a365ee3bc1af688ac"},{name:"version.json",digest:"sha256:c11572b368dcc984ea4c2666ec4aa46dc43c3434cd913cac044daf6142bb9f74"}]} and
  .releases.executable_evolution_trial_closed_loop_durable_release.historical_provenance["v0.1.0"] == {state:"REFUTED",tag:"v0.1.0",release_id:380032434,immutable:false,tag_object_sha:"f89b47fedab983b9c3cef0b9be03da65eadff3de",target_commit_sha:"57f5ef6ce407f51cd36da163b2b267e876c31e33"} and
  ([.releases.executable_evolution_trial_closed_loop_durable_release.upstream_inputs[]|{producer,release,release_id,immutable,tag_object,target_commit,release_run_id,release_job_id,release_artifact_id}]) == [{producer:"github.com/kimjooyoon/gooo-language-delta-forge",release:"v0.1.2",release_id:380033725,immutable:true,tag_object:"5d68c5f2f699f9d73bcf2e87121204512dfd64fc",target_commit:"30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45",release_run_id:33436456556,release_job_id:99633967202,release_artifact_id:9774576485},{producer:"github.com/kimjooyoon/gooo-reflexive-compiler-slice",release:"v0.2.0",release_id:380102097,immutable:true,tag_object:"5852cc52f4ecec7fc835fdb6ed7adc1108459d6a",target_commit:"7bdba0c353a73a40111747dbf55512939f6841a0",release_run_id:33448121915,release_job_id:99671691260,release_artifact_id:9778748463},{producer:"github.com/kimjooyoon/gooo-causal-verification-runner",release:"v0.1.1",release_id:380048457,immutable:true,tag_object:"82bb99006232a064725df29a53af5405e222cd42",target_commit:"0c16428762d1d1da1b28fe05c4e051d2cc41967b",release_run_id:33439000856,release_job_id:99642343892,release_artifact_id:9775474098}] and
  ([.releases.executable_evolution_trial_closed_loop_durable_release.upstream_inputs[].assets[]|{id,size_bytes,sha256}]) == [{id:538495830,size_bytes:240,sha256:"sha256:cd99462d4d6635ba03024ef3e03ea600dbe65f22ad416f379583f86fa6af7876"},{id:538495829,size_bytes:7542,sha256:"sha256:e14fc1d338ea85a51f1d6f43997e0e1c74d9be2ddc9eaa97d22d98ebfb5ff2d4"},{id:538495828,size_bytes:26671,sha256:"sha256:77424f9465322c37ab87efcb920f936e6ddf3e02c2b7e59657fae82ff05283ba"},{id:538495832,size_bytes:736,sha256:"sha256:0c467b96e4b91915139aa0d5990b49c8ca5a038a2ac965d43a4a5656e511064a"},{id:538621864,size_bytes:2628138,sha256:"sha256:039d8db0457cb8ff9d439ac52234c23de6c19b38212d8c32242155d276bd483b"},{id:538621862,size_bytes:31726,sha256:"sha256:3ced5c624b50afddf6906c093b80a3a83eebfc52ed2c59051ec427b28931eeba"},{id:538621865,size_bytes:795,sha256:"sha256:3e9a6b8d409725a1b8e99a387ebd33045e64677364df783c083b32472c3ba171"},{id:538621866,size_bytes:10167,sha256:"sha256:6d80a3941a55d4199f6fc3fae4ed2c2429f45d1fd24fb2e3aafecc1125ca2fc7"},{id:538621870,size_bytes:506,sha256:"sha256:e7554da06237c2b52eaa15f4a5fa4e16b1edbf6240eacffdaea6000fc73d7464"},{id:538621863,size_bytes:315,sha256:"sha256:cd55a20257e61a0603bbdc32c47667bf107d3d4dffe31518477ebb9c67a64214"},{id:538521941,size_bytes:38034,sha256:"sha256:fcf40acd1f09805e526b8e9634cd70b8f308e1f2312b0aac8d3253c4038db7fb"},{id:538521943,size_bytes:552,sha256:"sha256:36d3f52aeb74f32025d0eaa10767e2a6036b5ad42e0636f92b90339af9615eb8"},{id:538521942,size_bytes:214,sha256:"sha256:4297c6c933c4892016df45367015094c9d2fe122a950f7effa9276607df6201f"}] and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.schema == "gooo/evolution-trial/final-report/v1" and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.experiment == "second-release-to-release-reflexive-normalization-split" and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.decision == "CLOSED" and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.candidate_evolution == {decision:"CLOSED",added_cells:2,retired_cells:1,split_cells:1,rollback_exact_pair:true,graph_before:"sha256:ab965892722b03bf9d4da78a6bf91f018d9609018107a90db6435fc34832549b",graph_after:"sha256:9369abeeccfadba001ed001306281cb6b0e413fe094de6353d8208bcf76c0485",delta:"sha256:826a90daaf19fb0f0b0b51af89c53150219ca624331905a4c913e329b085a6e6",candidate:"sha256:4edd900ea94b1cb461b27d61fb06e72993424eb8ad424b82ac19b78b59318bdb"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.baseline == {decision:"CLOSED",distribution:{CLOSED:1,UNKNOWN:1,REFUTED:1},failed:0,replay:true,phase_digest:"sha256:8a557cb3b7445f5186f0619b14c82dd215f1950a2d298bafe2cbdc7e54768220",receipt_digest:"sha256:a1fd19e7b4f235318bbeac4de64f99174e5490489f98bc91991ef94874bf1d95"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.candidate == {decision:"CLOSED",distribution:{CLOSED:1,UNKNOWN:1,REFUTED:1},failed:0,replay:true,phase_digest:"sha256:30b38ad566a350a3d0107f48f79ff43db467a94ce4aaf464ad1970e872b862b3",reason:"",semantic_ir:"OBSERVED",backend:"OBSERVED",result_digest:"sha256:03225f426326f5d8969337eba00291e016f86a26f282ae02bd27a86d49ac8fbe"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.causal == {decision:"CLOSED",full_oracle:"CLOSED",metrics:{total:2,selected:1,executed:1,reused:1,full_oracle:2,fail:0,unknown:0,avoided:1}} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.acceptance_predicates == {candidate_compiled_and_generated_ir_backend:true,causal_selection_and_full_oracle_closed:true,closed_unknown_refuted_corpus_preserved:true,exact_semantic_resolution_pair_observed:true,replay_digests_match:true,rollback_possible:true} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.released_tools_executed == {delta_forge:true,reflexive_compiler:true,causal_runner:true,candidate_only:true} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.metrics == {compile_wall_ms:2516,build_wall_ms:584,test_wall_ms:62,conformance_wall_ms:10438,integration_wall_ms:10438,peak_rss_kib:91624,generated_files:143,generated_bytes:411050} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.tests == {total:3,executed:3,reused:0,failed:0,unknown:1} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.inventory == {regular_files:23,directories:12,go_files:9,gooo_files:2,physical_lines:2222,per_language_physical_lines:"NOT_OBSERVED",root_readme_excluded:true} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.authority == {repository_writes:0,upstream_writes:0,local_test_executions:0,verification_authority:"GITHUB_ACTIONS"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.state == {whole_language_improvement:"UNKNOWN",external_utility:"UNKNOWN/NOT_MADE"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.closure_receipt == {schema:"gooo/reflexive-improvement-closure/v1",state:"CLOSED",stage:"IMPROVEMENT",step:"RESOLVE_TRIAL_COUNTEREXAMPLE",reason:"GRAPH_SEMANTICS_ACCEPT_SPLIT_CANDIDATE",trial_refutation_state:"REFUTED",trial_refutation_error:"phase graph must declare exactly three executable activities",next_operation:"RETAIN_BASELINE_AND_CANDIDATE_EVIDENCE",blocked_by:[]} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.process == {bootstrap_direct_main:1,post_bootstrap_direct_main:0,exact:true,repository_writes_by_experiment:0,upstream_writes_by_experiment:0,local_test_executions:0,main_head:"aa72f7019d1224344802478490d94046d27af58f",bootstrap_root:"cd64acc2077474e459dcbcd457aff0d320524c14",pull_requests:[1,2,3,4,5]} and
  .releases.executable_evolution_trial_closed_loop_durable_release.protocol_observation.ledger_consumer_observation == {append_only:true,local_validation_executions:1,artifact_schema_assertion_replays:1,local_schema_replays:0,local_conformance_replays:0,local_go_test:0,local_go_build:0,local_go_vet:0,local_go_conformance:0,process_state:"REFUTED"} and
  .releases.executable_evolution_trial_closed_loop_durable_release.local_validation_followup == {local_validation_executions:2,inspection_only:false,process_state:"REFUTED",local_schema_replays:0,local_conformance_replays:0,local_go_test:0,local_go_build:0,local_go_vet:0,local_go_conformance:0} and
  (.releases.executable_evolution_trial_closed_loop_durable_release.assets|map(.id)) == [538638669,538638668,538638665,538638674,538638666,538638667] and
  (.releases.executable_evolution_trial_closed_loop_durable_release.assets|map(.size_bytes)) == [2345,30429,764,469,4134,319] and
  (.releases.executable_evolution_trial_closed_loop_durable_release.assets|map(.sha256)) == ["sha256:7cf59e690e9458eefffcb9cfd536119f6669146bf00aa96a365ee3bc1af688ac","sha256:984ef2a192221adc8ebeaeb8489e6a1bf450238d16036c045c4382fe19429218","sha256:48f4dd0c1391f9ec91654e8d2b25a67942e8e6febd3461c61d0651a35896153f","sha256:bc867402084059cda6fd1f9590f94b45f807725001c2d9e927e13808be8e9aca","sha256:28f5457240fb35d3c24c65373f824cb5df918f003245b60cb5389ca3618e4120","sha256:c11572b368dcc984ea4c2666ec4aa46dc43c3434cd913cac044daf6142bb9f74"] and
  .releases.structural_ledger_append_planner_durable_release.release_id == 380152259 and
  .releases.structural_ledger_append_planner_durable_release.tag == "v0.2.0" and
  .releases.structural_ledger_append_planner_durable_release.release_url == "https://github.com/kimjooyoon/gooo-ledger-append-planner/releases/tag/v0.2.0" and
  .releases.structural_ledger_append_planner_durable_release.target_commit_sha == "893042983ac5666abaefeb035e8efaf6d9f6cd62" and
  .releases.structural_ledger_append_planner_durable_release.tag_object_sha == "aaf26d3047e91deaf757dbc1976f1ada573c450b" and
  .releases.structural_ledger_append_planner_durable_release.immutable == true and
  (.releases.structural_ledger_append_planner_durable_release.assets|map({id,size_bytes,sha256})) == [{id:538748262,size_bytes:6300811,sha256:"sha256:25274148049853e3147618e6278570259cf3238fb578b8f808231e47c2488da8"},{id:538748260,size_bytes:402726,sha256:"sha256:f01a5ad3350a507aca5f91142e8cd09cbaf7ab923507a85f8209084d873663f7"},{id:538748261,size_bytes:242,sha256:"sha256:58eaa0009d817797ebc8d05d6d2d304ddd8b1ed1c455e6d70c620ca21cd568e2"}] and
  (.releases.structural_ledger_append_planner_durable_release.assets|map(.download_url)) == ["https://github.com/kimjooyoon/gooo-ledger-append-planner/releases/download/v0.2.0/gooo-ledger-append-planner-linux-amd64-v0.2.0","https://github.com/kimjooyoon/gooo-ledger-append-planner/releases/download/v0.2.0/gooo-ledger-append-planner-source-v0.2.0.tar.gz","https://github.com/kimjooyoon/gooo-ledger-append-planner/releases/download/v0.2.0/SHA256SUMS"] and
  .releases.explanation_carrying_compiler_durable_release.release_id == 380150043 and
  .releases.explanation_carrying_compiler_durable_release.tag == "v0.3.0" and
  .releases.explanation_carrying_compiler_durable_release.release_url == "https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/tag/v0.3.0" and
  .releases.explanation_carrying_compiler_durable_release.target_commit_sha == "0cf44db8b0d6cd96d190e9f902312d0be9394029" and
  .releases.explanation_carrying_compiler_durable_release.tag_object_sha == "d7e2bd301f5d1634e92b0de90d54798a35db424a" and
  .releases.explanation_carrying_compiler_durable_release.immutable == true and
  (.releases.explanation_carrying_compiler_durable_release.assets|map({id,size_bytes,sha256})) == [{id:538741020,size_bytes:2647664,sha256:"sha256:e03b605c14f5d4d0faf262e57556506f8cf7765756aee49a4ceb99fd700ae862"},{id:538741018,size_bytes:38820,sha256:"sha256:62c45b663084690ff0ad964991d9d7fda1c30ee361876f31fc4f10ef34b68dbc"},{id:538741021,size_bytes:795,sha256:"sha256:4d3bbafb7e31f1fabf83d39ff4f7ea918c658fed1ded18d9b9d177e7d9e95231"},{id:538741019,size_bytes:11497,sha256:"sha256:6a20f41e9f5700f7e400597833e72b055d1d495aeada5f0c57ea4fae5842d514"},{id:538741023,size_bytes:506,sha256:"sha256:560883657ad1bda5053d903beb113615f90bd8a2b4ac59c269abfce8c786d3c7"},{id:538741017,size_bytes:315,sha256:"sha256:32519d4c2b0372e3b5abe6a5a188b04d7f0be3f7d6cd037e53a3ab73b6223195"}] and
  (.releases.explanation_carrying_compiler_durable_release.assets|map(.download_url)) == ["https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/download/v0.3.0/gooo-reflexive-compiler-slice-linux-amd64-v0.3.0.tar.gz","https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/download/v0.3.0/gooo-reflexive-compiler-slice-source-v0.3.0.tar.gz","https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/download/v0.3.0/release-manifest-v0.3.0.json","https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/download/v0.3.0/release-report-v0.3.0.json","https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/download/v0.3.0/SHA256SUMS","https://github.com/kimjooyoon/gooo-reflexive-compiler-slice/releases/download/v0.3.0/version.json"] and
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
  and .releases.two_generation_bootstrap_durable_release == {
    repository:"kimjooyoon/gooo-two-generation-bootstrap",
    tag:"v0.1.1",
    release_id:380148091,
    release_url:"https://github.com/kimjooyoon/gooo-two-generation-bootstrap/releases/tag/v0.1.1",
    target_commit_sha:"6d2bc764f144900862ba5e127cfa19d4cec248b9",
    tag_object_sha:"8b89c283ece9ac7321858308366395946265400f",
    immutable:true,
    assets:[
      {id:538734713,name:"gooo-two-generation-release-v0.1.1-evidence.tar.gz",size_bytes:5823,sha256:"sha256:66fed9217a3a632e412a00feae80b87ac66fbf9fd63d4ee6e147b8d6a059ae9c",download_url:"https://github.com/kimjooyoon/gooo-two-generation-bootstrap/releases/download/v0.1.1/gooo-two-generation-release-v0.1.1-evidence.tar.gz",role:"release-evidence"},
      {id:538734714,name:"gooo-two-generation-release-v0.1.1-SHA256SUMS",size_bytes:117,sha256:"sha256:e28154200027dd298aa56dc5cc8c045f177c259a105166cfa8d8dce46e39ebc3",download_url:"https://github.com/kimjooyoon/gooo-two-generation-bootstrap/releases/download/v0.1.1/gooo-two-generation-release-v0.1.1-SHA256SUMS",role:"release-checksums"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: release lock contract passed"
jq -e '
  .releases.hygienic_origin_resolver_durable_release == {
    repository:"kimjooyoon/gooo-hygienic-origin-resolver",
    tag:"v0.1.1",
    release_id:380148937,
    release_url:"https://github.com/kimjooyoon/gooo-hygienic-origin-resolver/releases/tag/v0.1.1",
    target_commit_sha:"17933b4e7a724a622652c73de04f7973c524bec9",
    tag_object_sha:"b7ab8f0e21104d8dcd37c0557f264d8f763eeffd",
    immutable:true,
    assets:[
      {id:538737532,name:"gooo-hygienic-origin-resolver-v0.1.1-evidence.tar.gz",size_bytes:3903,sha256:"sha256:989a416a62e49436c9134b15a03d20a97891a976f92063ca9397a9621a94cb91",download_url:"https://github.com/kimjooyoon/gooo-hygienic-origin-resolver/releases/download/v0.1.1/gooo-hygienic-origin-resolver-v0.1.1-evidence.tar.gz",role:"release-evidence"},
      {id:538737530,name:"gooo-hygienic-origin-resolver-v0.1.1.tar.gz",size_bytes:24885,sha256:"sha256:83b3b2b13c5dabe41b4730eeb4ef9371d1f0d04e20c86e52c7da099377e7ceac",download_url:"https://github.com/kimjooyoon/gooo-hygienic-origin-resolver/releases/download/v0.1.1/gooo-hygienic-origin-resolver-v0.1.1.tar.gz",role:"release-source"},
      {id:538737529,name:"release-lock-v0.1.1.json",size_bytes:1233,sha256:"sha256:0529d8f65b0290f94a850ee9cf68de95fc4e62db5693a8f61c604ac24022af88",download_url:"https://github.com/kimjooyoon/gooo-hygienic-origin-resolver/releases/download/v0.1.1/release-lock-v0.1.1.json",role:"release-lock"},
      {id:538737531,name:"SHA256SUMS",size_bytes:229,sha256:"sha256:90e09809479162c1f3b9b287b04e6a4fe3d0bb44f9389f7ca1d35e7f0b73086e",download_url:"https://github.com/kimjooyoon/gooo-hygienic-origin-resolver/releases/download/v0.1.1/SHA256SUMS",role:"release-checksums"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: hygienic origin resolver release lock passed"
jq -e '
  .releases.capability_effect_checker_durable_release == {
    repository:"kimjooyoon/gooo-capability-effect-checker",
    tag:"v0.1.1",
    release_id:380149578,
    release_url:"https://github.com/kimjooyoon/gooo-capability-effect-checker/releases/tag/v0.1.1",
    target_commit_sha:"5bd2efb088ec9d38d3d4fc79c3545b61446935e8",
    tag_object_sha:"a94e28c3bba56886b709838c04723e25abf55c1b",
    immutable:true,
    assets:[
      {id:538739363,name:"ci-metrics.json",size_bytes:978,sha256:"sha256:f2ef6d03150d868d85f8a3e91e6c34a47446f3417937339c291dac2447a61303",download_url:"https://github.com/kimjooyoon/gooo-capability-effect-checker/releases/download/v0.1.1/ci-metrics.json",role:"ci-metrics"},
      {id:538739364,name:"gooo-capability-effect-checker-0.1.1.tar.gz",size_bytes:19964,sha256:"sha256:ca111a04da52d746223de7ce194433ac628bfc33754aea2655baa3a0e8b6ef2c",download_url:"https://github.com/kimjooyoon/gooo-capability-effect-checker/releases/download/v0.1.1/gooo-capability-effect-checker-0.1.1.tar.gz",role:"release-source"},
      {id:538739362,name:"release-manifest.json",size_bytes:872,sha256:"sha256:f4a8373e9f5f466a7c77ca09866e59fa344ece00acdf515c5a8c2927d0c86bb9",download_url:"https://github.com/kimjooyoon/gooo-capability-effect-checker/releases/download/v0.1.1/release-manifest.json",role:"release-manifest"},
      {id:538739365,name:"run-report.json",size_bytes:6234,sha256:"sha256:26089654c08e8db6353b253afb8a7c674aef6e813bd4d032545df0b973cd0843",download_url:"https://github.com/kimjooyoon/gooo-capability-effect-checker/releases/download/v0.1.1/run-report.json",role:"run-report"},
      {id:538739366,name:"SHA256SUMS",size_bytes:362,sha256:"sha256:49938f8dd3dc3e6c5818f92cabad028a2a15e6678d76527c107c284122e19139",download_url:"https://github.com/kimjooyoon/gooo-capability-effect-checker/releases/download/v0.1.1/SHA256SUMS",role:"release-checksums"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: capability effect checker release lock passed"
jq -e '
  .releases.deterministic_module_linker_durable_release == {
    repository:"kimjooyoon/gooo-module-linker",
    tag:"v0.1.1",
    release_id:380147845,
    release_url:"https://github.com/kimjooyoon/gooo-module-linker/releases/tag/v0.1.1",
    target_commit_sha:"73a2c4f64be92d3dff67e659794f1597427c3148",
    tag_object_sha:"006323188885fe6564c26a47c71b66a3a0dc960e",
    immutable:true,
    assets:[
      {id:538733980,name:"gooo-evidence-v0.1.1.json",size_bytes:7498,sha256:"sha256:a64231a836f62a0176ff1c1ad33ec4def0e9f31aed0258723db01a657c824738",download_url:"https://github.com/kimjooyoon/gooo-module-linker/releases/download/v0.1.1/gooo-evidence-v0.1.1.json",role:"evidence"},
      {id:538733979,name:"linked-ir-v0.1.1.json",size_bytes:2746,sha256:"sha256:1e9b83b38a09a31cc9fabb98c3ac0767e7b4941f84916f3f875f2bb6f91146e0",download_url:"https://github.com/kimjooyoon/gooo-module-linker/releases/download/v0.1.1/linked-ir-v0.1.1.json",role:"linked-ir"},
      {id:538733978,name:"generated-go-v0.1.1.go",size_bytes:982,sha256:"sha256:deec296b9f763c26ca852f223c7cdade64ba88c2fb73b8047917dcd85cbae4e2",download_url:"https://github.com/kimjooyoon/gooo-module-linker/releases/download/v0.1.1/generated-go-v0.1.1.go",role:"generated-go"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: deterministic module linker release lock passed"
jq -e '
  .releases.semantic_counterexample_reducer_durable_release == {
    repository:"kimjooyoon/gooo-semantic-counterexample-reducer",
    tag:"v0.1.1",
    release_id:380148374,
    release_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/tag/v0.1.1",
    target_commit_sha:"395f3faba810f0dd8f091cb6180527c7240eee61",
    tag_object_sha:"cc225db786718083a81264398096b75a23301646",
    immutable:true,
    assets:[
      {id:538735547,name:"ci-metrics-v0.1.1.json",size_bytes:181,sha256:"sha256:3be38f5674e2c063ce74f0bb5b42ffbc2550c69589d7438e9b0023657fe4e2e1",download_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/download/v0.1.1/ci-metrics-v0.1.1.json",role:"ci-metrics"},
      {id:538735550,name:"gooo-semantic-counterexample-reducer-source-v0.1.1.tar.gz",size_bytes:28172,sha256:"sha256:0d90dcad2c2aa072b8c0f46378e227813bd439e41e81cc7b3fe5f0111cb38454",download_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/download/v0.1.1/gooo-semantic-counterexample-reducer-source-v0.1.1.tar.gz",role:"release-source"},
      {id:538735549,name:"reduction-report-v0.1.1.json",size_bytes:9529,sha256:"sha256:1124d7378125128900827e82f8ab87ab3751b7ab0c06b9fd29e081ed9d28a37c",download_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/download/v0.1.1/reduction-report-v0.1.1.json",role:"reduction-report"},
      {id:538735548,name:"release-manifest-v0.1.1.json",size_bytes:793,sha256:"sha256:dbedbe01c851718fcd1ce09a6fea329d026e75cc6abc06242174e32c8fe4531b",download_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/download/v0.1.1/release-manifest-v0.1.1.json",role:"release-manifest"},
      {id:538735551,name:"SHA256SUMS",size_bytes:482,sha256:"sha256:e3a9dc202ad28cd961be76d3eefd5edaa72149978db5cd89ffe83e2808742454",download_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/download/v0.1.1/SHA256SUMS",role:"release-checksums"},
      {id:538735563,name:"version.json",size_bytes:258,sha256:"sha256:da7549433fadd2ecb62ee2854a45c8d7c3033c77ec30d93833f7271ca5d010f9",download_url:"https://github.com/kimjooyoon/gooo-semantic-counterexample-reducer/releases/download/v0.1.1/version.json",role:"release-version"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: semantic counterexample reducer release lock passed"
jq -e '
  .releases.differential_semantics_runtime_durable_release == {
    repository:"kimjooyoon/gooo-differential-semantics-runtime",
    tag:"v0.1.2",
    release_id:380172619,
    release_url:"https://github.com/kimjooyoon/gooo-differential-semantics-runtime/releases/tag/v0.1.2",
    target_commit_sha:"33e0f5a9b54f22824c1a34c914e74d8e0f931b62",
    tag_object_sha:"965abb84f065783db1183271fcf71a989a7637ff",
    immutable:true,
    assets:[
      {id:538817960,name:"differential-evidence.json",size_bytes:1844,sha256:"sha256:931f4bbf36aeaaeb153077e9e5588c2fa021e1e512408d45a3161aea7c554b40",download_url:"https://github.com/kimjooyoon/gooo-differential-semantics-runtime/releases/download/v0.1.2/differential-evidence.json",role:"differential-evidence"}
    ]
  }
' "$repository/contracts/release-locks-v1.json" >/dev/null
echo "conformance: differential semantics runtime release lock passed"

echo "conformance: verify emitted report"
jq -e '
  .denominator_migration == {from:48,to:49,add:1,retire:0,split:0,append_only:true} and
  .local_validation_followup == {local_validation_executions:2,inspection_only:false,process_state:"REFUTED",local_schema_replays:0,local_conformance_replays:0,local_go_test:0,local_go_build:0,local_go_vet:0,local_go_conformance:0} and
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
  ((.cells[] | select(.cell_id == "EXPERIENCE_MEMORY_RELEASE")) as $experience |
    $experience.state == "CLOSED" and
    $experience.release_key == "experience_memory_release" and
    ($experience.evidence | index("release:379896833:immutable=true")) != null and
    ($experience.evidence | index("tag-object:9b889fc3dd5b663b5ac1ce7cd975fc89030c4a46:target=79fd6edc588ea26279dbe735e5f6e250132f7730")) != null and
    ($experience.evidence | index("source-actions:run=33414536312:job=99561917616:success")) != null and
    ($experience.evidence | index("source-actions-artifact:9766475762:15798:sha256:0aaec4dc2f9a3822c8c3f275f178dde929c7abb87b733544b1f36e2d3b9f26fb")) != null and
    ($experience.evidence | index("release-recheck-actions:run=33414620023:job=99562201563:success")) != null and
    ($experience.evidence | index("upstream-experience-memory:denominator=12:proof=4/4/4:indicator=4/4/4:cases=normal=4:CLOSED:unknown=4:UNKNOWN:refuted=4:REFUTED:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($experience.evidence | index("upstream-metrics:recurrence=1->0:avoided=1:new_unknown=2:replay=2/0:attempts=2:memory=1:candidates=5:rss=7256:wall=1:go=1578-lines/9-files:gooo=16-lines/1-file:dirs=13:tests=2/2/0/0/0:authority=0/0/0")) != null and
    ($experience.evidence | index("source-asset:538237753:25993:sha256:177f7c872d4e704f5eba6dd96c43e28bfcab2a714b032188c511f3e7872e5d6d")) != null and
    ($experience.evidence | index("evidence-asset:538237751:11528:sha256:27afa525ccaa5ebdf738fef99615998b51bed85d865ccd6e9367036a46a961f6")) != null and
    ($experience.evidence | index("manifest-asset:538237752:555:sha256:34e97b1cb9fd2ee520cea5b82acd9ee44272abb7392c8a32ce51a144f397ada1")) != null and
    ($experience.evidence | index("checksum-asset:538237754:229:sha256:237c96b9bd3eed13676f0a8a4f0de37c71d75646b6a51a762ba5ca9aa1afb6ca")) != null and
    ($experience.evidence | index("manifest-bindings:source=sha256:177f7c872d4e704f5eba6dd96c43e28bfcab2a714b032188c511f3e7872e5d6d:evidence=sha256:27afa525ccaa5ebdf738fef99615998b51bed85d865ccd6e9367036a46a961f6")) != null and
    ($experience.evidence | index("checksum-bindings:source=sha256:177f7c872d4e704f5eba6dd96c43e28bfcab2a714b032188c511f3e7872e5d6d:evidence=sha256:27afa525ccaa5ebdf738fef99615998b51bed85d865ccd6e9367036a46a961f6")) != null and
    ($experience.evidence | index("evidence-manifest:subject=10210e2a1d7bf803ed5be5c187ead9300e88d5e6:manifest=sha256:f9105286cdd402372dfe4a65abde56c74d36b6246f5f3b60ce535cb2a35ec0be:summary=sha256:2a31e5eb0eca14843199c90d697c533650c67f820d22e65e473e78b3f7be2665:ir=sha256:11c6aaee3853a67fb446fff669bb3384f6221936da6c55224cb2328921f260e1:receipt=sha256:b013ea186daeb0517d208630dc523ede4180f986cf8265258400f46963b49e33")) != null and
    ($experience.evidence | index("process-observation:failed-release-workflow:run=33413752929:job=99559373690:step=Confirm tag is annotated and build source asset:failure:score_included=false")) != null and
    ($experience.evidence | index("process-observation:operational-pr:2:head=91d046ebcf12ac6baf6a43dfb9f88c404f0be711:merge=6bf9ca277478bab5e47393e4b0fbcbe07d847296:merged=true:score_included=false")) != null and
    ($experience.evidence | index("process-observation:operational-pr:3:head=79921641afc2742634a473bf77f0656da50cb9fb:merge=10210e2a1d7bf803ed5be5c187ead9300e88d5e6:merged=true:score_included=false")) != null) and
  ((.cells[] | select(.cell_id == "SEMANTIC_DRIFT_GUARD_RELEASE")) as $drift_guard |
    $drift_guard.state == "CLOSED" and
    $drift_guard.release_key == "semantic_drift_guard_release" and
    ($drift_guard.evidence | index("release:379915376:immutable=true")) != null and
    ($drift_guard.evidence | index("tag-object:1e1cf4882347ccd69c14c4aa96e63c096709d512:target=15b6c1dcce26feb5f64d562140708f7cb27390aa")) != null and
    ($drift_guard.evidence | index("release-actions:run=33416657453:job=99568816492:success")) != null and
    ($drift_guard.evidence | index("pr-actions:run=33416441475:job=99568101328:success")) != null and
    ($drift_guard.evidence | index("pr-actions-artifact:9767194212:44290:sha256:f6bd1319019ec14d836b4e4bcc31533bc2614768b85bdb1c73deea3e37c89171")) != null and
    ($drift_guard.evidence | index("upstream-semantic-drift-guard:denominator=12:cases=10:CLOSED=1:UNKNOWN=4:REFUTED=5:precedence=REFUTED>UNKNOWN>CLOSED:canonical=source>ir>generated-go")) != null and
    ($drift_guard.evidence | index("upstream-normal-metrics:releases=2:source_files=2:ir_nodes=24:generated_files=2:relations=12->12:equivalent=1:drift=0:unknown_bindings=0:replay=1/0:rss=12246:wall=1:build=4654:test=1993:tests=12/12/0/0/0:go=1772-lines/13-files:gooo=85-lines/6-files:dirs=24:files=45:authority=0/0/0")) != null and
    ($drift_guard.evidence | index("asset:538271587:6651:sha256:83ea0adf7b59b08147eb24ef16483682d8f21d204dc93ed337d39900ae9e09ec")) != null and
    ($drift_guard.evidence | index("asset:538271586:113:sha256:61e49e62af005dff6a27f43bf20be43d257095bee1b552ab89a433fbe5db111b")) != null and
    ($drift_guard.evidence | index("ruleset:21943064:Immutable v release tags:enforcement=active:include=refs/tags/v*")) != null and
    ($drift_guard.evidence | index("immutable-releases:enabled=true:tag-pattern=v*.*.*:annotated=true:post-publish-isImmutable=true")) != null and
    ($drift_guard.evidence | index("process-observation:v0.1.0:release=379905110:immutable=false:tag-object=1af22b91e82ba97203bd7270ae64b2e487a1a4e5:target=32c52a412f3e07451d8c4e0aa0428bc5b33bd214:literal-tag-object-defect=tag_object=v0.1.0^{tag}:score_included=false")) != null and
    ($drift_guard.evidence | index("process-observation:v0.1.0-assets:faulty=538253208,538253206:correction=538262313,538262314:append_only=true:score_included=false")) != null and
    ($drift_guard.evidence | index("process-observation:pr-2:merged=true:merge=15b6c1dcce26feb5f64d562140708f7cb27390aa:score_included=false")) != null) and
  ((.cells[] | select(.cell_id == "SEMANTIC_AUTHORITY_CENSUS_RELEASE")) as $census |
    $census.state == "CLOSED" and
    $census.release_key == "semantic_authority_census_release" and
    ($census.evidence | index("release:379947813:immutable=true")) != null and
    ($census.evidence | index("tag-object:c81ff9b843dce716c57fe2ab542bde52e922ab2b:target=0451a1f5813e51a2d09145d7516170c7802f9fd5")) != null and
    ($census.evidence | index("pr-merge:1:0451a1f5813e51a2d09145d7516170c7802f9fd5")) != null and
    ($census.evidence | index("main-actions:run=33421788389:job=99585671364:success")) != null and
    ($census.evidence | index("main-actions-artifact:9769198151:2612519:sha256:a77d6e089b61fcb6546385af9e91f47011cfe2d070cadec26f3ad66f35e79d35")) != null and
    ($census.evidence | index("release-actions:run=33421919840:job=99586108117:success")) != null and
    ($census.evidence | index("release-actions-artifact:9769259042:2577787:sha256:347c8f66d0f69f13244be95ea62116beabadf597e49480138e0b16bb6b0c3472")) != null and
    ($census.evidence | index("upstream-semantic-authority-census:denominator=12:proof=4/4/4:indicator=4/4/4:cases=CLOSED=3:UNKNOWN=3:REFUTED=3:score=NOT_COMBINED")) != null and
    ($census.evidence | index("upstream-exact-pair:obligations=3:generated_bound=2->3:handwritten_go=1->0")) != null and
    ($census.evidence | index("upstream-runtime:compile=5184:build=751:test=2209:conformance=8306:peak_rss_kib=270708:tests=4/4/0/0/0:replay=9/0")) != null and
    ($census.evidence | index("upstream-inventory:go=817-lines/6-files:gooo=28-lines/4-files:regular_files=29:dirs=12:output_artifacts=58:root_readme_excluded=true")) != null and
    ($census.evidence | index("upstream-authority:repository_write=0:net_changes=0:local_tests=0:infrastructure=0:provider_installs=0:network_mutations=0")) != null and
    ($census.evidence | index("upstream-bootstrap:compiler=HANDWRITTEN_GO:evaluator=HANDWRITTEN_GO:core_semantic_authority_closed=false")) != null and
    ($census.evidence | index("manifest-asset:538335235:413:sha256:9c403c7b607c91f1cddced37611875544f047899610be293c96b6475b269b260")) != null and
    ($census.evidence | index("checksum-asset:538335234:263:sha256:9ae4216b45722c43f62720a3e3d13048905e3291d7ee595d3fe6ab0f78f11411")) != null and
    ($census.evidence | index("source-asset:538335236:14360:sha256:3bd78b1b7cb5330dc901003b2d23abee9b95abfe23d1ad0d754d1bdb63471866")) != null and
    ($census.evidence | index("evidence-asset:538335233:2563982:sha256:e68c93214ef99e65ffd818bf384668c34e8332aa7b4481d6cc70b747afaaf0e3")) != null) and
  ((.cells[] | select(.cell_id == "REFLEXIVE_LEARNING_DRIFT_CYCLE_RELEASE")) as $learning_drift |
    $learning_drift.state == "CLOSED" and
    $learning_drift.release_key == "reflexive_learning_drift_cycle_release" and
    ($learning_drift.evidence | index("release:379940049:immutable=true")) != null and
    ($learning_drift.evidence | index("tag-object:89f6d283791f917c2fe789fa05016a0f33df21d2:target=134d9043e8808147ed2f7252527e809d3eafad44")) != null and
    ($learning_drift.evidence | index("main-actions:run=33420406673:job=99581097777:success")) != null and
    ($learning_drift.evidence | index("main-actions-artifact:9768699219:3624947:sha256:11f3fffb4c6ee93307e46b5c1fdb8013fe5829983e069d823d896dc77e84a6c2")) != null and
    ($learning_drift.evidence | index("upstream-reflexive-learning-drift-cycle:cycles=2:candidates=5:recurrence=1->0:attempts=2:avoided_refuted=1:refuted=1:unknown=2:replay=16/0:rollback=1/0")) != null and
    ($learning_drift.evidence | index("upstream-tests:total=4:executed=2:reused=1:skipped=1:not_observed=0")) != null and
    ($learning_drift.evidence | index("upstream-runtime:build=520/91448:test=0/7116:conformance=4291/14300")) != null and
    ($learning_drift.evidence | index("upstream-inventory:go=0-files/0-lines:gooo=8-files/136-lines:dirs=18:files=56:root_readme_excluded=true")) != null and
    ($learning_drift.evidence | index("upstream-output:artifacts=375:bytes=1327231")) != null and
    ($learning_drift.evidence | index("upstream-authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0:apply=0:commit=0:push=0:pull_request=0:merge=0")) != null and
    ($learning_drift.evidence | index("upstream-state:CLOSED=3:UNKNOWN=4:REFUTED=5:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($learning_drift.evidence | index("upstream-utility:external_utility=UNKNOWN:inference=false")) != null and
    ($learning_drift.evidence | index("upstream-manifest:implementation_pr=7:correction_pr=8:merged_main=134d9043e8808147ed2f7252527e809d3eafad44")) != null and
    ($learning_drift.evidence | index("evidence-asset:538319772:2468418:sha256:1bac0c50f4508922b5351df3a541f4daa115c60867ca106d11d4593e7c58b5ce")) != null and
    ($learning_drift.evidence | index("manifest-asset:538319775:6537:sha256:b3de9c74872b8b8ec4fac51393a4ee54256c1f97ab9f8f47effdc68971013977")) != null and
    ($learning_drift.evidence | index("source-asset:538319768:96363:sha256:fc8f5e551bb335d0a9133623c2fdc4549f634a93645b41b8fbb7c0acc98ab957")) != null and
    ($learning_drift.evidence | index("checksum-asset:538319776:323:sha256:e55c31a6c66eb82cfcf2d8b39182e07fd39f35f45a7bddfd17407025bda59dc0")) != null) and
  ((.cells[] | select(.cell_id == "UNKNOWN_RESOLUTION_LATTICE_RELEASE")) as $resolution_lattice |
    $resolution_lattice.state == "CLOSED" and
    $resolution_lattice.release_key == "unknown_resolution_lattice_release" and
    ($resolution_lattice.evidence | index("release:379967493:immutable=true")) != null and
    ($resolution_lattice.evidence | index("tag-object:2f452efe6b05b50760500da1a4bea7d323e9c11d:target=fac2f5c0688c62fd31912a310e0fae77bc198258")) != null and
    ($resolution_lattice.evidence | index("source-actions:run=33424634161:job=99595118419:success")) != null and
    ($resolution_lattice.evidence | index("source-actions-artifact:9770260397:23723:sha256:f80e798ca1893937ba49b86e40ad1ac7f2035e9d666acacb71c28fa6109bb294")) != null and
    ($resolution_lattice.evidence | index("post-main-actions:run=33425091977:job=99596614819:success")) != null and
    ($resolution_lattice.evidence | index("post-main-actions-artifact:9770452642:23723:sha256:7f3edacdfb5f58a9391ceb10b90de139368a0f537fffa86648eeaf62f9f5dc0e")) != null and
    ($resolution_lattice.evidence | index("release-actions:run=33425271313:job=99597213464:success")) != null and
    ($resolution_lattice.evidence | index("upstream-resolution-lattice:ladder=PROJECT>ARTIFACT>ACTIVITY>PREDICATE>FIELD:denominator=12:proof=4/4/4:indicator=4/4/4:cases=CLOSED=1:UNKNOWN=4:REFUTED=5:unknown_classes=4:receipts=6/6:identity=16/0")) != null and
    ($resolution_lattice.evidence | index("upstream-improvement-pairs:normal=4->2,5->3:decision_unknown=2->2,5->5:dependency_blocked=3->3,5->5:unknown=4->4,5->5")) != null and
    ($resolution_lattice.evidence | index("upstream-runtime:first=5446/1985/67/272748:post_main=5869/2259/80/265604")) != null and
    ($resolution_lattice.evidence | index("upstream-tests:total=10:executed=10:reused=0:skipped=0:not_observed=0")) != null and
    ($resolution_lattice.evidence | index("upstream-inventory:go=5-files/1335-lines:gooo=1-files/27-lines:dirs=14:files=23:root_readme_excluded=true")) != null and
    ($resolution_lattice.evidence | index("upstream-output:artifacts=22:bytes=67397")) != null and
    ($resolution_lattice.evidence | index("upstream-authority:repository_writes=0:direct_main_writes=0:local_test_executions=0:provider_install_attempts=0:network_mutation_attempts=0:infrastructure_mutations=0")) != null and
    ($resolution_lattice.evidence | index("upstream-policy:fixed_point_only=true:top_unknown=FAIL_CLOSED/FEEDBACK_COVERAGE_DECISION_UNKNOWN:contradiction_priority=REFUTED:utility_inference=false")) != null and
    ($resolution_lattice.evidence | index("upstream-manifest:commit=fac2f5c0688c62fd31912a310e0fae77bc198258:go=1.27.0:immutable=true")) != null and
    ($resolution_lattice.evidence | index("asset:538371288:23967:sha256:f16f43175104a42eb20fd8f701fa8296c289ce69929ff1861269cb3b00ebbc75")) != null and
    ($resolution_lattice.evidence | index("asset:538371290:186:sha256:c178b312da828be4589352fbc195853ccaa08e48adacf7f5522c4a06df65f9fd")) != null and
    ($resolution_lattice.evidence | index("asset:538371285:103:sha256:8a9b8575cdd5abae5ebba2d1e33a6e93f6b6bfcd7d3ac6855529c74652454549")) != null) and
  ((.cells[] | select(.cell_id == "SELF_REPAIR_INTEGRATION_RELEASE")) as $self_repair |
    $self_repair.state == "CLOSED" and
    $self_repair.release_key == "self_repair_integration_release" and
    ($self_repair.evidence | index("release:379971030:immutable=true")) != null and
    ($self_repair.evidence | index("tag-object:b8318c1645bc76286eb5c404b771118b6ce1e07b:target=28f3589d69796b4630b2e066c6a5c45ac8468096")) != null and
    ($self_repair.evidence | index("pr-merge:3:c460fd7b568adef24cfa85433b0022b450a51288")) != null and
    ($self_repair.evidence | index("pr-merge:4:28f3589d69796b4630b2e066c6a5c45ac8468096")) != null and
    ($self_repair.evidence | index("historical-direct-main:5dca56d238751739beba3fafe9a9018c0bb18ce4:parent=c460fd7b568adef24cfa85433b0022b450a51288:changed=.github/workflows/release.yml")) != null and
    ($self_repair.evidence | index("post-main-actions:run=33425759488:job=99598796427:success")) != null and
    ($self_repair.evidence | index("post-main-actions-artifact:9770678796:14701:sha256:870a731cf484535e2b1218e1d7eee37a0ccdd9c7ad194ff19030ab31e42c7514")) != null and
    ($self_repair.evidence | index("release-actions:run=33425908089:job=99599283424:success")) != null and
    ($self_repair.evidence | index("upstream-self-repair:activities=12:claims=3/3/3:proof=4/4/4:indicator=4/4/4:core_semantic_authority=CLOSED:development_process_authority=REFUTED:external_utility=UNKNOWN:utility_reason=RESOURCE_AXES_CROSS")) != null and
    ($self_repair.evidence | index("upstream-cycles:attempts=2:candidates=5:recurrence=1->0:avoided=1:unknown=2:replay=2/0")) != null and
    ($self_repair.evidence | index("upstream-tests:total=3:executed=3:reused=0:skipped=0:not_observed=0")) != null and
    ($self_repair.evidence | index("upstream-runtime:build=250:test=240:conformance=13757:peak_rss_kib=90856")) != null and
    ($self_repair.evidence | index("upstream-inventory:go=8-files/1547-lines:gooo=2-files/16-lines:dirs=15:files=25:root_readme_excluded=true")) != null and
    ($self_repair.evidence | index("upstream-output:artifacts=12:bytes=38440")) != null and
    ($self_repair.evidence | index("upstream-authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($self_repair.evidence | index("upstream-development-authority:historical_direct_main_push=1:offending=5dca56d238751739beba3fafe9a9018c0bb18ce4:historical_violation_count=1:current_guard=CLOSED:pr_association=1:post_guard_direct_writes=0")) != null and
    ($self_repair.evidence | index("asset:538378587:30698:sha256:7d505a14cfd11c0d6a57cb14ec8de2f51c946285b18d1af8bce1d6ff476b4582")) != null and
    ($self_repair.evidence | index("asset:538378586:134:sha256:3655571de02ba889fe83676d700e43befbf6130730079a26bed6aa6b65adcdd3")) != null and
    ($self_repair.evidence | index("asset:538378585:104:sha256:fd70f404c9238fb6fd2ace7cf36b19ed0ce7d89d15fc794ce96ee4d5333f5d1f")) != null) and
  ((.cells[] | select(.cell_id == "OPENTOFU_DURABLE_SEMANTIC_ENVELOPE_RELEASE")) as $durable_envelope |
    $durable_envelope.state == "CLOSED" and
    $durable_envelope.release_key == "opentofu_durable_semantic_envelope_release" and
    ($durable_envelope.evidence | index("release:380009987:immutable=true")) != null and
    ($durable_envelope.evidence | index("tag-object:8f913ac3bcef39a5105280a6a05114b7abc3ac87:target=b482afd68a864400a209cb4f439e727cfdfe2eda")) != null and
    ($durable_envelope.evidence | index("pr-merge:10:b482afd68a864400a209cb4f439e727cfdfe2eda")) != null and
    ($durable_envelope.evidence | index("main-actions:run=33432375475:job=99620555197:success")) != null and
    ($durable_envelope.evidence | index("source-actions-artifact:9773097414:99611:sha256:f04619dbd77314bdf84ba2d5c1b9edd4b9a09b533a8a26c2185ec3b786804157")) != null and
    ($durable_envelope.evidence | index("release-actions:run=33432449551:job=99620801430:success")) != null and
    ($durable_envelope.evidence | index("upstream-opentofu-envelope:denominator=12:paths=5:edges=14:proof=4/4/4:indicator=4/4/4:cases=3/3/3:replay=2/0")) != null and
    ($durable_envelope.evidence | index("upstream-tests:total=9:executed=9:reused=0:skipped=0:not_observed=0")) != null and
    ($durable_envelope.evidence | index("upstream-runtime:go=1.27.0:opentofu=1.12.6:build=214:test=45:conformance=324:peak_rss_kib=76084")) != null and
    ($durable_envelope.evidence | index("upstream-inventory:files=15:lines=2401:dirs=7:go=0/0:gooo=1/39:root_readme_excluded=true")) != null and
    ($durable_envelope.evidence | index("upstream-output:artifacts=3:bytes=8118")) != null and
    ($durable_envelope.evidence | index("upstream-authority:repository_writes=0:remote_mutations=0:direct_main_writes=0:tag_mutations=0:local_test_executions=0")) != null and
    ($durable_envelope.evidence | index("upstream-semantic-graph:scope=GOOO_SEMANTIC_GRAPH_ONLY:state=CLOSED:utility=UNKNOWN:global_core=NOT_MADE")) != null and
    ($durable_envelope.evidence | index("upstream-provenance:v0.1.3=release:379957493:immutable=true:assets=0:v0.1.4-v0.1.7=failed:no-release:v0.1.8=draft:release=380007644:immutable=false:assets=0")) != null and
    ($durable_envelope.evidence | index("asset:538450808:13344:sha256:79b549e7471f983e1f3a9f8f19ff73b5c759bac532ad86d8c3d2738885223f6d")) != null and
    ($durable_envelope.evidence | index("asset:538450812:55115:sha256:a1352aa6cdeeefc0112884673ce672e920033b6d13d7d8e69ffbf270632df2e1")) != null and
    ($durable_envelope.evidence | index("asset:538450816:263:sha256:efb3cebd7bcdf2dcc1a1a2279817be1286def7e7387b33f2afc505b3eb7129c6")) != null and
    ($durable_envelope.evidence | index("asset:538450823:30885:sha256:e33609eee44163d3201d125900d57ea12f183ebb561522e86e930d7f3805338f")) != null and
    ($durable_envelope.evidence | index("ledger-global-core=REFUTED:ledger-development-process=REFUTED")) != null) and
  ((.cells[] | select(.cell_id == "LANGUAGE_DELTA_FORGE_DURABLE_RELEASE")) as $language_delta |
    $language_delta.state == "CLOSED" and
    $language_delta.release_key == "language_delta_forge_durable_release" and
    ($language_delta.evidence | index("release:380033725:immutable=true")) != null and
    ($language_delta.evidence | index("tag-object:5d68c5f2f699f9d73bcf2e87121204512dfd64fc:target=30ad7a736d5d354a9e0cd998a8a1bd4dd5e11b45")) != null and
    ($language_delta.evidence | index("main-actions:run=33436391757:job=99633759904:success")) != null and
    ($language_delta.evidence | index("main-actions-artifact:9774550869:27490:sha256:a2f9a55ebb3870f2093e0f3b11439a523c899fac968efb0c449b6c5c6dc486cd")) != null and
    ($language_delta.evidence | index("release-actions:run=33436456556:job=99633967202:success")) != null and
    ($language_delta.evidence | index("release-actions-artifact:9774576485:58715:sha256:bcf1519c02234b44b69490378723c82fa9e9f83d64b65c2c24138d9ce341013b")) != null and
    ($language_delta.evidence | index("upstream-language-delta-forge:denominator=18:cases=CLOSED=3:UNKNOWN=3:REFUTED=3:proof=6/6/6:indicator=6/6/6")) != null and
    ($language_delta.evidence | index("upstream-delta:candidate_bundles=10:generated_json=11:representative=2/1/1:rollback=2/1/1")) != null and
    ($language_delta.evidence | index("upstream-runtime:go=1.27.0:compile=173:build=199:test=163:conformance=8:peak_rss_kib=95004:tests=3/3/0/0/0:outputs=25")) != null and
    ($language_delta.evidence | index("upstream-inventory:files=27:directories=13:go=9/1884:gooo=1/51:physical_lines=2610:root_readme_excluded=true")) != null and
    ($language_delta.evidence | index("upstream-authority:repository_writes=0:protected_core_adoption=0:automatic_merge=false:separate_authority_step=true:utility=NOT_CLAIMED:global_core=NOT_MADE")) != null and
    ($language_delta.evidence | index("asset:538495830:240:sha256:cd99462d4d6635ba03024ef3e03ea600dbe65f22ad416f379583f86fa6af7876")) != null and
    ($language_delta.evidence | index("asset:538495829:7542:sha256:e14fc1d338ea85a51f1d6f43997e0e1c74d9be2ddc9eaa97d22d98ebfb5ff2d4")) != null and
    ($language_delta.evidence | index("asset:538495828:26671:sha256:77424f9465322c37ab87efcb920f936e6ddf3e02c2b7e59657fae82ff05283ba")) != null and
    ($language_delta.evidence | index("asset:538495832:736:sha256:0c467b96e4b91915139aa0d5990b49c8ca5a038a2ac965d43a4a5656e511064a")) != null and
    ($language_delta.evidence | index("ledger-global-core=REFUTED:ledger-development-process=REFUTED")) != null) and
  (.cells|length) == 50 and
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
  ((.cells[] | select(.cell_id == "REFLEXIVE_MODERN_CYCLE_RELEASE")) as $modern_cycle |
    $modern_cycle.state == "CLOSED" and $modern_cycle.release_key == "reflexive_modern_cycle_release" and
    ($modern_cycle.evidence | index("release:379879740:immutable=true")) != null and
    ($modern_cycle.evidence | index("tag-object:e54e08feacb3ea4da67b5aa5e404a4ce0b605895:target=ed8ff02c7d8f56d8d9474b68036ea80cdc105261")) != null and
    ($modern_cycle.evidence | index("source-actions:run=33410813438:job=99549616696:success")) != null and
    ($modern_cycle.evidence | index("source-actions-artifact:9765064827:2122874:sha256:9a800498dca302d6cf9b2c9574d8adc69075f88c6c112db36d25aab34caa04c5")) != null and
    ($modern_cycle.evidence | index("upstream-metrics:oracle_failures=1->0:tests=4/2/1/1/0:replay=19/0:rollback=1/0:build=7436/270260:conformance=8844/14524:gooo=93-lines/44-files/16-dirs:authority=0/0/0/0/0/0/0/0")) != null and
    ($modern_cycle.evidence | index("asset:538205028:1391362:sha256:76bb2dab68bdaf8926a8a7489aa2cc60545d7165ae4a1c5a86ce407dacee0739")) != null and
    ($modern_cycle.evidence | index("asset:538205030:3490:sha256:853b02ea5be25873db7e77f65ea0341715a360599064d4fe5abffd0364d07f5d")) != null and
    ($modern_cycle.evidence | index("asset:538205039:81187:sha256:6e4757b752756502c99e358cdfc9071fe4950b83f49e9e02651a0b3afee16797")) != null and
    ($modern_cycle.evidence | index("asset:538205026:431:sha256:85ed7f91b12e4e33d9cd5868ce6459de7cfbb717fc9d7aa823c8d721d4fe7d2c")) != null and
    ($modern_cycle.evidence | index("preserved-prior-release:v0.3.0:release=379458203:immutable=true:target=75d655f04a0833b8cf40afa76f4a9703a3ba04fa:tag_kind=lightweight")) != null) and
  ((.cells[] | select(.cell_id == "EXECUTABLE_EVOLUTION_TRIAL_COUNTEREXAMPLE_DURABLE_RELEASE")) as $trial |
    $trial.state == "CLOSED" and
    $trial.release_key == "executable_evolution_trial_counterexample_durable_release" and
    ($trial.evidence | index("release:380086557:immutable=true")) != null and
    ($trial.evidence | index("tag-object:c3a87bd320a24e6c4961afc532fd4df6b5d165c3:target=d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982")) != null and
    ($trial.evidence | index("main-actions:run=33445305000:job=99662940416:head=d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982:success")) != null and
    ($trial.evidence | index("main-actions-artifact:9777794326:130085:sha256:07c81d12ecf003907678cbbea15d104effd44bdb658893ee426820fdb5b9a13a")) != null and
    ($trial.evidence | index("release-actions:run=33445379243:job=99663170908:head=d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982:success")) != null and
    ($trial.evidence | index("release-audit-artifact:9777817257:33589:sha256:1cf113aaf5a6e629ce2da1f358a5502dba3600ec9f8155b785d72acfd5f20001")) != null and
    ($trial.evidence | index("upstream-tools:delta_forge=v0.1.2:reflexive_compiler=v0.1.1:causal_runner=v0.1.1:all_executed=true")) != null and
    ($trial.evidence | index("candidate-evolution:decision=CLOSED:add=2:retire=1:split=1:rollback=true:graph_before=sha256:ab965892722b03bf9d4da78a6bf91f018d9609018107a90db6435fc34832549b:graph_after=sha256:9369abeeccfadba001ed001306281cb6b0e413fe094de6353d8208bcf76c0485:delta=sha256:826a90daaf19fb0f0b0b51af89c53150219ca624331905a4c913e329b085a6e6:candidate=sha256:4edd900ea94b1cb461b27d61fb06e72993424eb8ad424b82ac19b78b59318bdb")) != null and
    ($trial.evidence | index("baseline:decision=CLOSED:distribution=CLOSED1/UNKNOWN1/REFUTED1:failed=0:replay=true:phase=sha256:8a557cb3b7445f5186f0619b14c82dd215f1950a2d298bafe2cbdc7e54768220:receipt=sha256:ef560e68b9d88054c6e22e385955a698dd4806f014d7df7142987f5d0973c44d")) != null and
    ($trial.evidence | index("candidate:decision=REFUTED:distribution=CLOSED0/UNKNOWN0/REFUTED3:failed=3:replay=false:phase=sha256:0be26e6d653f0200c0300334fdf252b0d6ea0fdec81acdf7ac34801a03cd5ff1:reason=phase graph must declare exactly three executable activities:semantic_ir=NOT_OBSERVED:backend=NOT_OBSERVED")) != null and
    ($trial.evidence | index("causal-trial:decision=REFUTED:full_oracle=CLOSED:total=2:selected=1:executed=1:reused=1:oracle=2:fail=1:unknown=0:avoided=1:full_oracle_digest=sha256:65bf73d71b57aa3a07fe68a22cddf904e0629c7d2b145f1d9a7e55519025cb6c:candidate_result=sha256:f8a7d659e13ddb36889d7b2c8ad7d64b5c249399f80d62e23914523ed992758e")) != null and
    ($trial.evidence | index("acceptance:candidate_compiled=false:causal_selection_and_full_oracle_closed=false:corpus_preserved=false:exact_semantic_resolution_pair=true:replay_digests_match=false:rollback_possible=true")) != null and
    ($trial.evidence | index("unresolved:candidate_semantic_ir=NOT_OBSERVED:candidate_backend=NOT_OBSERVED:whole_language_improvement=UNKNOWN:external_utility=UNKNOWN/NOT_MADE")) != null and
    ($trial.evidence | index("upstream-metrics:compile=2673:build=609:test=58:conformance=11384:integration=11384:peak_rss_kib=91512:outputs=110/377573:tests=3/3/0/0/1")) != null and
    ($trial.evidence | index("upstream-inventory:regular_files=22:directories=11:go_files=9:gooo_files=1:physical_lines=2164:per_language_physical_lines=NOT_OBSERVED:root_readme_excluded=true")) != null and
    ($trial.evidence | index("upstream-authority:repository_writes=0:upstream_writes=0:local_test_executions=0:verification_authority=GITHUB_ACTIONS")) != null and
    ($trial.evidence | index("process-evidence:exact=true:bootstrap_direct_main=1:post_bootstrap_direct_main=0:bootstrap_root=cd64acc2077474e459dcbcd457aff0d320524c14:main_head=d917eec6344f2eaa9a6fb0069f7fe0aaafeb6982")) != null and
    ($trial.evidence | index("upstream-prs:all_merged=true")) != null and
    ($trial.evidence | index("prior-ledger-consumer-observation:local_validation_executions=1:artifact_schema_assertion_replays=1:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0:process=REFUTED")) != null and
    ($trial.evidence | index("asset:538589631:2077:sha256:6d72387f9ee60cc994166595d1cd1c2abc3d72863f05c857bcb1470352b73b5e")) != null and
    ($trial.evidence | index("asset:538589629:28486:sha256:b22d716111c7bcbe5dab18a1bb8caee03388579ac394f93a15798ebca5c43bfc")) != null and
    ($trial.evidence | index("asset:538589628:764:sha256:16d908073ae49566fd7186a8d042758a79d30274e94fe5c5ca7ca20773fc9839")) != null and
    ($trial.evidence | index("asset:538589633:469:sha256:e1431e654fe65bdb9a325b1da797b0da613e8712ad32c55854d78610f14380b4")) != null and
    ($trial.evidence | index("asset:538589630:3888:sha256:b7cff57d0a300af2876cc6da1a2ccf6aad51f1a153ac794761eb76763c1e8330")) != null and
    ($trial.evidence | index("asset:538589627:319:sha256:b5475730a3726c2e2ff89457e8e976d8f5aada46bfcee6218e99cf6689b51b07")) != null and
    ($trial.evidence | index("ledger-global-core=REFUTED:ledger-development-process=REFUTED")) != null) and
  ((.cells[] | select(.cell_id == "REFLEXIVE_COMPILER_GRAPH_TOPOLOGY_SELF_IMPROVEMENT_DURABLE_RELEASE")) as $topology |
    $topology.state == "CLOSED" and
    $topology.release_key == "reflexive_compiler_graph_topology_self_improvement_durable_release" and
    ($topology.evidence | index("release:380102097:immutable=true")) != null and
    ($topology.evidence | index("tag-object:5852cc52f4ecec7fc835fdb6ed7adc1108459d6a:target=7bdba0c353a73a40111747dbf55512939f6841a0")) != null and
    ($topology.evidence | index("pr-merge:8:head=69727313308f5143319b4bb2b95e67b6bdd2735d:merge=7bdba0c353a73a40111747dbf55512939f6841a0:merged=true")) != null and
    ($topology.evidence | index("pr-actions:run=33447973294:job=99671224008:head=69727313308f5143319b4bb2b95e67b6bdd2735d:success")) != null and
    ($topology.evidence | index("pr-actions-artifact:9778718602:24954557:sha256:596a6042d1682097df78e237c7b60541fc05dcc359c05dff749a4bc77debbb75")) != null and
    ($topology.evidence | index("main-actions:run=33448048024:job=99671456387:head=7bdba0c353a73a40111747dbf55512939f6841a0:success")) != null and
    ($topology.evidence | index("main-actions-artifact:9778748463:24954565:sha256:be15de0147fb86e12e0ccf1432dfab7628e64fe6ac2201f5739fc7e017da98f7")) != null and
    ($topology.evidence | index("release-actions:run=33448121915:job=99671691260:head=7bdba0c353a73a40111747dbf55512939f6841a0:success")) != null and
    ($topology.evidence | index("upstream-release-assets:538621864:2628138:sha256:039d8db0457cb8ff9d439ac52234c23de6c19b38212d8c32242155d276bd483b,538621862:31726:sha256:3ced5c624b50afddf6906c093b80a3a83eebfc52ed2c59051ec427b28931eeba,538621865:795:sha256:3e9a6b8d409725a1b8e99a387ebd33045e64677364df783c083b32472c3ba171,538621866:10167:sha256:6d80a3941a55d4199f6fc3fae4ed2c2429f45d1fd24fb2e3aafecc1125ca2fc7,538621870:506:sha256:e7554da06237c2b52eaa15f4a5fa4e16b1edbf6240eacffdaea6000fc73d7464,538621863:315:sha256:cd55a20257e61a0603bbdc32c47667bf107d3d4dffe31518477ebb9c67a64214")) != null and
    ($topology.evidence | index("compiler-v0.1.0-historical:release=380032434:immutable=false:tag-object=f89b47fedab983b9c3cef0b9be03da65eadff3de:target=57f5ef6ce407f51cd36da163b2b267e876c31e33:state=NON_DURABLE")) != null and
    ($topology.evidence | index("upstream-protocol:schema=gooo/reflexive-compiler-graph-topology/v1:scope=ONE_COMPILER_PHASE:old_roles=3:old_edges=2:old_stages=1:new_roles=4:new_typed_edges=3:new_stages=2:semantics=ROLE_EDGE_STAGE_TOPOLOGY_NOT_COUNT")) != null and
    ($topology.evidence | index("exact-pairs:supported_topology_cardinality=1->2:accepted_trial_candidate_cases=0->3:localization_stages=1->2")) != null and
    ($topology.evidence | index("applied-bundle:sha256:49244a778d6e80c67bb5fb0b99342873ba987916b14febb500524a26a5af3490:candidate=sha256:4edd900ea94b1cb461b27d61fb06e72993424eb8ad424b82ac19b78b59318bdb:delta=sha256:826a90daaf19fb0f0b0b51af89c53150219ca624331905a4c913e329b085a6e6:applied-root-phase=sha256:30b38ad566a350a3d0107f48f79ff43db467a94ce4aaf464ad1970e872b862b3:root_match=true")) != null and
    ($topology.evidence | index("matched-source-tree:sha256:09fef83853c981cb5d77f31a31e8d424523fec4eb730423b8b27167c1c5db477:contract=sha256:a15ac998e85d7fe7a62d112260024da08e433b603af03360f348a194c22d03d2:toolchain=sha256:76227025cc0bc2be7067aa45d11e09cacfd49c58f498f4c2e4f6a9872a607bf9")) != null and
    ($topology.evidence | index("closure:state=CLOSED:stage=IMPROVEMENT:step=RESOLVE_TRIAL_COUNTEREXAMPLE:reason=GRAPH_SEMANTICS_ACCEPT_SPLIT_CANDIDATE:trial_refutation=REFUTED:protected_core_adoption=0")) != null and
    ($topology.evidence | index("direct-corpus:before=CLOSED1/UNKNOWN1/REFUTED1:after=CLOSED1/UNKNOWN1/REFUTED1:after_cases=3:all_independently_verified=true")) != null and
    ($topology.evidence | index("metrics:go_files=8:go_lines=1775:gooo_files=4:gooo_lines=48:regular_files=29:directories=14:root_readme_excluded=true:outputs=21/32289:peak_rss_bytes=7008256:peak_rss_kib=7072:compile=59:build=5248:test=2096:conformance=2538:integration=8228:tests=3/3/0/0/1")) != null and
    ($topology.evidence | index("authority:repository_writes=0:upstream_writes=0:local_test_executions=0:verification_authority=GITHUB_ACTIONS")) != null and
    ($topology.evidence | index("state:global_self_hosting=UNKNOWN:external_utility=UNKNOWN:scope=ONE_COMPILER_PHASE")) != null and
    ($topology.evidence | index("prior-ledger-consumer-observation:local_validation_executions=1:process=REFUTED:local_schema_replays=0:local_conformance_replays=0")) != null and
    ($topology.evidence | index("ledger-global-core=REFUTED:ledger-development-process=REFUTED")) != null) and
  ((.cells[] | select(.cell_id == "EXECUTABLE_EVOLUTION_TRIAL_CLOSED_LOOP_DURABLE_RELEASE")) as $closed_loop |
    $closed_loop.state == "CLOSED" and
    $closed_loop.release_key == "executable_evolution_trial_closed_loop_durable_release" and
    ($closed_loop.evidence | index("release:380109530:immutable=true")) != null and
    ($closed_loop.evidence | index("tag-object:b05e646ac009208e2451473b019b5768a4b20bb8:target=aa72f7019d1224344802478490d94046d27af58f")) != null and
    ($closed_loop.evidence | index("pr-merge:5:head=7c008ae80333771ca2158dec8a6ecb2a8bd9de58:merge=aa72f7019d1224344802478490d94046d27af58f:merged=true")) != null and
    ($closed_loop.evidence | index("pr-actions:run=33449309946:job=99675370500:head=7c008ae80333771ca2158dec8a6ecb2a8bd9de58:success")) != null and
    ($closed_loop.evidence | index("pr-actions-artifact:9779165344:151620:sha256:c8d92b7626520f4a3d41a55695969d3fd211ff40a2f8db6ba7a03d5ce6e51608")) != null and
    ($closed_loop.evidence | index("main-actions:run=33449393842:job=99675631928:head=aa72f7019d1224344802478490d94046d27af58f:success")) != null and
    ($closed_loop.evidence | index("main-actions-artifact:9779197222:151681:sha256:6cbcef44dffa70e1972e3f1c195272a9d45c644e7a1eb9fc61148d591a2ab33e")) != null and
    ($closed_loop.evidence | index("release-actions:run=33449476756:job=99675899128:head=aa72f7019d1224344802478490d94046d27af58f:success")) != null and
    ($closed_loop.evidence | index("release-audit-artifact:9779223480:35765:sha256:7f8bcab82d8f0c73f61a0ecee169872747118c7989c1ec9648fe4ff206aa7ba6")) != null and
    ($closed_loop.evidence | index("upstream-release-assets:538638669:2345:sha256:7cf59e690e9458eefffcb9cfd536119f6669146bf00aa96a365ee3bc1af688ac,538638668:30429:sha256:984ef2a192221adc8ebeaeb8489e6a1bf450238d16036c045c4382fe19429218,538638665:764:sha256:48f4dd0c1391f9ec91654e8d2b25a67942e8e6febd3461c61d0651a35896153f,538638674:469:sha256:bc867402084059cda6fd1f9590f94b45f807725001c2d9e927e13808be8e9aca,538638666:4134:sha256:28f5457240fb35d3c24c65373f824cb5df918f003245b60cb5389ca3618e4120,538638667:319:sha256:c11572b368dcc984ea4c2666ec4aa46dc43c3434cd913cac044daf6142bb9f74")) != null and
    ($closed_loop.evidence | index("historical-v0.1.0:release=380032434:immutable=false:tag-object=f89b47fedab983b9c3cef0b9be03da65eadff3de:target=57f5ef6ce407f51cd36da163b2b267e876c31e33:state=REFUTED")) != null and
    ($closed_loop.evidence | index("closed-loop:experiment=second-release-to-release-reflexive-normalization-split:decision=CLOSED:candidate_compiled=true:baseline=CLOSED1/UNKNOWN1/REFUTED1:candidate=CLOSED1/UNKNOWN1/REFUTED1:replay=true:rollback=true:causal=2/1/1/1/2/0/0")) != null and
    ($closed_loop.evidence | index("reuse:compiler=v0.2.0:tag-object=5852cc52f4ecec7fc835fdb6ed7adc1108459d6a:target=7bdba0c353a73a40111747dbf55512939f6841a0")) != null and
    ($closed_loop.evidence | index("reuse:bundle=sha256:49244a778d6e80c67bb5fb0b99342873ba987916b14febb500524a26a5af3490:candidate=sha256:4edd900ea94b1cb461b27d61fb06e72993424eb8ad424b82ac19b78b59318bdb:delta=sha256:826a90daaf19fb0f0b0b51af89c53150219ca624331905a4c913e329b085a6e6:phase=sha256:30b38ad566a350a3d0107f48f79ff43db467a94ce4aaf464ad1970e872b862b3")) != null and
    ($closed_loop.evidence | index("closure:state=CLOSED:stage=IMPROVEMENT:step=RESOLVE_TRIAL_COUNTEREXAMPLE:reason=GRAPH_SEMANTICS_ACCEPT_SPLIT_CANDIDATE:trial_refutation=REFUTED")) != null and
    ($closed_loop.evidence | index("metrics:go_files=9:gooo_files=2:physical_lines=2222:regular_files=23:directories=12:root_readme_excluded=true:outputs=143/411050:peak_rss_kib=91624:compile=2516:build=584:test=62:conformance=10438:integration=10438:tests=3/3/0/0/1")) != null and
    ($closed_loop.evidence | index("authority:repository_writes=0:upstream_writes=0:local_test_executions=0:verification_authority=GITHUB_ACTIONS")) != null and
    ($closed_loop.evidence | index("process:bootstrap_direct_main=1:post_bootstrap_direct_main=0:exact=true:repository_writes=0:upstream_writes=0:local_test_executions=0")) != null and
    ($closed_loop.evidence | index("prior-ledger-consumer-observation:local_validation_executions=1:process=REFUTED:local_schema_replays=0:local_conformance_replays=0")) != null and
    ($closed_loop.evidence | index("ledger-global-core=REFUTED:ledger-development-process=REFUTED")) != null) and
  ((.cells[] | select(.cell_id == "STRUCTURAL_LEDGER_APPEND_PLANNER_DURABLE_RELEASE")) as $planner |
    $planner.state == "CLOSED" and
    $planner.release_key == "structural_ledger_append_planner_durable_release" and
    ($planner.evidence | index("planner_used=true:version=v0.2.0:tag=v0.2.0:release=380152259:tag_object=aaf26d3047e91deaf757dbc1976f1ada573c450b:target=893042983ac5666abaefeb035e8efaf6d9f6cd62")) != null and
    ($planner.evidence | index("planner-assets:538748262:6300811:sha256:25274148049853e3147618e6278570259cf3238fb578b8f808231e47c2488da8,538748260:402726:sha256:f01a5ad3350a507aca5f91142e8cd09cbaf7ab923507a85f8209084d873663f7,538748261:242:sha256:58eaa0009d817797ebc8d05d6d2d304ddd8b1ed1c455e6d70c620ca21cd568e2")) != null and
    ($planner.evidence | index("structural-append:cell=STRUCTURAL_LEDGER_APPEND_PLANNER_DURABLE_RELEASE:activity=AdoptStructuralLedgerAppendPlannerDurableRelease:lock=structural_ledger_append_planner_durable_release")) != null and
    ($planner.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($planner.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($planner.evidence | index("matched-immutable-target-bindings:v0.1->v0.2:1->2:exact=true")) != null and
    ($planner.evidence | index("wrong-digest-case:state=REFUTED:reason=SOURCE_TREE_DIGEST_MISMATCH:preserved=true")) != null and
    ($planner.evidence | index("missing-binding-case:state=UNKNOWN:unknown_fields=stage/step/reason/unknown_class/next_operation/blocked_by:preserved=true")) != null and
    ($planner.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null and
    ($planner.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null) and
  ((.cells[] | select(.cell_id == "EXPLANATION_CARRYING_COMPILER_DURABLE_RELEASE")) as $compiler |
    $compiler.state == "CLOSED" and
    $compiler.release_key == "explanation_carrying_compiler_durable_release" and
    ($compiler.evidence | index("upstream-release:repo=kimjooyoon/gooo-reflexive-compiler-slice:tag=v0.3.0:release=380150043:tag_object=d7e2bd301f5d1634e92b0de90d54798a35db424a:target=0cf44db8b0d6cd96d190e9f902312d0be9394029:immutable=true")) != null and
    ($compiler.evidence | index("upstream-assets:538741020:2647664:sha256:e03b605c14f5d4d0faf262e57556506f8cf7765756aee49a4ceb99fd700ae862,538741018:38820:sha256:62c45b663084690ff0ad964991d9d7fda1c30ee361876f31fc4f10ef34b68dbc,538741021:795:sha256:4d3bbafb7e31f1fabf83d39ff4f7ea918c658fed1ded18d9b9d177e7d9e95231,538741019:11497:sha256:6a20f41e9f5700f7e400597833e72b055d1d495aeada5f0c57ea4fae5842d514,538741023:506:sha256:560883657ad1bda5053d903beb113615f90bd8a2b4ac59c269abfce8c786d3c7,538741017:315:sha256:32519d4c2b0372e3b5abe6a5a188b04d7f0be3f7d6cd037e53a3ab73b6223195")) != null and
    ($compiler.evidence | index("terminal-corpus:executions=18/18:cases=9:closed=2:unknown=5:refuted=2:unknown_fields=stage/step/reason/unknown_class/next_operation/blocked_by:frontier_digest=true:counterexample_digest=true")) != null and
    ($compiler.evidence | index("terminal-record:winning-state=REFUTED>UNKNOWN>CLOSED:minimal_frontier=true:counterexample_digest=true:unknown_six_fields=true")) != null and
    ($compiler.evidence | index("resolution-pairs:valid-topologies=1->2:accepted-trial-candidates=0->3:localization-stages=1->2:source-contract-toolchain-digests=equal")) != null and
    ($compiler.evidence | index("scope:ONE_COMPILER_PHASE_ONLY:whole-language-improvement=UNKNOWN:external-utility=UNKNOWN")) != null and
    ($compiler.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($compiler.evidence | index("projection-before-digests:report=sha256:94999f6037cfeb8875ed1bc4323a146e4a7b3bcac9208bfcd209020c1f5ee4df:history=sha256:ea4a0e784a21ffd6aeede799918e8ee058e13117fcc91768627ce115ea18ef4a")) != null and
    ($compiler.evidence | index("projection-source-semantic-digests:report=sha256:217d611a973b5edd64b571269e396cb82570a0e84203f7a48286c6ef9ec5ad90:history=sha256:217d611a973b5edd64b571269e396cb82570a0e84203f7a48286c6ef9ec5ad90")) != null and
    ($compiler.evidence | index("projection-after-invariants:report=deterministic-regenerate-from-post-append-semantic-source:history=deterministic-regenerate-from-post-append-semantic-source")) != null and
    ($compiler.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($compiler.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($compiler.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($compiler.evidence | index("input-repository-writes:0")) != null and
    ($compiler.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null) and
  ((.cells[] | select(.cell_id == "TWO_GENERATION_BOOTSTRAP_DURABLE_RELEASE")) as $bootstrap |
    $bootstrap.state == "CLOSED" and
    $bootstrap.release_key == "two_generation_bootstrap_durable_release" and
    ($bootstrap.evidence | index("upstream-release:repo=kimjooyoon/gooo-two-generation-bootstrap:tag=v0.1.1:release=380148091:tag_object=8b89c283ece9ac7321858308366395946265400f:target=6d2bc764f144900862ba5e127cfa19d4cec248b9:immutable=true")) != null and
    ($bootstrap.evidence | index("upstream-assets:538734713:5823:sha256:66fed9217a3a632e412a00feae80b87ac66fbf9fd63d4ee6e147b8d6a059ae9c,538734714:117:sha256:e28154200027dd298aa56dc5cc8c045f177c259a105166cfa8d8dce46e39ebc3")) != null and
    ($bootstrap.evidence | index("two-generation-digests:stage1_ir=sha256:cf0d124e7e37ec79edf657b0372f8c72f477a646762c98a22f1dc5090dade34f:stage2_ir=sha256:cf0d124e7e37ec79edf657b0372f8c72f477a646762c98a22f1dc5090dade34f:stage1_generated=sha256:8c637d379b21cfae4e549ad1c8087de43427c56349982643a73587431cd7ea6b:stage2_generated=sha256:8c637d379b21cfae4e549ad1c8087de43427c56349982643a73587431cd7ea6b")) != null and
    ($bootstrap.evidence | index("terminal-corpus:cases=6:closed=2:unknown=2:refuted=2:unknown_fields=stage/step/reason/unknown_class/next_operation/blocked_by:frontier_digest=true:counterexample_digest=true")) != null and
    ($bootstrap.evidence | index("terminal-record:winning-state=REFUTED>UNKNOWN>CLOSED:minimal_frontier=true:counterexample_digest=true:unknown_six_fields=true")) != null and
    ($bootstrap.evidence | index("fixed-point:status=CLOSED:semantic_ir_equal=true:generated_artifact_equal=true")) != null and
    ($bootstrap.evidence | index("bootstrap-conformance:status=PASS:canonical_cases=3")) != null and
    ($bootstrap.evidence | index("scope:TWO_GENERATION_BOOTSTRAP_ONLY:whole-language-improvement=UNKNOWN:external-utility=UNKNOWN")) != null and
    ($bootstrap.evidence | index("structural-append:cell=TWO_GENERATION_BOOTSTRAP_DURABLE_RELEASE:activity=AdoptTwoGenerationBootstrapDurableRelease:lock=two_generation_bootstrap_durable_release")) != null and
    ($bootstrap.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($bootstrap.evidence | index("projection-before-digests:report=sha256:a43fcebbe71c675e66c1f93144531d0b76943bd204260867996794d430fb74ff:history=sha256:ecea52f56a67637f7c25151708cdd6f7829ecca31b60360f5edb069056621794")) != null and
    ($bootstrap.evidence | index("projection-source-semantic-digests:report=sha256:f02aada16a072abacabf3bf7657c803e1758fe43ff4295b586062bea474aeb8c:history=sha256:f02aada16a072abacabf3bf7657c803e1758fe43ff4295b586062bea474aeb8c")) != null and
    ($bootstrap.evidence | index("projection-after-invariants:report=deterministic-regenerate-from-post-append-semantic-source:history=deterministic-regenerate-from-post-append-semantic-source")) != null and
    ($bootstrap.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($bootstrap.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($bootstrap.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($bootstrap.evidence | index("input-repository-writes:0")) != null and
    ($bootstrap.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null) and
  ((.cells[] | select(.cell_id == "HYGIENIC_ORIGIN_RESOLVER_DURABLE_RELEASE")) as $origin |
    $origin.state == "CLOSED" and
    $origin.release_key == "hygienic_origin_resolver_durable_release" and
    ($origin.evidence | index("upstream-release:repo=kimjooyoon/gooo-hygienic-origin-resolver:tag=v0.1.1:release=380148937:tag_object=b7ab8f0e21104d8dcd37c0557f264d8f763eeffd:target=17933b4e7a724a622652c73de04f7973c524bec9:immutable=true")) != null and
    ($origin.evidence | index("upstream-assets:538737532:3903:sha256:989a416a62e49436c9134b15a03d20a97891a976f92063ca9397a9621a94cb91,538737530:24885:sha256:83b3b2b13c5dabe41b4730eeb4ef9371d1f0d04e20c86e52c7da099377e7ceac,538737529:1233:sha256:0529d8f65b0290f94a850ee9cf68de95fc4e62db5693a8f61c604ac24022af88,538737531:229:sha256:90e09809479162c1f3b9b287b04e6a4fe3d0bb44f9389f7ca1d35e7f0b73086e")) != null and
    ($origin.evidence | index("child-corpus:cases=5:normal_nested_expansion=CLOSED:intended_capture=CLOSED:unintended_capture=REFUTED:missing_origin=UNKNOWN:replay=CLOSED:unknown_fields=stage/step/reason/unknown_class/next_operation/blocked_by:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($origin.evidence | index("origin-proof:stable_symbol_identities=true:alpha_renaming=true:proof_paths=true")) != null and
    ($origin.evidence | index("generated-capture-free-go:build=CLOSED:artifact=gooo-artifacts/generated_capture_free.go")) != null and
    ($origin.evidence | index("replay:status=CLOSED:same_identities=true:same_names=true:same_decisions=true")) != null and
    ($origin.evidence | index("bootstrap-conformance:status=PASS:canonical_cases=3")) != null and
    ($origin.evidence | index("policy:status=CLOSED:bootstrap_commits=1:post_bootstrap_direct_main=0")) != null and
    ($origin.evidence | index("upstream-input:commit=17933b4e7a724a622652c73de04f7973c524bec9:origin_resolve_contract=sha256:1aa44ff29b0433dcb2e80dd1dd74e70d3f6332865e276a7eb913ab2386697216:policy_contract=sha256:601fc367ccbc62ef20a5a56e4ec18cec98a177d82a1c7bf4d4f3d3b70cfcb2f7")) != null and
    ($origin.evidence | index("scope:HYGIENIC_ORIGIN_RESOLVER_ONLY:whole-language-improvement=UNKNOWN:external-utility=UNKNOWN")) != null and
    ($origin.evidence | index("structural-append:cell=HYGIENIC_ORIGIN_RESOLVER_DURABLE_RELEASE:activity=AdoptHygienicOriginResolverDurableRelease:lock=hygienic_origin_resolver_durable_release")) != null and
    ($origin.evidence | index("immutable-v0.35.0-baseline:semantic-source-bound")) != null and
    ($origin.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($origin.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($origin.evidence | index("projection-before-digests:report=sha256:2c23107490ef5b0e6127d6f263dc6f8562b2f822c36adce7dc41d1cea3dfb226:history=sha256:7565161292a16a7105cd04f3eb21b96db71d0ab8342e0fd5cb69cce6cf50ca87")) != null and
    ($origin.evidence | index("projection-source-semantic-digests:report=sha256:638d0ddb4fe3f1f7ba2dadcafc36a7af15aca44bfb6b9f8d9cefd0e1adaa007c:history=sha256:638d0ddb4fe3f1f7ba2dadcafc36a7af15aca44bfb6b9f8d9cefd0e1adaa007c")) != null and
    ($origin.evidence | index("projection-after-invariants:report=deterministic-regenerate-from-post-append-semantic-source:history=deterministic-regenerate-from-post-append-semantic-source")) != null and
    ($origin.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($origin.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($origin.evidence | index("replay-mismatches:0")) != null and
    ($origin.evidence | index("input-repository-writes:0")) != null and
    ($origin.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($origin.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null) and
  ((.cells[] | select(.cell_id == "CAPABILITY_EFFECT_CHECKER_DURABLE_RELEASE")) as $checker |
    $checker.state == "CLOSED" and
    $checker.release_key == "capability_effect_checker_durable_release" and
    ($checker.evidence | index("upstream-release:repo=kimjooyoon/gooo-capability-effect-checker:tag=v0.1.1:release=380149578:tag_object=a94e28c3bba56886b709838c04723e25abf55c1b:target=5bd2efb088ec9d38d3d4fc79c3545b61446935e8:immutable=true")) != null and
    ($checker.evidence | index("upstream-assets:538739363:978:sha256:f2ef6d03150d868d85f8a3e91e6c34a47446f3417937339c291dac2447a61303,538739364:19964:sha256:ca111a04da52d746223de7ce194433ac628bfc33754aea2655baa3a0e8b6ef2c,538739362:872:sha256:f4a8373e9f5f466a7c77ca09866e59fa344ece00acdf515c5a8c2927d0c86bb9,538739365:6234:sha256:26089654c08e8db6353b253afb8a7c674aef6e813bd4d032545df0b973cd0843,538739366:362:sha256:49938f8dd3dc3e6c5818f92cabad028a2a15e6678d76527c107c284122e19139")) != null and
    ($checker.evidence | index("child-corpus:cases=5:safe-generator=CLOSED:repository-write-escalation=REFUTED:indirect-missing-grant=UNKNOWN:indirect-repository-write=REFUTED:external-oracle=UNKNOWN:unknown_fields=stage/step/reason/unknown_class/next_operation/blocked_by:precedence=REFUTED>UNKNOWN>CLOSED")) != null and
    ($checker.evidence | index("effect-sets:safe-generator=READ_INPUT+WRITE_CALLER_OUTPUT:repository-write-escalation=READ_INPUT+REPOSITORY_WRITE:indirect-missing-grant=NETWORK+READ_INPUT+WRITE_CALLER_OUTPUT:indirect-repository-write=READ_INPUT+REPOSITORY_WRITE+WRITE_CALLER_OUTPUT:external-oracle=READ_INPUT+WRITE_CALLER_OUTPUT")) != null and
    ($checker.evidence | index("offending-call-paths:repository-write-escalation=generator->generator:indirect-missing-grant=generator->helper:indirect-repository-write=generator->generator,generator->helper:external-oracle=generator")) != null and
    ($checker.evidence | index("generated-checker-go:artifact=generated/checker.go:bytes=2481:digest=sha256:93db4dfda9d2069e07557e17113b46c9bbbc998d071f5ee562395e997edfa94f")) != null and
    ($checker.evidence | index("replay:status=UNKNOWN:source_contract_toolchain_before_after_pair=false")) != null and
    ($checker.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($checker.evidence | index("metrics:go_files=7:gooo_files=6:go_physical_lines=1259:gooo_physical_lines=88:regular_files=25:directories=12:outputs=4/16271:generated_artifacts=1/2481:tests=5/5/0/0/2:peak_rss_kib=274988:compile=17:build=5917:test=2303:conformance=7:integration=19")) != null and
    ($checker.evidence | index("scope:CAPABILITY_EFFECT_CHECKER_ONLY:whole-language-improvement=UNKNOWN:external-utility=UNKNOWN")) != null and
    ($checker.evidence | index("structural-append:cell=CAPABILITY_EFFECT_CHECKER_DURABLE_RELEASE:activity=AdoptCapabilityEffectCheckerDurableRelease:lock=capability_effect_checker_durable_release")) != null and
    ($checker.evidence | index("immutable-v0.36.0-baseline:semantic-source-bound")) != null and
    ($checker.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($checker.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($checker.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($checker.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($checker.evidence | index("replay-mismatches:0")) != null and
    ($checker.evidence | index("input-repository-writes:0")) != null and
    ($checker.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($checker.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null) and
  ((.cells[] | select(.cell_id == "DETERMINISTIC_MODULE_LINKER_DURABLE_RELEASE")) as $linker |
    $linker.state == "CLOSED" and
    $linker.release_key == "deterministic_module_linker_durable_release" and
    ($linker.evidence | index("upstream-release:repo=kimjooyoon/gooo-module-linker:tag=v0.1.1:release=380147845:tag_object=006323188885fe6564c26a47c71b66a3a0dc960e:target=73a2c4f64be92d3dff67e659794f1597427c3148:immutable=true")) != null and
    ($linker.evidence | index("upstream-assets:538733980:7498:sha256:a64231a836f62a0176ff1c1ad33ec4def0e9f31aed0258723db01a657c824738,538733979:2746:sha256:1e9b83b38a09a31cc9fabb98c3ac0767e7b4941f84916f3f875f2bb6f91146e0,538733978:982:sha256:deec296b9f763c26ca852f223c7cdade64ba88c2fb73b8047917dcd85cbae4e2")) != null and
    ($linker.evidence | index("child-corpus:cases=9:selected=9:executed=9:canonical_input_order_digest=sha256:526c7bf9fe423e2d8487f8a89a68918045ab4ffa28dce8ebd9998e5419feb794:unknown=2:six_fields=stage/step/reason/unknown_class/next_operation/blocked_by:refuted=duplicate,digest,release,cycle:generated-go-build=CLOSED")) != null and
    ($linker.evidence | index("linked-ir-and-generated-go:linked_ir=2746:sha256:1e9b83b38a09a31cc9fabb98c3ac0767e7b4941f84916f3f875f2bb6f91146e0:generated_go=982:sha256:deec296b9f763c26ca852f223c7cdade64ba88c2fb73b8047917dcd85cbae4e2")) != null and
    ($linker.evidence | index("child-states:unknown=2:duplicate=REFUTED:digest=REFUTED:release=REFUTED:cycle=REFUTED:generated-go-build=CLOSED")) != null and
    ($linker.evidence | index("canonical-input-order-digest:sha256:526c7bf9fe423e2d8487f8a89a68918045ab4ffa28dce8ebd9998e5419feb794")) != null and
    ($linker.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($linker.evidence | index("structural-append:cell=DETERMINISTIC_MODULE_LINKER_DURABLE_RELEASE:activity=AdoptDeterministicModuleLinkerDurableRelease:lock=deterministic_module_linker_durable_release")) != null and
    ($linker.evidence | index("immutable-v0.37.0-baseline:semantic-source-bound")) != null and
    ($linker.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($linker.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($linker.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($linker.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($linker.evidence | index("replay-mismatches:0")) != null and
    ($linker.evidence | index("input-repository-writes:0")) != null and
    ($linker.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($linker.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null) and
  ((.cells[] | select(.cell_id == "SEMANTIC_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE")) as $reducer |
    $reducer.state == "CLOSED" and
    $reducer.release_key == "semantic_counterexample_reducer_durable_release" and
    ($reducer.evidence | index("upstream-release:repo=kimjooyoon/gooo-semantic-counterexample-reducer:tag=v0.1.1:release=380148374:tag_object=cc225db786718083a81264398096b75a23301646:target=395f3faba810f0dd8f091cb6180527c7240eee61:immutable=true")) != null and
    ($reducer.evidence | index("upstream-assets:538735547:181:sha256:3be38f5674e2c063ce74f0bb5b42ffbc2550c69589d7438e9b0023657fe4e2e1,538735550:28172:sha256:0d90dcad2c2aa072b8c0f46378e227813bd439e41e81cc7b3fe5f0111cb38454,538735549:9529:sha256:1124d7378125128900827e82f8ab87ab3751b7ab0c06b9fd29e081ed9d28a37c,538735548:793:sha256:dbedbe01c851718fcd1ce09a6fea329d026e75cc6abc06242174e32c8fe4531b,538735551:482:sha256:e3a9dc202ad28cd961be76d3eefd5edaa72149978db5cd89ffe83e2808742454,538735563:258:sha256:da7549433fadd2ecb62ee2854a45c8d7c3033c77ec30d93833f7271ca5d010f9")) != null and
    ($reducer.evidence | index("child-corpus:cases=2:selected=2:executed=2:reduction=CLOSED2:improvement=UNKNOWN2:4-activity=nodes=7->4:edges=4->0:bytes=1425->530:oracle=30:capture-escalation=nodes=4->3:edges=3->2:bytes=1067->672:oracle=36")) != null and
    ($reducer.evidence | index("child-verdicts:4-activity=baseline=REFUTED:final=REFUTED:reason_digest_same=true:capture-escalation=baseline=REFUTED:final=REFUTED:reason_digest_same=true")) != null and
    ($reducer.evidence | index("child-unknown-fields:stage/step/reason/unknown_class/next_operation/blocked_by")) != null and
    ($reducer.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($reducer.evidence | index("structural-append:cell=SEMANTIC_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE:activity=AdoptSemanticCounterexampleReducerDurableRelease:lock=semantic_counterexample_reducer_durable_release")) != null and
    ($reducer.evidence | index("immutable-v0.38.0-baseline:semantic-source-bound")) != null and
    ($reducer.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($reducer.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($reducer.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($reducer.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($reducer.evidence | index("replay-mismatches:0")) != null and
    ($reducer.evidence | index("input-repository-writes:0")) != null and
    ($reducer.evidence | index("planner-tool-executions:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($reducer.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null) and
  ((.cells[] | select(.cell_id == "DIFFERENTIAL_SEMANTICS_RUNTIME_DURABLE_RELEASE")) as $runtime |
    $runtime.state == "CLOSED" and
    $runtime.release_key == "differential_semantics_runtime_durable_release" and
    ($runtime.evidence | index("upstream-release:repo=kimjooyoon/gooo-differential-semantics-runtime:tag=v0.1.2:release=380172619:tag_object=965abb84f065783db1183271fcf71a989a7637ff:target=33e0f5a9b54f22824c1a34c914e74d8e0f931b62:immutable=true")) != null and
    ($runtime.evidence | index("upstream-assets:538817960:1844:sha256:931f4bbf36aeaaeb153077e9e5588c2fa021e1e512408d45a3161aea7c554b40")) != null and
    ($runtime.evidence | index("upstream-ci:workflow=gooo-differential-semantics:run_id=33462237222:commit=33e0f5a9b54f22824c1a34c914e74d8e0f931b62")) != null and
    ($runtime.evidence | index("semantic-contract:path=.gooo/semantics.gooo:digest=sha256:d95962094f41e8610161e8316dd1eb123db53ab960c8f0522f85d79e6bb4c21f")) != null and
    ($runtime.evidence | index("corpus:path=.gooo/corpus.gooo:digest=sha256:e51ec2ac8a1430389ee015b7c54cb5cd3f520f4b352eb5c68d86f34168943060")) != null and
    ($runtime.evidence | index("toolchain:go=1.27.x:target=go1.27")) != null and
    ($runtime.evidence | index("child-corpus:cases=9:selected=9:executed=9:normal=4:unknown=2:refuted=2:replay=1:byte_identical=true:overall=UNKNOWN:comparison_fields=typed_value/ordered_effect_trace/terminal_explanation_digest")) != null and
    ($runtime.evidence | index("runtime:compile=14340:build=1676:test=110:conformance=40:integration=20:peak_rss_kib=272448/87452/7076/7100/6852")) != null and
    ($runtime.evidence | index("inventory:go=14/2464:gooo=12/211:regular_files=30:subdirectories=10")) != null and
    ($runtime.evidence | index("generated-artifacts:count=18:bytes=38691843")) != null and
    ($runtime.evidence | index("upstream-improvement:status=UNKNOWN:reason=matched scenario, source, contract, and toolchain before/after integer evidence is absent")) != null and
    ($runtime.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($runtime.evidence | index("structural-append:cell=DIFFERENTIAL_SEMANTICS_RUNTIME_DURABLE_RELEASE:activity=AdoptDifferentialSemanticsRuntimeDurableRelease:lock=differential_semantics_runtime_durable_release")) != null and
    ($runtime.evidence | index("immutable-v0.39.0-baseline:semantic-source-bound")) != null and
    ($runtime.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($runtime.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($runtime.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($runtime.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($runtime.evidence | index("replay-mismatches:0")) != null and
    ($runtime.evidence | index("input-repository-writes:0")) != null and
    ($runtime.evidence | index("planner-tool-executions:version=v0.3.0:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($runtime.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null and
    ($runtime.evidence | index("planner-ci:workflow=v0.40.0 planner generator-only:run_id=33476918995:run_url=https://github.com/kimjooyoon/gooo-self-improvement-ledger/actions/runs/33476918995:artifact_id=9788480373:artifact_digest=03b6a43461dafb833304d0406861f338c57168bf0694596abfd0d9a507287711")) != null) and
  ((.cells[] | select(.cell_id == "STAGED_QUASIQUOTE_DURABLE_RELEASE")) as $quasiquote |
    $quasiquote.state == "CLOSED" and
    $quasiquote.release_key == "staged_quasiquote_durable_release" and
    ($quasiquote.evidence | index("upstream-release:repo=kimjooyoon/gooo-staged-quasiquote-slice:tag=v0.1.0:release=380175121:tag_object=f3041976c533b87d0110598c06bb7e320abe30ee:target=a6dbb1f696feacaf6702aafd1b759a09c70bd917:immutable=true")) != null and
    ($quasiquote.evidence | index("upstream-assets:538825432:10029:sha256:fa0c1735c4ba26a6ab1b459a96f41087e8e27fd62b5e627f8bba467fb80f84de,538825434:251:sha256:e3b922b930ec5ad21b045cdc9cec65e0639610dce77e36b95e6836d966e5016f,538825438:793:sha256:d9b6981e40aa70b6f26b2c33134aa7c1fe0a3d34b2b34f9800d4b8300614b8ae,538825436:1378:sha256:75b98b3d6945c6fac581d14824cf9a36b4a4bbac47cbd8d6a5eff69471c33ebf,538825447:21644:sha256:11abe1335a8f52120b9201365c6943087f02f313061acc4134aeae477f6ba87d,538825435:590:sha256:f87253473d129ceae0eaf7adcaebea8fb1be6d3282ae9a73fd64b58606f01012")) != null and
    ($quasiquote.evidence | index("upstream-ci:workflow=CI:run_id=33462845515:job=99716479817:commit=a6dbb1f696feacaf6702aafd1b759a09c70bd917:success")) != null and
    ($quasiquote.evidence | index("optional-origin-oracle:workflow=Optional origin oracle:run_id=33462930216:job=99716741052:artifact=9783807803:artifact_digest=sha256:54fb20a8d95ac7caab02ab33ab47a06824e9e1e7e956e663e70e7375a8b4dfdf:advisory=true")) != null and
    ($quasiquote.evidence | index("semantic-contract:path=gooo-staged-quasiquote-slice-v0.1.0-contract.gooo:digest=sha256:fa0c1735c4ba26a6ab1b459a96f41087e8e27fd62b5e627f8bba467fb80f84de")) != null and
    ($quasiquote.evidence | index("resolver-oracle:path=gooo-hygienic-origin-resolver-v0.1.1.tar.gz:digest=sha256:83b3b2b13c5dabe41b4730eeb4ef9371d1f0d04e20c86e52c7da099377e7ceac:advisory=true")) != null and
    ($quasiquote.evidence | index("corpus:cases=6:selected=6:executed=6:closed=3:unknown=1:refuted=2:replay=1:overall=REFUTED")) != null and
    ($quasiquote.evidence | index("runtime:compile=8940:build=415:test=231:conformance=7:integration=854:peak_rss_kib=272672/88580/97008/7000/67772")) != null and
    ($quasiquote.evidence | index("inventory:go=10/1349:gooo=7/322:regular_files=34:subdirectories=14")) != null and
    ($quasiquote.evidence | index("generated-artifacts:count=19:bytes=80351")) != null and
    ($quasiquote.evidence | index("upstream-improvement:status=UNKNOWN:reason=no matched scenario/source/contract/toolchain before/after integer pair")) != null and
    ($quasiquote.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($quasiquote.evidence | index("structural-append:cell=STAGED_QUASIQUOTE_DURABLE_RELEASE:activity=AdoptStagedQuasiquoteDurableRelease:lock=staged_quasiquote_durable_release")) != null and
    ($quasiquote.evidence | index("immutable-v0.40.1-baseline:semantic-source-bound")) != null and
    ($quasiquote.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($quasiquote.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($quasiquote.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($quasiquote.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($quasiquote.evidence | index("replay-mismatches:0")) != null and
    ($quasiquote.evidence | index("input-repository-writes:0")) != null and
    ($quasiquote.evidence | index("planner-tool-executions:version=v0.3.0:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($quasiquote.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null and
    ($quasiquote.evidence | index("planner-ci:workflow=v0.41.0 planner generator-only:run_id=33479819018:run_url=https://github.com/kimjooyoon/gooo-self-improvement-ledger/actions/runs/33479819018:artifact_id=9789487893:artifact_digest=87c6b57cce621bdd250e7c4666164b7130a6d5a5c72e0d8b7d21b72249cfa04f")) != null) and
  ((.cells[] | select(.cell_id == "ERROR_DIRECTED_EVOLUTION_PLANNER_DURABLE_RELEASE")) as $error_directed |
    $error_directed.state == "CLOSED" and
    $error_directed.release_key == "error_directed_evolution_planner_durable_release" and
    ($error_directed.evidence | index("upstream-release:repo=kimjooyoon/gooo-error-directed-evolution-planner:tag=v0.1.1:release=380175481:tag_object=e44041e4cd7d42cc716048b2dc94fb23d9b36fec:target=72350a2cbc53190cadc9cc5e4ac9f60875418289:immutable=true")) != null and
    ($error_directed.evidence | index("upstream-assets:538826659:2763054:sha256:5e457e61466c58e2c2fede1cdf9ab94645c4f19648ccdfb397f1e2f8275489f9,538826660:27388:sha256:5a753a6f75a9ebe78e857a373890d2be307ccb4c9f91b4939110c71bda9e8594,538826664:67823:sha256:8ec628e0b7fd84cd893b6801a622b207693db68c9c8890386d5382417aad094b,538826662:834:sha256:212873c68d9b6a8c7f9fc21a51057ed631832144cd9d2825252dd3263fb1de44,538826661:522:sha256:bba3d5ff2832d0cb15e8d9488853c9b7dd9a7b0dfc8361826d5073623856cd1e,538826671:373:sha256:a70099e31a7703dd955626e404bce46fc1bd6699ce882a0c3319100ab975eaf4")) != null and
    ($error_directed.evidence | index("upstream-ci:workflow=error-directed-evolution-planner:run_id=33462832367:job=99716440307:commit=72350a2cbc53190cadc9cc5e4ac9f60875418289:success")) != null and
    ($error_directed.evidence | index("upstream-ci-artifact:9783781309:51897:sha256:ee093a01df73d2a2733aa0407e71fbeb95a4f3d535b443ab09d8ca0397804f59")) != null and
    ($error_directed.evidence | index("upstream-bindings:compiler=gooo-reflexive-compiler-slice:v0.3.0:release=380150043:tag_object=d7e2bd301f5d1634e92b0de90d54798a35db424a:target=0cf44db8b0d6cd96d190e9f902312d0be9394029:asset=538741020:2647664:sha256:e03b605c14f5d4d0faf262e57556506f8cf7765756aee49a4ceb99fd700ae862,reducer=gooo-semantic-counterexample-reducer:v0.1.1:release=380148374:tag_object=cc225db786718083a81264398096b75a23301646:target=395f3faba810f0dd8f091cb6180527c7240eee61:asset=538735549:9529:sha256:1124d7378125128900827e82f8ab87ab3751b7ab0c06b9fd29e081ed9d28a37c")) != null and
    ($error_directed.evidence | index("corpus:cases=5:selected=5:executed=5:closed=2:unknown=2:refuted=1:replay=1:overall=CLOSED")) != null and
    ($error_directed.evidence | index("runtime:compile=7594:build=5456:test=151:conformance=33:integration=33:peak_rss_kib=280656")) != null and
    ($error_directed.evidence | index("inventory:go=7/1545:gooo=2/35:regular_files=31:subdirectories=15")) != null and
    ($error_directed.evidence | index("generated-artifacts:count=39:bytes=204350")) != null and
    ($error_directed.evidence | index("tests:total=4:selected=4:executed=4:reused=0:failed=0:unknown=0")) != null and
    ($error_directed.evidence | index("upstream-improvement:status=UNKNOWN:reason=no matched scenario/source/contract/toolchain before/after integer pair")) != null and
    ($error_directed.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($error_directed.evidence | index("structural-append:cell=ERROR_DIRECTED_EVOLUTION_PLANNER_DURABLE_RELEASE:activity=AdoptErrorDirectedEvolutionPlannerDurableRelease:lock=error_directed_evolution_planner_durable_release")) != null and
    ($error_directed.evidence | index("immutable-v0.41.0-baseline:semantic-source-bound")) != null and
    ($error_directed.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($error_directed.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($error_directed.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($error_directed.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($error_directed.evidence | index("replay-mismatches:0")) != null and
    ($error_directed.evidence | index("input-repository-writes:0")) != null and
    ($error_directed.evidence | index("planner-tool-executions:version=v0.3.0:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($error_directed.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null and
    ($error_directed.evidence | index("planner-ci:workflow=v0.42.0 planner generator-only:run_id=33483134192:run_url=https://github.com/kimjooyoon/gooo-self-improvement-ledger/actions/runs/33483134192:artifact_id=9790698590:artifact_digest=9d3c79155fc9ed6044907cca868664fcd2ee0421bd01af5bd7313381b4e317d2")) != null) and
  ((.cells[] | select(.cell_id == "INCREMENTAL_MODULE_COMPILER_DURABLE_RELEASE")) as $incremental |
    $incremental.state == "CLOSED" and
    $incremental.release_key == "incremental_module_compiler_durable_release" and
    ($incremental.evidence | index("upstream-release:repo=kimjooyoon/gooo-incremental-module-compiler:tag=v0.1.3:release=380177397:tag_object=985f914ae5beb0e2d2c9c48a39da0a1897c4af3a:target=336669ce954917fc0d34b0b190da8ab5487ab095:immutable=true")) != null and
    ($incremental.evidence | index("upstream-assets:538832233:9473:sha256:704329d78a0468b2cf3292d10fc8cce73a5a9542d1f30daf067c39baffba9dc6,538832237:31899:sha256:16e23ecf2562cac1e6dde050e7e3789a80976209623bb39663f613d8c18f9a11,538832232:33195:sha256:2533b316ba05c110d465c8dd051874e9499e62aa11ee3bd5a18c2cb19398aae1,538832236:434:sha256:6310ca6099b0c14add8355e10d9a259205f50903fb136f507bee1247e6f7359f")) != null and
    ($incremental.evidence | index("upstream-ci:workflow=gooo-incremental-module-compiler-ci:run_id=33463205917:job=99717581340:commit=336669ce954917fc0d34b0b190da8ab5487ab095:success")) != null and
    ($incremental.evidence | index("upstream-ci-artifact:9783911351:16509:sha256:da8f814094a687755e349f06f7baa83a445da864123729dbc6bc5efab6987ab2")) != null and
    ($incremental.evidence | index("upstream-manifest:ci_evidence_sha256=sha256:704329d78a0468b2cf3292d10fc8cce73a5a9542d1f30daf067c39baffba9dc6:source_sha256=sha256:16e23ecf2562cac1e6dde050e7e3789a80976209623bb39663f613d8c18f9a11:manifest_sha256=sha256:2533b316ba05c110d465c8dd051874e9499e62aa11ee3bd5a18c2cb19398aae1:checksums_sha256=sha256:6310ca6099b0c14add8355e10d9a259205f50903fb136f507bee1247e6f7359f:upstream_lock_sha256=sha256:81f2a28d5fcc2a743820079938d359be37ad2d2c6cc8d5294bcbc28b6095c490")) != null and
    ($incremental.evidence | index("corpus:cases=5:selected=5:executed=5:closed=3:unknown=1:refuted=1:replay=0:overall=CLOSED")) != null and
    ($incremental.evidence | index("runtime:compile=4:build=193:test=263:conformance=5:integration=464:peak_rss_kib=150308")) != null and
    ($incremental.evidence | index("inventory:go=15/2790:gooo=18/197:regular_files=44:subdirectories=20")) != null and
    ($incremental.evidence | index("generated-artifacts:count=5:bytes=2421")) != null and
    ($incremental.evidence | index("tests:total=15:selected=6:executed=6:reused=9:failed=0:unknown=0")) != null and
    ($incremental.evidence | index("upstream-improvement:status=CLOSED:reason=MATCHED_EXACT_PAIR")) != null and
    ($incremental.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($incremental.evidence | index("structural-append:cell=INCREMENTAL_MODULE_COMPILER_DURABLE_RELEASE:activity=AdoptIncrementalModuleCompilerDurableRelease:lock=incremental_module_compiler_durable_release")) != null and
    ($incremental.evidence | index("immutable-v0.42.0-baseline:semantic-source-bound")) != null and
    ($incremental.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($incremental.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($incremental.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($incremental.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($incremental.evidence | index("replay-mismatches:0")) != null and
    ($incremental.evidence | index("input-repository-writes:0")) != null and
    ($incremental.evidence | index("planner-tool-executions:version=v0.3.0:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($incremental.evidence | index("local-validation-followup:local_validation_executions=2:inspection_only=false:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null and
    ($incremental.evidence | index("planner-ci:workflow=v0.43.0 planner generator-only:run_id=33486099504:run_url=https://github.com/kimjooyoon/gooo-self-improvement-ledger/actions/runs/33486099504:artifact_id=9791810587:artifact_digest=f70286380682101739b1c19b84219f0d09dc09f5dfaca1d1327ecb7ff8767b3c")) != null) and
  ((.cells[] | select(.cell_id == "SELF_REWRITE_SANDBOX_DURABLE_RELEASE")) as $sandbox |
    $sandbox.state == "CLOSED" and
    $sandbox.release_key == "self_rewrite_sandbox_durable_release" and
    ($sandbox.evidence | index("upstream-release:repo=kimjooyoon/gooo-self-rewrite-sandbox:tag=v0.1.1:release=380237396:tag_object=7afaab763564e356e454db4d63d22ffa7ba53f14:target=bccfd3a740f3d9c254d715e01a61a7554e96568a:immutable=true")) != null and
    ($sandbox.evidence | index("upstream-assets:539057455:2825115:sha256:313d243bd9e7cba3479511a10472882b05d5b954a3082f109aacd82297b471d8,539057461:23210:sha256:16ac09b679257fc77dce92d538d79e8676eea088ef499bc73c10290a4b1e5b1b,539057456:790:sha256:d7a4615beb26b9e27883f4d46620215f78548d1eec646fe5cf156446592b3383,539057458:40509:sha256:d5072d9ba452636a0023513f346cecc879b25fbb7730f26932950f8037d93d38,539057459:498:sha256:37b2f03ea77842bd81503435f0a069d10c2c61e0f5446ecadcaf0f0841de7570,539057471:294:sha256:32e1ed0dd02ef58c148feb74705384d961915197e047f7639f7ec339c6c56008")) != null and
    ($sandbox.evidence | index("upstream-ci:workflow=Conformance:run_id=33474678408:job=99751363760:commit=bccfd3a740f3d9c254d715e01a61a7554e96568a:success")) != null and
    ($sandbox.evidence | index("upstream-ci-artifact:9787734796:2890709:sha256:6ba52984ba8a072baf33ecc32836475179ebd11094b1a5704f41d4edd5c65aa4")) != null and
    ($sandbox.evidence | index("upstream-release-ci:workflow=Immutable release:run_id=33474686476:job=99751390530:commit=bccfd3a740f3d9c254d715e01a61a7554e96568a:success")) != null and
    ($sandbox.evidence | index("upstream-manifest:manifest_sha256=sha256:d7a4615beb26b9e27883f4d46620215f78548d1eec646fe5cf156446592b3383:source_sha256=sha256:16ac09b679257fc77dce92d538d79e8676eea088ef499bc73c10290a4b1e5b1b:binary_sha256=sha256:313d243bd9e7cba3479511a10472882b05d5b954a3082f109aacd82297b471d8:report_sha256=sha256:d5072d9ba452636a0023513f346cecc879b25fbb7730f26932950f8037d93d38:sums_sha256=sha256:37b2f03ea77842bd81503435f0a069d10c2c61e0f5446ecadcaf0f0841de7570:version_sha256=sha256:32e1ed0dd02ef58c148feb74705384d961915197e047f7639f7ec339c6c56008")) != null and
    ($sandbox.evidence | index("corpus:cases=6:selected=6:executed=6:closed=3:unknown=1:refuted=2:replay=0:overall=CLOSED")) != null and
    ($sandbox.evidence | index("runtime:compile=6052:build=6052:test=2304:conformance=1256:integration=0:peak_rss_kib=281064")) != null and
    ($sandbox.evidence | index("inventory:go=6/1401:gooo=9/148:regular_files=31:subdirectories=17")) != null and
    ($sandbox.evidence | index("generated-artifacts:count=40:bytes=24997")) != null and
    ($sandbox.evidence | index("tests:total=4:selected=4:executed=4:reused=0:failed=0:unknown=1")) != null and
    ($sandbox.evidence | index("upstream-improvement:status=CLOSED:reason=MATCHED_EXACT_PAIR")) != null and
    ($sandbox.evidence | index("authority:repository_writes=0:local_test_executions=0:cross_project_required_gates=0")) != null and
    ($sandbox.evidence | index("parent-v0.43.0:release=380333473:tag_object=df8f2ac1dddcb6db09883fc488e0f5b45d8e843b:target=8de54d1adb544be8506e938522e6e247a7b1a216:asset=539249006:27461608:sha256:b6f96d505ccfd27aa24755887ca4ae9bc9549285d776ca872fb44b3a3503660b:immutable=true")) != null and
    ($sandbox.evidence | index("parent-v0.43.0-transport:run_id=33487786002:job=99791823088:receipt_artifact=9792471417:755:sha256:cedcbff51c841e9b825e021541aeceb3d42315959a7e81cedf1d4df435119477")) != null and
    ($sandbox.evidence | index("immutable-v0.43.0-baseline:semantic-source-bound")) != null and
    ($sandbox.evidence | index("structural-append:cell=SELF_REWRITE_SANDBOX_DURABLE_RELEASE:activity=AdoptSelfRewriteSandboxDurableRelease:lock=self_rewrite_sandbox_durable_release")) != null and
    ($sandbox.evidence | index("derived-projection-regeneration:report-and-history-replaced-in-caller-copy")) != null and
    ($sandbox.evidence | index("projection-replacements:count=2:report=replace:history=replace")) != null and
    ($sandbox.evidence | index("ast-patch:planned=7:changed=7:ast_nodes_added=5:replay_mismatches=0:planning_repository_writes=0")) != null and
    ($sandbox.evidence | index("rollback-receipt:rollback_ready=true")) != null and
    ($sandbox.evidence | index("replay-mismatches:0")) != null and
    ($sandbox.evidence | index("input-repository-writes:0")) != null and
    ($sandbox.evidence | index("planner-tool-executions:version=v0.3.0:current_task=1:classification=generator_only:not_validation=true")) != null and
    ($sandbox.evidence | index("local-validation-followup:local_validation_executions=0:inspection_only=true:process=REFUTED:local_schema_replays=0:local_conformance_replays=0:local_go_test=0:local_go_build=0:local_go_vet=0:local_go_conformance=0")) != null and
    ($sandbox.evidence | index("planner-ci:workflow=v0.44.0 planner generator-only:run_id=33488925074:run_url=https://github.com/kimjooyoon/gooo-self-improvement-ledger/actions/runs/33488925074:artifact_id=9792922258:artifact_digest=fff595d3e1f6265fd05d7ef5ab963fd9a2ab1ef19b9cbda089fce6a20f871542")) != null) and
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
set +e
/usr/bin/time -f '%M' -o "$probe/report-peak-rss" "$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$probe/report.json" \
  -output-markdown "$probe/report.md" 2>"$artifact/report-command.stderr"
report_status=$?
set -e
echo "conformance: probe report generator exit status=$report_status"
if test -s "$artifact/report-command.stderr"; then
  cat "$artifact/report-command.stderr" >&2
fi
if test "$report_status" -ne 0; then
  exit 1
fi
end=$(date +%s%N)
report_wall=$(( (end - start) / 1000000 ))
report_raw=$((end - start))
echo "conformance: probe report generator completed"
if test -f "$probe/report-peak-rss"; then
  report_rss=$(cat "$probe/report-peak-rss")
else
  echo "conformance: probe report peak RSS measurement missing" >&2
  exit 1
fi

jq --argjson wall "$report_wall" --argjson raw "$report_raw" --argjson rss "$report_rss" \
  '.timing.report={wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$rss}' \
  "$artifact/runtime.json" > "$probe/runtime.json"
mv "$probe/runtime.json" "$artifact/runtime.json"

start=$(date +%s%N)
set +e
/usr/bin/time -f '%M' -o "$probe/final-report-peak-rss" "$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$artifact/report.json" \
  -output-markdown "$artifact/report.md" 2>"$artifact/final-report-command.stderr"
final_report_status=$?
set -e
echo "conformance: final report generator exit status=$final_report_status"
if test -s "$artifact/final-report-command.stderr"; then
  cat "$artifact/final-report-command.stderr" >&2
fi
if test "$final_report_status" -ne 0; then
  exit 1
fi
end=$(date +%s%N)

echo "conformance: emitted report diagnostics"
jq '{schema,profile_id,decision,summary,proof_counts,indicator_counts,bindings,releases,authority,local_execution_counts}' "$artifact/report.json"

jq -e '
  .schema == "gooo/self-improvement-portfolio/report/v1" and
  .profile_id == "self-improvement-portfolio-v1" and
  .summary == {total:50,closed:47,unknown:1,refuted:2} and
  .precedence == ["REFUTED","UNKNOWN","CLOSED"] and
  (.cells|length) == 50 and
  (.cells|map(.id)|length) == (.cells|map(.id)|unique|length) and
  (.cells|map(.activity)|length) == (.cells|map(.activity)|unique|length) and
  (.cells|map(select(.numerator == 1 and .denominator == 1))|length) == 47 and
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
    UTILITY_TRIAL_PROTOCOL_RELEASE:"CLOSED",
    REFLEXIVE_MODERN_CYCLE_RELEASE:"CLOSED",
    EXPERIENCE_MEMORY_RELEASE:"CLOSED",
    SEMANTIC_DRIFT_GUARD_RELEASE:"CLOSED",
    SEMANTIC_AUTHORITY_CENSUS_RELEASE:"CLOSED",
    REFLEXIVE_LEARNING_DRIFT_CYCLE_RELEASE:"CLOSED",
    UNKNOWN_RESOLUTION_LATTICE_RELEASE:"CLOSED",
    SELF_REPAIR_INTEGRATION_RELEASE:"CLOSED",
    OPENTOFU_DURABLE_SEMANTIC_ENVELOPE_RELEASE:"CLOSED",
    LANGUAGE_DELTA_FORGE_DURABLE_RELEASE:"CLOSED",
    OPENTOFU_GENERATED_SERVICE_PROJECT_DURABLE_RELEASE:"CLOSED",
    REFLEXIVE_COMPILER_PHASE_DURABLE_RELEASE:"CLOSED",
    CAUSAL_VERIFICATION_RUNNER_DURABLE_RELEASE:"CLOSED",
    EXECUTABLE_EVOLUTION_TRIAL_COUNTEREXAMPLE_DURABLE_RELEASE:"CLOSED",
    REFLEXIVE_COMPILER_GRAPH_TOPOLOGY_SELF_IMPROVEMENT_DURABLE_RELEASE:"CLOSED",
    EXECUTABLE_EVOLUTION_TRIAL_CLOSED_LOOP_DURABLE_RELEASE:"CLOSED",
    STRUCTURAL_LEDGER_APPEND_PLANNER_DURABLE_RELEASE:"CLOSED",
    EXPLANATION_CARRYING_COMPILER_DURABLE_RELEASE:"CLOSED",
    TWO_GENERATION_BOOTSTRAP_DURABLE_RELEASE:"CLOSED",
    HYGIENIC_ORIGIN_RESOLVER_DURABLE_RELEASE:"CLOSED",
    CAPABILITY_EFFECT_CHECKER_DURABLE_RELEASE:"CLOSED",
    DETERMINISTIC_MODULE_LINKER_DURABLE_RELEASE:"CLOSED",
    SEMANTIC_COUNTEREXAMPLE_REDUCER_DURABLE_RELEASE:"CLOSED",
    DIFFERENTIAL_SEMANTICS_RUNTIME_DURABLE_RELEASE:"CLOSED",
    STAGED_QUASIQUOTE_DURABLE_RELEASE:"CLOSED",
    ERROR_DIRECTED_EVOLUTION_PLANNER_DURABLE_RELEASE:"CLOSED",
    INCREMENTAL_MODULE_COMPILER_DURABLE_RELEASE:"CLOSED",
    SELF_REWRITE_SANDBOX_DURABLE_RELEASE:"CLOSED"
  } and
  all(.cells[]; if .state == "UNKNOWN" then
    (.unknown|keys|sort) == ["blocked_by","next_operation","reason","stage","step","unknown_class"] and
    (.unknown.blocked_by|length) > 0
  else true end) and
  .bindings == {one_to_one:true,cells:50,activities:50,unique_axes:50,unique_metrics:50,source_bindings:50,ir_bindings:50,generated_artifact_bindings:50,evaluator_bindings:50} and
  .proof_counts.FOUNDATION.denominator == 4 and .proof_counts.COHERENCE.denominator == 41 and .proof_counts.REGRESSION.denominator == 5 and
  .indicator_counts.DRIVER.denominator == 4 and .indicator_counts.OUTCOME.denominator == 41 and .indicator_counts.GUARDRAIL.denominator == 5 and
  .releases == {total:47,verified:47,unknown:0,refuted:0} and
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
