#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "snapshot evaluator failed at line ${BASH_LINENO[0]}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 4 ]; then
  echo "usage: evaluate-release-lock-snapshot.sh LOCK_JSON SNAPSHOT_DIR sequential|parallel OUTPUT_JSON" >&2
  exit 64
fi

lock=$(realpath "$1")
snapshot=$(realpath "$2")
mode=$3
output=$(realpath "$4" 2>/dev/null || { mkdir -p "$(dirname "$4")"; realpath "$4"; })
case "$mode" in sequential|parallel) ;; *) echo "mode must be sequential or parallel" >&2; exit 64 ;; esac
mkdir -p "$(dirname "$output")"
command -v jq >/dev/null

unknown_frontier() {
  jq -n '{stage:"RELEASE_FETCH",step:"READ_RELEASE_API",reason:"RELEASE_RESPONSE_NOT_OBSERVED_WITHIN_RETRY_TIMEOUT",unknown_class:"TRANSIENT",next_operation:"RETRY_RELEASE_FETCH",blocked_by:["release-api-response"]}'
}

evaluate_one() {
  local key=$1
  local release_file="$snapshot/$key.release.json"
  local result_file="$work/$key.json"
  if [ ! -s "$release_file" ] || ! jq -e . "$release_file" >/dev/null 2>&1; then
    jq -S -n --arg key "$key" --argjson frontier "$(unknown_frontier)" \
      '{lock_id:$key,state:"UNKNOWN",verified:false,unknown_frontier:$frontier}' > "$result_file"
    return
  fi
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$lock")
  tag=$(jq -r --arg key "$key" '.releases[$key].tag' "$lock")
  release_url=$(jq -r --arg key "$key" '.releases[$key].release_url' "$lock")
  release_id=$(jq -r --arg key "$key" '.releases[$key].release_id // empty' "$lock")
  if [ -n "$release_id" ]; then
    release_matches=$(jq -e --arg tag "$tag" --arg url "$release_url" --argjson release_id "$release_id" \
      '.id==$release_id and .tag_name==$tag and .html_url==$url and .draft==false and .prerelease==false and .immutable==true' \
      "$release_file" >/dev/null; echo "$?")
  else
    release_matches=$(jq -e --arg tag "$tag" --arg url "$release_url" \
      '.tag_name==$tag and .html_url==$url and .draft==false and .prerelease==false and .immutable==true' \
      "$release_file" >/dev/null; echo "$?")
  fi
  if [ "$release_matches" -eq 0 ]; then
    jq -S -n --arg key "$key" --arg repo "$repo" --arg tag "$tag" \
      --argjson observed "$(jq '{id,tag_name,html_url,draft,prerelease,immutable}' "$release_file")" \
      '{lock_id:$key,state:"CLOSED",verified:true,repository:$repo,tag:$tag,observed:$observed}' > "$result_file"
  elif jq -e '.immutable==false' "$release_file" >/dev/null 2>&1; then
    jq -S -n --arg key "$key" --arg repo "$repo" --arg tag "$tag" \
      --argjson observed "$(jq '{id,tag_name,html_url,draft,prerelease,immutable}' "$release_file")" \
      '{lock_id:$key,state:"REFUTED",verified:false,repository:$repo,tag:$tag,observed:$observed,refutation:{stage:"RELEASE_FETCH",step:"MATCH_RELEASE_METADATA",reason:"IMMUTABLE_RELEASE_METADATA_CONTRADICTED",unknown_class:null,next_operation:"PRESERVE_REFUTED_RELEASE_AND_OPEN_CORRECTION_PR",blocked_by:["immutable-release-metadata"]}}' > "$result_file"
  else
    jq -S -n --arg key "$key" --arg repo "$repo" --arg tag "$tag" \
      --argjson observed "$(jq '{id,tag_name,html_url,draft,prerelease,immutable}' "$release_file")" \
      '{lock_id:$key,state:"REFUTED",verified:false,repository:$repo,tag:$tag,observed:$observed,refutation:{stage:"RELEASE_FETCH",step:"MATCH_RELEASE_METADATA",reason:"RELEASE_METADATA_COORDINATE_CONTRADICTION",unknown_class:null,next_operation:"PRESERVE_REFUTED_RELEASE_AND_OPEN_CORRECTION_PR",blocked_by:["release-metadata"]}}' > "$result_file"
  fi
}

work=$(mktemp -d "$(dirname "$output")/snapshot-evaluation.XXXXXX")
trap 'rm -rf "$work"' EXIT
mapfile -t keys < <(jq -r '.releases | keys[]' "$lock" | LC_ALL=C sort)
if [ "$mode" = sequential ]; then
  for key in "${keys[@]}"; do evaluate_one "$key"; done
else
  bound=8
  index=0
  while [ "$index" -lt "${#keys[@]}" ]; do
    pids=()
    for key in "${keys[@]:index:bound}"; do evaluate_one "$key" & pids+=("$!"); done
    for pid in "${pids[@]}"; do wait "$pid"; done
    index=$((index + bound))
  done
fi

results=$(jq -S -s 'sort_by(.lock_id)' "$work"/*.json)
jq -S -n --arg schema "gooo/self-improvement-portfolio/release-lock-snapshot-evaluation/v1" \
  --arg mode "$mode" --argjson order "$(printf '%s\n' "${keys[@]}" | jq -R -s 'split("\n")|map(select(length>0))')" \
  --argjson results "$results" \
  '{schema:$schema,mode:$mode,canonical_order:$order,results:$results,summary:{total:($results|length),closed:([$results[]|select(.state=="CLOSED")]|length),unknown:([$results[]|select(.state=="UNKNOWN")]|length),refuted:([$results[]|select(.state=="REFUTED")]|length)},policy:{state_precedence:["REFUTED","UNKNOWN","CLOSED"],completion_order_ignored:true,snapshot_single_fetch:true}}' > "$output"
