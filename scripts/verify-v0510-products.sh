#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.51 product integration failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0510-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v051-products"
temp_root="${RUNNER_TEMP:-$artifact_root/.v051-products-temp}"
measurement_root="$products/measurement-boundary-v2"
operational_root="$products/operational-provenance"
frontier_parent_root="$products/frontier-v050-parent"
frontier_candidate_root="$products/frontier-v051-candidate"

command -v gh >/dev/null
command -v go >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v wc >/dev/null
command -v awk >/dev/null
command -v python3 >/dev/null
test -n "${GH_TOKEN:-}"
rm -rf "$products" "$temp_root"
mkdir -p "$products" "$temp_root" "$measurement_root" "$operational_root" "$frontier_parent_root" "$frontier_candidate_root"

sha256_prefixed() {
  printf 'sha256:%s\n' "$(sha256sum "$1" | awk '{print $1}')"
}

file_bytes() {
  find "$1" -type f -exec wc -c {} + | awk 'END {print $1+0}'
}

file_count() {
  find "$1" -type f -print | wc -l | tr -d ' '
}

echo "v0.51 products: run measurement-boundary-projector v0.2.0"
measurement_key=measurement_boundary_v2_projector_durable_release
measurement_archive="$artifact_root/releases/$measurement_key/assets/gooo-measurement-boundary-projector-v0.2.0.tar.gz"
measurement_manifest="$artifact_root/releases/$measurement_key/assets/release-manifest.json"
measurement_sums="$artifact_root/releases/$measurement_key/assets/SHA256SUMS"
test -s "$measurement_archive" -a -s "$measurement_manifest" -a -s "$measurement_sums"
measurement_source_root="$temp_root/measurement-source"
mkdir -p "$measurement_source_root"
tar --no-xattrs -xzf "$measurement_archive" -C "$measurement_source_root"
measurement_source_dir=$(find "$measurement_source_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$measurement_source_dir"
measurement_bin="$temp_root/measurement-boundary-projector"
(cd "$measurement_source_dir" && go build -trimpath -o "$measurement_bin" ./cmd/measurement-boundary-projector)

"$measurement_bin" v2-conformance \
  --source "$measurement_source_dir/examples/measurement-boundary-v2.gooo" \
  --corpus "$measurement_source_dir/fixtures/v2/corpus.json" \
  --out "$measurement_root/bundled-conformance"
jq -e '.schema=="gooo/measurement-boundary/conformance/v2" and .total==12 and .closed==4 and .unknown==4 and .refuted==4 and .replay_exact==true' \
  "$measurement_root/bundled-conformance/conformance-report.json" >/dev/null

cp "$artifact_root/v0510-live-lock-receipt.json" "$measurement_root/stage-input-receipt.json"
measurement_input_digest=$(sha256_prefixed "$measurement_root/stage-input-receipt.json")
stage_start=$(python3 -c 'import time; print(time.monotonic_ns())')
/usr/bin/time -f '%M' -o "$measurement_root/stage-peak-rss" \
  sh -c 'sleep 0.05; jq -S . "$1" > "$2"' sh "$artifact_root/report.json" "$measurement_root/stage-operation-output.json"
stage_end=$(python3 -c 'import time; print(time.monotonic_ns())')
stage_wall_ms=$(( (stage_end - stage_start) / 1000000 ))
if [ "$stage_wall_ms" -lt 1 ]; then stage_wall_ms=1; fi
stage_peak_rss=$(cat "$measurement_root/stage-peak-rss")
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-stage-observation/v1" \
  --arg input "$measurement_input_digest" --arg source_sha "$(sha256_prefixed "$measurement_archive")" \
  --arg commit_sha "$(sha256_prefixed "$measurement_archive")" --argjson wall "$stage_wall_ms" --argjson rss "$stage_peak_rss" \
  '{schema:$schema,stage_id:"stage:product-integration",start_event:"event:product-integration.start",end_event:"event:product-integration.end",input_receipt_digest:$input,source_archive_digest:$source_sha,source_commit_identity:$commit_sha,wall_ms:$wall,peak_rss_kib:$rss,work_units:2,authority:{repository_writes:0,local_test_executions:0,cross_project_required_gates:0},source_artifact:"v051-stage-observation.json",consumer_artifacts:["v051-stage-observation.json","report.json"]}' \
  > "$measurement_root/stage-output-receipt.json"
measurement_output_digest=$(sha256_prefixed "$measurement_root/stage-output-receipt.json")
cp "$measurement_root/stage-output-receipt.json" "$measurement_root/v051-stage-observation.json"
measurement_source_digest=$(sha256_prefixed "$measurement_archive")
measurement_commit_digest="$measurement_source_digest"
measurement_contract_digest=$(sha256_prefixed "$measurement_source_dir/contracts/measurement-boundary-v2.json")
measurement_fixture_template_digest=$(sha256_prefixed "$measurement_source_dir/fixtures/v2/cases/closed-single-stage-exact-coverage.json")
measurement_source_actual="$temp_root/measurement-boundary-v2.gooo"
sed \
  -e "s/sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa/$measurement_input_digest/g" \
  -e "s/sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb/$measurement_output_digest/g" \
  -e "s/sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc/$measurement_source_digest/g" \
  -e "s/sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd/$measurement_commit_digest/g" \
  "$measurement_source_dir/examples/measurement-boundary-v2.gooo" > "$measurement_source_actual"
measurement_fixture="$temp_root/measurement-boundary-v2-fixture.json"
jq -S --arg input "$measurement_input_digest" --arg output "$measurement_output_digest" --arg fixture "$measurement_fixture_template_digest" \
  --arg repo "$measurement_source_digest" --arg commit "$measurement_commit_digest" \
  --arg contract "$measurement_contract_digest" --arg job "${GITHUB_RUN_ID:-unknown}/${GITHUB_JOB:-v0510-products}" \
  --argjson wall "$stage_wall_ms" --argjson rss "$stage_peak_rss" \
  '.samples |= map(.input_receipt_digest=$input | .output_receipt_digest=$output | .identity_digests.repository=$repo | .identity_digests.commit=$commit | .measured=true | .value=(if .unit=="ms" then $wall else $rss end) | .work_units=2 | .peak_rss_kib=$rss | .source_artifact="v051-stage-observation.json" | .consumer_artifacts=["v051-stage-observation.json","report.json"] | .scenario_id="v0510-product-integration" | .input_digest=$input | .contract_digest=$contract | .fixture_digest=$fixture | .toolchain="go1.27.0" | .runner="github-actions/ubuntu-latest" | .job=$job | .pair_id="v0510-single-stage" | .phase="single")' \
  "$measurement_source_dir/fixtures/v2/cases/closed-single-stage-exact-coverage.json" > "$measurement_fixture"
measurement_actual_root="$measurement_root/actual"
"$measurement_bin" v2-compile --source "$measurement_source_actual" --out "$measurement_actual_root/compile"
"$measurement_bin" v2-collect --ir "$measurement_actual_root/compile/semantic-ir.json" --fixture "$measurement_fixture" --out "$measurement_actual_root/collection"
"$measurement_bin" v2-evaluate --ir "$measurement_actual_root/compile/semantic-ir.json" --collection "$measurement_actual_root/collection/collection.json" --out "$measurement_actual_root/evaluation.json"
"$measurement_bin" v2-report --evaluation "$measurement_actual_root/evaluation.json" --out "$measurement_actual_root/report.md"
jq -e '.schema=="gooo/measurement-boundary/evaluation/v2" and .decision=="CLOSED" and .closed_count==2 and .unknown_count==0 and .refuted_count==0 and .aggregate_policy=="FORBID_UNSCOPED_SCALAR" and all(.metrics[]; .state=="CLOSED" and .improvement.state=="UNKNOWN" and .improvement.reason=="BEFORE_AFTER_PAIR_NOT_EXACT") and all(.metrics[]; (.input_receipt_digest|startswith("sha256:")) and (.output_receipt_digest|startswith("sha256:")))' "$measurement_actual_root/evaluation.json" >/dev/null
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-measurement-boundary-receipt/v1" \
  --argjson release "$(jq -c '.releases.measurement_boundary_v2_projector_durable_release' "$repository/contracts/release-locks-v1.json")" \
  --argjson evaluation "$(cat "$measurement_actual_root/evaluation.json")" --argjson conformance "$(cat "$measurement_root/bundled-conformance/conformance-report.json")" \
  --arg input "$measurement_input_digest" --arg output "$measurement_output_digest" --argjson wall "$stage_wall_ms" --argjson rss "$stage_peak_rss" \
  '{schema:$schema,release:$release,actual_stage:{input_receipt_digest:$input,output_receipt_digest:$output,wall_ms:$wall,peak_rss_kib:$rss,work_units:2,state:"CLOSED",scope:"stage-boundary/process-tree",runtime_authority:{repository_writes:0,local_test_executions:0,cross_project_required_gates:0}},evaluation:$evaluation,bundled_conformance:$conformance,improvement:{state:"UNKNOWN",reason:"PAIR_NOT_EXACT_SINGLE_OBSERVATION",aggregate_policy:"FORBID_UNSCOPED_SCALAR"},external_utility:{state:"UNKNOWN",required_gate:false},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' \
  > "$measurement_root/measurement-boundary-v2-receipt.json"

echo "v0.51 products: run operational-provenance-projector v0.1.2"
operational_key=operational_provenance_projector_durable_release
operational_evidence="$artifact_root/releases/$operational_key/assets/gooo-operational-provenance-projector-evidence.tar.gz"
operational_audit="$artifact_root/releases/$operational_key/assets/release-audit.json"
test -s "$operational_evidence" -a -s "$operational_audit"
operational_source_archive="$temp_root/operational-source.tar.gz"
gh api "repos/kimjooyoon/gooo-operational-provenance-projector/tarball/36126b2a4b177d2b6f44713ffbf6908eb490af4b" > "$operational_source_archive"
test "$(wc -c < "$operational_source_archive" | tr -d ' ')" = 26303
test "$(sha256sum "$operational_source_archive" | awk '{print $1}')" = a082d9ead0a9b7d80abb889de6a42a09a85dca2926b15cf4eb716897a3a47ced
operational_source_root="$temp_root/operational-source"
mkdir -p "$operational_source_root"
tar --no-xattrs -xzf "$operational_source_archive" -C "$operational_source_root"
operational_source_dir=$(find "$operational_source_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$operational_source_dir"
operational_bin="$temp_root/gooo-operational-provenance-projector"
(cd "$operational_source_dir" && go build -trimpath -o "$operational_bin" ./cmd/gooo-operational-provenance-projector)
operational_upstream="$temp_root/operational-upstream"
mkdir -p "$operational_upstream"
tar --no-xattrs -xzf "$operational_evidence" -C "$operational_upstream"
operational_upstream_report=$(find "$operational_upstream" -type f -name report.json -print -quit)
test -s "$operational_upstream_report"
jq -e '.schema=="gooo/operational-provenance-projector/report/v1" and .decision=="CLOSED" and .summary=={closed:4,unknown:4,refuted:4} and .metrics=={denominator:12,states:{closed:4,unknown:4,refuted:4},event_count:12,receipt_count:12,repository_writes:0,local_test_executions:0,cross_project_required_gates:0} and .operator_api_attempts==null and .operator_api_attempts_state=="UNKNOWN" and .operational_audit.state=="OPERATIONAL_REFUTED" and .operational_audit.exact_count==5 and .operational_audit.executed_by_current_runtime==false' "$operational_upstream_report" >/dev/null
jq -e '.schema=="gooo/operational-provenance-projector/release-audit/v1" and .summary=={closed:4,unknown:4,refuted:4} and .authority.repository_writes==0 and .authority.runtime.source_repository_writes==0 and .authority.operator.operator_api_attempts==null and .authority.operator.operator_api_attempts_state=="UNKNOWN" and .operational_audit.preserved_existing_refuted==true' "$operational_audit" >/dev/null

operational_input_root="$operational_root/input"
mkdir -p "$operational_input_root"
jq -S -n --arg report_digest "$(sha256_prefixed "$artifact_root/report.json")" --arg verification_digest "$(sha256_prefixed "$artifact_root/releases/verification.json")" \
  '{schema:"gooo/self-improvement-ledger/v0510-ci-runtime-receipt/v1",source:"portfolio.yml",report_digest:$report_digest,verification_digest:$verification_digest,authority:"GITHUB_ACTIONS",repository_writes:0,local_validation_events:0,local_test_executions:0,cross_project_required_gates:0}' \
  > "$operational_input_root/ci-runtime-receipt.json"
jq -S -n '{schema:"gooo/self-improvement-ledger/v0510-operator-authoring-receipt/v1",operator_api_attempts:null,operator_api_attempts_state:"UNKNOWN",authoring_events:1,validation_events:0,authority:"OPERATOR_EXPLICIT",repository_writes:0}' > "$operational_input_root/operator-authoring-receipt.json"
jq -S -n '{schema:"gooo/self-improvement-ledger/v0510-orchestrator-local-receipt/v1",local_authoring_events:1,local_validation_events:0,repository_writes:0,authority:"AUTHORING_ONLY"}' > "$operational_input_root/orchestrator-local-receipt.json"
ci_receipt_digest=$(sha256_prefixed "$operational_input_root/ci-runtime-receipt.json")
operator_receipt_digest=$(sha256_prefixed "$operational_input_root/operator-authoring-receipt.json")
local_receipt_digest=$(sha256_prefixed "$operational_input_root/orchestrator-local-receipt.json")
operational_fixture="$temp_root/operational-fixture.json"
jq -S --arg ci "$ci_receipt_digest" --arg operator "$operator_receipt_digest" --arg local "$local_receipt_digest" \
  '.cases[0].observation += ";ci_receipt="+$ci | .cases[1].observation += ";operator_receipt="+$operator | .cases[2].observation += ";local_authoring_receipt="+$local | .cases[3].observation += ";ci_receipt="+$ci' \
  "$operational_source_dir/fixtures/canonical-v1.json" > "$operational_fixture"
operational_project="$operational_root/project"
operational_conformance="$operational_root/conformance"
"$operational_bin" project --source "$operational_source_dir/.gooo/operational-provenance-projector.gooo" --contract "$operational_source_dir/contracts/denominator-v1.json" --fixture "$operational_fixture" --history "$operational_source_dir/fixtures/v0.49-static-validation-history.json" --root "$operational_source_dir" --output "$operational_project"
"$operational_bin" conformance --source "$operational_source_dir/.gooo/operational-provenance-projector.gooo" --contract "$operational_source_dir/contracts/denominator-v1.json" --fixture "$operational_fixture" --history "$operational_source_dir/fixtures/v0.49-static-validation-history.json" --root "$operational_source_dir" --output "$operational_conformance"
"$operational_bin" verify --report "$operational_project/report.json" > "$operational_root/verify-output.json"
jq -e '.schema=="gooo/operational-provenance-projector/report/v1" and .decision=="CLOSED" and .summary=={closed:4,unknown:4,refuted:4} and .metrics.repository_writes==0 and .metrics.local_test_executions==0 and .metrics.cross_project_required_gates==0 and .operator_api_attempts==null and .operator_api_attempts_state=="UNKNOWN" and .operational_audit.state=="OPERATIONAL_REFUTED" and .operational_audit.exact_count==5 and .operational_audit.executed_by_current_runtime==false and .replay.deterministic==true and .utility.status=="UNKNOWN"' "$operational_project/report.json" >/dev/null
jq -e '.schema=="gooo/operational-provenance-projector/report/v1" and .decision=="CLOSED" and .summary=={closed:4,unknown:4,refuted:4} and .replay.deterministic==true' "$operational_conformance/report.json" >/dev/null
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-operational-provenance-receipt/v1" \
  --argjson release "$(jq -c '.releases.operational_provenance_projector_durable_release' "$repository/contracts/release-locks-v1.json")" \
  --argjson report "$(cat "$operational_project/report.json")" --argjson conformance "$(cat "$operational_conformance/report.json")" \
  --arg ci "$ci_receipt_digest" --arg operator "$operator_receipt_digest" --arg local "$local_receipt_digest" \
  '{schema:$schema,release:$release,actual_receipts:{ci_runtime:$ci,operator_authoring:$operator,orchestrator_local:$local},project_report:$report,conformance_report:$conformance,operator_api_attempts:null,operator_api_attempts_state:"UNKNOWN",external_utility:{state:"UNKNOWN",required_gate:false},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' \
  > "$operational_root/operational-provenance-receipt.json"

echo "v0.51 products: run frontier-projector v0.2.0 against v0.50 parent and v0.51 candidate"
frontier_key=self_improvement_frontier_projector_durable_release
frontier_evidence="$artifact_root/releases/$frontier_key/assets/frontier-projector-evidence.tar.gz"
frontier_source_archive="$artifact_root/releases/$frontier_key/assets/frontier-projector-source.tar.gz"
frontier_manifest="$artifact_root/releases/$frontier_key/assets/release-manifest-v0.2.0.json"
test -s "$frontier_evidence" -a -s "$frontier_source_archive" -a -s "$frontier_manifest"
frontier_source_root="$temp_root/frontier-source"
mkdir -p "$frontier_source_root"
tar --no-xattrs -xzf "$frontier_source_archive" -C "$frontier_source_root"
frontier_source_dir=$(find "$frontier_source_root" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$frontier_source_dir"
frontier_bin="$temp_root/gooo-frontier"
(cd "$frontier_source_dir" && go build -trimpath -o "$frontier_bin" ./cmd/gooo-frontier)
frontier_upstream="$temp_root/frontier-upstream"
mkdir -p "$frontier_upstream"
tar --no-xattrs -xzf "$frontier_evidence" -C "$frontier_upstream"
"$frontier_bin" conformance --source "$frontier_source_dir/.gooo" --contract "$frontier_source_dir/contracts/frontier-denominator-v1.json" --fixtures "$frontier_source_dir/fixtures/cases" --output "$frontier_upstream/conformance-run"
jq -e '.schema=="gooo/self-improvement-frontier/conformance-report/v1" and .total==12 and .actual_counts=={CLOSED:4,UNKNOWN:4,REFUTED:4} and .all_expected_match==true and .replay_exact==true and .no_scores_or_percentages==true and .authority.runtime_authority=={repository_writes:0,source_mutations:0,commit:0,merge:0,release:0,local_test_executions:0,cross_project_required_gates:0,acceptance_required_gate:0}' "$frontier_upstream/conformance-run/conformance-report.json" >/dev/null
frontier_ops="$temp_root/frontier-operational-events.json"
jq -S '[.operational_events[] | select(.state=="OPERATIONAL_REFUTED")]' "$frontier_source_dir/fixtures/inputs/immutable-ledger-v0490.json" > "$frontier_ops"
frontier_parent_input="$temp_root/immutable-ledger-v0500.json"
jq -S --slurpfile report "$artifact_root/v050-parent-report.json" --slurpfile ops "$frontier_ops" '
  def tuple: {stage:(.stage//""),step:(.step//""),reason:(.reason//""),unknown_class:(.unknown_class//""),next_operation:(.next_operation//""),blocked_by:(.blocked_by//[])};
  ($report[0].cells | map({ordinal,id,axis,proof,indicator,activity,state,numerator,denominator} + (if .state=="UNKNOWN" then {unknown:(.unknown|tuple)} elif .state=="REFUTED" then {refutation:(.refutation|tuple)} else {} end))) as $cells |
  ($ops[0] + [{id:"operational:v050-parent-cache-reuse",state:"CLOSED",historical:false,stage:"v050-parent-artifact-preflight",step:"parent-release-reuse",reason:"",unknown_class:"",next_operation:"",blocked_by:[],source:"v0510-parent-lock-receipt.json#primary"}]) as $events |
  {schema:"gooo/self-improvement-frontier/immutable-ledger-input/v1",ledger_version:"gooo/self-improvement-portfolio/report/v1",tag:{name:"v0.50.0",object_sha:"9e3263ea902bef64fa31c05ca7c1ab038ef962ef",target_commit_sha:"e93768f4204e8a88214026ffa22febad7ecedcbd"},release:{repository:"kimjooyoon/gooo-self-improvement-ledger",release_id:380866481,tag:"v0.50.0",immutable:true,tag_object_sha:"9e3263ea902bef64fa31c05ca7c1ab038ef962ef",target_commit_sha:"e93768f4204e8a88214026ffa22febad7ecedcbd",assets:[{id:540246273,name:"gooo-self-improvement-ledger-e93768f4204e8a88214026ffa22febad7ecedcbd",size_bytes:55178070,digest:"sha256:80575837d8ebb8d838bab912ff7802946fb37b2d90d923e8a9cec27bdf543e25"}]},released_asset:{id:540246273,name:"gooo-self-improvement-ledger-e93768f4204e8a88214026ffa22febad7ecedcbd",size_bytes:55178070,digest:"sha256:80575837d8ebb8d838bab912ff7802946fb37b2d90d923e8a9cec27bdf543e25",entry_path:"report.json"},profile:{schema:"gooo/self-improvement-portfolio/report/v1",profile_id:"self-improvement-portfolio-v1",assessment_id:"self-improvement-portfolio-v1-current-frontier",subject_sha:"e93768f4204e8a88214026ffa22febad7ecedcbd",decision:"REPORT_ONLY",precedence:["REFUTED","UNKNOWN","CLOSED"],summary:{total:64,closed:61,unknown:1,refuted:2}},cells:$cells,operational_events:$events}' \
  "$frontier_parent_input"
"$frontier_bin" project --source "$frontier_source_dir/.gooo" --contract "$frontier_source_dir/contracts/frontier-denominator-v1.json" --input "$frontier_parent_input" --output "$frontier_parent_root/project"
jq -e '.schema=="gooo/self-improvement-frontier/receipt/v1" and .decision=="CLOSED" and .input_status=="UNKNOWN" and .historical_refutation_count==7 and .operational_refuted_count==5 and .replay_exact==true and .authority.runtime_authority=={repository_writes:0,source_mutations:0,commit:0,merge:0,release:0,local_test_executions:0,cross_project_required_gates:0,acceptance_required_gate:0}' "$frontier_parent_root/project/receipt.json" >/dev/null
jq -e '.decision=="CLOSED" and ([.frontier[].activity_id]==["EXTERNAL_UTILITY_EVIDENCE"]) and (.frontier|length)==1 and (.blocked|length)==0' "$frontier_parent_root/project/canonical-frontier.json" >/dev/null
cp "$frontier_parent_input" "$frontier_parent_root/immutable-ledger-v0500.json"

frontier_candidate_input="$temp_root/candidate-ledger-v0510.json"
jq -S --argjson report "$(cat "$artifact_root/report.json")" --argjson ops "$(cat "$frontier_ops")" '
  def tuple: {stage:(.stage//""),step:(.step//""),reason:(.reason//""),unknown_class:(.unknown_class//""),next_operation:(.next_operation//""),blocked_by:(.blocked_by//[])};
  ($report.cells | map({ordinal,id,axis,proof,indicator,activity,state,numerator,denominator} + (if .state=="UNKNOWN" then {unknown:(.unknown|tuple)} elif .state=="REFUTED" then {refutation:(.refutation|tuple)} else {} end))) as $cells |
  {schema:"gooo/self-improvement-frontier/input/v1",source:{kind:"candidate-ledger",release:"v0.51.0-candidate",immutable:true,acceptance_required_gate:0,external_utility_state:"UNKNOWN"},immutable_history:true,graph_bounded:true,claims:($cells|map({id:"claim:"+.id,activity_id:.id,state:.state,historical:(.state=="REFUTED"),immutable:true})),activities:($cells|map({id:.id,claim_id:"claim:"+.id,state:.state,actionable:(.state=="UNKNOWN"),historical:(.state=="REFUTED"),blocked_by:[],evidence:(if .state=="CLOSED" then {complete:true} else null end),unknown:(if .state=="UNKNOWN" then .unknown else null end)})),edges:[],history:([$cells[]|select(.state=="REFUTED")|{id:"history:cell:"+.id,activity_id:.id,state:"REFUTED",historical:true,immutable:true,mutation:"APPEND"}] + [$ops[]|{id:"history:operational:"+.id,activity_id:.id,state:"REFUTED",historical:true,immutable:true,mutation:"APPEND"}]),operational_events:$ops}' \
  > "$frontier_candidate_input"
"$frontier_bin" project --source "$frontier_source_dir/.gooo" --contract "$frontier_source_dir/contracts/frontier-denominator-v1.json" --input "$frontier_candidate_input" --output "$frontier_candidate_root/project"
jq -e '.schema=="gooo/self-improvement-frontier/receipt/v1" and .decision=="CLOSED" and .input_status=="UNKNOWN" and .historical_refutation_count==7 and .operational_refuted_count==5 and .replay_exact==true and .authority.runtime_authority=={repository_writes:0,source_mutations:0,commit:0,merge:0,release:0,local_test_executions:0,cross_project_required_gates:0,acceptance_required_gate:0}' "$frontier_candidate_root/project/receipt.json" >/dev/null
jq -e '.decision=="CLOSED" and ([.frontier[].activity_id]==["EXTERNAL_UTILITY_EVIDENCE"]) and (.frontier|length)==1 and (.blocked|length)==0 and (.subject.source_release=="v0.51.0-candidate")' "$frontier_candidate_root/project/canonical-frontier.json" >/dev/null
if jq -e '.frontier[]? | select(.activity_id=="operational:v050-parent-cache-reuse")' "$frontier_candidate_root/project/canonical-frontier.json" >/dev/null 2>&1; then
  echo "v0.51 candidate incorrectly retained parent cache as an actionable frontier item" >&2
  exit 1
fi
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-frontier-receipt/v1" \
  --argjson release "$(jq -c '.releases.self_improvement_frontier_projector_durable_release' "$repository/contracts/release-locks-v1.json")" \
  --argjson parent "$(cat "$frontier_parent_root/project/receipt.json")" --argjson candidate "$(cat "$frontier_candidate_root/project/receipt.json")" \
  --argjson parent_frontier "$(cat "$frontier_parent_root/project/canonical-frontier.json")" --argjson candidate_frontier "$(cat "$frontier_candidate_root/project/canonical-frontier.json")" \
  '{schema:$schema,release:$release,v050_parent:{immutable:true,release_id:380866481,tag:"v0.50.0",tag_object_sha:"9e3263ea902bef64fa31c05ca7c1ab038ef962ef",target_commit_sha:"e93768f4204e8a88214026ffa22febad7ecedcbd",project_receipt:$parent,frontier:$parent_frontier},v051_candidate:{source_release:"v0.51.0-candidate",immutable:true,project_receipt:$candidate,frontier:$candidate_frontier,parent_cache_present:false,historical_refutations_excluded:true},decision:{state:"CLOSED",frontier_only:"EXTERNAL_UTILITY_EVIDENCE",external_utility_state:"UNKNOWN",acceptance_required_gate:0},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' \
  > "$products/frontier-projector-receipt.json"

echo "v0.51 products: record candidate-only packaging pair"
packaging_baseline="$temp_root/packaging-baseline"
packaging_candidate="$temp_root/packaging-candidate"
baseline_archive="$temp_root/v051-baseline-inputs.tar.gz"
candidate_archive="$temp_root/v051-candidate-products.tar.gz"
baseline_time="$temp_root/v051-baseline-time"
candidate_time="$temp_root/v051-candidate-time"
rm -rf "$packaging_baseline" "$packaging_candidate"
mkdir -p "$packaging_baseline" "$packaging_candidate"
cp "$repository/contracts/self-improvement-portfolio-v1.json" "$packaging_baseline/profile-contract.json"
cp "$repository/contracts/release-locks-v1.json" "$packaging_baseline/release-locks.json"
cp "$repository/evidence/assessment-v1.json" "$packaging_baseline/assessment.json"
cp "$repository/examples/self-improvement-portfolio/main.gooo" "$packaging_baseline/portfolio.gooo"
cp "$repository/evidence/atomic-v0510-wave-v1.json" "$packaging_baseline/atomic-v0510-wave.json"
cp "$artifact_root/v0510-parent-lock-receipt.json" "$packaging_baseline/v0510-parent-lock-receipt.json"
cp "$artifact_root/v0510-live-lock-receipt.json" "$packaging_baseline/v0510-live-lock-receipt.json"
cp "$artifact_root/v050-parent-report.json" "$packaging_baseline/v050-parent-report.json"
cp "$artifact_root/report.json" "$packaging_baseline/report.json"
cp "$artifact_root/conformance.json" "$packaging_baseline/conformance.json"
cp "$artifact_root/releases/verification.json" "$packaging_baseline/releases-verification.json"
packaging_input_manifest="$temp_root/packaging-input-manifest.json"
find "$packaging_baseline" -type f -print | LC_ALL=C sort | while read -r path; do
  relative=${path#"$packaging_baseline/"}
  jq -S -n --arg path "$relative" --arg bytes "$(wc -c < "$path" | tr -d ' ')" --arg digest "$(sha256_prefixed "$path")" '{path:$path,bytes:($bytes|tonumber),digest:$digest}'
done | jq -S -s '{schema:"gooo/self-improvement-ledger/v0510-packaging-input-manifest/v1",files:sort_by(.path)}' > "$packaging_input_manifest"
packaging_input_digest=$(sha256_prefixed "$packaging_input_manifest")
cp "$packaging_input_manifest" "$packaging_baseline/packaging-input-manifest.json"
cp -a "$products/." "$packaging_candidate/"
baseline_files=$(file_count "$packaging_baseline")
baseline_bytes=$(file_bytes "$packaging_baseline")
/usr/bin/time -f '%e %M' -o "$baseline_time" tar --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -czf "$baseline_archive" -C "$packaging_baseline" .
candidate_files=$(file_count "$packaging_candidate")
candidate_bytes=$(file_bytes "$packaging_candidate")
/usr/bin/time -f '%e %M' -o "$candidate_time" tar --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -czf "$candidate_archive" -C "$packaging_candidate" .
baseline_wall_ms=$(awk '{printf "%d", $1*1000}' "$baseline_time")
baseline_peak_rss_kib=$(awk '{print $2+0}' "$baseline_time")
candidate_wall_ms=$(awk '{printf "%d", $1*1000}' "$candidate_time")
candidate_peak_rss_kib=$(awk '{print $2+0}' "$candidate_time")
packaging_contract_digest=$(sha256_prefixed "$repository/contracts/self-improvement-portfolio-v1.json")
packaging_fixture_digest=$(sha256_prefixed "$repository/evidence/atomic-v0510-wave-v1.json")
packaging_job="${GITHUB_RUN_ID:-unknown}/${GITHUB_JOB:-v0510-products}"
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-packaging-receipt/v1" \
  --arg input "$packaging_input_digest" --arg contract "$packaging_contract_digest" --arg fixture "$packaging_fixture_digest" --arg job "$packaging_job" \
  --argjson baseline_bytes "$baseline_bytes" --argjson baseline_files "$baseline_files" --argjson baseline_wall "$baseline_wall_ms" --argjson baseline_rss "$baseline_peak_rss_kib" \
  --argjson candidate_bytes "$candidate_bytes" --argjson candidate_files "$candidate_files" --argjson candidate_wall "$candidate_wall_ms" --argjson candidate_rss "$candidate_peak_rss_kib" \
  '{schema:$schema,candidate_only:true,baseline_published:false,scenario:"v0510-evidence-inputs",input_digest:$input,contract_digest:$contract,fixture_digest:$fixture,toolchain:"go1.27.0",runner:"github-actions/ubuntu-latest",job:$job,indicators:["bytes","files","wall_ms","peak_rss_kib"],baseline:{bytes:$baseline_bytes,files:$baseline_files,wall_ms:$baseline_wall,peak_rss_kib:$baseline_rss},candidate:{bytes:$candidate_bytes,files:$candidate_files,wall_ms:$candidate_wall,peak_rss_kib:$candidate_rss},rss_delta_kib:($candidate_rss-$baseline_rss),improvement:{state:"UNKNOWN",reason:"NO_EXACT_SAME_SCENARIO_RELEASED_BEFORE_AFTER_PAIR"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' \
  > "$products/packaging-receipt.json"
measurement_release=$(jq -c '.releases.measurement_boundary_v2_projector_durable_release' "$repository/contracts/release-locks-v1.json")
operational_release=$(jq -c '.releases.operational_provenance_projector_durable_release' "$repository/contracts/release-locks-v1.json")
frontier_release=$(jq -c '.releases.self_improvement_frontier_projector_durable_release' "$repository/contracts/release-locks-v1.json")
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-product-integration/v1" \
  --argjson measurement "$measurement_release" --argjson operational "$operational_release" --argjson frontier "$frontier_release" \
  --argjson measurement_receipt "$(cat "$measurement_root/measurement-boundary-v2-receipt.json")" --argjson operational_receipt "$(cat "$operational_root/operational-provenance-receipt.json")" --argjson frontier_receipt "$(cat "$products/frontier-projector-receipt.json")" --argjson packaging "$(cat "$products/packaging-receipt.json")" \
  '{schema:$schema,products:{measurement_boundary_v2_projector:$measurement,operational_provenance_projector:$operational,self_improvement_frontier_projector:$frontier},receipts:{measurement_boundary_v2:$measurement_receipt,operational_provenance:$operational_receipt,self_improvement_frontier:$frontier_receipt,packaging:$packaging},external_utility:{state:"UNKNOWN",independent_user_evidence:false,required_gate:false},claims:{aggregate_score:false,aggregate_percentage:false,whole_language_improvement:"UNKNOWN",candidate_release_immutable:false},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}}' \
  > "$products/product-integration.json"
jq -e '.schema=="gooo/self-improvement-ledger/v0510-product-integration/v1" and .products.measurement_boundary_v2_projector.release_id==380839207 and .products.measurement_boundary_v2_projector.tag=="v0.2.0" and .products.operational_provenance_projector.release_id==380835618 and .products.operational_provenance_projector.tag=="v0.1.2" and .products.self_improvement_frontier_projector.release_id==380832128 and .products.self_improvement_frontier_projector.tag=="v0.2.0" and .receipts.measurement_boundary_v2.improvement.state=="UNKNOWN" and .receipts.operational_provenance.project_report.summary=={closed:4,unknown:4,refuted:4} and .receipts.self_improvement_frontier.v050_parent.immutable==true and .receipts.self_improvement_frontier.v051_candidate.source_release=="v0.51.0-candidate" and .receipts.packaging.candidate_only==true and .receipts.packaging.baseline_published==false and (.receipts.packaging.rss_delta_kib|type)=="number" and .external_utility.state=="UNKNOWN" and .claims.aggregate_score==false and .claims.aggregate_percentage==false and .claims.whole_language_improvement=="UNKNOWN" and .claims.candidate_release_immutable==false and .authority=={verification:"GITHUB_ACTIONS",repository_writes:0,local_test_executions:0,cross_project_required_gates:0}' "$products/product-integration.json" >/dev/null
echo "v0.51 product integration passed: measurement=2/2 CLOSED, operational=4/4/4 CLOSED/UNKNOWN/REFUTED, frontier=v0.50 parent plus v0.51 candidate, packaging=candidate-only"
