#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.50 parent receipt finalization failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 1 ]; then
  echo "usage: finalize-v0500-parent-receipt.sh ARTIFACT_ROOT" >&2
  exit 64
fi

root=$(realpath "$1")
receipt="$root/v0500-parent-lock-receipt.json"
verification="$root/releases/verification.json"
test -s "$receipt" -a -s "$verification"
command -v gh >/dev/null
command -v jq >/dev/null

requests=$(jq -r '.release_lock_snapshot.parallel_live_metrics.requests' "$verification")
completed=$(jq -r '.release_lock_snapshot.parallel_live_metrics.completed' "$verification")
reused=$(jq -r '.release_lock_snapshot.parallel_live_metrics.reused' "$verification")
unknown=$(jq -r '.release_lock_snapshot.parallel_live_metrics.unknown' "$verification")
refuted=$(jq -r '.release_lock_snapshot.parallel_live_metrics.refuted' "$verification")
peak_rss=$(jq -r '.release_lock_snapshot.parallel_live_metrics.peak_rss_kib' "$verification")
wall_ms=$(jq -r '.release_lock_snapshot.parallel_live_metrics.wall_ms' "$verification")
test "$requests" -ge 0
test "$completed" -eq 59
test "$unknown" -eq 0
test "$refuted" -eq 0

rate='{}'
if observed_rate=$(gh api rate_limit 2>/dev/null); then rate="$observed_rate"; fi
remaining=$(jq -r '.resources.core.remaining // .rate.remaining // null' <<< "$rate")
reset=$(jq -r '.resources.core.reset // .rate.reset // null' <<< "$rate")

jq -S --argjson requests "$requests" --argjson completed "$completed" --argjson reused "$reused" --argjson unknown "$unknown" --argjson refuted "$refuted" --argjson peak "$peak_rss" --argjson wall "$wall_ms" --argjson remaining "$remaining" --argjson reset "$reset" '
  .full_fallback.state="CLOSED" |
  .full_fallback.reason="FULL_59_LOCK_AUDIT_COMPLETED" |
  .full_fallback.observation={selected:59,executed:59,reused:0,completed:$completed,unknown:$unknown,refuted:$refuted,bytes_read:null,bytes_read_state:"UNKNOWN",bytes_downloaded:null,bytes_downloaded_state:"UNKNOWN",measurement_state:{state:"UNKNOWN",stage:"FULL_59_LOCK_AUDIT",step:"CAPTURE_LOCK_BYTES",reason:"RELEASE_LOCK_VERIFIER_DOES_NOT_EMIT_PER_LOCK_BYTE_TOTAL",unknown_class:"MEASUREMENT_MISSING",next_operation:"ADD_BYTE_COUNTER_TO_LOCK_VERIFIER",blocked_by:["release-lock-byte-counter"]},wall_ms:$wall,peak_rss_kib:$peak} |
  .primary.api_observation={requests:0,selected:0,executed:0,reused:(if .primary.state=="CLOSED" then 59 else 0 end),bytes_read:0,bytes_downloaded:0,rate_limit:{remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)},source:(if .primary.state=="CLOSED" then "PARENT_RELEASE_RECEIPT_REUSE" else "PENDING_FULL_59_LOCK_AUDIT" end)} |
  .parent_fetch_observation.full_fallback={requests:$requests,selected:59,executed:59,reused:0,completed:$completed,unknown:$unknown,refuted:$refuted,rate_limit:{remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)}}
' "$receipt" > "$receipt.tmp"
mv "$receipt.tmp" "$receipt"

echo "v0.50 full 59-lock audit fallback finalized: requests=$requests selected=59 executed=59 reused=0 wall_ms=$wall_ms peak_rss_kib=$peak_rss"
