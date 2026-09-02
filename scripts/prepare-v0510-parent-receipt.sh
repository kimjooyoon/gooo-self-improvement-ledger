#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.51 parent receipt preparation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: prepare-v0510-parent-receipt.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
contract="$repository/contracts/release-locks-v1.json"
receipt="$artifact_root/v0510-parent-lock-receipt.json"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0510-parent-temp}"
counter="$temp_root/api-request-count"
parent_release_zip="$temp_root/v050-parent-release.zip"
parent_release_root="$temp_root/v050-parent-release"
mkdir -p "$artifact_root" "$temp_root"
printf '0\n' > "$counter"

command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v unzip >/dev/null
command -v wc >/dev/null
command -v base64 >/dev/null
test -n "${GH_TOKEN:-}"
test -s "$contract"

repo="kimjooyoon/gooo-self-improvement-ledger"
parent_tag="v0.50.0"
parent_release_id=380866481
parent_tag_object="9e3263ea902bef64fa31c05ca7c1ab038ef962ef"
parent_target="e93768f4204e8a88214026ffa22febad7ecedcbd"
parent_asset_id=540246273
parent_asset_name="gooo-self-improvement-ledger-e93768f4204e8a88214026ffa22febad7ecedcbd"
parent_asset_size=55178070
parent_asset_digest="sha256:80575837d8ebb8d838bab912ff7802946fb37b2d90d923e8a9cec27bdf543e25"
parent_manifest_sha="9b3cb03c401a2faa6044cc05ad58030504a09a7f"
parent_manifest_size=307511
parent_manifest_digest="sha256:7fbcb681ac47f1ae26935615229c824b21d4aca08ea41cb7639d74ea5bdf38a3"
parent_lock_set_digest="sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71"

current_count=$(jq '.releases|length' "$contract")
current_lock_set_digest="sha256:$(jq -cS 'del(.releases.measurement_boundary_v2_projector_durable_release,.releases.operational_provenance_projector_durable_release,.releases.self_improvement_frontier_projector_durable_release,.releases.bounded_self_change_compiler_v2_durable_release,.releases.causal_counterexample_reducer_durable_release,.releases.bounded_observational_equivalence_durable_release,.releases.semantic_wave_merge_projector_durable_release) | .releases' "$contract" | sha256sum | awk '{print $1}')"
current_manifest_digest="sha256:$(sha256sum "$contract" | awk '{print $1}')"

api_requests=0
metadata_api_requests=0
asset_download_requests=0
parent_release='{}'
parent_ref='{}'
parent_tag_record='{}'
parent_contents='{}'
release_asset='{}'
rate_limit='{}'
metadata_state=UNKNOWN
contents_state=UNKNOWN
public_tag_state=UNKNOWN
asset_bytes_state=UNKNOWN
primary_state=UNKNOWN
reason="PARENT_RELEASE_OR_MANIFEST_NOT_OBSERVED"
unknown_class="PARENT_RECEIPT_UNAVAILABLE"
downloaded_bytes=0

metadata_api() {
  metadata_api_requests=$((metadata_api_requests + 1))
  api_requests=$((api_requests + 1))
  gh api "$@"
}

asset_download() {
  asset_download_requests=$((asset_download_requests + 1))
  api_requests=$((api_requests + 1))
  gh api -H 'Accept: application/octet-stream' "$@"
}

if parent_release=$(metadata_api "repos/$repo/releases/$parent_release_id" 2>/dev/null); then
  release_asset=$(jq -c --argjson id "$parent_asset_id" 'first(.assets[]? | select(.id==$id)) // {}' <<< "$parent_release")
  metadata_state=$(jq -r --arg tag "$parent_tag" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson id "$parent_release_id" --argjson asset_id "$parent_asset_id" --argjson size "$parent_asset_size" 'if .id==$id and .tag_name==$tag and .draft==false and .prerelease==false and .immutable==true and ([.assets[]? | select(.id==$asset_id and .name==$name and .size==$size and .digest==$digest)]|length)==1 then "CLOSED" else "REFUTED" end' <<< "$parent_release")
else
  reason="PARENT_V050_RELEASE_METADATA_NOT_OBSERVED"
  unknown_class="PARENT_RELEASE_UNAVAILABLE"
fi
if parent_ref=$(metadata_api "repos/$repo/git/ref/tags/$parent_tag" 2>/dev/null); then :; else reason="PARENT_V050_TAG_REF_NOT_OBSERVED"; unknown_class="PARENT_TAG_UNAVAILABLE"; fi
if parent_tag_record=$(metadata_api "repos/$repo/git/tags/$parent_tag_object" 2>/dev/null); then :; else reason="PARENT_V050_TAG_OBJECT_NOT_OBSERVED"; unknown_class="PARENT_TAG_UNAVAILABLE"; fi
if parent_contents=$(metadata_api "repos/$repo/contents/contracts/release-locks-v1.json?ref=$parent_target" 2>/dev/null); then :; else reason="PARENT_V050_LOCK_MANIFEST_NOT_OBSERVED"; unknown_class="PARENT_MANIFEST_UNAVAILABLE"; fi
if rate_limit=$(metadata_api rate_limit 2>/dev/null); then :; else rate_limit='{}'; fi

tag_state=$(jq -r --arg object "$parent_tag_object" 'if .object.sha==$object and .object.type=="tag" then "CLOSED" else "REFUTED" end' <<< "$parent_ref")
target_state=$(jq -r --arg target "$parent_target" 'if .object.sha==$target and .object.type=="commit" then "CLOSED" else "REFUTED" end' <<< "$parent_tag_record")
contents_state=$(jq -r --arg sha "$parent_manifest_sha" --argjson size "$parent_manifest_size" 'if .sha==$sha and .size==$size and .encoding=="base64" then "CLOSED" else "REFUTED" end' <<< "$parent_contents")
if public_refs=$(git ls-remote "https://github.com/$repo.git" "refs/tags/$parent_tag" "refs/tags/$parent_tag^{}" 2>/dev/null); then
  if test "$(awk -v ref="refs/tags/$parent_tag" '$2==ref {print $1}' <<< "$public_refs")" = "$parent_tag_object" && test "$(awk -v ref="refs/tags/$parent_tag^{}" '$2==ref {print $1}' <<< "$public_refs")" = "$parent_target"; then public_tag_state=CLOSED; else public_tag_state=REFUTED; fi
fi

if [ "$contents_state" = CLOSED ]; then
  jq -r '.content' <<< "$parent_contents" | tr -d '\r\n' | base64 --decode > "$temp_root/parent-lock-manifest.json"
  observed_digest="sha256:$(sha256sum "$temp_root/parent-lock-manifest.json" | awk '{print $1}')"
  observed_lock_set="sha256:$(jq -cS '.releases' "$temp_root/parent-lock-manifest.json" | sha256sum | awk '{print $1}')"
  if test "$(wc -c < "$temp_root/parent-lock-manifest.json" | tr -d ' ')" != "$parent_manifest_size" || test "$observed_digest" != "$parent_manifest_digest" || test "$observed_lock_set" != "$parent_lock_set_digest"; then
    contents_state=REFUTED
    reason="PARENT_V050_LOCK_MANIFEST_BYTES_CONTRADICTED"
    unknown_class="PARENT_RECEIPT_CONTRADICTION"
  fi
fi

if [ "$metadata_state" = REFUTED ] || [ "$tag_state" = REFUTED ] || [ "$target_state" = REFUTED ] || [ "$contents_state" = REFUTED ] || [ "$public_tag_state" = REFUTED ]; then
  primary_state=REFUTED
  reason="PARENT_V050_RELEASE_IDENTITY_OR_MANIFEST_CONTRADICTED"
  unknown_class="PARENT_RECEIPT_CONTRADICTION"
elif [ "$metadata_state" = CLOSED ] && [ "$tag_state" = CLOSED ] && [ "$target_state" = CLOSED ] && [ "$contents_state" = CLOSED ] && [ "$public_tag_state" = CLOSED ] && { [ "$current_count" -eq 62 ] || [ "$current_count" -eq 66 ]; } && [ "$current_lock_set_digest" = "$parent_lock_set_digest" ]; then
  primary_state=CLOSED
  reason="IMMUTABLE_V050_PARENT_METADATA_AND_59_LOCK_SET_MATCHED"
else
  primary_state=UNKNOWN
fi

if [ "$primary_state" != REFUTED ]; then
  if asset_download "repos/$repo/releases/assets/$parent_asset_id" > "$parent_release_zip" 2>/dev/null; then
    downloaded_bytes=$(wc -c < "$parent_release_zip" | tr -d ' ')
    asset_bytes_state=CLOSED
    if test "$downloaded_bytes" != "$parent_asset_size" || test "sha256:$(sha256sum "$parent_release_zip" | awk '{print $1}')" != "$parent_asset_digest"; then
      asset_bytes_state=REFUTED
      primary_state=REFUTED
      reason="PARENT_V050_RELEASE_ASSET_BYTES_CONTRADICTED"
      unknown_class="PARENT_RECEIPT_CONTRADICTION"
    else
      mkdir -p "$parent_release_root"
      unzip -q "$parent_release_zip" -d "$parent_release_root"
      if test -s "$parent_release_root/report.json"; then cp "$parent_release_root/report.json" "$artifact_root/v050-parent-report.json"; fi
      if test -d "$parent_release_root/releases"; then
        mkdir -p "$artifact_root/releases"
        cp -a "$parent_release_root/releases/." "$artifact_root/releases/"
        cp "$artifact_root/releases/verification.json" "$artifact_root/releases/v050-parent-verification.json"
        jq -S '.release_lock_snapshot.parallel_live_metrics.requests=0 | .release_lock_snapshot.parallel_live_metrics.selected=0 | .release_lock_snapshot.parallel_live_metrics.executed=0 | .release_lock_snapshot.parallel_live_metrics.reused=59 | .release_lock_snapshot.parallel_live_metrics.completed=0 | .release_lock_snapshot.parallel_live_metrics.duration_ns=0 | .release_lock_snapshot.parallel_live_metrics.exact_wall_ms=0 | .release_lock_snapshot.parallel_live_metrics.peak_rss_kib=0 | .release_lock_snapshot.parallel_live_metrics.wall_ms=0 | .release_lock_snapshot.parallel_live_metrics.max_in_flight=0' "$artifact_root/releases/verification.json" > "$artifact_root/releases/verification.json.tmp"
        mv "$artifact_root/releases/verification.json.tmp" "$artifact_root/releases/verification.json"
      fi
    fi
  fi
fi

remaining=$(jq -r '.resources.core.remaining // .rate.remaining // null' <<< "$rate_limit")
reset=$(jq -r '.resources.core.reset // .rate.reset // null' <<< "$rate_limit")
jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v0510-parent-lock-receipt/v1" \
  --arg state "$primary_state" --arg reason "$reason" --arg unknown_class "$unknown_class" \
  --arg repo "$repo" --arg tag "$parent_tag" --argjson release_id "$parent_release_id" --arg tag_object "$parent_tag_object" --arg target "$parent_target" \
  --argjson asset_id "$parent_asset_id" --arg asset_name "$parent_asset_name" --argjson asset_size "$parent_asset_size" --arg asset_digest "$parent_asset_digest" \
  --arg manifest_digest "$parent_manifest_digest" --arg lock_digest "$parent_lock_set_digest" --arg current_lock_digest "$current_lock_set_digest" --arg current_manifest "$current_manifest_digest" --argjson current_count "$current_count" \
  --argjson api_requests "$api_requests" --argjson metadata_requests "$metadata_api_requests" --argjson asset_download_requests "$asset_download_requests" --argjson downloaded_bytes "$downloaded_bytes" \
  --arg metadata_state "$metadata_state" --arg tag_state "$tag_state" --arg target_state "$target_state" --arg contents_state "$contents_state" --arg public_tag_state "$public_tag_state" --arg asset_bytes_state "$asset_bytes_state" \
  --argjson remaining "$remaining" --argjson reset "$reset" \
  '{schema:$schema,parent:{repository:$repo,tag:$tag,release_id:$release_id,tag_object_sha:$tag_object,target_commit_sha:$target,immutable:true,release_asset:{id:$asset_id,name:$asset_name,size_bytes:$asset_size,sha256:$asset_digest},release_lock_manifest:{sha256:$manifest_digest,size_bytes:307511,contents_blob_sha:"9b3cb03c401a2faa6044cc05ad58030504a09a7f"},parent_lock_set_digest:$lock_digest},primary:{state:$state,reason:$reason,unknown:(if $state=="UNKNOWN" then {stage:"PARENT_RECEIPT",step:"READ_IMMUTABLE_V050_RECEIPT",reason:$reason,unknown_class:$unknown_class,next_operation:"RUN_FULL_59_LOCK_AUDIT",blocked_by:["v050-parent-release-receipt"]} else null end),refuted:(if $state=="REFUTED" then {stage:"PARENT_RECEIPT",step:"COMPARE_IMMUTABLE_V050_RECEIPT",reason:$reason,unknown_class:$unknown_class,next_operation:"RUN_FULL_59_LOCK_AUDIT",blocked_by:["v050-parent-release-receipt-contradiction"]} else null end),api_observation:{requests:0,selected:0,executed:0,reused:(if $state=="CLOSED" then 59 else 0 end),bytes_read:0,bytes_downloaded:0,source:(if $state=="CLOSED" then "PARENT_V050_RELEASE_RECEIPT_REUSE" else "PENDING_FULL_59_LOCK_AUDIT" end)}},lock_set:{current_count:$current_count,current_digest:("sha256:" + ($current_lock_digest|sub("^sha256:";""))),parent_count:59,parent_digest:$lock_digest,unchanged_59_lock_set:($current_lock_digest==$lock_digest)},release_lock_manifest:{current_digest:$current_manifest,parent_digest:$manifest_digest,parent_contents_blob_sha:"9b3cb03c401a2faa6044cc05ad58030504a09a7f",parent_contents_size_bytes:307511},parent_input_observation:{api_requests:$api_requests,metadata_api_requests:$metadata_requests,release_asset_download_requests:$asset_download_requests,bytes_downloaded:$downloaded_bytes,observed_states:{release_metadata:$metadata_state,tag_ref:$tag_state,tag_object:$target_state,contents:$contents_state,public_tag_refs:$public_tag_state,release_asset_bytes:$asset_bytes_state},rate_limit:{remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)},source:"GITHUB_API_AND_IMMUTABLE_RELEASE_ASSET"},full_fallback:{required:($state!="CLOSED"),state:(if $state=="CLOSED" then "NOT_REQUIRED" else "PENDING" end),selected:(if $state=="CLOSED" then 0 else 59 end),executed:0,reused:(if $state=="CLOSED" then 59 else 0 end)},authority:{verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,local_test_executions:0,cross_project_required_gates:0,caller_owned_temp_outputs_only:true}}' > "$receipt"

cp "$receipt" "$artifact_root/v0500-parent-lock-receipt.json"
echo "v0.51 parent receipt: primary=$primary_state metadata_api_requests=$metadata_api_requests asset_download_requests=$asset_download_requests current_locks=$current_count reused_59=$(if test "$primary_state" = CLOSED; then echo 59; else echo 0; fi)"
