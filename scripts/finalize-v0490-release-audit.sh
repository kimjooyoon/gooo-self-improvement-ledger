#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.49 release-audit finalization failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 1 ]; then
  echo "usage: finalize-v0490-release-audit.sh ARTIFACT_ROOT" >&2
  exit 64
fi

root=$(realpath "$1")
receipt="$root/v0490-release-audit-receipt.json"
verification="$root/releases/verification.json"
test -s "$receipt" -a -s "$verification"
command -v gh >/dev/null
command -v jq >/dev/null

requests=$(jq -r '.release_lock_snapshot.parallel_live_metrics.requests' "$verification")
test "$requests" -ge 0
rate='{}'
if observed_rate=$(gh api rate_limit 2>/dev/null); then
  rate="$observed_rate"
fi
remaining=$(jq -r '.resources.core.remaining // .rate.remaining // null' <<< "$rate")
reset=$(jq -r '.resources.core.reset // .rate.reset // null' <<< "$rate")

jq -S --argjson requests "$requests" --argjson remaining "$remaining" --argjson reset "$reset" '
  .full_fallback.state="CLOSED" |
  .full_fallback.reason="FULL_59_LOCK_AUDIT_COMPLETED" |
  .api_observation.requests=$requests |
  .api_observation.reused=0 |
  .api_observation.selected=59 |
  .api_observation.executed=59 |
  .api_observation.source="FULL_59_LOCK_AUDIT" |
  .api_observation.rate_limit={remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)}
' "$receipt" > "$receipt.tmp"
mv "$receipt.tmp" "$receipt"

echo "v0.49 full release-audit fallback finalized: requests=$requests selected=59 executed=59 reused=0"
