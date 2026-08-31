#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "release verification failed at line ${BASH_LINENO[0]}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-releases.sh LOCK_JSON OUTPUT_DIR" >&2
  exit 64
fi

lock=$(realpath "$1")
output=$(realpath -m "$2")
repository=$(realpath .)
case "$output" in
  "$repository"|"$repository"/*)
    echo "release output must be outside the input repository" >&2
    exit 65
    ;;
esac
mkdir -p "$output"

command -v gh >/dev/null
command -v curl >/dev/null
command -v git >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null

measurement() {
  local start=$1
  local end=$2
  local peak=${3:-0}
  jq -n --argjson wall "$(( (end - start) / 1000000 ))" --argjson raw "$((end - start))" --argjson peak "$peak" \
    '{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$peak}'
}

fetch_start=$(date +%s%N)
for key in $(jq -r '.releases | keys[]' "$lock"); do
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$lock")
  tag=$(jq -r --arg key "$key" '.releases[$key].tag' "$lock")
  /usr/bin/time -f '%M' -o "$output/$key.fetch-rss" \
    gh api "repos/$repo/releases/tags/$tag" > "$output/$key.release.json"
done
fetch_end=$(date +%s%N)

verify_start=$(date +%s%N)
for key in $(jq -r '.releases | keys[]' "$lock"); do
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$lock")
  tag=$(jq -r --arg key "$key" '.releases[$key].tag' "$lock")
  release_url=$(jq -r --arg key "$key" '.releases[$key].release_url' "$lock")
  target=$(jq -r --arg key "$key" '.releases[$key].target_commit_sha' "$lock")
  release_json="$output/$key.release.json"

  if ! jq -e --arg tag "$tag" --arg url "$release_url" \
    '.tag_name==$tag and .html_url==$url and .draft==false and .prerelease==false and .immutable==true' \
    "$release_json" >/dev/null; then
    echo "release metadata mismatch for $repo@$tag" >&2
    jq -c '{tag_name,html_url,draft,prerelease,immutable}' "$release_json" >&2
    exit 1
  fi

  tag_target=""
  for attempt in 1 2 3; do
    if remote_refs=$(git ls-remote "https://github.com/$repo.git" "refs/tags/$tag" "refs/tags/$tag^{}"); then
      tag_target=$(awk -v direct="refs/tags/$tag" -v peeled="refs/tags/$tag^{}" '$2==peeled {p=$1} $2==direct {d=$1} END {if (p!="") print p; else print d}' <<< "$remote_refs")
      break
    fi
    echo "tag lookup attempt $attempt failed for $repo@$tag" >&2
    sleep 1
  done
  if test "$tag_target" != "$target"; then
    echo "tag target mismatch for $repo@$tag: expected $target, observed ${tag_target:-<empty>}" >&2
    exit 1
  fi

  mkdir -p "$output/$key/assets"
  asset_results="$output/$key/assets.ndjson"
  : > "$asset_results"
  asset_count=$(jq -r --arg key "$key" '.releases[$key].assets | length' "$lock")
  for index in $(seq 0 $((asset_count - 1))); do
    name=$(jq -r --arg key "$key" --argjson index "$index" '.releases[$key].assets[$index].name' "$lock")
    size=$(jq -r --arg key "$key" --argjson index "$index" '.releases[$key].assets[$index].size_bytes' "$lock")
    sha=$(jq -r --arg key "$key" --argjson index "$index" '.releases[$key].assets[$index].sha256' "$lock")
    download_url=$(jq -r --arg key "$key" --argjson index "$index" '.releases[$key].assets[$index].download_url' "$lock")
    jq -e --arg name "$name" --arg digest "$sha" --arg url "$download_url" --argjson size "$size" \
      '[.assets[] | select(.name==$name and .size==$size and .digest==$digest and .browser_download_url==$url)] | length == 1' \
      "$release_json" >/dev/null
    curl --fail --location --retry 3 --silent --show-error "$download_url" -o "$output/$key/assets/$name"
    actual_size=$(wc -c < "$output/$key/assets/$name" | tr -d ' ')
    actual_sha="sha256:$(sha256sum "$output/$key/assets/$name" | awk '{print $1}')"
    test "$actual_size" -eq "$size"
    test "$actual_sha" = "$sha"
    jq -S -n --arg name "$name" --argjson size "$size" --arg sha "$sha" --arg url "$download_url" \
      '{name:$name,size_bytes:$size,sha256:$sha,download_url:$url,verified:true}' >> "$asset_results"
  done
  manifest_name=$(jq -r --arg key "$key" '.releases[$key].manifest.name // empty' "$lock")
  if [ -n "$manifest_name" ]; then
    manifest_path="$output/$key/assets/$manifest_name"
    if jq -e --arg key "$key" '.releases[$key] | has("source_artifact")' "$lock" >/dev/null; then
      source_run_id=$(jq -r --arg key "$key" '.releases[$key].source_artifact.run_id' "$lock")
      source_artifact_id=$(jq -r --arg key "$key" '.releases[$key].source_artifact.artifact_id' "$lock")
      source_artifact_name=$(jq -r --arg key "$key" '.releases[$key].source_artifact.name' "$lock")
      source_artifact_size=$(jq -r --arg key "$key" '.releases[$key].source_artifact.size_bytes' "$lock")
      source_artifact_sha=$(jq -r --arg key "$key" '.releases[$key].source_artifact.sha256' "$lock")
      jq -e --arg target "$target" --argjson run_id "$source_run_id" --argjson artifact_id "$source_artifact_id" \
        --arg name "$source_artifact_name" --argjson size "$source_artifact_size" --arg sha "$source_artifact_sha" \
        '.provenance.merge_commit_sha==$target and .provenance.post_main_workflow_run_id==$run_id and
         .provenance.actions_artifact_id==$artifact_id and .provenance.actions_artifact_name==$name and
         .provenance.actions_artifact_size_bytes==$size and .provenance.actions_artifact_digest==$sha' \
        "$manifest_path" >/dev/null
    fi
    if jq -e --arg key "$key" '.releases[$key] | has("release_manifest_lock")' "$lock" >/dev/null; then
      lock_path=$(jq -r --arg key "$key" '.releases[$key].release_manifest_lock.path' "$lock")
      lock_sha=$(jq -r --arg key "$key" '.releases[$key].release_manifest_lock.sha256' "$lock")
      jq -e --arg path "$lock_path" --arg sha "$lock_sha" \
        '.external_inputs.lock.path==$path and .external_inputs.lock.sha256==$sha' \
        "$manifest_path" >/dev/null
    fi
  fi
  assets=$(jq -s . "$asset_results")
  fetch_rss=$(cat "$output/$key.fetch-rss")
  jq -S -n \
    --arg state "CLOSED" --arg repository "$repo" --arg tag "$tag" --arg release_url "$release_url" \
    --arg target "$target" --argjson assets "$assets" --argjson fetch_rss "$fetch_rss" \
    '{state:$state,verified:true,repository:$repository,tag:$tag,release_url:$release_url,target_commit_sha:$target,assets:$assets,fetch:{wall_ms:0,duration_ns:0,peak_rss_kib:$fetch_rss},verify:{wall_ms:0,duration_ns:0,peak_rss_kib:0},reason:""}' \
    > "$output/$key.result.json"
done
verify_end=$(date +%s%N)

releases='{}'
for key in $(jq -r '.releases | keys[]' "$lock"); do
  result=$(cat "$output/$key.result.json")
  releases=$(jq -c --arg key "$key" --argjson result "$result" '. + {($key):$result}' <<< "$releases")
done

fetch_peak=$(for file in "$output"/*.fetch-rss; do cat "$file"; done | sort -n | tail -1)
fetch_timing=$(measurement "$fetch_start" "$fetch_end" "$fetch_peak")
verify_timing=$(measurement "$verify_start" "$verify_end")
jq -S -n \
  --arg schema "gooo/self-improvement-portfolio/release-verification/v1" \
  --argjson releases "$releases" --argjson fetch "$fetch_timing" --argjson verify "$verify_timing" \
  '{schema:$schema,releases:$releases,summary:{total:($releases|length),verified:([ $releases[] | select(.state=="CLOSED") ]|length),unknown:([ $releases[] | select(.state=="UNKNOWN") ]|length),refuted:([ $releases[] | select(.state=="REFUTED") ]|length)},timing:{fetch:$fetch,verify:$verify,report:{wall_ms:0,duration_ns:0,peak_rss_kib:0}}}' \
  > "$output/verification.json"
