#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.54 parent receipt preparation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: prepare-v0540-parent-receipt.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
lock_file="$repository/contracts/release-locks-v1.json"
release_repo="kimjooyoon/gooo-self-improvement-ledger"
parent_tag="v0.53.0"
parent_release_id=380943341
parent_asset_id=540503110
parent_asset_name="gooo-self-improvement-ledger-217fa01"
parent_asset_size=58162484
parent_asset_digest="sha256:6a63abbe48cbe5ccf6955b81a19de1d7a6ec7301d595d0152bdff7ac997e7ae3"
parent_tag_object="dd204df84abecdd634e9321cc40b2714f91d96eb"
parent_target="e84c9209316cfa6d07d2ea96d988d05c8c6f7367"
parent_manifest_blob="2c6877c2fea2090fe19ab0782872c076dd79507c"
parent_manifest_size=314813
parent_manifest_digest="sha256:8802e3874758fb4f00a2c8ad906f23b51524bdbcc06f308fcf91688a296e7bb9"
parent_lock_set_digest="sha256:31f9885ee4282a1b72308021814c968221003d9bcbdc5b1ec4c7533c2fd59635"

temp_root="${RUNNER_TEMP:-$artifact_root/.v0540-parent-temp}"
parent_root="$temp_root/v053-parent-release"
parent_zip="$temp_root/v053-parent-release.zip"
mkdir -p "$artifact_root/releases" "$temp_root"
command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v unzip >/dev/null
command -v base64 >/dev/null
command -v awk >/dev/null
command -v wc >/dev/null
test -n "${GH_TOKEN:-}"

current_count=$(jq '.releases|length' "$lock_file")
current_parent_digest="sha256:$(jq -cS 'del(.releases.output_authority_projector_durable_release,.releases.protected_change_gate_projector_durable_release)|.releases' "$lock_file" | sha256sum | awk '{print $1}')"
current_manifest_digest="sha256:$(sha256sum "$lock_file" | awk '{print $1}')"
test "$current_count" -eq 72
test "$current_parent_digest" = "$parent_lock_set_digest"

release_json=$(gh api "repos/$release_repo/releases/$parent_release_id")
jq -e --arg tag "$parent_tag" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson release_id "$parent_release_id" --argjson asset_id "$parent_asset_id" --argjson size "$parent_asset_size" '
  .id==$release_id and .tag_name==$tag and .draft==false and .prerelease==false and .immutable==true and
  ([.assets[]|select(.id==$asset_id and .name==$name and .size==$size and .digest==$digest and .expired==false)]|length)==1
' <<<"$release_json" >/dev/null

tag_ref=$(gh api "repos/$release_repo/git/ref/tags/$parent_tag")
jq -e --arg tag_object "$parent_tag_object" '.object.sha==$tag_object and .object.type=="tag"' <<<"$tag_ref" >/dev/null
tag_record=$(gh api "repos/$release_repo/git/tags/$parent_tag_object")
jq -e --arg target "$parent_target" '.object.sha==$target and .object.type=="commit"' <<<"$tag_record" >/dev/null
public_refs=$(git ls-remote "https://github.com/$release_repo.git" "refs/tags/$parent_tag" "refs/tags/$parent_tag^{}")
test "$(awk -v ref="refs/tags/$parent_tag" '$2==ref {print $1}' <<<"$public_refs")" = "$parent_tag_object"
test "$(awk -v ref="refs/tags/$parent_tag^{}" '$2==ref {print $1}' <<<"$public_refs")" = "$parent_target"

manifest_json=$(gh api "repos/$release_repo/contents/contracts/release-locks-v1.json?ref=$parent_target")
jq -e --arg blob "$parent_manifest_blob" --argjson size "$parent_manifest_size" '.sha==$blob and .size==$size and .encoding=="base64"' <<<"$manifest_json" >/dev/null
jq -r '.content' <<<"$manifest_json" | tr -d '\r\n' | base64 --decode > "$temp_root/parent-lock-manifest.json"
test "$(wc -c <"$temp_root/parent-lock-manifest.json" | tr -d ' ')" = "$parent_manifest_size"
test "sha256:$(sha256sum "$temp_root/parent-lock-manifest.json" | awk '{print $1}')" = "$parent_manifest_digest"
test "sha256:$(jq -cS '.releases' "$temp_root/parent-lock-manifest.json" | sha256sum | awk '{print $1}')" = "$parent_lock_set_digest"
test "$(jq '.releases|length' "$temp_root/parent-lock-manifest.json")" -eq 70

rm -rf "$parent_root"
mkdir -p "$parent_root"
gh api -H 'Accept: application/octet-stream' "repos/$release_repo/releases/assets/$parent_asset_id" > "$parent_zip"
test "$(wc -c <"$parent_zip" | tr -d ' ')" = "$parent_asset_size"
test "sha256:$(sha256sum "$parent_zip" | awk '{print $1}')" = "$parent_asset_digest"
unzip -q "$parent_zip" -d "$parent_root"
test -s "$parent_root/report.json"
test -s "$parent_root/releases/verification.json"
bash "$repository/scripts/verify-v0530-release-input.sh" --artifact "$parent_root"
cp -a "$parent_root/releases/." "$artifact_root/releases/"
cp "$parent_root/releases/verification.json" "$artifact_root/releases/v0530-parent-verification.json"
cp "$parent_root/report.json" "$artifact_root/v053-parent-report.json"
for historical in v0530-parent-lock-receipt.json v0530-live-lock-receipt.json atomic-v0530-wave-v1.json; do
  if test -s "$parent_root/$historical"; then cp "$parent_root/$historical" "$artifact_root/$historical"; fi
done
if test -d "$parent_root/v0530-products"; then cp -a "$parent_root/v0530-products" "$artifact_root/v0530-products"; fi

jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v0540-parent-lock-receipt/v1" \
  --arg repo "$release_repo" --arg tag "$parent_tag" --argjson release_id "$parent_release_id" \
  --arg tag_object "$parent_tag_object" --arg target "$parent_target" \
  --argjson asset_id "$parent_asset_id" --arg asset_name "$parent_asset_name" \
  --argjson asset_size "$parent_asset_size" --arg asset_digest "$parent_asset_digest" \
  --arg manifest_blob "$parent_manifest_blob" --argjson manifest_size "$parent_manifest_size" \
  --arg manifest_digest "$parent_manifest_digest" --arg lock_digest "$parent_lock_set_digest" \
  --arg current_manifest "$current_manifest_digest" --arg current_lock "$current_parent_digest" \
  --argjson current_count "$current_count" \
  '{schema:$schema,
    parent:{repository:$repo,tag:$tag,release_id:$release_id,immutable:true,tag_object_sha:$tag_object,target_commit_sha:$target,
      release_asset:{id:$asset_id,name:$asset_name,size_bytes:$asset_size,sha256:$asset_digest},
      release_lock_manifest:{sha256:$manifest_digest,size_bytes:$manifest_size,contents_blob_sha:$manifest_blob},
      parent_lock_set_digest:$lock_digest},
    primary:{state:"CLOSED",reason:"IMMUTABLE_V053_PARENT_METADATA_BYTES_AND_70_LOCK_SET_MATCHED",unknown:null,refuted:null,
      api_observation:{selected:0,executed:0,reused:70,source:"PARENT_V0530_RELEASE_RECEIPT_REUSE"}},
    lock_set:{current_count:$current_count,current_digest:$current_lock,parent_count:70,parent_digest:$lock_digest,unchanged_70_lock_set:($current_lock==$lock_digest),current_manifest_digest:$current_manifest},
    release_lock_manifest:{parent_contents_blob_sha:$manifest_blob,parent_contents_size_bytes:$manifest_size,parent_digest:$manifest_digest},
    full_fallback:{required:false,state:"NOT_REQUIRED",selected:0,executed:0,reused:70},
    authority:{verification:"GITHUB_ACTIONS",token_source:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$artifact_root/v0540-parent-lock-receipt.json"
echo "v0.54 parent receipt: immutable v0.53 verified; parent_locks=70 current_locks=$current_count full_72_lock_audit=false"
