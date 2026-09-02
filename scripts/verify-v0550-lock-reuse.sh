#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.55 lock-reuse verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0550-lock-reuse.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
parent_receipt="$artifact_root/v0550-parent-lock-receipt.json"
parent_verification="$artifact_root/releases/verification.json"
parent_copy="$artifact_root/releases/v0540-parent-verification.json"
lock_file="$repository/contracts/release-locks-v1.json"
live_receipt="$artifact_root/v0550-live-lock-receipt.json"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0550-lock-reuse-temp}"
mkdir -p "$artifact_root/releases" "$temp_root"
command -v jq >/dev/null
command -v sha256sum >/dev/null
test -s "$parent_receipt"
test -s "$parent_verification"

jq -e '
  .schema=="gooo/self-improvement-ledger/v0550-parent-lock-receipt/v1" and
  .primary.state=="CLOSED" and .parent.tag=="v0.54.0" and .parent.release_id==380979192 and
  .parent.target_commit_sha=="20ed18182087a76c6f6f54cf345397febc59f1d9" and .parent.immutable==true and
  .parent.release_asset.id==540625084 and .parent.release_asset.sha256=="sha256:e1b1dbd3f3e540ab88c9b62ade806d1154496439dfbeace2072cb162d1ae5a1c" and
  .lock_set.current_count==72 and .lock_set.parent_count==72 and .lock_set.unchanged_72_lock_set==true and
  .primary.api_observation=={executed:0,reused:72,selected:0,source:"PARENT_V0540_RELEASE_RECEIPT_REUSE"} and
  .full_fallback=={executed:0,required:false,reused:72,selected:0,state:"NOT_REQUIRED"} and .authority.repository_writes==0
' "$parent_receipt" >/dev/null

cp "$parent_verification" "$parent_copy"
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72' "$parent_copy" >/dev/null
current_keys=$(jq -c '.releases|keys|sort' "$lock_file")
parent_keys=$(jq -c '.releases|keys|sort' "$parent_copy")
test "$(jq 'length' <<<"$current_keys")" = 72
test "$current_keys" = "$parent_keys"

jq -S --argjson keys "$current_keys" '
  .schema="gooo/self-improvement-portfolio/release-verification/v1" |
  .summary={total:72,verified:72,unknown:0,refuted:0} |
  .release_lock_snapshot={snapshot_single_fetch:false,canonical_order_exact:true,completion_order_ignored:true,
    parent_reuse:{mode:"PARENT_V0540_RELEASE_RECEIPT_REUSE",selected:0,executed:0,reused:72,reused_lock_ids:$keys,parent_input_api_requests:0,parent_metadata_api_requests:0},
    changed_live:{selected:0,executed:0,reused:0,live_verified:0,changed_lock_ids:[],parallel_live_metrics:{requests:0,completed:0,unknown:0,refuted:0}},
    full_72_lock_audit:{executed:false,required:false,reason:"PARENT_REUSE_ONLY_NO_NEW_RELEASE_LOCKS"}}
' "$parent_copy" > "$parent_verification"

jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v0550-live-lock-receipt/v1" \
  --argjson ids "$current_keys" \
  '{schema:$schema,parent_reuse:{mode:"PARENT_V0540_RELEASE_RECEIPT_REUSE",selected:0,executed:0,reused:72,reused_lock_ids:$ids},changed_live:{selected:0,executed:0,reused:0,live_verified:0,requests:0,completed:0,unknown:0,refuted:0,changed_lock_ids:[]},full_72_lock_audit:{executed:false,required:false,reason:"PARENT_REUSE_ONLY_NO_NEW_RELEASE_LOCKS"},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$live_receipt"
jq -e '.schema=="gooo/self-improvement-ledger/v0550-live-lock-receipt/v1" and .parent_reuse.mode=="PARENT_V0540_RELEASE_RECEIPT_REUSE" and .parent_reuse.executed==0 and .parent_reuse.reused==72 and .parent_reuse.selected==0 and .changed_live=={changed_lock_ids:[],completed:0,executed:0,live_verified:0,refuted:0,requests:0,reused:0,selected:0,unknown:0} and .full_72_lock_audit=={executed:false,reason:"PARENT_REUSE_ONLY_NO_NEW_RELEASE_LOCKS",required:false} and .authority.repository_writes==0' "$live_receipt" >/dev/null
echo "v0.55 lock reuse verified: parent_reused=72 changed_selected=0 changed_executed=0 full_72_lock_audit=false"
