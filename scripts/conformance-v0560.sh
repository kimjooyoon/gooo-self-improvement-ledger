#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.56 conformance failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 3 ]; then
  echo "usage: conformance-v0560.sh REPORT_BINARY REPOSITORY_ROOT ARTIFACT_ROOT" >&2
  exit 64
fi

binary=$(realpath "$1")
repository=$(realpath "$2")
artifact=$(realpath "$3")
command -v jq >/dev/null
test -x "$binary"
test -s "$repository/contracts/self-improvement-portfolio-v1.json"
test -s "$repository/evidence/assessment-v1.json"
test -s "$repository/examples/self-improvement-portfolio/main.gooo"
test -s "$artifact/releases/verification.json"
test -s "$artifact/runtime.json"

bash "$repository/scripts/verify-v0560-release-input.sh" --repository "$repository"

"$binary" \
  -profile "$repository/contracts/self-improvement-portfolio-v1.json" \
  -activities "$repository/examples/self-improvement-portfolio/main.gooo" \
  -assessment "$repository/evidence/assessment-v1.json" \
  -verification "$artifact/releases/verification.json" \
  -runtime "$artifact/runtime.json" \
  -repository-root "$repository" \
  -artifact-root "$artifact" \
  -output-json "$artifact/report.json" \
  -output-markdown "$artifact/report.md"

jq -e '.summary=={total:88,closed:83,unknown:1,refuted:4} and .proof_counts=={COHERENCE:{closed:75,denominator:75,refuted:0,unknown:0},FOUNDATION:{closed:4,denominator:5,refuted:1,unknown:0},REGRESSION:{closed:4,denominator:8,refuted:3,unknown:1}} and .indicator_counts=={DRIVER:{closed:4,denominator:5,refuted:1,unknown:0},GUARDRAIL:{closed:4,denominator:8,refuted:3,unknown:1},OUTCOME:{closed:75,denominator:75,refuted:0,unknown:0}} and .bindings.one_to_one==true and .bindings.cells==88 and .bindings.activities==88 and .bindings.unique_axes==88 and .bindings.unique_metrics==88 and .bindings.source_bindings==88 and .bindings.ir_bindings==88 and .bindings.generated_artifact_bindings==88 and .bindings.evaluator_bindings==88 and .releases=={total:77,verified:77,unknown:0,refuted:0} and .precedence==["REFUTED","UNKNOWN","CLOSED"] and .policy.aggregate_percentage==false and .policy.aggregate_score==false and .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0 and .local_execution_counts=={gofmt:0,build:0,test:0,vet:0,conformance:0} and (has("percentage")|not) and (has("score")|not)' "$artifact/report.json" >/dev/null

jq -S -n --arg subject "${SUBJECT_SHA:-unknown}" \
  --slurpfile report "$artifact/report.json" \
  --slurpfile verification "$artifact/releases/verification.json" \
  --slurpfile wave "$artifact/atomic-v0560-wave-v1.json" \
  --slurpfile products "$artifact/v0560-products/product-integration.json" \
  --slurpfile guard "$artifact/v0560-products/release-lineage-guard-plan-assertions.json" \
  '{schema:"gooo-self-improvement-portfolio/conformance/v1",subject_sha:$subject,decision:"CLOSED",summary:$report[0].summary,checks:{profile_state:true,proof_indicator_totals:true,one_to_one_bindings:true,parent_receipt_reuse:($verification[0].release_lock_snapshot.parent_reuse.reused==72),changed_lock_wave:($verification[0].release_lock_snapshot.changed_live.selected==5 and $verification[0].release_lock_snapshot.changed_live.executed==5),semantic_wave:(($wave[0].semantic_wave.accepted_wave_order|length)==7),product_integration:(($products[0].products|length)==7),lineage_guard:($guard[0].policy_conformance.pass==true)},repository_writes:0,authority:{verification:"GITHUB_ACTIONS_ONLY",local_validation_commands:0,cross_project_required_gates:0},preservation:{external_utility:"UNKNOWN",whole_language_improvement:"UNKNOWN",improvement_aggregation:"NOT_CLAIMED",exact_before_after_pair:"UNKNOWN"}}' > "$artifact/conformance.json"

jq -e '.schema=="gooo/self-improvement-portfolio/conformance/v1" and .decision=="CLOSED" and .summary=={closed:83,refuted:4,total:88,unknown:1} and all(.checks[];.==true) and .repository_writes==0 and .authority=={cross_project_required_gates:0,local_validation_commands:0,verification:"GITHUB_ACTIONS_ONLY"} and (has("percentage")|not) and (has("score")|not)' "$artifact/conformance.json" >/dev/null
echo "v0.56 conformance passed: 88 total / 83 CLOSED / 1 UNKNOWN / 4 REFUTED; parent 72 reused and five changed locks executed"
