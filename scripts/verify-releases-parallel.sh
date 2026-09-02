#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "parallel release verification failed at line ${BASH_LINENO[0]}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-releases-parallel.sh LOCK_JSON OUTPUT_DIR" >&2
  exit 64
fi

lock=$(realpath "$1")
output=$(realpath "$2" 2>/dev/null || { mkdir -p "$2"; realpath "$2"; })
repository=$(realpath .)
case "$output" in
  "$repository"|"$repository"/*) echo "release output must be outside the input repository" >&2; exit 65 ;;
esac
mkdir -p "$output"
command -v gh >/dev/null
command -v jq >/dev/null
command -v timeout >/dev/null

bound=8
max_attempts=3
backoff_ms=250
timeout_seconds=30
snapshot=$(mktemp -d "$output/release-snapshot.XXXXXX")
mapfile -t keys < <(jq -r '.releases | keys[]' "$lock" | LC_ALL=C sort)

fetch_one() {
  local key=$1
  local repo tag release_id attempt=0 tmp response_status=UNKNOWN fetch_ok
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$lock")
  tag=$(jq -r --arg key "$key" '.releases[$key].tag' "$lock")
  release_id=$(jq -r --arg key "$key" '.releases[$key].release_id // empty' "$lock")
  tmp="$snapshot/$key.release.json.tmp"
  while [ "$attempt" -lt "$max_attempts" ]; do
    attempt=$((attempt + 1))
    fetch_ok=false
    if [ -n "$release_id" ]; then
      if /usr/bin/time -f '%M' -o "$snapshot/$key.fetch-rss" timeout "${timeout_seconds}s" gh api "repos/$repo/releases/$release_id" > "$tmp"; then
        fetch_ok=true
      fi
    elif /usr/bin/time -f '%M' -o "$snapshot/$key.fetch-rss" timeout "${timeout_seconds}s" gh api "repos/$repo/releases?per_page=100" | jq -e --arg tag "$tag" '[.[] | select(.tag_name==$tag)] | if length==1 then .[0] else error("expected one release") end' > "$tmp"; then
      fetch_ok=true
    fi
    if [ "$fetch_ok" = true ]; then
      mv "$tmp" "$snapshot/$key.release.json"
      response_status=CLOSED
      break
    fi
    rm -f "$tmp"
    if [ "$attempt" -lt "$max_attempts" ]; then
      sleep "0.$(printf '%03d' "$backoff_ms")"
    fi
  done
  jq -S -n --arg key "$key" --arg state "$response_status" --argjson request_count "$attempt" \
    '{lock_id:$key,state:$state,request_count:$request_count,completed:($state=="CLOSED"),reused:0,unknown:($state=="UNKNOWN"),refuted:0}' \
    > "$snapshot/$key.fetch-meta.json"
  if [ "$response_status" != CLOSED ]; then
    jq -S -n --arg key "$key" '{lock_id:$key,error:"RELEASE_RESPONSE_NOT_OBSERVED_WITHIN_RETRY_TIMEOUT"}' > "$snapshot/$key.release.json"
    printf '0\n' > "$snapshot/$key.fetch-rss"
  fi
}

fetch_start=$(date +%s%N)
index=0
while [ "$index" -lt "${#keys[@]}" ]; do
  pids=()
  for key in "${keys[@]:index:bound}"; do fetch_one "$key" & pids+=("$!"); done
  for pid in "${pids[@]}"; do wait "$pid"; done
  index=$((index + bound))
done
fetch_end=$(date +%s%N)

requests=$(jq -s 'map(.request_count)|add // 0' "$snapshot"/*.fetch-meta.json)
completed=$(jq -s 'map(select(.completed==true))|length' "$snapshot"/*.fetch-meta.json)
reused=$(jq -s 'map(.reused // 0)|add // 0' "$snapshot"/*.fetch-meta.json)
unknown=$(jq -s 'map(select(.unknown==true))|length' "$snapshot"/*.fetch-meta.json)
refuted=$(jq -s 'map(select(.refuted==true))|length' "$snapshot"/*.fetch-meta.json)
peak_rss=$(for file in "$snapshot"/*.fetch-rss; do cat "$file"; done | sort -n | tail -1)
wall_ms=$(( (fetch_end - fetch_start) / 1000000 ))
parallel_live_metrics=$(jq -n \
  --argjson wall "$wall_ms" --argjson raw "$((fetch_end - fetch_start))" --argjson peak "$peak_rss" \
  --argjson requests "$requests" --argjson completed "$completed" --argjson reused "$reused" --argjson unknown "$unknown" --argjson refuted "$refuted" \
  '{wall_ms:$wall,duration_ns:$raw,exact_wall_ms:$wall,peak_rss_kib:$peak,requests:$requests,max_in_flight:8,completed:$completed,reused:$reused,unknown:$unknown,refuted:$refuted}')

export GOOO_RELEASE_SNAPSHOT_DIR="$snapshot"
bash scripts/verify-releases.sh "$lock" "$output"

sequential="$output/snapshot-sequential.json"
parallel="$output/snapshot-parallel.json"
bash scripts/evaluate-release-lock-snapshot.sh "$lock" "$snapshot" sequential "$sequential"
bash scripts/evaluate-release-lock-snapshot.sh "$lock" "$snapshot" parallel "$parallel"
legacy_results=$(for key in "${keys[@]}"; do jq -S --arg key "$key" '{lock_id:$key,state,verified}' "$output/$key.result.json"; done | jq -S -s 'sort_by(.lock_id)')
snapshot_sequential_results=$(jq -S '.results|map({lock_id,state,verified})' "$sequential")
if ! cmp <(printf '%s\n' "$legacy_results" | jq -S .) <(printf '%s\n' "$snapshot_sequential_results" | jq -S .) >/dev/null; then
  echo "legacy sequential and snapshot sequential semantic evaluations diverged" >&2
  exit 1
fi
legacy_digest=$(printf '%s\n' "$legacy_results" | sha256sum | awk '{print $1}')
semantic_compare=$(jq -S '{canonical_order,results,summary}' "$sequential" | sha256sum | awk '{print $1}')
parallel_compare=$(jq -S '{canonical_order,results,summary}' "$parallel" | sha256sum | awk '{print $1}')
if ! cmp <(jq -S '{canonical_order,results,summary}' "$sequential") <(jq -S '{canonical_order,results,summary}' "$parallel") >/dev/null; then
  echo "sequential and parallel snapshot evaluations diverged" >&2
  exit 1
fi

jq -S --argjson metrics "$parallel_live_metrics" --arg legacy_digest "sha256:$legacy_digest" --arg sequential_digest "sha256:$semantic_compare" --arg parallel_digest "sha256:$parallel_compare" \
  --argjson legacy_results "$legacy_results" --argjson sequential "$(cat "$sequential")" --argjson parallel "$(cat "$parallel")" \
  '. + {release_lock_snapshot:{snapshot_single_fetch:true,canonical_order_exact:true,completion_order_ignored:true,legacy_sequential:{results:$legacy_results,semantic_equivalence:"CLOSED",digest:$legacy_digest},sequential:$sequential,parallel:$parallel,snapshot_semantic_equivalence:{state:"CLOSED",same_snapshot:true,legacy_sequential_same_state:true,canonical_order_exact:true,completion_order_ignored:true,sequential_digest:$sequential_digest,parallel_digest:$parallel_digest},parallel_live_metrics:$metrics}}' \
  "$output/verification.json" > "$output/verification.json.tmp"
mv "$output/verification.json.tmp" "$output/verification.json"
