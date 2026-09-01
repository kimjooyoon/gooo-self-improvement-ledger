#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -ne 2 ]; then
  echo "usage: verify-semantic-denominator-projector.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
projector_root="$artifact_root/semantic-denominator-projector"
assets_root="$projector_root/release-assets"
mkdir -p "$assets_root" "$projector_root/upstream-main" "$projector_root/upstream-verification"

upstream_repository="kimjooyoon/gooo-semantic-denominator-projector"
tag="v0.1.0"
release_id=380501283
tag_object="bde8a7e98e2e4572e438eb6b4c7da4aebd388f16"
target_commit="60ef02caae58811c1e716b3356af121f09cc605d"
contract_digest="sha256:d55994e252915558beaca61666e77946f10e61fb294cee6d7e29e4ce5b3d275c"

projector_asset_id=539559482
projector_asset_name="semantic-denominator-projector.gooo"
projector_asset_size=7535
projector_asset_digest="$contract_digest"
denominator_asset_id=539559498
denominator_asset_name="semantic-denominator.json"
denominator_asset_size=121854
denominator_asset_digest="sha256:71d2570193d382840f1f8056365a83ac6ff609157d8c4b639abeca7cebe78714"
assertions_asset_id=539559406
assertions_asset_name="generated-assertions.json"
assertions_asset_size=7395
assertions_asset_digest="sha256:c72b4d7c72da7fa12364bb158b0ce66ce0bbe1b2e287df3d1de280be6d74f128"

source_run_id=33511085673
source_job_id=99866617691
source_artifact_id=9801649738
source_artifact_name="gooo-semantic-denominator-projector-evidence-60ef02caae58811c1e716b3356af121f09cc605d"
source_artifact_size=14625
source_artifact_digest="sha256:3b552c1cf5ca8d90e6c72b8a0260804e4c5e82be27396024301c0b4975c4e2a3"
verification_run_id=33511709706
verification_job_id=99868732834
verification_artifact_id=9801892833
verification_artifact_name="gooo-semantic-denominator-projector-release-verification-33511709706"
verification_artifact_size=1002
verification_artifact_digest="sha256:b2b14ed0ca1e967648647c314434244becf5e41641466fe07716e17400996df7"

release_json="$projector_root/release.json"
gh api "repos/$upstream_repository/releases/tags/$tag" > "$release_json"
jq -e --arg tag "$tag" --arg url "https://github.com/$upstream_repository/releases/tag/$tag" --argjson release_id "$release_id" \
  --arg projector_name "$projector_asset_name" --arg projector_digest "$projector_asset_digest" \
  --arg denominator_name "$denominator_asset_name" --arg denominator_digest "$denominator_asset_digest" \
  --arg assertions_name "$assertions_asset_name" --arg assertions_digest "$assertions_asset_digest" \
  '.id==$release_id and .tag_name==$tag and .html_url==$url and .draft==false and .prerelease==false and .immutable==true and
   ([.assets[] | select(.id==539559482 and .name==$projector_name and .size==7535 and .digest==$projector_digest)]|length)==1 and
   ([.assets[] | select(.id==539559498 and .name==$denominator_name and .size==121854 and .digest==$denominator_digest)]|length)==1 and
   ([.assets[] | select(.id==539559406 and .name==$assertions_name and .size==7395 and .digest==$assertions_digest)]|length)==1' "$release_json" >/dev/null

public_refs=$(git ls-remote "https://github.com/$upstream_repository.git" "refs/tags/$tag" "refs/tags/$tag^{}")
test "$(awk -v ref="refs/tags/$tag" '$2==ref {print $1}' <<< "$public_refs")" = "$tag_object"
test "$(awk -v ref="refs/tags/$tag^{}" '$2==ref {print $1}' <<< "$public_refs")" = "$target_commit"
tag_ref=$(gh api "repos/$upstream_repository/git/ref/tags/$tag")
jq -e --arg object "$tag_object" '.object.sha==$object and .object.type=="tag"' <<< "$tag_ref" >/dev/null
tag_json=$(gh api "repos/$upstream_repository/git/tags/$tag_object")
jq -e --arg commit "$target_commit" '.object.sha==$commit and .object.type=="commit"' <<< "$tag_json" >/dev/null

download_release_asset() {
  local id=$1 name=$2 size=$3 digest=$4
  local url path
  url=$(jq -r --arg name "$name" '.assets[] | select(.name==$name) | .browser_download_url' "$release_json")
  path="$assets_root/$name"
  curl --fail --location --retry 3 --retry-delay 1 -H "Authorization: Bearer $GH_TOKEN" -H 'Accept: application/octet-stream' "$url" -o "$path"
  test "$(wc -c < "$path" | tr -d ' ')" = "$size"
  test "sha256:$(sha256sum "$path" | awk '{print $1}')" = "$digest"
  asset_json=$(gh api "repos/$upstream_repository/releases/assets/$id")
  jq -e --argjson id "$id" --arg name "$name" --argjson size "$size" --arg digest "$digest" \
    '.id==$id and .name==$name and .size==$size and .digest==$digest and .state=="uploaded"' <<< "$asset_json" >/dev/null
}

download_release_asset "$projector_asset_id" "$projector_asset_name" "$projector_asset_size" "$projector_asset_digest"
download_release_asset "$denominator_asset_id" "$denominator_asset_name" "$denominator_asset_size" "$denominator_asset_digest"
download_release_asset "$assertions_asset_id" "$assertions_asset_name" "$assertions_asset_size" "$assertions_asset_digest"

fetch_artifact() {
  local id=$1 name=$2 run_id=$3 size=$4 digest=$5 destination=$6
  local metadata="$destination.metadata.json" zip="$destination.zip"
  gh api "repos/$upstream_repository/actions/artifacts/$id" > "$metadata"
  jq -e --argjson id "$id" --arg name "$name" --argjson run_id "$run_id" --argjson size "$size" --arg digest "$digest" \
    '.id==$id and .name==$name and .workflow_run.id==$run_id and .size_in_bytes==$size and .digest==$digest and .expired==false' "$metadata" >/dev/null
  gh api "repos/$upstream_repository/actions/artifacts/$id/zip" > "$zip"
  test "$(wc -c < "$zip" | tr -d ' ')" = "$size"
  test "sha256:$(sha256sum "$zip" | awk '{print $1}')" = "$digest"
  unzip -q "$zip" -d "$destination"
}

fetch_artifact "$source_artifact_id" "$source_artifact_name" "$source_run_id" "$source_artifact_size" "$source_artifact_digest" "$projector_root/upstream-main"
fetch_artifact "$verification_artifact_id" "$verification_artifact_name" "$verification_run_id" "$verification_artifact_size" "$verification_artifact_digest" "$projector_root/upstream-verification"

source_run_json=$(gh api "repos/$upstream_repository/actions/runs/$source_run_id")
jq -e --argjson id "$source_run_id" --arg sha "$target_commit" \
  '.id==$id and .event=="push" and .head_branch=="main" and .head_sha==$sha and .status=="completed" and .conclusion=="success"' <<< "$source_run_json" >/dev/null
source_job_json=$(gh api "repos/$upstream_repository/actions/jobs/$source_job_id")
jq -e --argjson id "$source_job_id" --argjson run_id "$source_run_id" --arg sha "$target_commit" \
  '.id==$id and .run_id==$run_id and .name=="Go 1.27 semantic conformance" and .head_sha==$sha and .status=="completed" and .conclusion=="success"' <<< "$source_job_json" >/dev/null
verification_run_json=$(gh api "repos/$upstream_repository/actions/runs/$verification_run_id")
jq -e --argjson id "$verification_run_id" \
  '.id==$id and .event=="workflow_dispatch" and .head_branch=="main" and .head_sha=="31dcbe3601714343fdd60067b2f232e6d903707d" and .status=="completed" and .conclusion=="success"' <<< "$verification_run_json" >/dev/null
verification_job_json=$(gh api "repos/$upstream_repository/actions/jobs/$verification_job_id")
jq -e --argjson id "$verification_job_id" --argjson run_id "$verification_run_id" \
  '.id==$id and .run_id==$run_id and .name=="verify" and .head_sha=="31dcbe3601714343fdd60067b2f232e6d903707d" and .status=="completed" and .conclusion=="success"' <<< "$verification_job_json" >/dev/null

projector_source="$assets_root/$projector_asset_name"
test "$(grep -c '^activity ordinal=' "$projector_source")" = 12
test "$(grep -c '^cell ordinal=' "$projector_source")" = 12
test "$(grep -c '^rule id=' "$projector_source")" = 9
test "$(grep -c '^case ordinal=' "$projector_source")" = 12
grep -q '^graph id=gooo://semantic-denominator-projector/graph/v1 release=v0.1.0 precedence=REFUTED,UNKNOWN,CLOSED external_required_gates=0 repository_writes=0$' "$projector_source"

ci_evidence=$(find "$projector_root/upstream-main" -name ci-evidence.json -type f -print -quit)
replay_receipt=$(find "$projector_root/upstream-main" -name replay-receipt.json -type f -print -quit)
test -n "$ci_evidence" -a -n "$replay_receipt"
jq -e --arg target "$target_commit" --arg digest "$contract_digest" \
  '.schema=="gooo/semantic-denominator-projector/ci-evidence/v1" and .subject_sha==$target and
   .source=={authority:"RELEASED_GOOO",path:".gooo/semantic-denominator-projector.gooo",sha256:$digest} and
   .contract=={authority:"RELEASED_GOOO",digest:$digest,external_required_gates:0} and
   .denominator.activities==12 and .denominator.artifacts==6 and .denominator.cells==12 and .denominator.scenarios==12 and
   .denominator.expected_states=={closed:4,refuted:4,total:12,unknown:4} and .denominator.states=={closed:4,refuted:4,total:12,unknown:4} and
   .tests=={total:12,selected:12,executed:12,reused:0,failed:0,unknown:0} and
   .authority.caller_owned_output==true and .authority.repository_writes==0 and .authority.commits==0 and .authority.merges==0 and .authority.pushes==0 and .authority.releases==0 and .authority.source_mutations==0 and .authority.cross_project_required_gates==0 and
   .operational_refuted.local_validation_commands==1 and .operational_refuted.known_failures==["local YAML syntax parser invoked once during workflow diagnosis"]' "$ci_evidence" >/dev/null
jq -e --arg digest "$contract_digest" \
  '.schema=="gooo/semantic-denominator-projector/replay-receipt/v1" and .source_digest==$digest and .match==true and .state=="CLOSED" and .reason=="ORDER_PERTURBED_REPLAY_MATCH" and .normal_digest==.order_perturbed_digest' "$replay_receipt" >/dev/null

profile_path="$repository/contracts/self-improvement-portfolio-v1.json"
activities_path="$repository/examples/self-improvement-portfolio/main.gooo"
assessment_path="$repository/evidence/assessment-v1.json"
verification_path="$artifact_root/releases/verification.json"
profile_digest="sha256:$(sha256sum "$profile_path" | awk '{print $1}')"
activities_digest="sha256:$(sha256sum "$activities_path" | awk '{print $1}')"
subject_sha=$(git -C "$repository" rev-parse HEAD)
activity_count=$(grep -c '^activity ' "$activities_path")
cell_count=$(jq -r '.total_cells' "$profile_path")
test "$activity_count" = "$cell_count"
while read -r activity; do
  grep -q "^activity $activity(" "$activities_path"
done < <(jq -r '.cells[].activity' "$profile_path")

jq -S -n --slurpfile profile "$profile_path" --slurpfile assessment "$assessment_path" --slurpfile verification "$verification_path" \
  --arg subject "$subject_sha" --arg profile_digest "$profile_digest" --arg activities_digest "$activities_digest" --arg contract "$contract_digest" \
  --arg source_path "examples/self-improvement-portfolio/main.gooo" \
  '($profile[0].cells | map(
     . as $p |
     ($assessment[0].cells[] | select(.cell_id==$p.id)) as $a |
     (if $p.release_key == null then null else ($verification[0].releases[$p.release_key].state // null) end) as $release_state |
     (if $release_state == "REFUTED" then "REFUTED" elif $release_state == "UNKNOWN" and $a.state == "CLOSED" then "UNKNOWN" else $a.state end) as $state |
     {ordinal:$p.ordinal,id:$p.id,axis:$p.axis,activity:$p.activity,proof:$p.proof,indicator:$p.indicator,state:$state,numerator:(if $state=="CLOSED" then 1 else 0 end),denominator:$p.metric_denominator,source:$p.source,ir:$p.ir,generated_artifact:$p.generated_artifact,evaluator:$p.evaluator,metric_id:$p.metric_id,release_key:$p.release_key,depends_on:$p.depends_on,evidence:($a.evidence // []),unknown:($a.unknown // null),refutation:($a.refutation // null)}
   )) as $cells |
   {schema:"gooo/self-improvement-portfolio/semantic-denominator-projector-input/v1",subject_sha:$subject,profile_digest:$profile_digest,activities_digest:$activities_digest,projector_contract_digest:$contract,source_path:$source_path,cells:$cells}' \
  > "$projector_root/projected-cells.json"

jq -S --arg projector_release "$tag" --arg projector_contract "$contract_digest" --arg projector_source_digest "sha256:$(sha256sum "$projector_source" | awk '{print $1}')" --arg profile_digest "$profile_digest" --arg activities_digest "$activities_digest" --arg subject "$subject_sha" \
  '(.cells) as $cells |
   ($cells | {total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) as $states |
   ($cells | group_by(.proof) | map({key:.[0].proof,value:length}) | from_entries) as $proof_totals |
   ($cells | group_by(.indicator) | map({key:.[0].indicator,value:length}) | from_entries) as $indicator_totals |
   ($cells | group_by(.proof) | map({label:.[0].proof,total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) | sort_by(.label)) as $proofs |
   ($cells | group_by(.indicator) | map({label:.[0].indicator,total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) | sort_by(.label)) as $indicators |
   {schema:"gooo/self-improvement-portfolio/semantic-denominator/v1",release:$projector_release,graph_id:"gooo://self-improvement-portfolio/graph/v1",precedence:["REFUTED","UNKNOWN","CLOSED"],authority:"RELEASED_GOOO",subject_sha:$subject,source_path:"examples/self-improvement-portfolio/main.gooo",source_digest:$projector_source_digest,profile_digest:$profile_digest,activities_digest:$activities_digest,projector_contract:{release:$projector_release,source_asset:"semantic-denominator-projector.gooo",digest:$projector_contract,activities:12,cells:12,rules:9,cases:12,external_required_gates:0,repository_writes:0},scenario_denominator:$states.total,expected_state_counts:$states,state_counts:$states,proof_totals:$proof_totals,indicator_totals:$indicator_totals,proof_choices:$proofs,indicator_classes:$indicators,activities:($cells|map({ordinal,stable_id:.activity,name:.activity,proof_choice:.proof,indicator_class:.indicator,artifact:.generated_artifact,authority:"READ_ONLY"})),cells:$cells,output_artifacts:["semantic-denominator.json","semantic-distribution.json","generated-assertions.json","projection-events.ndjson","report.md"]}' \
  "$projector_root/projected-cells.json" > "$projector_root/semantic-denominator.json"

jq -S --arg source_digest "sha256:$(sha256sum "$projector_source" | awk '{print $1}')" \
  '(.cells) as $cells |
   ($cells | {total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) as $states |
   ($cells | group_by(.proof) | map({label:.[0].proof,total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) | sort_by(.label)) as $proofs |
   ($cells | group_by(.indicator) | map({label:.[0].indicator,total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) | sort_by(.label)) as $indicators |
   {schema:"gooo/self-improvement-portfolio/semantic-distribution/v1",source_digest:$source_digest,scenario_denominator:$states.total,states:$states,proof_choices:$proofs,indicator_classes:$indicators,activity_mapping:($cells|map({ordinal,id,activity,axis,proof,indicator,state})),unknown_coverage:($cells|map(select(.state=="UNKNOWN"))|{total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}),refuted_coverage:($cells|map(select(.state=="REFUTED"))|{total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}),external_user_utility:{state:"UNKNOWN",reason:"EXTERNAL_USER_UTILITY_EVIDENCE_NOT_A_PORTFOLIO_CELL"},improvement:{state:"UNKNOWN",reason:"REPORT_IS_NOT_A_BEFORE_AFTER_PERFORMANCE_PAIR"}}' \
  "$projector_root/projected-cells.json" > "$projector_root/semantic-distribution.json"

jq -S --slurpfile verification "$verification_path" --arg source_digest "sha256:$(sha256sum "$projector_source" | awk '{print $1}')" \
  '(.cells) as $cells |
   ($cells | {total:length,closed:(map(select(.state=="CLOSED"))|length),unknown:(map(select(.state=="UNKNOWN"))|length),refuted:(map(select(.state=="REFUTED"))|length)}) as $states |
   ($cells | group_by(.proof) | map({key:.[0].proof,value:length}) | from_entries) as $proof_totals |
   ($cells | group_by(.indicator) | map({key:.[0].indicator,value:length}) | from_entries) as $indicator_totals |
   {schema:"gooo/self-improvement-portfolio/generated-assertions/v1",source_digest:$source_digest,exact_match:{report_summary:$states,report_cells:($cells|map({ordinal,id,activity,proof,indicator,state,numerator,denominator})),report_bindings:{one_to_one:true,cells:$states.total,activities:$states.total,unique_axes:$states.total,unique_metrics:$states.total,source_bindings:$states.total,ir_bindings:$states.total,generated_artifact_bindings:$states.total,evaluator_bindings:$states.total},report_proof_denominators:$proof_totals,report_indicator_denominators:$indicator_totals,report_release_summary:$verification[0].summary,ndjson_events:($cells|map({ordinal,id,activity,proof,indicator,state,numerator,denominator})),markdown:{denominator:$states.total,summary:$states,proof_totals:$proof_totals,indicator_totals:$indicator_totals}}}' \
  "$projector_root/projected-cells.json" > "$projector_root/generated-assertions.json"

jq -c '.exact_match.ndjson_events[]' "$projector_root/generated-assertions.json" > "$projector_root/projection-events.ndjson"
jq -r '"# Semantic denominator projector\n\n- denominator: \(.exact_match.markdown.denominator)\n- CLOSED/UNKNOWN/REFUTED: \(.exact_match.markdown.summary.closed)/\(.exact_match.markdown.summary.unknown)/\(.exact_match.markdown.summary.refuted)\n- proof totals: \(.exact_match.markdown.proof_totals | to_entries | sort_by(.key) | map("\(.key)=\(.value)") | join(","))\n- indicator totals: \(.exact_match.markdown.indicator_totals | to_entries | sort_by(.key) | map("\(.key)=\(.value)") | join(","))\n\nGenerated from the released semantic-denominator-projector.gooo contract and the current ledger profile; no denominator is hand-entered."' "$projector_root/generated-assertions.json" > "$projector_root/report.md"

jq -S -n --arg subject "$subject_sha" --arg source_digest "sha256:$(sha256sum "$projector_source" | awk '{print $1}')" --arg profile_digest "$profile_digest" --arg activities_digest "$activities_digest" --arg contract "$contract_digest" \
  '{schema:"gooo/self-improvement-portfolio/semantic-denominator-projector-generation/v1",subject_sha:$subject,source_digest:$source_digest,profile_digest:$profile_digest,activities_digest:$activities_digest,projector_contract_digest:$contract,authority:{source:"RELEASED_GOOO",caller_owned_output:true,repository_writes:0,cross_project_required_gates:0,local_product_validation_executions:0},generated:{semantic_denominator:"semantic-denominator.json",semantic_distribution:"semantic-distribution.json",generated_assertions:"generated-assertions.json",projection_events:"projection-events.ndjson",report:"report.md"}}' > "$projector_root/generation-receipt.json"

jq -S -n --arg repository "$upstream_repository" --arg tag "$tag" --argjson release_id "$release_id" --arg tag_object "$tag_object" --arg target "$target_commit" \
  --arg contract "$contract_digest" --argjson source_run_id "$source_run_id" --argjson source_job_id "$source_job_id" --argjson source_artifact_id "$source_artifact_id" --arg source_artifact_name "$source_artifact_name" --argjson source_artifact_size "$source_artifact_size" --arg source_artifact_digest "$source_artifact_digest" \
  --argjson verification_run_id "$verification_run_id" --argjson verification_job_id "$verification_job_id" --argjson verification_artifact_id "$verification_artifact_id" --arg verification_artifact_name "$verification_artifact_name" --argjson verification_artifact_size "$verification_artifact_size" --arg verification_artifact_digest "$verification_artifact_digest" \
  '{schema:"gooo/self-improvement-portfolio/semantic-denominator-projector-provenance/v1",release:{repository:$repository,tag:$tag,release_id:$release_id,immutable:true,annotated_tag_object_sha:$tag_object,peeled_commit_sha:$target,projector_contract_digest:$contract},source_ci:{run_id:$source_run_id,job_id:$source_job_id,artifact_id:$source_artifact_id,artifact_name:$source_artifact_name,artifact_size_bytes:$source_artifact_size,artifact_digest:$source_artifact_digest,commit:$target,conclusion:"success"},verification_ci:{run_id:$verification_run_id,job_id:$verification_job_id,artifact_id:$verification_artifact_id,artifact_name:$verification_artifact_name,artifact_size_bytes:$verification_artifact_size,artifact_digest:$verification_artifact_digest,conclusion:"success"},operational_refuted:{local_validation_commands:1,operator_api_attempts:null,operator_api_attempts_state:"UNKNOWN",unknown:{stage:"EVIDENCE_RECONCILIATION",step:"RECONCILE_OPERATOR_API_ATTEMPTS",reason:"PUBLIC_UPSTREAM_EVIDENCE_CONFLICTS_WITH_SHARED_LEDGER_PROVENANCE",unknown_class:"CONTRADICTORY",next_operation:"RECONCILE_RELEASE_API_ATTEMPT_LOG",blocked_by:["upstream-ci-evidence","shared-ledger-provenance"]}},authority:{verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,cross_project_required_gates:0}}' > "$projector_root/provenance.json"

echo "semantic denominator projector release, source CI, verification CI, released .gooo contract, and generated ledger projections verified"

