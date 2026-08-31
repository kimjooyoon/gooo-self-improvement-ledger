#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: verify-capability-evidence-registry.sh LOCK_JSON ASSESSMENT_JSON OUTPUT_DIR" >&2
  exit 64
fi

lock=$(realpath "$1")
assessment=$(realpath "$2")
output=$(realpath -m "$3")
repository=$(realpath .)
case "$output" in
  "$repository"|"$repository"/*)
    echo "registry output must be outside the input repository" >&2
    exit 65
    ;;
esac
mkdir -p "$output"

command -v gh >/dev/null
command -v curl >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null

jq -e '
  .schema == "gooo/non-completeness/capability-evidence-registry/lock/v1" and
  .registry_id == "non-completeness-capability-evidence-registry-v1" and
  .entry_count == 5 and (.entries|length) == 5 and
  (.entries|map(.entry_id)|length) == (.entries|map(.entry_id)|unique|length) and
  .policy.separate_from_portfolio_denominator == true and
  .policy.aggregate_percentage == false and .policy.aggregate_score == false
' "$lock" >/dev/null
jq -e '
  .schema == "gooo/non-completeness/capability-evidence-registry/assessment/v1" and
  .registry_id == "non-completeness-capability-evidence-registry-v1" and
  .entry_count == 5 and (.entries|length) == 5 and
  (.entries|map(.entry_id)|length) == (.entries|map(.entry_id)|unique|length) and
  all(.entries[]; .state == "CLOSED" or .state == "UNKNOWN" or .state == "REFUTED")
' "$assessment" >/dev/null

measurement() {
  local start=$1
  local end=$2
  jq -n --argjson wall "$(( (end - start) / 1000000 ))" --argjson raw "$((end - start))" \
    '{wall_ms:$wall,duration_ns:$raw}'
}

mark_unknown() {
  if [ "$state" = "CLOSED" ]; then
    state="UNKNOWN"
    reason=$1
  fi
}

mark_refuted() {
  state="REFUTED"
  reason=$1
}

verification_start=$(date +%s%N)
for entry_id in $(jq -r '.entries[].entry_id' "$lock"); do
  repo=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .repository' "$lock")
  tag=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .tag' "$lock")
  release_url=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .release_url' "$lock")
  target=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .target_commit_sha' "$lock")
  release_json="$output/$entry_id.release.json"
  state="CLOSED"
  reason=""
  observed_release='{}'
  observed_target='null'
  observed_source_run='null'
  observed_source_artifact='null'
  asset_results="$output/$entry_id.assets.ndjson"
  : > "$asset_results"

  if ! gh api "repos/$repo/releases/tags/$tag" > "$release_json" 2> "$output/$entry_id.release.error"; then
    state="UNKNOWN"
    reason="RELEASE_API_UNAVAILABLE"
    jq -S -n --arg id "$entry_id" --arg state "$state" --arg reason "$reason" \
      '{entry_id:$id,state:$state,observed:{},verified_assets:[],reason:$reason}' \
      > "$output/$entry_id.result.json"
    continue
  fi

  observed_release=$(jq -S '{tag_name,html_url,draft,prerelease,immutable,asset_count:(.assets|length)}' "$release_json")
  immutable_required=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .immutable_required' "$lock")
  if ! jq -e --arg tag "$tag" --arg url "$release_url" --argjson immutable "$immutable_required" \
    '.tag_name==$tag and .html_url==$url and .draft==false and .prerelease==false and .immutable==$immutable' \
    "$release_json" >/dev/null; then
    mark_refuted "RELEASE_API_METADATA_MISMATCH"
  fi

  tag_ref="$output/$entry_id.tag-ref.json"
  tag_target_json="$output/$entry_id.tag-target.json"
  if ! gh api "repos/$repo/git/ref/tags/$tag" > "$tag_ref" 2> "$output/$entry_id.tag-ref.error"; then
    mark_unknown "TAG_REF_UNAVAILABLE"
  else
    ref_type=$(jq -r '.object.type // empty' "$tag_ref")
    ref_sha=$(jq -r '.object.sha // empty' "$tag_ref")
    resolved_target="$ref_sha"
    if [ "$ref_type" = "tag" ] && [ -n "$ref_sha" ]; then
      if ! gh api "repos/$repo/git/tags/$ref_sha" > "$tag_target_json" 2> "$output/$entry_id.tag-target.error"; then
        resolved_target=""
        mark_unknown "TAG_OBJECT_UNAVAILABLE"
      else
        resolved_target=$(jq -r '.object.sha // empty' "$tag_target_json")
      fi
    fi
    if [ -z "$resolved_target" ]; then
      mark_unknown "TAG_TARGET_UNAVAILABLE"
    else
      observed_target=$(jq -n --arg type "$ref_type" --arg object "$ref_sha" --arg target "$resolved_target" \
        '{ref_type:$type,ref_object_sha:$object,resolved_target_sha:$target}')
      if [ "$resolved_target" != "$target" ]; then
        mark_refuted "TAG_TARGET_MISMATCH"
      fi
    fi
  fi

  expected_asset_count=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | (.release_assets_expected // (.assets|length))' "$lock")
  locked_asset_count=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | (.assets|length)' "$lock")
  if [ "$expected_asset_count" -ne "$locked_asset_count" ]; then
    mark_refuted "REGISTRY_ASSET_COUNT_DECLARATION_MISMATCH"
  fi
  actual_asset_count=$(jq -r '.assets|length' "$release_json")
  if [ "$actual_asset_count" -ne "$expected_asset_count" ]; then
    mark_refuted "RELEASE_ASSET_COUNT_MISMATCH"
  fi
  mkdir -p "$output/$entry_id/assets"
  if [ "$expected_asset_count" -gt 0 ]; then
    for index in $(seq 0 $((expected_asset_count - 1))); do
      name=$(jq -r --arg id "$entry_id" --argjson index "$index" '.entries[] | select(.entry_id==$id) | .assets[$index].name' "$lock")
      size=$(jq -r --arg id "$entry_id" --argjson index "$index" '.entries[] | select(.entry_id==$id) | .assets[$index].size_bytes' "$lock")
      sha=$(jq -r --arg id "$entry_id" --argjson index "$index" '.entries[] | select(.entry_id==$id) | .assets[$index].sha256' "$lock")
      download_url=$(jq -r --arg id "$entry_id" --argjson index "$index" '.entries[] | select(.entry_id==$id) | .assets[$index].download_url' "$lock")
      if ! jq -e --arg name "$name" --arg digest "$sha" --arg url "$download_url" --argjson size "$size" \
        '[.assets[] | select(.name==$name and .size==$size and .digest==$digest and .browser_download_url==$url)] | length == 1' \
        "$release_json" >/dev/null; then
        mark_refuted "RELEASE_ASSET_API_MISMATCH"
        continue
      fi
      asset_path="$output/$entry_id/assets/$index.bin"
      if ! curl --fail --location --retry 3 --silent --show-error "$download_url" -o "$asset_path"; then
        mark_unknown "RELEASE_ASSET_DOWNLOAD_UNAVAILABLE"
        continue
      fi
      actual_size=$(wc -c < "$asset_path" | tr -d ' ')
      actual_sha="sha256:$(sha256sum "$asset_path" | awk '{print $1}')"
      if [ "$actual_size" -ne "$size" ] || [ "$actual_sha" != "$sha" ]; then
        mark_refuted "RELEASE_ASSET_DIGEST_MISMATCH"
        continue
      fi
      jq -S -n --arg name "$name" --argjson size "$size" --arg sha "$sha" --arg url "$download_url" \
        '{name:$name,size_bytes:$size,sha256:$sha,download_url:$url,verified:true}' >> "$asset_results"
    done
  fi

  if jq -e --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | has("source_run")' "$lock" >/dev/null; then
    source_run_id=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .source_run.run_id' "$lock")
    source_run_json="$output/$entry_id.source-run.json"
    if ! gh api "repos/$repo/actions/runs/$source_run_id" > "$source_run_json" 2> "$output/$entry_id.source-run.error"; then
      mark_unknown "SOURCE_RUN_API_UNAVAILABLE"
    else
      observed_source_run=$(jq -S '{id,head_sha,conclusion,html_url}' "$source_run_json")
      if ! jq -e --arg sha "$target" --argjson id "$source_run_id" \
        '.id==$id and .head_sha==$sha and .conclusion=="success"' "$source_run_json" >/dev/null; then
        mark_refuted "SOURCE_RUN_PROVENANCE_MISMATCH"
      fi
    fi
  fi

  if jq -e --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | has("source_artifact")' "$lock" >/dev/null; then
    source_artifact_id=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .source_artifact.artifact_id' "$lock")
    source_artifact_json="$output/$entry_id.artifacts.json"
    if ! gh api "repos/$repo/actions/artifacts?per_page=100" > "$source_artifact_json" 2> "$output/$entry_id.artifacts.error"; then
      mark_unknown "SOURCE_ARTIFACT_API_UNAVAILABLE"
    elif ! jq -e --argjson id "$source_artifact_id" '.artifacts[] | select(.id==$id)' "$source_artifact_json" >/dev/null; then
      mark_unknown "SOURCE_ARTIFACT_NOT_FOUND"
    else
      source_artifact_name=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .source_artifact.name' "$lock")
      source_artifact_size=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .source_artifact.size_bytes' "$lock")
      source_artifact_sha=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .source_artifact.sha256' "$lock")
      source_run_id=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .source_artifact.run_id' "$lock")
      observed_source_artifact=$(jq -S --argjson id "$source_artifact_id" '.artifacts[] | select(.id==$id) | {id,name,size_in_bytes,digest,expired,workflow_run}' "$source_artifact_json")
      if ! jq -e --arg target "$target" --argjson id "$source_artifact_id" --arg name "$source_artifact_name" \
        --argjson size "$source_artifact_size" --arg sha "$source_artifact_sha" --argjson run_id "$source_run_id" \
        '.artifacts[] | select(.id==$id) | .name==$name and .size_in_bytes==$size and .digest==$sha and .expired==false and .workflow_run.id==$run_id and .workflow_run.head_sha==$target' \
        "$source_artifact_json" >/dev/null; then
        mark_refuted "SOURCE_ARTIFACT_METADATA_MISMATCH"
      fi
    fi
  fi

  assets=$(jq -s . "$asset_results")
  jq -S -n \
    --arg id "$entry_id" --arg state "$state" --arg reason "$reason" \
    --argjson release "$observed_release" --argjson target "$observed_target" \
    --argjson assets "$assets" --argjson source_run "$observed_source_run" \
    --argjson source_artifact "$observed_source_artifact" \
    '{entry_id:$id,state:$state,observed:{release:$release,resolved_tag:$target,source_run:$source_run,source_artifact:$source_artifact},verified_assets:$assets,reason:(if $reason=="" then null else $reason end)}' \
    > "$output/$entry_id.result.json"
done
verification_end=$(date +%s%N)

results='{}'
for entry_id in $(jq -r '.entries[].entry_id' "$lock"); do
  result=$(jq -c . "$output/$entry_id.result.json")
  results=$(jq -c --arg id "$entry_id" --argjson result "$result" '. + {($id):$result}' <<< "$results")
done

assessment_mismatches=0
for entry_id in $(jq -r '.entries[].entry_id' "$lock"); do
  expected=$(jq -r --arg id "$entry_id" '.entries[] | select(.entry_id==$id) | .state' "$assessment")
  actual=$(jq -r --arg id "$entry_id" '.[$id].state' <<< "$results")
  if [ "$expected" != "$actual" ]; then
    echo "registry state mismatch for $entry_id: assessment=$expected observed=$actual" >&2
    assessment_mismatches=$((assessment_mismatches + 1))
  fi
done

summary=$(jq -c '{entry_count:length,closed:([.[]|select(.state=="CLOSED")]|length),unknown:([.[]|select(.state=="UNKNOWN")]|length),refuted:([.[]|select(.state=="REFUTED")]|length)}' <<< "$results")
jq -S -n \
  --arg schema "gooo/non-completeness/capability-evidence-registry/verification/v1" \
  --arg registry "non-completeness-capability-evidence-registry-v1" \
  --arg source_lock "contracts/non-completeness-capability-evidence-registry-v1.json" \
  --argjson entries "$results" --argjson summary "$summary" \
  --argjson timing "$(measurement "$verification_start" "$verification_end")" \
  '{schema:$schema,registry_id:$registry,source_lock:$source_lock,entry_count:$summary.entry_count,summary:{closed:$summary.closed,unknown:$summary.unknown,refuted:$summary.refuted},entries:$entries,timing:{verification:$timing}}' \
  > "$output/verification.json"

if [ "$assessment_mismatches" -ne 0 ]; then
  exit 1
fi
