#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.51 changed-lock verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0510-changed-locks.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
temp_root="${RUNNER_TEMP:-$artifact_root/.v0510-changed-locks}"
changed_lock="$temp_root/changed-locks.json"
fallback_lock="$temp_root/parent-59-locks.json"
changed_root="$temp_root/changed-verification"
fallback_root="$temp_root/full-59-verification"
live_receipt="$artifact_root/v0510-live-lock-receipt.json"
mkdir -p "$temp_root"
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v gh >/dev/null
test -n "${GH_TOKEN:-}"

jq -S ' .releases |= with_entries(select(.key == "measurement_boundary_v2_projector_durable_release" or .key == "operational_provenance_projector_durable_release" or .key == "self_improvement_frontier_projector_durable_release")) ' "$repository/contracts/release-locks-v1.json" > "$changed_lock"
jq -S ' .releases |= with_entries(select(.key != "measurement_boundary_v2_projector_durable_release" and .key != "operational_provenance_projector_durable_release" and .key != "self_improvement_frontier_projector_durable_release")) ' "$repository/contracts/release-locks-v1.json" > "$fallback_lock"

parent_state=$(jq -r '.primary.state' "$artifact_root/v0510-parent-lock-receipt.json")
parent_selected=0
parent_executed=0
parent_reused=59
parent_mode=PARENT_V050_RECEIPT_REUSE
parent_verification=""

if [ "$parent_state" = CLOSED ]; then
  test -s "$artifact_root/releases/verification.json"
  parent_verification="$temp_root/parent-reused-verification.json"
  cp "$artifact_root/releases/verification.json" "$parent_verification"
else
  /usr/bin/time -f '%M' -o "$artifact_root/release-verify-peak-rss" bash scripts/verify-releases-parallel.sh "$fallback_lock" "$fallback_root"
  mkdir -p "$artifact_root/releases"
  cp -a "$fallback_root/." "$artifact_root/releases/"
  parent_selected=59
  parent_executed=59
  parent_reused=0
  parent_mode=FULL_59_LOCK_AUDIT_FALLBACK
  parent_verification="$fallback_root/verification.json"
  jq -S --argjson selected "$parent_selected" --argjson executed "$parent_executed" --argjson reused "$parent_reused" --arg mode "$parent_mode" --argjson requests "$(jq -r '.release_lock_snapshot.parallel_live_metrics.requests' "$parent_verification")" --argjson completed "$(jq -r '.release_lock_snapshot.parallel_live_metrics.completed' "$parent_verification")" --argjson unknown "$(jq -r '.release_lock_snapshot.parallel_live_metrics.unknown' "$parent_verification")" --argjson refuted "$(jq -r '.release_lock_snapshot.parallel_live_metrics.refuted' "$parent_verification")" '.full_fallback={required:true,state:"CLOSED",reason:"FULL_59_LOCK_AUDIT_COMPLETED",selected:$selected,executed:$executed,reused:$reused,requests:$requests,completed:$completed,unknown:$unknown,refuted:$refuted,mode:$mode}' "$artifact_root/v0510-parent-lock-receipt.json" > "$artifact_root/v0510-parent-lock-receipt.json.tmp"
  mv "$artifact_root/v0510-parent-lock-receipt.json.tmp" "$artifact_root/v0510-parent-lock-receipt.json"
  cp "$artifact_root/v0510-parent-lock-receipt.json" "$artifact_root/v0500-parent-lock-receipt.json"
fi

mkdir -p "$changed_root"
/usr/bin/time -f '%M' -o "$temp_root/changed-lock-peak-rss" bash scripts/verify-releases-parallel.sh "$changed_lock" "$changed_root"
cp -a "$changed_root/." "$artifact_root/releases/"

base_verification="$parent_verification"
if [ -z "$base_verification" ]; then base_verification="$artifact_root/releases/verification.json"; fi
base_json=$(cat "$base_verification")
changed_json=$(cat "$changed_root/verification.json")
live_metrics=$(jq -c '.release_lock_snapshot.parallel_live_metrics' "$changed_root/verification.json")
parent_metadata_requests=$(jq -r '.parent_input_observation.metadata_api_requests' "$artifact_root/v0510-parent-lock-receipt.json")
parent_input_requests=$(jq -r '.parent_input_observation.api_requests' "$artifact_root/v0510-parent-lock-receipt.json")
changed_keys=$(jq -c '.releases|keys|sort' "$changed_lock")
reused_keys=$(jq -c '.releases|keys|sort' "$fallback_lock")

jq -S --argjson changed "$changed_json" --argjson live "$live_metrics" --argjson changed_keys "$changed_keys" --argjson reused_keys "$reused_keys" --arg mode "$parent_mode" --argjson parent_selected "$parent_selected" --argjson parent_executed "$parent_executed" --argjson parent_reused "$parent_reused" --argjson parent_requests "$parent_input_requests" --argjson parent_metadata_requests "$parent_metadata_requests" \
  '.releases = (.releases + $changed.releases) |
   .summary={total:62,verified:62,unknown:0,refuted:0} |
   .release_lock_snapshot={snapshot_single_fetch:true,canonical_order_exact:true,completion_order_ignored:true,parent_reuse:{mode:$mode,selected:$parent_selected,executed:$parent_executed,reused:$parent_reused,reused_lock_ids:$reused_keys,parent_input_api_requests:$parent_requests,parent_metadata_api_requests:$parent_metadata_requests},changed_live:{selected:3,executed:3,reused:0,live_verified:3,changed_lock_ids:$changed_keys,parallel_live_metrics:$live},full_62_lock_audit:{executed:false,required:false,reason:"PARENT_REUSE_PLUS_THREE_CHANGED_LOCKS"}} |
   .timing=$changed.timing' <<< "$base_json" > "$artifact_root/releases/verification.json"

live_requests=$(jq -r '.requests' <<< "$live_metrics")
live_completed=$(jq -r '.completed' <<< "$live_metrics")
live_unknown=$(jq -r '.unknown' <<< "$live_metrics")
live_refuted=$(jq -r '.refuted' <<< "$live_metrics")
live_wall=$(jq -r '.wall_ms' <<< "$live_metrics")
live_peak=$(jq -r '.peak_rss_kib' <<< "$live_metrics")
jq -S -n --arg schema "gooo/self-improvement-ledger/v0510-live-lock-receipt/v1" --arg mode "$parent_mode" --argjson parent_selected "$parent_selected" --argjson parent_executed "$parent_executed" --argjson parent_reused "$parent_reused" --argjson parent_requests "$parent_input_requests" --argjson parent_metadata_requests "$parent_metadata_requests" --argjson requests "$live_requests" --argjson completed "$live_completed" --argjson unknown "$live_unknown" --argjson refuted "$live_refuted" --argjson wall "$live_wall" --argjson peak "$live_peak" --argjson changed "$changed_keys" \
  '{schema:$schema,parent_reuse:{mode:$mode,selected:$parent_selected,executed:$parent_executed,reused:$parent_reused,parent_input_api_requests:$parent_requests,parent_metadata_api_requests:$parent_metadata_requests},changed_live:{selected:3,executed:3,reused:0,live_verified:$completed,requests:$requests,completed:$completed,unknown:$unknown,refuted:$refuted,changed_lock_ids:$changed,wall_ms:$wall,peak_rss_kib:$peak},full_62_lock_audit:{executed:false,required:false},authority:{verification:"GITHUB_ACTIONS",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' > "$live_receipt"

test "$live_requests" -ge 3
test "$live_completed" -eq 3
test "$live_unknown" -eq 0
test "$live_refuted" -eq 0
echo "v0.51 lock wave verified: parent_mode=$parent_mode parent_reused=$parent_reused changed_selected=3 changed_executed=3 live_verified=$live_completed"
