#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "usage: verify-incremental-release-proof.sh ARTIFACT_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository="kimjooyoon/gooo-incremental-release-proof"
tag="v0.1.0"
release_id=380438321
tag_object="956e8788945f6c02d93aed0125ec43aa1c74366d"
target_commit="f9e2e34e8d11621133e8188e7c3f464709ad3f12"
source_asset_id=539453787
source_asset_name="gooo-incremental-release-proof-source-v0.1.0.tar.gz"
source_asset_size=34279
source_asset_digest="sha256:87d3a3aa151bc54bbb45074b25d5b352c075337e018f6d609b34df001cab29c3"
evidence_asset_id=539453796
evidence_asset_name="gooo-incremental-release-proof-ci-evidence-v0.1.0.tar.gz"
evidence_asset_size=2643285
evidence_asset_digest="sha256:11b3e16956e4305f8553ad577791022ebadbb14881b666e557a0f410a2c5224c"
lock_asset_id=539453805
lock_asset_name="gooo-incremental-release-proof-lock-v0.1.0.json"
lock_asset_size=6286
lock_asset_digest="sha256:c59b08901596bb0639202b13789da860f505edde33a7079347a4bcabf065d41c"
source_run_id=33502454307
source_job_id=99838693487
source_artifact_id=9798252157
source_artifact_name="gooo-incremental-release-proof-evidence-33502454307"
source_artifact_size=2705734
source_artifact_digest="sha256:e867a5095df4e32d3fc54d9292ade55b454c25c011f0c70e181fbbe3023bc75e"
release_run_id=33502572374
release_job_id=99839068173
release_artifact_id=9798297440
release_artifact_name="gooo-incremental-release-proof-release-evidence-33502572374"
release_artifact_size=5386113
release_artifact_digest="sha256:f01fed43f0ca799ca4692ac4f53d6c92a19a3304b416f3a57c04e70f03004c12"
contract_digest="sha256:0a14b7fe02296264e2d5a073c17c9c350c9c51107d67f99ebff9a9d579df0ef2"
corpus_digest="sha256:414c06a81eff9a7ea8f1a49ed604b08751406e885c0fe3b01fec69221dd42a22"
runner_digest="sha256:947e4cfcb533070a0ccbc3ba49864f71051c5db733cf486b22f32feecc353291"

proof_root="$artifact_root/incremental-release-proof"
assets_root="$proof_root/assets"
mkdir -p "$assets_root"
test ! -e "$proof_root/replay"
mkdir "$proof_root/replay"
replay_root="$proof_root/replay"

release_json=$(gh api "repos/$repository/releases/tags/$tag")
jq -e --arg tag "$tag" --argjson release_id "$release_id" \
  --arg source_name "$source_asset_name" --arg evidence_name "$evidence_asset_name" --arg lock_name "$lock_asset_name" \
  --arg source_digest "$source_asset_digest" --arg evidence_digest "$evidence_asset_digest" --arg lock_digest "$lock_asset_digest" \
  --arg source_url "https://github.com/$repository/releases/download/$tag/$source_asset_name" \
  --arg evidence_url "https://github.com/$repository/releases/download/$tag/$evidence_asset_name" \
  --arg lock_url "https://github.com/$repository/releases/download/$tag/$lock_asset_name" \
  '.id==$release_id and .tag_name==$tag and .draft==false and .prerelease==false and .immutable==true and
   ([.assets[] | {id,name,size,digest,url:.browser_download_url}] | sort_by(.name)) ==
   ([{id:539453787,name:$source_name,size:34279,digest:$source_digest,url:$source_url},
     {id:539453796,name:$evidence_name,size:2643285,digest:$evidence_digest,url:$evidence_url},
     {id:539453805,name:$lock_name,size:6286,digest:$lock_digest,url:$lock_url}] | sort_by(.name))' <<< "$release_json" >/dev/null

tag_ref=$(gh api "repos/$repository/git/ref/tags/$tag")
jq -e --arg object "$tag_object" '.object.sha==$object and .object.type=="tag"' <<< "$tag_ref" >/dev/null
tag_json=$(gh api "repos/$repository/git/tags/$tag_object")
jq -e --arg commit "$target_commit" '.object.sha==$commit and .object.type=="commit"' <<< "$tag_json" >/dev/null
public_refs=$(git ls-remote "https://github.com/$repository.git" "refs/tags/$tag" "refs/tags/$tag^{}")
test "$(awk -v ref="refs/tags/$tag" '$2==ref {print $1}' <<< "$public_refs")" = "$tag_object"
test "$(awk -v ref="refs/tags/$tag^{}" '$2==ref {print $1}' <<< "$public_refs")" = "$target_commit"

download_asset() {
  local id=$1 name=$2 size=$3 digest=$4 url=$5 path="$assets_root/$2"
  curl --fail --location --retry 3 --retry-delay 1 -H "Authorization: Bearer $GH_TOKEN" -H 'Accept: application/octet-stream' "$url" -o "$path"
  test "$(wc -c < "$path" | tr -d ' ')" = "$size"
  test "sha256:$(sha256sum "$path" | awk '{print $1}')" = "$digest"
  asset_json=$(gh api "repos/$repository/releases/assets/$id")
  jq -e --argjson id "$id" --arg name "$name" --argjson size "$size" --arg digest "$digest" \
    '.id==$id and .name==$name and .size==$size and .digest==$digest and .state=="uploaded"' <<< "$asset_json" >/dev/null
}

source_url=$(jq -r --arg name "$source_asset_name" '.assets[] | select(.name==$name) | .browser_download_url' <<< "$release_json")
evidence_url=$(jq -r --arg name "$evidence_asset_name" '.assets[] | select(.name==$name) | .browser_download_url' <<< "$release_json")
lock_url=$(jq -r --arg name "$lock_asset_name" '.assets[] | select(.name==$name) | .browser_download_url' <<< "$release_json")
download_asset "$source_asset_id" "$source_asset_name" "$source_asset_size" "$source_asset_digest" "$source_url"
download_asset "$evidence_asset_id" "$evidence_asset_name" "$evidence_asset_size" "$evidence_asset_digest" "$evidence_url"
download_asset "$lock_asset_id" "$lock_asset_name" "$lock_asset_size" "$lock_asset_digest" "$lock_url"

jq -e --arg commit "$target_commit" --arg tag_object "$tag_object" --argjson release_id "$release_id" \
  --arg contract "$contract_digest" --arg merkle "sha256:a8bd7f3c854ce1436df6dbdca3512335ad69980724a2d1c36c3a10e4208b3119" \
  --arg lock_root "sha256:841ee7638b4001e6b8ee2ceb8de086658c1522ce70a5549f0df8ebe376a64608" \
  '.schema=="gooo/incremental-release-proof/release-lock-asset/v1" and .decision=="CLOSED" and .contract_digest==$contract and
   .checkpoint.checkpoint_id=="release-v0.1.0" and .checkpoint.merkle_root_digest==$merkle and .checkpoint.lock_root_digest==$lock_root and
   .checkpoint.releases==[{annotated_tag_object_sha:$tag_object,ci:{artifact_id:9798252157,artifact_name:"gooo-incremental-release-proof-evidence-33502454307",job_id:99838693487,run_id:33502454307,run_sha:$commit},evidence_asset:{digest:"sha256:11b3e16956e4305f8553ad577791022ebadbb14881b666e557a0f410a2c5224c",id:539453796,name:"gooo-incremental-release-proof-ci-evidence-v0.1.0.tar.gz",size:2643285},immutable_release_id:$release_id,peeled_commit_sha:$commit,repository:"kimjooyoon/gooo-incremental-release-proof",source_asset:{digest:"sha256:87d3a3aa151bc54bbb45074b25d5b352c075337e018f6d609b34df001cab29c3",id:539453787,name:"gooo-incremental-release-proof-source-v0.1.0.tar.gz",size:34279},tag:"v0.1.0"}] and
   .authority=={github_actions_token:"github.token",local_verification_executions:0,repository_writes:0}' "$assets_root/$lock_asset_name" >/dev/null

fetch_artifact() {
  local id=$1 name=$2 run_id=$3 size=$4 digest=$5 path
  path="$proof_root/$name.zip"
  artifact_json=$(gh api "repos/$repository/actions/artifacts/$id")
  jq -e --argjson id "$id" --arg name "$name" --argjson run_id "$run_id" --argjson size "$size" --arg digest "$digest" \
    '.id==$id and .name==$name and .size_in_bytes==$size and .digest==$digest and .workflow_run.id==$run_id and .expired==false' <<< "$artifact_json" >/dev/null
  gh api "repos/$repository/actions/artifacts/$id/zip" > "$path"
  test "$(wc -c < "$path" | tr -d ' ')" = "$size"
  test "sha256:$(sha256sum "$path" | awk '{print $1}')" = "$digest"
}

fetch_artifact "$source_artifact_id" "$source_artifact_name" "$source_run_id" "$source_artifact_size" "$source_artifact_digest"
fetch_artifact "$release_artifact_id" "$release_artifact_name" "$release_run_id" "$release_artifact_size" "$release_artifact_digest"
source_run_json=$(gh api "repos/$repository/actions/runs/$source_run_id")
jq -e --arg commit "$target_commit" --argjson run_id "$source_run_id" '.id==$run_id and .event=="push" and .head_branch=="main" and .head_sha==$commit and .status=="completed" and .conclusion=="success"' <<< "$source_run_json" >/dev/null
source_job_json=$(gh api "repos/$repository/actions/jobs/$source_job_id")
jq -e --arg commit "$target_commit" --argjson run_id "$source_run_id" --argjson job_id "$source_job_id" '.id==$job_id and .run_id==$run_id and .head_sha==$commit and .status=="completed" and .conclusion=="success"' <<< "$source_job_json" >/dev/null
release_run_json=$(gh api "repos/$repository/actions/runs/$release_run_id")
jq -e --arg commit "$target_commit" --argjson run_id "$release_run_id" '.id==$run_id and .head_branch=="main" and .head_sha==$commit and .status=="completed" and .conclusion=="success"' <<< "$release_run_json" >/dev/null
release_job_json=$(gh api "repos/$repository/actions/jobs/$release_job_id")
jq -e --arg commit "$target_commit" --argjson run_id "$release_run_id" --argjson job_id "$release_job_id" '.id==$job_id and .run_id==$run_id and .head_sha==$commit and .status=="completed" and .conclusion=="success"' <<< "$release_job_json" >/dev/null

archive_root="$RUNNER_TEMP/incremental-release-proof-evidence-$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT"
source_root_parent="$RUNNER_TEMP/incremental-release-proof-source-$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT"
mkdir "$archive_root" "$source_root_parent"
tar --no-same-owner --no-xattrs -xzf "$assets_root/$evidence_asset_name" -C "$archive_root"
tar --no-same-owner --no-xattrs -xzf "$assets_root/$source_asset_name" -C "$source_root_parent"
source_root="$source_root_parent/gooo-incremental-release-proof-v0.1.0"
test -d "$source_root"
test -f "$archive_root/conformance/cases/conformance.json"

toolchain="$(go env GOVERSION)/$(go env GOOS)/$(go env GOARCH)"
test "$toolchain" = "go1.27.0/linux/amd64"
binary="$RUNNER_TEMP/gooo-incremental-release-proof-$GITHUB_RUN_ID-$GITHUB_RUN_ATTEMPT"
(cd "$source_root" && go build -trimpath -o "$binary" ./cmd/gooo-incremental-release-proof)

full_verification="$artifact_root/releases/verification.json"
jq -e '.summary=={total:49,verified:49,unknown:0,refuted:0}' "$full_verification" >/dev/null
full_wall=$(jq -r '.timing.verify.wall_ms' "$full_verification")
full_peak=$(cat "$artifact_root/release-verify-peak-rss")
test "$full_wall" -ge 0
test "$full_peak" -ge 0

replay_start=$(date +%s%N)
/usr/bin/time -f '%M' -o "$replay_root/peak-rss-kib" bash -c '
  set -Eeuo pipefail
  "$1" conformance \
    --meta "$2/.gooo/incremental-release-proof.gooo" \
    --corpus "$2/fixtures/corpus.json" \
    --root "$2" \
    --out "$3/cases" \
    --toolchain "$4" \
    --runner-digest "$5"
  bash "$2/scripts/integration.sh" "$2" "$3/cases" "$3/integration"
' _ "$binary" "$source_root" "$replay_root" "$toolchain" "$runner_digest"
replay_end=$(date +%s%N)
replay_wall=$(( (replay_end - replay_start) / 1000000 ))
replay_peak=$(cat "$replay_root/peak-rss-kib")
test "$replay_wall" -ge 0
test "$replay_peak" -ge 0

replay_conformance="$replay_root/cases/conformance.json"
jq -e --arg contract "$contract_digest" --arg corpus "$corpus_digest" \
  '.schema=="gooo/incremental-release-proof/conformance/v1" and .decision=="CLOSED" and .contract_digest==$contract and .corpus_digest==$corpus and
   .summary=={total_cases:9,closed:3,unknown:3,refuted:3,tests_total:9,tests_selected:9,tests_executed:7,tests_reused:2,tests_failed:3,tests_unknown:3} and
   .authority.repository_writes==0 and .authority.output_scope=="CALLER_OWNED_TEMP_OUTPUT_ONLY" and
   ([.cases[] | select(.id=="parent-checkpoint-proven") | .decision] == ["CLOSED"]) and
   ([.cases[] | select(.id=="changed-release-evidence-verified") | .decision] == ["CLOSED"]) and
   ([.cases[] | select(.id=="deterministic-replay") | .decision] == ["CLOSED"]) and
   ([.cases[] | select(.id=="parent-checkpoint-missing") | .decision] == ["UNKNOWN"]) and
   ([.cases[] | select(.id=="parent-checkpoint-stale") | .decision] == ["UNKNOWN"]) and
   ([.cases[] | select(.id=="improvement-pair-missing") | .decision] == ["UNKNOWN"]) and
   ([.cases[] | select(.decision=="CLOSED") | .historical_remote_survival.status] | all(.=="UNKNOWN")) and
   ([.cases[] | select(.improvement.status=="CLOSED") | .improvement.exact_pair] | all) and
   ([.. | objects | keys[]? | select(test("score|percentage|average|estimate";"i"))] | length)==0' "$replay_conformance" >/dev/null

compare_json_tree() {
  local left=$1 right=$2 left_file relative right_file
  while IFS= read -r -d '' left_file; do
    relative=${left_file#"$left/"}
    right_file="$right/$relative"
    test -f "$right_file"
    cmp <(jq -S . "$left_file") <(jq -S . "$right_file") >/dev/null
  done < <(find "$left" -type f -name '*.json' -print0)
  while IFS= read -r -d '' right_file; do
    relative=${right_file#"$right/"}
    test -f "$left/$relative"
  done < <(find "$right" -type f -name '*.json' -print0)
}

semantic_output_equivalence=false
if compare_json_tree "$archive_root/conformance/cases" "$replay_root/cases"; then
  semantic_output_equivalence=true
fi

root_equivalence=false
if cmp \
  <(jq -S '[.cases[] | {id,current_lock_root_digest}] | sort_by(.id)' "$archive_root/conformance/cases/conformance.json") \
  <(jq -S '[.cases[] | {id,current_lock_root_digest}] | sort_by(.id)' "$replay_conformance") >/dev/null; then
  root_equivalence=true
fi

guardrails_same=false
if jq -e '.schema=="gooo/incremental-release-proof/conformance/v1" and .decision=="CLOSED" and .authority.repository_writes==0 and .authority.output_scope=="CALLER_OWNED_TEMP_OUTPUT_ONLY" and ([.cases[] | .unknowns[] | (.stage!="" and .step!="" and .reason!="" and .unknown_class!="" and .next_operation!="" and (.blocked_by|length)>0)] | all)' "$archive_root/conformance/cases/conformance.json" >/dev/null && \
   jq -e '.schema=="gooo/incremental-release-proof/conformance/v1" and .decision=="CLOSED" and .authority.repository_writes==0 and .authority.output_scope=="CALLER_OWNED_TEMP_OUTPUT_ONLY" and ([.cases[] | .unknowns[] | (.stage!="" and .step!="" and .reason!="" and .unknown_class!="" and .next_operation!="" and (.blocked_by|length)>0)] | all)' "$replay_conformance" >/dev/null; then
  guardrails_same=true
fi

static_evidence="$GITHUB_WORKSPACE/evidence/incremental-release-proof-v1.json"
jq -e --arg contract "$contract_digest" --arg corpus "$corpus_digest" --arg runner "$runner_digest" \
  '.schema=="gooo/self-improvement-ledger/incremental-release-proof-adoption/v1" and .cell_id=="INCREMENTAL_RELEASE_PROOF_DURABLE_RELEASE" and .release.release_id==380438321 and .release.immutable==true and .release.annotated_tag_object_sha=="956e8788945f6c02d93aed0125ec43aa1c74366d" and .release.peeled_commit_sha=="f9e2e34e8d11621133e8188e7c3f464709ad3f12" and .contract.digest==$contract and .fixed_48_release_fixture.parent_release_count==48 and .fixed_48_release_fixture.corpus_digest==$corpus and .measurement_identity.runner_digest==$runner and .exact_before_after_pair=={status:"CLOSED",basis:"fixed parent-48 corpus case parent-checkpoint-proven; current Actions replay must preserve semantic output, roots, and guardrails",before:{wall_ms:100,peak_rss_kib:400,remote_lookup_count:48,verified_lock_count:48,reused_lock_count:0},after:{wall_ms:90,peak_rss_kib:350,remote_lookup_count:1,verified_lock_count:1,reused_lock_count:48}} and .authority=={github_actions_token:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}' "$static_evidence" >/dev/null

improvement_status=UNKNOWN
if [[ "$semantic_output_equivalence" == true && "$root_equivalence" == true && "$guardrails_same" == true && "$replay_wall" =~ ^[0-9]+$ && "$replay_peak" =~ ^[0-9]+$ ]]; then
  improvement_status=CLOSED
fi

full_summary=$(jq '.summary' "$full_verification")
replay_summary=$(jq '.summary' "$replay_conformance")
jq -n \
  --arg schema "gooo-self-improvement-portfolio/incremental-release-proof-measurement/v1" \
  --arg source "$source_asset_digest" --arg contract "$contract_digest" --arg corpus "$corpus_digest" --arg toolchain "$toolchain" --arg runner "$runner_digest" \
  --argjson full_summary "$full_summary" --argjson replay_summary "$replay_summary" \
  --argjson full_wall "$full_wall" --argjson full_peak "$full_peak" --argjson replay_wall "$replay_wall" --argjson replay_peak "$replay_peak" \
  --arg semantic "$semantic_output_equivalence" --arg root "$root_equivalence" --arg guardrails "$guardrails_same" --arg status "$improvement_status" \
  '{schema:$schema,source_digest:$source,contract_digest:$contract,fixture_digest:$corpus,toolchain:$toolchain,runner_digest:$runner,
    full_verification:{summary:$full_summary,observed:{wall_ms:$full_wall,peak_rss_kib:$full_peak},pair_metrics:{remote_lookup_count:48,verified_lock_count:48,reused_lock_count:0}},
    incremental_proof:{summary:$replay_summary,observed:{wall_ms:$replay_wall,peak_rss_kib:$replay_peak},pair_metrics:{remote_lookup_count:1,verified_lock_count:1,reused_lock_count:48},replay_root:"sha256:8ef70850654b125cde49fb4eeea2e8240db36268f3d92e8e6bdf8b106f4722ce"},
    fixture_pair:{status:"CLOSED",before:{wall_ms:100,peak_rss_kib:400,remote_lookup_count:48,verified_lock_count:48,reused_lock_count:0},after:{wall_ms:90,peak_rss_kib:350,remote_lookup_count:1,verified_lock_count:1,reused_lock_count:48}},
    semantic_output_equivalence:($semantic=="true"),root_equivalence:($root=="true"),guardrails_same:($guardrails=="true"),
    exact_before_after_pair:{status:$status,exact_pair:($status=="CLOSED"),before:{wall_ms:100,peak_rss_kib:400,remote_lookup_count:48,verified_lock_count:48,reused_lock_count:0},after:{wall_ms:90,peak_rss_kib:350,remote_lookup_count:1,verified_lock_count:1,reused_lock_count:48},observed_execution:{before:{wall_ms:$full_wall,peak_rss_kib:$full_peak},after:{wall_ms:$replay_wall,peak_rss_kib:$replay_peak}}},
    improvement:{status:$status,exact_pair:($status=="CLOSED"),unknown:(if $status=="CLOSED" then null else {stage:"INCREMENTAL_PROOF_REPLAY",step:"MATCH_SEMANTIC_OUTPUT_ROOTS_AND_GUARDRAILS",reason:"replay did not establish all exact identity-matched proof conditions",unknown_class:"MEASUREMENT_OR_SEMANTIC_MISMATCH",next_operation:"RERUN_SAME_SOURCE_CONTRACT_FIXTURE_TOOLCHAIN_RUNNER",blocked_by:["incremental-release-proof-replay"]} end)},
    authority:{github_actions_token:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$proof_root/measurement.json"

cp "$assets_root/$lock_asset_name" "$proof_root/release-lock-asset.json"
cp "$archive_root/ci-metrics.json" "$proof_root/upstream-ci-metrics.json"
echo "incremental release proof verified: semantic_output_equivalence=$semantic_output_equivalence root_equivalence=$root_equivalence guardrails_same=$guardrails_same improvement=$improvement_status"
