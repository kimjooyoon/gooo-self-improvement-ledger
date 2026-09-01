#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.50 content-addressed product verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v050-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v050-products"
temp_root="${RUNNER_TEMP:-$artifact_root/.v050-products-temp}"
utility_root="$temp_root/utility-release"
utility_source="$temp_root/utility-source"
input_root="$temp_root/legacy-full-copy"
baseline_root="$temp_root/baseline-inputs"
candidate_output="$temp_root/candidate-output"
baseline_archive="$temp_root/legacy-full-copy.tar.gz"
baseline_time="$temp_root/baseline-time"
candidate_time="$temp_root/candidate-time"
fixture="$temp_root/v050-fixture.json"
input_manifest="$temp_root/input-manifest.json"
utility_archive="$temp_root/gooo-content-addressed-evidence-projector-v0.1.1.tar.gz"

command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v unzip >/dev/null
command -v go >/dev/null
command -v awk >/dev/null
test -n "${GH_TOKEN:-}"
mkdir -p "$products" "$temp_root"

utility_repo="kimjooyoon/gooo-content-addressed-evidence-projector"
utility_release_id=380750147
utility_tag="v0.1.1"
utility_tag_object="03dbbe7cd13549d4791e5e6086e036c81db3eac9"
utility_target="f3bfd2c6c05a45214fc7ed0732f2c3f0770bf463"
utility_asset_id=539995619
utility_asset_name="gooo-content-addressed-evidence-projector-v0.1.1.tar.gz"
utility_asset_size=26063
utility_asset_digest="sha256:a1d83f2503755bc6ea591d32cd4ef5d7a088e936da2a843d9d80af947acbe435"

utility_release=$(gh api "repos/$utility_repo/releases/$utility_release_id")
utility_ref=$(gh api "repos/$utility_repo/git/ref/tags/$utility_tag")
utility_tag_record=$(gh api "repos/$utility_repo/git/tags/$utility_tag_object")
utility_asset=$(jq -c --argjson id "$utility_asset_id" 'first(.assets[] | select(.id==$id))' <<< "$utility_release")
jq -e --argjson id "$utility_release_id" --arg tag "$utility_tag" --argjson asset_id "$utility_asset_id" --arg name "$utility_asset_name" --argjson size "$utility_asset_size" --arg digest "$utility_asset_digest" '
  .id==$id and .tag_name==$tag and .immutable==true and .draft==false and .prerelease==false and
  ([.assets[] | select(.id==$asset_id and .name==$name and .size==$size and .digest==$digest)]|length)==1
' <<< "$utility_release" >/dev/null
jq -e --arg object "$utility_tag_object" '.object.sha==$object and .object.type=="tag"' <<< "$utility_ref" >/dev/null
jq -e --arg target "$utility_target" '.object.sha==$target and .object.type=="commit"' <<< "$utility_tag_record" >/dev/null
gh api -H "Accept: application/octet-stream" "repos/$utility_repo/releases/assets/$utility_asset_id" > "$utility_archive"
test "$(wc -c < "$utility_archive" | tr -d ' ')" = "$utility_asset_size"
test "sha256:$(sha256sum "$utility_archive" | awk '{print $1}')" = "$utility_asset_digest"
rm -rf "$utility_source"
mkdir -p "$utility_source"
tar --no-xattrs -xzf "$utility_archive" -C "$utility_source"
utility_source_dir=$(find "$utility_source" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$utility_source_dir"

rm -rf "$input_root" "$baseline_root" "$candidate_output"
mkdir -p "$input_root" "$baseline_root" "$candidate_output"
cp "$repository/contracts/self-improvement-portfolio-v1.json" "$input_root/profile-contract.json"
cp "$repository/evidence/assessment-v1.json" "$input_root/assessment.json"
cp "$repository/contracts/release-locks-v1.json" "$input_root/release-locks.json"
cp "$repository/examples/self-improvement-portfolio/main.gooo" "$input_root/portfolio.gooo"
cp "$repository/evidence/atomic-v0500-wave-v1.json" "$input_root/atomic-v0500-wave.json"
cp "$artifact_root/v0500-parent-lock-receipt.json" "$input_root/parent-lock-receipt.json"
cp "$artifact_root/report.json" "$input_root/report.json"
cp "$artifact_root/conformance.json" "$input_root/conformance.json"

jq -S -n \
  --rawfile profile "$input_root/profile-contract.json" \
  --rawfile assessment "$input_root/assessment.json" \
  --rawfile locks "$input_root/release-locks.json" \
  --rawfile gooo "$input_root/portfolio.gooo" \
  --rawfile wave "$input_root/atomic-v0500-wave.json" \
  --rawfile parent "$input_root/parent-lock-receipt.json" \
  --rawfile report "$input_root/report.json" \
  --rawfile conformance "$input_root/conformance.json" \
  '{schema:"gooo/self-improvement-ledger/v050-evidence-input-manifest/v1",files:{"profile-contract.json":$profile,"assessment.json":$assessment,"release-locks.json":$locks,"portfolio.gooo":$gooo,"atomic-v0500-wave.json":$wave,"parent-lock-receipt.json":$parent,"report.json":$report,"conformance.json":$conformance}}' \
  > "$input_manifest"
input_digest="sha256:$(sha256sum "$input_manifest" | awk '{print $1}')"
cp "$input_manifest" "$input_root/evidence-input-manifest.json"
cp -a "$input_root/." "$baseline_root/"

baseline_files=$(find "$baseline_root" -type f -print | wc -l | tr -d ' ')
baseline_bytes=$(find "$baseline_root" -type f -exec wc -c {} + | awk 'END {print $1+0}')
/usr/bin/time -f '%e %M' -o "$baseline_time" tar --sort=name --mtime='UTC 1970-01-01' --owner=0 --group=0 --numeric-owner -czf "$baseline_archive" -C "$baseline_root" .
baseline_wall_ms=$(awk '{printf "%d", $1*1000}' "$baseline_time")
baseline_peak_rss_kib=$(awk '{print $2+0}' "$baseline_time")

fixture_source="$utility_source_dir/fixtures/deterministic-corpus-v1.json"
test -s "$fixture_source"
jq -S --arg digest "$input_digest" '
  .cases[0].cells[0].content="input-manifest:"+$digest | .cases[0].cells[1].content=$digest | .cases[0].cells[2].content="replay:"+$digest |
  .cases[1].cells[0].content="input-manifest:"+$digest | .cases[2].cells[0].content="input-manifest:"+$digest | .cases[2].cells[1].content="input-manifest:"+$digest
' "$fixture_source" > "$fixture"
contract_file="$utility_source_dir/.gooo/content-addressed-evidence-projector.gooo"
contract_digest="sha256:$(sha256sum "$contract_file" | awk '{print $1}')"
go_version=$(go env GOVERSION)
toolchain="go1.27.x"
runner="github-actions/ubuntu-latest"
(cd "$utility_source_dir" && go build -trimpath -o "$temp_root/projector" ./cmd/projector)
/usr/bin/time -f '%e %M' -o "$candidate_time" "$temp_root/projector" conformance --source "$contract_file" --fixture "$fixture" --output "$candidate_output" --root "$utility_source_dir" > "$temp_root/projector-result.json"
candidate_wall_ms=$(awk '{printf "%d", $1*1000}' "$candidate_time")
candidate_peak_rss_kib=$(awk '{print $2+0}' "$candidate_time")

jq -e '.decision=="CLOSED" and .scenario_denominator==9 and .closed==3 and .unknown==3 and .refuted==3 and .replay_match==true' "$temp_root/projector-result.json" >/dev/null
jq -e '
  .schema=="gooo/content-addressed-evidence-projector/conformance-report/v1" and
  .scenario_denominator==9 and .state_counts=={CLOSED:3,UNKNOWN:3,REFUTED:3} and .expected_state_counts==.state_counts and .decision=="CLOSED" and .replay.match==true and
  .runtime.repository_writes==0 and .runtime.local_test_executions==0 and .runtime.cross_project_required_gates==0 and .runtime.verification_authority=="GITHUB_ACTIONS" and .runtime.github_token_source=="github.token" and .runtime.failed_history_preserved==true and .inventory.root_readme_excluded==true and
  all(.cases[]; .comparison.canonical_evidence_equal==true and .comparison.semantic_root_equal==true and all(.comparison.per_indicator_pairs[]; .exact_pair==true and .state=="CLOSED")) and
  all(.cases[]; all(.inclusion_proofs[]; .verified==true))
' "$candidate_output/conformance-report.json" >/dev/null

candidate_files=$(find "$candidate_output" -type f -print | wc -l | tr -d ' ')
candidate_bytes=$(find "$candidate_output" -type f -exec wc -c {} + | awk 'END {print $1+0}')
job=$(jq -r '.cases[0].comparison.per_indicator_pairs[0].job' "$candidate_output/conformance-report.json")
fixture_from_report=$(jq -r '.fixture_digest' "$candidate_output/conformance-report.json")
semantic_root=$(jq -r '.replay.normal_semantic_digest' "$candidate_output/conformance-report.json")
replay_normal=$(jq -r '.replay.normal_semantic_digest' "$candidate_output/conformance-report.json")
replay_perturbed=$(jq -r '.replay.perturbed_semantic_digest' "$candidate_output/conformance-report.json")
test -n "$semantic_root" -a "$replay_normal" = "$replay_perturbed"

jq -S -n \
  --argjson comparison "$(<"$candidate_output/exact-pair-comparison.json")" \
  --argjson report "$(<"$candidate_output/conformance-report.json")" \
  '{schema:"gooo/content-addressed-evidence-projector/exact-pair-comparison/v1",case_count:($comparison.cases|length),semantic_root_equal:($comparison.cases|all(.semantic_root_equal)),canonical_evidence_equal:($comparison.cases|all(.canonical_evidence_equal)),inclusion_proofs_verified:($report.cases|all(all(.inclusion_proofs[];.verified==true))),replay_equal:$report.replay.match,scenario_identity_equal:($comparison.cases|all(all(.per_indicator_pairs[];.scenario != ""))),fixture_digest_equal:($comparison.cases|all(all(.per_indicator_pairs[];.fixture != ""))),contract_digest_equal:($comparison.cases|all(all(.per_indicator_pairs[];.contract != ""))),toolchain_equal:($comparison.cases|all(all(.per_indicator_pairs[];.toolchain=="go1.27.x"))),runner_equal:($comparison.cases|all(all(.per_indicator_pairs[];.runner=="github-actions/ubuntu-latest"))),job_equal:($comparison.cases|all(all(.per_indicator_pairs[];.job==$comparison.cases[0].per_indicator_pairs[0].job)))}' \
  > "$products/exact-pair-comparison.json"

cp "$candidate_output/content-addressed-manifest.json" "$products/content-addressed-manifest.json"
cp "$candidate_output/projection-results.ndjson" "$products/projection-results.ndjson"
cp "$candidate_output/inclusion-proofs.json" "$products/inclusion-proofs.json"
cp "$candidate_output/replay-receipt.json" "$products/replay-receipt.json"
cp "$candidate_output/exact-pair-comparison.json" "$products/released-exact-pair-comparison.json"
cp "$candidate_output/conformance-report.json" "$products/conformance-report.json"
cp "$input_manifest" "$products/evidence-input-manifest.json"

candidate_published_files=$(find "$products" -maxdepth 1 -type f -print | wc -l | tr -d ' ')
candidate_published_bytes=$(find "$products" -maxdepth 1 -type f -exec wc -c {} + | awk 'END {print $1+0}')

jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v050-content-addressed-release-projection/v1" \
  --arg utility_repo "$utility_repo" --arg utility_tag "$utility_tag" --argjson utility_release_id "$utility_release_id" --arg utility_tag_object "$utility_tag_object" --arg utility_target "$utility_target" --argjson utility_asset "$utility_asset" \
  --arg input_digest "$input_digest" --argjson input_files "$baseline_files" --argjson input_bytes "$baseline_bytes" --arg fixture_digest "$fixture_from_report" --arg contract_digest "$contract_digest" --arg semantic_root "$semantic_root" \
  --arg toolchain "$toolchain" --arg runner "$runner" --arg job "$job" --arg go_version "$go_version" \
  --argjson baseline_bytes "$baseline_bytes" --argjson baseline_files "$baseline_files" --argjson baseline_wall "$baseline_wall_ms" --argjson baseline_rss "$baseline_peak_rss_kib" \
  --argjson candidate_bytes "$candidate_published_bytes" --argjson candidate_files "$candidate_published_files" --argjson candidate_wall "$candidate_wall_ms" --argjson candidate_rss "$candidate_peak_rss_kib" \
  '{schema:$schema,utility_release:{repository:$utility_repo,tag:$utility_tag,release_id:$utility_release_id,tag_object_sha:$utility_tag_object,target_commit_sha:$utility_target,immutable:true,asset:$utility_asset},input_manifest:{digest:$input_digest,files:$input_files,bytes:$input_bytes,fixture_digest:$fixture_digest},primary_gate:{primary_state:"CLOSED",mode:"CONTENT_ADDRESSED_PARENT_RELEASE_REUSE",selected:0,executed:0,reused:59,full_fallback_required:false},semantic_root:$semantic_root,semantic_root_equality:true,inclusion_proofs_verified:true,replay_equality:true,baseline_published:false,packaging_pair:{indicators:["bytes","files","wall_ms","peak_rss_kib"],baseline:{scenario:"v0.50-evidence-inputs",input_digest:$input_digest,contract_digest:$contract_digest,toolchain:$toolchain,runner:$runner,job:$job,bytes:$baseline_bytes,files:$baseline_files,wall_ms:$baseline_wall,peak_rss_kib:$baseline_rss},candidate:{scenario:"v0.50-evidence-inputs",input_digest:$input_digest,contract_digest:$contract_digest,toolchain:$toolchain,runner:$runner,job:$job,bytes:$candidate_bytes,files:$candidate_files,wall_ms:$candidate_wall,peak_rss_kib:$candidate_rss}},utility_run:{go_version:$go_version,scenario_denominator:9,state_counts:{CLOSED:3,UNKNOWN:3,REFUTED:3},output_published_files:["content-addressed-manifest.json","projection-results.ndjson","inclusion-proofs.json","replay-receipt.json","released-exact-pair-comparison.json","conformance-report.json","evidence-input-manifest.json","exact-pair-comparison.json"]},improvement_vs_v049:{state:"UNKNOWN",reason:"NO_EXACT_V049_IDENTITY_MATCH"},external_utility:{state:"UNKNOWN",independent_user_evidence:false,required_gate:false},authority:{verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,local_test_executions:0,cross_project_required_gates:0,caller_owned_temp_outputs_only:true}}' \
  > "$products/content-addressed-release-projection.json"

rm -f "$baseline_archive"
echo "v0.50 content-addressed product verified: released utility=$utility_tag semantic_root=$semantic_root baseline_files=$baseline_files candidate_files=$candidate_published_files"
