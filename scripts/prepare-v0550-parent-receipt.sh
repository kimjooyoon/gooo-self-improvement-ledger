#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.55 parent receipt preparation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: prepare-v0550-parent-receipt.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
temp_root="${RUNNER_TEMP:-$artifact_root/.v0550-parent-temp}"
parent_release_id=380979192
parent_tag="v0.54.0"
parent_target="20ed18182087a76c6f6f54cf345397febc59f1d9"
parent_tag_object="51b8c42db6cc23ac724dc102245ff02f2693cf75"
parent_asset_id=540625084
parent_asset_name="gooo-self-improvement-ledger-20ed18182087a76c6f6f54cf345397febc59f1d9"
parent_asset_size=63441343
parent_asset_digest="sha256:e1b1dbd3f3e540ab88c9b62ade806d1154496439dfbeace2072cb162d1ae5a1c"
parent_archive="$temp_root/$parent_asset_name.zip"
parent_extract="$temp_root/v0540-parent-artifact"
parent_receipt="$artifact_root/v0550-parent-lock-receipt.json"

mkdir -p "$artifact_root" "$temp_root"
rm -rf "$parent_extract"
mkdir -p "$parent_extract"
command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v unzip >/dev/null
command -v base64 >/dev/null
command -v wc >/dev/null
test -n "${GH_TOKEN:-}"

release_json=$(gh api "repos/kimjooyoon/gooo-self-improvement-ledger/releases/$parent_release_id")
asset_json=$(gh api "repos/kimjooyoon/gooo-self-improvement-ledger/releases/assets/$parent_asset_id")
tag_ref=$(gh api "repos/kimjooyoon/gooo-self-improvement-ledger/git/ref/tags/$parent_tag")
tag_record=$(gh api "repos/kimjooyoon/gooo-self-improvement-ledger/git/tags/$parent_tag_object")
public_refs=$(git ls-remote https://github.com/kimjooyoon/gooo-self-improvement-ledger.git "refs/tags/$parent_tag" "refs/tags/$parent_tag^{}")

jq -e --arg tag "$parent_tag" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson release_id "$parent_release_id" --argjson asset_id "$parent_asset_id" --argjson size "$parent_asset_size" \
  '.id==$release_id and .tag_name==$tag and .draft==false and .prerelease==false and .immutable==true and (.assets|length)==1 and .assets[0].id==$asset_id and .assets[0].name==$name and .assets[0].size==$size and .assets[0].digest==$digest' <<<"$release_json" >/dev/null
jq -e --argjson asset_id "$parent_asset_id" --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson size "$parent_asset_size" \
  '.id==$asset_id and .name==$name and .size==$size and .digest==$digest and .state=="uploaded"' <<<"$asset_json" >/dev/null
jq -e --arg object "$parent_tag_object" '.object.sha==$object and .object.type=="tag"' <<<"$tag_ref" >/dev/null
jq -e --arg commit "$parent_target" '.object.sha==$commit and .object.type=="commit"' <<<"$tag_record" >/dev/null
test "$(awk -v ref="refs/tags/$parent_tag" '$2==ref {print $1}' <<<"$public_refs")" = "$parent_tag_object"
test "$(awk -v ref="refs/tags/$parent_tag^{}" '$2==ref {print $1}' <<<"$public_refs")" = "$parent_target"

parent_lock_manifest="$temp_root/v0540-parent-release-locks-v1.json"
parent_lock_manifest_json=$(gh api "repos/kimjooyoon/gooo-self-improvement-ledger/contents/contracts/release-locks-v1.json?ref=$parent_target")
jq -e --arg encoding base64 '.encoding==$encoding and (.content|type)=="string"' <<<"$parent_lock_manifest_json" >/dev/null
jq -r '.content' <<<"$parent_lock_manifest_json" | tr -d '\r\n' | base64 --decode > "$parent_lock_manifest"
cmp -s "$parent_lock_manifest" "$repository/contracts/release-locks-v1.json"

gh api -H 'Accept: application/octet-stream' "repos/kimjooyoon/gooo-self-improvement-ledger/releases/assets/$parent_asset_id" > "$parent_archive"
test "$(wc -c <"$parent_archive" | tr -d ' ')" = "$parent_asset_size"
test "sha256:$(sha256sum "$parent_archive" | awk '{print $1}')" = "$parent_asset_digest"
unzip -q "$parent_archive" -d "$parent_extract"

parent_verification="$parent_extract/releases/verification.json"
parent_wave="$parent_extract/atomic-v0540-wave-v1.json"
parent_product="$parent_extract/v0540-products/product-integration.json"
for required_file in "$parent_verification" "$parent_wave" "$parent_product" "$parent_extract/v0540-products/output-authority/receipt.json" "$parent_extract/v0540-products/protected-change-gate/receipt.json" "$parent_extract/v0540-products/semantic-wave/receipt.json"; do
  test -s "$required_file"
done
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72 and .release_lock_snapshot.parent_reuse.reused==70 and .release_lock_snapshot.changed_live.selected==2 and .release_lock_snapshot.changed_live.executed==2 and .release_lock_snapshot.full_72_lock_audit.executed==false' "$parent_verification" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/atomic-v0540-adoption-wave/v1" and .wave.projected_profile_state=={closed:76,refuted:2,total:79,unknown:1} and .parent_preservation.parent_reused==70 and .parent_preservation.changed_executed==2' "$parent_wave" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-product-integration/v1" and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .authority.repository_writes==0' "$parent_product" >/dev/null

current_keys=$(jq -c '.releases|keys|sort' "$repository/contracts/release-locks-v1.json")
parent_keys=$(jq -c '.releases|keys|sort' "$parent_verification")
test "$(jq 'length' <<<"$current_keys")" = 72
test "$current_keys" = "$parent_keys"

mkdir -p "$artifact_root/releases" "$artifact_root/v0550-parent-v0540-products/output-authority" "$artifact_root/v0550-parent-v0540-products/protected-change-gate" "$artifact_root/v0550-parent-v0540-products/semantic-wave/upstream"
cp "$parent_verification" "$artifact_root/releases/verification.json"
cp "$parent_wave" "$artifact_root/v0550-parent-atomic-v0540-wave-v1.json"
cp "$parent_product" "$artifact_root/v0550-parent-v0540-products/product-integration.json"
cp "$parent_extract/v0540-products/output-authority/receipt.json" "$artifact_root/v0550-parent-v0540-products/output-authority/receipt.json"
cp "$parent_extract/v0540-products/protected-change-gate/receipt.json" "$artifact_root/v0550-parent-v0540-products/protected-change-gate/receipt.json"
cp "$parent_extract/v0540-products/semantic-wave/receipt.json" "$artifact_root/v0550-parent-v0540-products/semantic-wave/receipt.json"
  for wave_asset in wave-projection.json wave-distribution.json generated-assertions.json replay-receipt.json report.md; do
  cp "$parent_extract/v0540-products/semantic-wave/upstream/$wave_asset" "$artifact_root/v0550-parent-v0540-products/semantic-wave/upstream/$wave_asset"
done

parent_lock_digest=$(jq -cS '.releases|keys|sort' "$parent_verification" | sha256sum | awk '{print "sha256:"$1}')
current_lock_digest=$(jq -cS '.releases|keys|sort' "$repository/contracts/release-locks-v1.json" | sha256sum | awk '{print "sha256:"$1}')
jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v0550-parent-lock-receipt/v1" \
  --arg repo "kimjooyoon/gooo-self-improvement-ledger" --arg tag "$parent_tag" --arg target "$parent_target" --arg tag_object "$parent_tag_object" \
  --arg name "$parent_asset_name" --arg digest "$parent_asset_digest" --argjson release_id "$parent_release_id" --argjson asset_id "$parent_asset_id" --argjson size "$parent_asset_size" \
  --arg parent_lock_digest "$parent_lock_digest" --arg current_lock_digest "$current_lock_digest" \
  '{schema:$schema,
    parent:{repository:$repo,tag:$tag,release_id:$release_id,tag_object_sha:$tag_object,target_commit_sha:$target,immutable:true,release_asset:{id:$asset_id,name:$name,size_bytes:$size,sha256:$digest}},
    primary:{state:"CLOSED",mode:"PARENT_V0540_RELEASE_RECEIPT_REUSE",reason:"IMMUTABLE_V0540_RELEASE_RECEIPT_AND_ARTIFACT_MATCHED",api_observation:{selected:0,executed:0,reused:72,source:"PARENT_V0540_RELEASE_RECEIPT_REUSE"}},
    lock_set:{current_count:72,parent_count:72,current_key_digest:$current_lock_digest,parent_key_digest:$parent_lock_digest,unchanged_72_lock_set:($current_lock_digest==$parent_lock_digest),keys_match:true},
    product_receipt_reuse:{source:"V0.54.0_IMMUTABLE_RELEASE_ASSET",output_authority:true,protected_change_gate:true,semantic_wave:true},
    full_fallback:{required:false,state:"NOT_REQUIRED",selected:0,executed:0,reused:72},
    authority:{verification:"GITHUB_ACTIONS_ONLY",token_source:"github.token",repository_writes:0,local_validation_commands:0,cross_project_required_gates:0}}' > "$parent_receipt"
jq -e '.schema=="gooo/self-improvement-ledger/v0550-parent-lock-receipt/v1" and .primary.state=="CLOSED" and .parent.release_id==380979192 and .parent.target_commit_sha=="20ed18182087a76c6f6f54cf345397febc59f1d9" and .parent.release_asset.id==540625084 and .parent.release_asset.sha256=="sha256:e1b1dbd3f3e540ab88c9b62ade806d1154496439dfbeace2072cb162d1ae5a1c" and .lock_set.current_count==72 and .lock_set.parent_count==72 and .lock_set.unchanged_72_lock_set==true and .product_receipt_reuse=={output_authority:true,protected_change_gate:true,semantic_wave:true,source:"V0.54.0_IMMUTABLE_RELEASE_ASSET"} and .full_fallback=={executed:0,required:false,reused:72,selected:0,state:"NOT_REQUIRED"}' "$parent_receipt" >/dev/null
echo "v0.55 parent receipt: immutable v0.54 verified; parent_locks=72 current_locks=72 new_live_locks=0"
