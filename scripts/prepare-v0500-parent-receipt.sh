#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.50 parent receipt preparation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: prepare-v0500-parent-receipt.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
contract="$repository/contracts/release-locks-v1.json"
receipt="$artifact_root/v0500-parent-lock-receipt.json"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0500-parent-temp}"
parent_source_root="$temp_root/parent-source-artifact"
parent_release_root="$temp_root/parent-release-asset"
parent_artifact_zip="$temp_root/parent-source-artifact.zip"
parent_release_zip="$temp_root/parent-release-asset.zip"
api_request_counter="$temp_root/api-request-count"

command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v unzip >/dev/null
command -v git >/dev/null
command -v wc >/dev/null
command -v base64 >/dev/null
test -n "${GH_TOKEN:-}"
test -s "$contract"
mkdir -p "$artifact_root" "$temp_root"
printf '0\n' > "$api_request_counter"

repo="kimjooyoon/gooo-self-improvement-ledger"
parent_tag="v0.49.0"
parent_release_id=380810861
parent_tag_object="36f4fa271a72616a39a703c9658e905b670f5f64"
parent_target="036d2d1e25df72a5568aeb16f6ac0a077ce4471f"
parent_asset_id=540115901
parent_asset_name="gooo-self-improvement-ledger-036d2d1e25df72a5568aeb16f6ac0a077ce4471f"
parent_artifact_id=9819745734
parent_run_id=33556630730
parent_job_id=100018938289
parent_size=84127616
parent_digest="sha256:e680c234fee34e36bae27685a29c716208cf83bb67e9375a31a9ee5194ca5208"
expected_manifest_digest="sha256:7fbcb681ac47f1ae26935615229c824b21d4aca08ea41cb7639d74ea5bdf38a3"
expected_lock_set_digest="sha256:5d36775c847acd70597cf92717106265f50e3719daa45d2d0fc29f8cc595cf71"

current_lock_count=$(jq '.releases | length' "$contract")
current_manifest_digest="sha256:$(sha256sum "$contract" | awk '{print $1}')"
current_lock_set_digest="sha256:$(jq -cS '.releases' "$contract" | sha256sum | awk '{print $1}')"

api_requests=0
downloaded_bytes=0
parent_release='{}'
parent_ref='{}'
parent_tag_record='{}'
parent_artifact='{}'
parent_run='{}'
parent_job='{}'
parent_contents='{}'
public_refs=""
release_asset='{}'
release_fetch_state=UNKNOWN
artifact_fetch_state=UNKNOWN
artifact_download_state=UNKNOWN
release_asset_download_state=UNKNOWN
parent_manifest_digest=""
parent_lock_set_digest=""
release_manifest_digest=""
release_lock_set_digest=""
reason="PARENT_RECEIPT_NOT_OBSERVED"
unknown_class=PARENT_RECEIPT_UNAVAILABLE
primary_state=UNKNOWN

github_api() {
  request_count=$(cat "$api_request_counter")
  printf '%d\n' "$((request_count + 1))" > "$api_request_counter"
  gh api "$@"
}

download_api() {
  request_count=$(cat "$api_request_counter")
  printf '%d\n' "$((request_count + 1))" > "$api_request_counter"
  gh api -H "Accept: application/octet-stream" "$@"
}

record_download_bytes() {
  local path=$1
  downloaded_bytes=$((downloaded_bytes + $(wc -c < "$path" | tr -d ' ')))
}

if parent_release=$(github_api "repos/$repo/releases/$parent_release_id" 2>/dev/null); then
  release_asset=$(jq -c --argjson id "$parent_asset_id" 'first(.assets[]? | select(.id==$id)) // {}' <<< "$parent_release")
else
  reason="PARENT_IMMUTABLE_RELEASE_API_NOT_OBSERVED"
  unknown_class=PARENT_RELEASE_UNAVAILABLE
fi

if parent_ref=$(github_api "repos/$repo/git/ref/tags/$parent_tag" 2>/dev/null); then :; else
  reason="PARENT_ANNOTATED_TAG_REF_NOT_OBSERVED"
  unknown_class=PARENT_TAG_UNAVAILABLE
fi
if parent_tag_record=$(github_api "repos/$repo/git/tags/$parent_tag_object" 2>/dev/null); then :; else
  reason="PARENT_ANNOTATED_TAG_OBJECT_NOT_OBSERVED"
  unknown_class=PARENT_TAG_UNAVAILABLE
fi
if parent_artifact=$(github_api "repos/$repo/actions/artifacts/$parent_artifact_id" 2>/dev/null); then :; else
  reason="PARENT_SOURCE_ARTIFACT_METADATA_NOT_OBSERVED"
  unknown_class=PARENT_ARTIFACT_UNAVAILABLE
fi
if parent_run=$(github_api "repos/$repo/actions/runs/$parent_run_id" 2>/dev/null); then :; else
  reason="PARENT_SOURCE_RUN_NOT_OBSERVED"
  unknown_class=PARENT_RUN_UNAVAILABLE
fi
if parent_job=$(github_api "repos/$repo/actions/jobs/$parent_job_id" 2>/dev/null); then :; else
  reason="PARENT_SOURCE_JOB_NOT_OBSERVED"
  unknown_class=PARENT_JOB_UNAVAILABLE
fi
if parent_contents=$(github_api "repos/$repo/contents/contracts/release-locks-v1.json?ref=$parent_target" 2>/dev/null); then :; else
  reason="PARENT_RELEASE_LOCK_MANIFEST_CONTENTS_NOT_OBSERVED"
  unknown_class=PARENT_MANIFEST_UNAVAILABLE
fi
if public_refs=$(git ls-remote "https://github.com/$repo.git" "refs/tags/$parent_tag" "refs/tags/$parent_tag^{}" 2>/dev/null); then :; else
  reason="PARENT_PUBLIC_TAG_REFS_NOT_OBSERVED"
  unknown_class=PARENT_TAG_UNAVAILABLE
fi

release_identity_state=$(jq -r --argjson id "$parent_release_id" --arg tag "$parent_tag" --argjson asset_id "$parent_asset_id" --arg name "$parent_asset_name" --argjson size "$parent_size" --arg digest "$parent_digest" '
  if (.id==null or .tag_name==null or .immutable==null or .assets==null) then "UNKNOWN"
  elif .id==$id and .tag_name==$tag and .draft==false and .prerelease==false and .immutable==true and
       ([.assets[] | select(.id==$asset_id and .name==$name and .size==$size and .digest==$digest)] | length)==1 then "CLOSED"
  else "REFUTED" end
' <<< "$parent_release")
tag_identity_state=$(jq -r --arg object "$parent_tag_object" --arg target "$parent_target" '
  if (.object.sha==null or .object.type==null) then "UNKNOWN"
  elif .object.sha==$object and .object.type=="tag" then "CLOSED" else "REFUTED" end
' <<< "$parent_ref")
target_identity_state=$(jq -r --arg target "$parent_target" 'if (.object.sha==null or .object.type==null) then "UNKNOWN" elif .object.sha==$target and .object.type=="commit" then "CLOSED" else "REFUTED" end' <<< "$parent_tag_record")
artifact_identity_state=$(jq -r --argjson id "$parent_artifact_id" --arg name "$parent_asset_name" --argjson size "$parent_size" --arg digest "$parent_digest" --argjson run "$parent_run_id" --arg sha "$parent_target" '
  if (.id==null or .name==null or .size_in_bytes==null or .digest==null or .workflow_run==null) then "UNKNOWN"
  elif .id==$id and .name==$name and .size_in_bytes==$size and .digest==$digest and .expired==false and
       .workflow_run.id==$run and .workflow_run.head_branch=="main" and .workflow_run.head_sha==$sha then "CLOSED"
  else "REFUTED" end
' <<< "$parent_artifact")
run_identity_state=$(jq -r --argjson id "$parent_run_id" --arg sha "$parent_target" 'if (.id==null or .head_sha==null or .status==null) then "UNKNOWN" elif .id==$id and .head_sha==$sha and .head_branch=="main" and .event=="push" and .status=="completed" and .conclusion=="success" then "CLOSED" else "REFUTED" end' <<< "$parent_run")
job_identity_state=$(jq -r --argjson id "$parent_job_id" --argjson run "$parent_run_id" --arg sha "$parent_target" 'if (.id==null or .run_id==null or .head_sha==null or .status==null) then "UNKNOWN" elif .id==$id and .run_id==$run and .head_sha==$sha and .status=="completed" and .conclusion=="success" then "CLOSED" else "REFUTED" end' <<< "$parent_job")
contents_state=$(jq -r --arg sha "9b3cb03c401a2faa6044cc05ad58030504a09a7f" --argjson size 307511 'if (.sha==null or .size==null or .encoding==null) then "UNKNOWN" elif .sha==$sha and .size==$size and .encoding=="base64" then "CLOSED" else "REFUTED" end' <<< "$parent_contents")
public_tag_state=$(if test "$(awk '$2=="refs/tags/v0.49.0" {print $1}' <<< "$public_refs")" = "$parent_tag_object" && test "$(awk '$2=="refs/tags/v0.49.0^{}" {print $1}' <<< "$public_refs")" = "$parent_target"; then echo CLOSED; elif test -n "$public_refs"; then echo REFUTED; else echo UNKNOWN; fi)

if [ "$contents_state" = CLOSED ]; then
  if jq -r '.content' <<< "$parent_contents" | tr -d '\r\n' | base64 --decode > "$temp_root/parent-lock-manifest.json"; then
    content_manifest_digest="sha256:$(sha256sum "$temp_root/parent-lock-manifest.json" | awk '{print $1}')"
    content_lock_set_digest="sha256:$(jq -cS '.releases' "$temp_root/parent-lock-manifest.json" | sha256sum | awk '{print $1}')"
    if [ "$(wc -c < "$temp_root/parent-lock-manifest.json" | tr -d ' ')" != "307511" ] || [ "$content_manifest_digest" != "$expected_manifest_digest" ] || [ "$content_lock_set_digest" != "$expected_lock_set_digest" ]; then
      contents_state=REFUTED
      reason="PARENT_CONTENTS_MANIFEST_BYTES_OR_DIGEST_CONTRADICT_IMMUTABLE_RECEIPT"
      unknown_class=PARENT_RECEIPT_CONTRADICTION
    else
      parent_manifest_digest="$content_manifest_digest"
      parent_lock_set_digest="$content_lock_set_digest"
    fi
  else
    contents_state=UNKNOWN
    reason="PARENT_CONTENTS_MANIFEST_DECODE_NOT_OBSERVED"
    unknown_class=PARENT_MANIFEST_UNAVAILABLE
  fi
fi

if [ "$release_identity_state" = REFUTED ] || [ "$tag_identity_state" = REFUTED ] || [ "$target_identity_state" = REFUTED ] || [ "$artifact_identity_state" = REFUTED ] || [ "$run_identity_state" = REFUTED ] || [ "$job_identity_state" = REFUTED ] || [ "$contents_state" = REFUTED ] || [ "$public_tag_state" = REFUTED ]; then
  primary_state=REFUTED
  reason="PARENT_RELEASE_OR_SOURCE_ARTIFACT_IDENTITY_CONTRADICTS_IMMUTABLE_RECEIPT"
  unknown_class=PARENT_RECEIPT_CONTRADICTION
elif [ "$release_identity_state" != CLOSED ] || [ "$tag_identity_state" != CLOSED ] || [ "$target_identity_state" != CLOSED ] || [ "$artifact_identity_state" != CLOSED ] || [ "$run_identity_state" != CLOSED ] || [ "$job_identity_state" != CLOSED ] || [ "$contents_state" != CLOSED ] || [ "$public_tag_state" != CLOSED ]; then
  primary_state=UNKNOWN
  reason="PARENT_RELEASE_OR_SOURCE_ARTIFACT_IDENTITY_NOT_OBSERVED"
  unknown_class=PARENT_RECEIPT_UNAVAILABLE
fi

if [ "$primary_state" = UNKNOWN ] && [ "$parent_manifest_digest" = "$expected_manifest_digest" ] && [ "$parent_lock_set_digest" = "$expected_lock_set_digest" ] && [ "$current_lock_count" -eq 59 ] && [ "$current_manifest_digest" = "$expected_manifest_digest" ] && [ "$current_lock_set_digest" = "$expected_lock_set_digest" ]; then
  primary_state=CLOSED
  reason="IMMUTABLE_PARENT_METADATA_AND_CONTENTS_MANIFEST_MATCHED"
fi

if [ "$primary_state" != REFUTED ]; then
  if download_api "repos/$repo/actions/artifacts/$parent_artifact_id/zip" > "$parent_artifact_zip" 2>/dev/null; then
    artifact_download_state=CLOSED
    record_download_bytes "$parent_artifact_zip"
    if [ "$(wc -c < "$parent_artifact_zip" | tr -d ' ')" != "$parent_size" ] || [ "sha256:$(sha256sum "$parent_artifact_zip" | awk '{print $1}')" != "$parent_digest" ]; then
      artifact_download_state=REFUTED
      primary_state=REFUTED
      reason="PARENT_SOURCE_ARTIFACT_BYTES_OR_DIGEST_CONTRADICT_IMMUTABLE_METADATA"
      unknown_class=PARENT_RECEIPT_CONTRADICTION
    else
      rm -rf "$parent_source_root"
      mkdir -p "$parent_source_root"
      unzip -q "$parent_artifact_zip" -d "$parent_source_root"
      artifact_manifest="$parent_source_root/contracts/release-locks-v1.json"
      if [ -s "$artifact_manifest" ]; then
        parent_manifest_digest="sha256:$(sha256sum "$artifact_manifest" | awk '{print $1}')"
        parent_lock_set_digest="sha256:$(jq -cS '.releases' "$artifact_manifest" | sha256sum | awk '{print $1}')"
        if [ "$parent_manifest_digest" != "$expected_manifest_digest" ] || [ "$parent_lock_set_digest" != "$expected_lock_set_digest" ]; then
          artifact_download_state=REFUTED
          primary_state=REFUTED
          reason="PARENT_SOURCE_ARTIFACT_LOCK_MANIFEST_CONTRADICTS_CONTENTS_MANIFEST"
          unknown_class=PARENT_RECEIPT_CONTRADICTION
        fi
      fi
    fi
  fi
fi

if [ "$primary_state" != REFUTED ]; then
  if download_api "repos/$repo/releases/assets/$parent_asset_id" > "$parent_release_zip" 2>/dev/null; then
    release_asset_download_state=CLOSED
    record_download_bytes "$parent_release_zip"
    if [ "$(wc -c < "$parent_release_zip" | tr -d ' ')" != "$parent_size" ] || [ "sha256:$(sha256sum "$parent_release_zip" | awk '{print $1}')" != "$parent_digest" ]; then
      release_asset_download_state=REFUTED
      primary_state=REFUTED
      reason="PARENT_RELEASE_ASSET_BYTES_OR_DIGEST_CONTRADICT_IMMUTABLE_METADATA"
      unknown_class=PARENT_RECEIPT_CONTRADICTION
    else
      rm -rf "$parent_release_root"
      mkdir -p "$parent_release_root"
      unzip -q "$parent_release_zip" -d "$parent_release_root"
      release_manifest="$parent_release_root/contracts/release-locks-v1.json"
      if [ -s "$release_manifest" ]; then
        release_manifest_digest="sha256:$(sha256sum "$release_manifest" | awk '{print $1}')"
        release_lock_set_digest="sha256:$(jq -cS '.releases' "$release_manifest" | sha256sum | awk '{print $1}')"
        if [ "$release_manifest_digest" != "$expected_manifest_digest" ] || [ "$release_lock_set_digest" != "$expected_lock_set_digest" ]; then
          release_asset_download_state=REFUTED
          primary_state=REFUTED
          reason="PARENT_RELEASE_ASSET_LOCK_MANIFEST_CONTRADICTS_CONTENTS_MANIFEST"
          unknown_class=PARENT_RECEIPT_CONTRADICTION
        fi
      else
        release_manifest_digest="$parent_manifest_digest"
        release_lock_set_digest="$parent_lock_set_digest"
      fi
      if [ "$primary_state" = CLOSED ]; then
        copy_root="$parent_source_root"
        if [ ! -d "$copy_root/releases" ]; then copy_root="$parent_release_root"; fi
        mkdir -p "$artifact_root/releases"
        cp -a "$copy_root/releases/." "$artifact_root/releases/"
        cp "$artifact_root/releases/verification.json" "$artifact_root/releases/v049-full-audit-verification.json"
        jq -S '
          .release_lock_snapshot.parallel_live_metrics.requests=0 |
          .release_lock_snapshot.parallel_live_metrics.selected=0 |
          .release_lock_snapshot.parallel_live_metrics.executed=0 |
          .release_lock_snapshot.parallel_live_metrics.reused=59 |
          .release_lock_snapshot.parallel_live_metrics.completed=0 |
          .release_lock_snapshot.parallel_live_metrics.duration_ns=0 |
          .release_lock_snapshot.parallel_live_metrics.exact_wall_ms=0 |
          .release_lock_snapshot.parallel_live_metrics.peak_rss_kib=0 |
          .release_lock_snapshot.parallel_live_metrics.wall_ms=0 |
          .release_lock_snapshot.parallel_live_metrics.max_in_flight=0
        ' "$artifact_root/releases/verification.json" > "$artifact_root/releases/verification.json.tmp"
        mv "$artifact_root/releases/verification.json.tmp" "$artifact_root/releases/verification.json"
      fi
    fi
  else
    primary_state=UNKNOWN
    reason="PARENT_RELEASE_ASSET_DOWNLOAD_NOT_OBSERVED"
    unknown_class=PARENT_RELEASE_UNAVAILABLE
  fi
fi

rate_limit='{}'
if observed_rate=$(github_api rate_limit 2>/dev/null); then rate_limit="$observed_rate"; fi
rate_remaining=$(jq -r '.resources.core.remaining // .rate.remaining // null' <<< "$rate_limit")
rate_reset=$(jq -r '.resources.core.reset // .rate.reset // null' <<< "$rate_limit")
api_requests=$(cat "$api_request_counter")
parent_manifest_digest=${parent_manifest_digest:-null}
parent_lock_set_digest=${parent_lock_set_digest:-null}
release_manifest_digest=${release_manifest_digest:-null}
release_lock_set_digest=${release_lock_set_digest:-null}

jq -S . <<< "$parent_release" > "$temp_root/parent-release.json"
jq -S . <<< "$parent_ref" > "$temp_root/parent-ref.json"
jq -S . <<< "$parent_tag_record" > "$temp_root/parent-tag-record.json"
jq -S . <<< "$parent_artifact" > "$temp_root/parent-artifact.json"
jq -S . <<< "$parent_run" > "$temp_root/parent-run.json"
jq -S . <<< "$parent_job" > "$temp_root/parent-job.json"
jq -S . <<< "$parent_contents" > "$temp_root/parent-contents.json"
jq -S . <<< "$release_asset" > "$temp_root/release-asset.json"

if [ "$primary_state" = CLOSED ]; then
  primary_mode=CONTENT_ADDRESSED_PARENT_RELEASE_REUSE
  fallback_required=false
  fallback_state=NOT_REQUIRED
  fallback_reason=""
  primary_selected=0
  primary_executed=0
  primary_reused=59
else
  primary_mode=FULL_59_LOCK_AUDIT_FALLBACK_REQUIRED
  fallback_required=true
  fallback_state=PENDING
  fallback_reason=RUN_FULL_59_LOCK_AUDIT
  primary_selected=0
  primary_executed=0
  primary_reused=0
fi

jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v050-parent-lock-receipt/v1" \
  --arg state "$primary_state" --arg mode "$primary_mode" --arg reason "$reason" --arg unknown_class "$unknown_class" \
  --argjson current_count "$current_lock_count" --arg current_manifest "$current_manifest_digest" --arg current_lock_set "$current_lock_set_digest" \
  --arg parent_manifest "$parent_manifest_digest" --arg parent_lock_set "$parent_lock_set_digest" \
  --arg release_manifest "$release_manifest_digest" --arg release_lock_set "$release_lock_set_digest" \
  --argjson api_requests "$api_requests" --argjson downloaded_bytes "$downloaded_bytes" \
  --argjson selected "$primary_selected" --argjson executed "$primary_executed" --argjson reused "$primary_reused" \
  --argjson remaining "$rate_remaining" --argjson reset "$rate_reset" \
  --arg fallback_state "$fallback_state" --arg fallback_reason "$fallback_reason" --argjson fallback_required "$fallback_required" \
  --slurpfile release "$temp_root/parent-release.json" --slurpfile ref "$temp_root/parent-ref.json" --slurpfile tag_record "$temp_root/parent-tag-record.json" --slurpfile artifact "$temp_root/parent-artifact.json" --slurpfile run "$temp_root/parent-run.json" --slurpfile job "$temp_root/parent-job.json" --slurpfile contents "$temp_root/parent-contents.json" \
  --slurpfile asset "$temp_root/release-asset.json" --arg public_refs "$public_refs" \
  --argjson parent_release_id "$parent_release_id" --arg parent_tag "$parent_tag" --arg parent_tag_object "$parent_tag_object" --arg parent_target "$parent_target" \
  --argjson parent_asset_id "$parent_asset_id" --arg parent_asset_name "$parent_asset_name" --argjson parent_artifact_id "$parent_artifact_id" --argjson parent_run_id "$parent_run_id" --argjson parent_job_id "$parent_job_id" --argjson parent_size "$parent_size" --arg parent_digest "$parent_digest" \
  --arg artifact_download_state "$artifact_download_state" --arg release_asset_download_state "$release_asset_download_state" \
  '{schema:$schema,parent:{repository:"kimjooyoon/gooo-self-improvement-ledger",tag:$parent_tag,release_id:$parent_release_id,tag_object_sha:$parent_tag_object,target_commit_sha:$parent_target,release_asset:{id:$parent_asset_id,name:$parent_asset_name,size_bytes:$parent_size,sha256:$parent_digest},source_artifact:{id:$parent_artifact_id,run_id:$parent_run_id,job_id:$parent_job_id,size_bytes:$parent_size,sha256:$parent_digest},release_lock_manifest_digest:$parent_manifest,lock_set_digest:$parent_lock_set},primary:{state:$state,mode:$mode,reason:$reason,unknown:(if $state=="UNKNOWN" then {stage:"PARENT_RECEIPT",step:"READ_IMMUTABLE_PARENT_RECEIPT",reason:$reason,unknown_class:$unknown_class,next_operation:"RUN_FULL_59_LOCK_AUDIT",blocked_by:["parent-release-receipt"]} else null end),refuted:(if $state=="REFUTED" then {stage:"PARENT_RECEIPT",step:"COMPARE_IMMUTABLE_PARENT_RECEIPT",reason:$reason,unknown_class:$unknown_class,next_operation:"RUN_FULL_59_LOCK_AUDIT",blocked_by:["parent-release-receipt-contradiction"]} else null end),api_observation:{requests:0,selected:$selected,executed:$executed,reused:$reused,bytes_read:0,bytes_downloaded:0,rate_limit:{remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)},source:(if $state=="CLOSED" then "PARENT_RELEASE_RECEIPT_REUSE" else "PENDING_FULL_59_LOCK_AUDIT" end)}},lock_set:{count:$current_count,current_digest:$current_lock_set,parent_digest:$parent_lock_set,unchanged:($state=="CLOSED")},release_lock_manifest:{current_digest:$current_manifest,parent_digest:$parent_manifest,release_asset_digest:$release_manifest,source_artifact_digest:$parent_manifest,unchanged:($state=="CLOSED")},parent_fetch_observation:{api_requests:$api_requests,selected:0,executed:0,reused:0,bytes_read:0,bytes_downloaded:$downloaded_bytes,rate_limit:{remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)},source_artifact_download:{state:$artifact_download_state,metadata_digest:$parent_digest},release_asset_download:{state:$release_asset_download_state,metadata_digest:$parent_digest},release_api_identity:{state:(if $release[0].id==null then "UNKNOWN" elif $release[0].id==$parent_release_id and $release[0].immutable==true then "CLOSED" else "REFUTED" end)},tag_ref:$ref[0],tag_object:$tag_record[0],source_artifact:$artifact[0],source_run:$run[0],source_job:$job[0],manifest_contents:$contents[0],release_asset:$asset[0],public_tag_refs:$public_refs},full_fallback:{required:$fallback_required,state:$fallback_state,reason:$fallback_reason},authority:{verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,local_test_executions:0,cross_project_required_gates:0,caller_owned_temp_outputs_only:true}}' \
  > "$receipt"

echo "v0.50 parent receipt: primary=$primary_state lock_set=$current_lock_set_digest api_requests=$api_requests selected=$primary_selected executed=$primary_executed reused=$primary_reused"
