#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.56 parent receipt preparation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: prepare-v0560-parent-receipt.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
repo="kimjooyoon/gooo-self-improvement-ledger"
parent_release_id=380997346
parent_tag="v0.55.0"
parent_target="a6591498d5096b73586d06760e1008370fae5eef"
parent_tag_object="3ef84943f91e5043a61d1d626442fd7f1867737a"
parent_asset_id=540679512
parent_asset_name="gooo-self-improvement-ledger-a6591498d5096b73586d06760e1008370fae5eef"
parent_asset_size=55194333
parent_asset_digest="sha256:804ed35da651c369deb491ecbb7313bff24027e1f25e2916a4a7e16ce75d23c0"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0560-parent-temp}/v0560-parent-${GITHUB_RUN_ID:-manual}-${GITHUB_RUN_ATTEMPT:-1}"
parent_archive="$temp_root/$parent_asset_name.zip"
parent_extract="$temp_root/extracted"
parent_manifest="$temp_root/parent-release-locks-v1.json"
parent_contents_json="$temp_root/parent-contents.json"
parent_receipt="$artifact_root/v0560-parent-lock-receipt.json"

mkdir -p "$artifact_root" "$temp_root" "$parent_extract"
rm -f "$parent_archive" "$parent_manifest" "$parent_contents_json"
command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v unzip >/dev/null
command -v base64 >/dev/null
command -v wc >/dev/null
command -v git >/dev/null
test -n "${GH_TOKEN:-}"

release_json=$(gh api "repos/$repo/releases/$parent_release_id")
asset_json=$(gh api "repos/$repo/releases/assets/$parent_asset_id")
tag_ref=$(gh api "repos/$repo/git/ref/tags/$parent_tag")
tag_record=$(gh api "repos/$repo/git/tags/$parent_tag_object")
public_refs=$(git ls-remote "https://github.com/$repo.git" "refs/tags/$parent_tag" "refs/tags/$parent_tag^{}")

jq -e --arg tag "$parent_tag" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson release_id "$parent_release_id" --argjson asset_id "$parent_asset_id" --argjson size "$parent_asset_size" \
  '.id==$release_id and .tag_name==$tag and .draft==false and .prerelease==false and .immutable==true and (.assets|length)==1 and .assets[0].id==$asset_id and .assets[0].name==$name and .assets[0].size==$size and .assets[0].digest==$digest' <<<"$release_json" >/dev/null
jq -e --argjson asset_id "$parent_asset_id" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson size "$parent_asset_size" \
  '.id==$asset_id and .name==$name and .size==$size and .digest==$digest and .state=="uploaded"' <<<"$asset_json" >/dev/null
jq -e --arg object "$parent_tag_object" '.object.sha==$object and .object.type=="tag"' <<<"$tag_ref" >/dev/null
jq -e --arg commit "$parent_target" '.object.sha==$commit and .object.type=="commit"' <<<"$tag_record" >/dev/null
test "$(awk -v ref="refs/tags/$parent_tag" '$2==ref {print $1}' <<<"$public_refs")" = "$parent_tag_object"
test "$(awk -v ref="refs/tags/$parent_tag^{}" '$2==ref {print $1}' <<<"$public_refs")" = "$parent_target"

parent_contents_json=$(gh api "repos/$repo/contents/contracts/release-locks-v1.json?ref=$parent_target")
jq -e '.encoding=="base64" and (.content|type)=="string"' <<<"$parent_contents_json" >/dev/null
jq -r '.content' <<<"$parent_contents_json" | tr -d '\r\n' | base64 --decode > "$parent_manifest"
parent_lock_count=$(jq '.releases|length' "$parent_manifest")
test "$parent_lock_count" = 72
current_lock_count=$(jq '.releases|length' "$repository/contracts/release-locks-v1.json")
test "$current_lock_count" = 77
jq -S --slurpfile parent "$parent_manifest" '([.releases|to_entries[]|select(.key as $key | ($parent[0].releases|has($key)))|.value] == ($parent[0].releases|to_entries|map(.value))) and ([.releases|to_entries[]|select(.key as $key | ($parent[0].releases|has($key)))]|length)==72' "$repository/contracts/release-locks-v1.json" >/dev/null

gh api -H 'Accept: application/octet-stream' "repos/$repo/releases/assets/$parent_asset_id" > "$parent_archive"
test "$(wc -c <"$parent_archive" | tr -d ' ')" = "$parent_asset_size"
test "sha256:$(sha256sum "$parent_archive" | awk '{print $1}')" = "$parent_asset_digest"
unzip -q "$parent_archive" -d "$parent_extract"

parent_verification="$parent_extract/releases/verification.json"
parent_product="$parent_extract/v0550-products/product-integration.json"
parent_wave="$parent_extract/atomic-v0550-wave-v1.json"
for required_file in "$parent_verification" "$parent_product" "$parent_wave" "$parent_extract/v0550-products/output-authority/receipt.json" "$parent_extract/v0550-products/protected-change-gate/receipt.json" "$parent_extract/v0550-products/semantic-wave/receipt.json"; do test -s "$required_file"; done
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72' "$parent_verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-product-integration/v1" and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .authority.repository_writes==0' "$parent_product" >/dev/null

mkdir -p "$artifact_root/releases" "$artifact_root/v0560-parent-products"
cp "$parent_verification" "$artifact_root/releases/v0550-parent-verification.json"
cp "$parent_verification" "$artifact_root/releases/verification.json"
cp -a "$parent_extract/releases/." "$artifact_root/releases/"
cp "$parent_verification" "$artifact_root/releases/v0550-parent-verification.json"
cp "$parent_product" "$artifact_root/v0560-parent-products/product-integration.json"
cp -a "$parent_extract/v0550-products/." "$artifact_root/v0560-parent-products/"
cp "$parent_wave" "$artifact_root/v0560-parent-atomic-v0550-wave-v1.json"
if test -s "$parent_extract/v0500-parent-lock-receipt.json"; then cp "$parent_extract/v0500-parent-lock-receipt.json" "$artifact_root/v0500-parent-lock-receipt.json"; fi
if test -s "$parent_extract/v050-parent-report.json"; then cp "$parent_extract/v050-parent-report.json" "$artifact_root/v050-parent-report.json"; fi

parent_key_digest=$(jq -cS '.releases|keys|sort' "$parent_verification" | sha256sum | awk '{print "sha256:"$1}')
current_key_digest=$(jq -cS '.releases|keys|sort' "$repository/contracts/release-locks-v1.json" | sha256sum | awk '{print "sha256:"$1}')
current_manifest_digest="sha256:$(sha256sum "$repository/contracts/release-locks-v1.json" | awk '{print $1}')"
parent_manifest_digest="sha256:$(sha256sum "$parent_manifest" | awk '{print $1}')"
parent_contents_sha=$(jq -r '.sha' <<<"$parent_contents_json")

jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v0560-parent-lock-receipt/v1" \
  --arg repo "$repo" --arg tag "$parent_tag" --arg target "$parent_target" --arg tag_object "$parent_tag_object" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" \
  --arg manifest_digest "$parent_manifest_digest" --arg current_manifest_digest "$current_manifest_digest" --arg parent_key_digest "$parent_key_digest" --arg current_key_digest "$current_key_digest" --arg contents_sha "$parent_contents_sha" \
  --argjson release_id "$parent_release_id" --argjson asset_id "$parent_asset_id" --argjson size "$parent_asset_size" --argjson current_count "$current_lock_count" \
  '{schema:$schema,
    parent:{repository:$repo,tag:$tag,release_id:$release_id,tag_object_sha:$tag_object,target_commit_sha:$target,immutable:true,release_asset:{id:$asset_id,name:$name,size_bytes:$size,sha256:$digest},release_lock_manifest:{sha256:$manifest_digest,contents_blob_sha:$contents_sha},parent_lock_set_digest:$parent_key_digest},
    primary:{state:"CLOSED",mode:"PARENT_V0550_RELEASE_RECEIPT_REUSE",reason:"IMMUTABLE_V0550_RELEASE_AND_72_LOCK_PARENT_RECEIPT_MATCHED",api_observation:{selected:0,executed:0,reused:72,source:"PARENT_V0550_RELEASE_RECEIPT_REUSE"}},
    lock_set:{current_count:$current_count,parent_count:72,current_key_digest:$current_key_digest,parent_key_digest:$parent_key_digest,unchanged_72_lock_set:true,first_72_manifest_digest:$manifest_digest,current_manifest_digest:$current_manifest_digest},
    product_receipt_reuse:{source:"V0.55.0_IMMUTABLE_RELEASE_ASSET",output_authority:true,protected_change_gate:true,semantic_wave:true},
    full_fallback:{required:false,state:"NOT_REQUIRED",selected:0,executed:0,reused:72},
    authority:{verification:"GITHUB_ACTIONS_ONLY",token_source:"github.token",repository_writes:0,local_validation_commands:0,cross_project_required_gates:0}}' > "$parent_receipt"
jq -e '.schema=="gooo/self-improvement-ledger/v0560-parent-lock-receipt/v1" and .primary.state=="CLOSED" and .parent.release_id==380997346 and .parent.target_commit_sha=="a6591498d5096b73586d06760e1008370fae5eef" and .parent.release_asset.id==540679512 and .parent.release_asset.sha256=="sha256:804ed35da651c369deb491ecbb7313bff24027e1f25e2916a4a7e16ce75d23c0" and .lock_set.current_count==77 and .lock_set.parent_count==72 and .lock_set.unchanged_72_lock_set==true and .primary.api_observation.selected==0 and .primary.api_observation.executed==0 and .primary.api_observation.reused==72 and .primary.api_observation.source=="PARENT_V0550_RELEASE_RECEIPT_REUSE" and .full_fallback.executed==0 and .full_fallback.required==false and .full_fallback.reused==72 and .full_fallback.state=="NOT_REQUIRED"' "$parent_receipt" >/dev/null
echo "v0.56 parent receipt: immutable v0.55 verified; parent_locks=72 current_locks=77 new_live_locks=5"
