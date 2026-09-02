#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.54 changed-lock verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0540-changed-locks.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
temp_root="${RUNNER_TEMP:-$artifact_root/.v0540-changed-locks}"
changed_lock="$temp_root/changed-locks.json"
changed_root="$temp_root/changed-verification"
parent_receipt="$artifact_root/v0540-parent-lock-receipt.json"
parent_verification="$artifact_root/releases/v0530-parent-verification.json"
mkdir -p "$artifact_root/releases" "$temp_root"
command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
test -n "${GH_TOKEN:-}"
test -s "$parent_receipt"
test -s "$parent_verification"
jq -e '.primary.state=="CLOSED" and .parent.tag=="v0.53.0" and .parent.release_id==380943341 and .parent.parent_lock_set_digest=="sha256:ffc92192ef7ba838e8f4917c5f7c97d878786a00a79f6079e0761f64a05001b3"' "$parent_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:70,verified:70,unknown:0,refuted:0} and (.releases|length)==70' "$parent_verification" >/dev/null

jq -S '
  .releases |= with_entries(select(.key=="output_authority_projector_durable_release" or .key=="protected_change_gate_projector_durable_release")) |
  .counterexamples=[] | .counterexample_runs=[] | .failed_release_triggers=[]
' "$repository/contracts/release-locks-v1.json" > "$changed_lock"
jq -e '(.releases|length)==2 and ((.releases|keys|sort)==["output_authority_projector_durable_release","protected_change_gate_projector_durable_release"])' "$changed_lock" >/dev/null

rm -rf "$changed_root"
mkdir -p "$changed_root"
/usr/bin/time -f '%M' -o "$temp_root/changed-lock-peak-rss" \
  bash "$repository/scripts/verify-releases-parallel.sh" "$changed_lock" "$changed_root"
jq -e '.summary=={total:2,verified:2,unknown:0,refuted:0} and (.releases|length)==2 and .release_lock_snapshot.parallel_live_metrics.completed==2 and .release_lock_snapshot.parallel_live_metrics.unknown==0 and .release_lock_snapshot.parallel_live_metrics.refuted==0' "$changed_root/verification.json" >/dev/null
cp -a "$changed_root" "$artifact_root/releases/changed-live-verification"

changed_metrics=$(jq -c '.release_lock_snapshot.parallel_live_metrics' "$changed_root/verification.json")
parent_keys=$(jq -c '.releases|keys|sort' "$parent_verification")
changed_keys=$(jq -c '.releases|keys|sort' "$changed_lock")
parent_requests=$(jq -r '.release_lock_snapshot.parallel_live_metrics.requests // 0' "$parent_verification")
parent_metadata=$(jq -r '.release_lock_snapshot.parallel_live_metrics.requests // 0' "$parent_verification")
jq -S -n \
  --slurpfile parent "$parent_verification" --slurpfile changed "$changed_root/verification.json" --argjson metrics "$changed_metrics" \
  --argjson parent_keys "$parent_keys" --argjson changed_keys "$changed_keys" \
  --argjson parent_requests "$parent_requests" --argjson parent_metadata "$parent_metadata" \
  '.schema="gooo/self-improvement-portfolio/release-verification/v1" |
   .releases=($parent[0].releases+$changed[0].releases) |
   .counterexamples=[] | .counterexample_runs=[] | .failed_release_triggers=[] |
   .summary={total:72,verified:72,unknown:0,refuted:0} |
   .release_lock_snapshot={snapshot_single_fetch:true,canonical_order_exact:true,completion_order_ignored:true,
     parent_reuse:{mode:"PARENT_V0530_RELEASE_RECEIPT_REUSE",selected:0,executed:0,reused:70,reused_lock_ids:$parent_keys,parent_input_api_requests:$parent_requests,parent_metadata_api_requests:$parent_metadata},
     changed_live:{selected:2,executed:2,reused:0,live_verified:2,changed_lock_ids:$changed_keys,parallel_live_metrics:$metrics},
     full_72_lock_audit:{executed:false,required:false,reason:"PARENT_REUSE_PLUS_TWO_CHANGED_LOCKS"}} |
   .timing=$changed[0].timing' \
  > "$artifact_root/releases/verification.json"

live_requests=$(jq -r '.requests' <<<"$changed_metrics")
live_completed=$(jq -r '.completed' <<<"$changed_metrics")
live_unknown=$(jq -r '.unknown' <<<"$changed_metrics")
live_refuted=$(jq -r '.refuted' <<<"$changed_metrics")
live_wall=$(jq -r '.wall_ms' <<<"$changed_metrics")
live_peak=$(cat "$temp_root/changed-lock-peak-rss")
jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v0540-live-lock-receipt/v1" \
  --argjson requests "$live_requests" --argjson completed "$live_completed" --argjson unknown "$live_unknown" --argjson refuted "$live_refuted" \
  --argjson wall "$live_wall" --argjson peak "$live_peak" --argjson changed "$changed_keys" \
  '{schema:$schema,parent_reuse:{mode:"PARENT_V0530_RELEASE_RECEIPT_REUSE",selected:0,executed:0,reused:70},
    changed_live:{selected:2,executed:2,reused:0,live_verified:$completed,requests:$requests,completed:$completed,unknown:$unknown,refuted:$refuted,changed_lock_ids:$changed,wall_ms:$wall,peak_rss_kib:$peak},
    full_72_lock_audit:{executed:false,required:false},
    authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' \
  > "$artifact_root/v0540-live-lock-receipt.json"
test "$live_requests" -ge 2
test "$live_completed" -eq 2
test "$live_unknown" -eq 0
test "$live_refuted" -eq 0
echo "v0.54 lock wave verified: parent_reused=70 changed_selected=2 changed_executed=2 live_verified=$live_completed full_72_lock_audit=false"
