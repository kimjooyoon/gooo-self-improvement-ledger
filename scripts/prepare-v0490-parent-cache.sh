#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.49 parent-cache preparation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: prepare-v0490-parent-cache.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
contract="$repository/contracts/release-locks-v1.json"
contract_rel=contracts/release-locks-v1.json
receipt="$artifact_root/v0490-release-audit-receipt.json"
parent_temp_root="${RUNNER_TEMP:-$artifact_root/.v0490-parent-temp}"
parent_root="$parent_temp_root/v0490-parent-artifact"
parent_zip="$parent_temp_root/v0490-parent-artifact.zip"

command -v gh >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v unzip >/dev/null
command -v git >/dev/null
test -n "${GH_TOKEN:-}"
mkdir -p "$artifact_root"
mkdir -p "$parent_temp_root"

parent_artifact_id=9817152046
parent_artifact_name=gooo-self-improvement-ledger-489f71d106dac76ceb3f019a9eef9c0f000dcef7
parent_artifact_size=84125369
parent_artifact_digest=sha256:32ed80d4d173d609eb60f47aa88096552a90bdb76c3ad8706e483005e1c331d8
parent_run_id=33549740697
parent_sha=489f71d106dac76ceb3f019a9eef9c0f000dcef7
parent_branch=main

current_lock_set_digest=$(jq -cS '.releases' "$contract" | sha256sum | awk '{print $1}')
parent_lock_set_digest=""
api_requests=0
parent_meta='{}'
parent_run='{}'
primary_state=UNKNOWN
reason="PARENT_ARTIFACT_NOT_OBSERVED"
unknown_class=PARENT_ARTIFACT_UNAVAILABLE
parent_semantic_root=""
parent_semantic_status=""
parent_canonical_equal=false

github_api() {
  api_requests=$((api_requests + 1))
  gh api "$@"
}

if ! parent_lock_json=$(git -C "$repository" show "$parent_sha:$contract_rel" 2>/dev/null); then
  reason="PARENT_COMMIT_NOT_AVAILABLE_FOR_LOCK_SET_COMPARISON"
elif ! parent_lock_set_digest=$(jq -cS '.releases' <<< "$parent_lock_json" | sha256sum | awk '{print $1}'); then
  reason="PARENT_LOCK_SET_DIGEST_NOT_OBSERVED"
elif [ "$parent_lock_set_digest" != "$current_lock_set_digest" ]; then
  primary_state=REFUTED
  unknown_class=PARENT_ARTIFACT_CONTRADICTION
  reason="CURRENT_LOCK_SET_DIGEST_DIFFERS_FROM_PARENT"
else
  if parent_meta=$(github_api "repos/kimjooyoon/gooo-self-improvement-ledger/actions/artifacts/$parent_artifact_id" 2>/dev/null); then
    metadata_state=$(jq -r --argjson id "$parent_artifact_id" --arg name "$parent_artifact_name" --argjson size "$parent_artifact_size" --arg digest "$parent_artifact_digest" --argjson run "$parent_run_id" --arg sha "$parent_sha" '
      if .expired==true then "UNKNOWN"
      elif .id==$id and .name==$name and .size_in_bytes==$size and .digest==$digest and .expired==false and
        .workflow_run.id==$run and .workflow_run.head_branch=="main" and .workflow_run.head_sha==$sha then "CLOSED"
      elif (.id==null or .name==null or .size_in_bytes==null or .digest==null or .workflow_run==null or .workflow_run.id==null or .workflow_run.head_sha==null) then "UNKNOWN"
      else "REFUTED" end
    ' <<< "$parent_meta")
    if [ "$metadata_state" = UNKNOWN ]; then
      reason="PARENT_MAIN_EVIDENCE_ARTIFACT_MISSING_OR_STALE"
      unknown_class=PARENT_ARTIFACT_UNAVAILABLE
    elif [ "$metadata_state" = REFUTED ]; then
      primary_state=REFUTED
      unknown_class=PARENT_ARTIFACT_CONTRADICTION
      reason="PARENT_ARTIFACT_METADATA_CONTRADICTS_IMMUTABLE_IDENTITY"
    else
      if parent_run=$(github_api "repos/kimjooyoon/gooo-self-improvement-ledger/actions/runs/$parent_run_id" 2>/dev/null); then
        if ! jq -e --argjson id "$parent_run_id" --arg sha "$parent_sha" '
          .id==$id and .head_sha==$sha and .head_branch=="main" and .event=="push" and .status=="completed" and .conclusion=="success"
        ' <<< "$parent_run" >/dev/null; then
          primary_state=REFUTED
          unknown_class=PARENT_ARTIFACT_CONTRADICTION
          reason="PARENT_MAIN_RUN_IS_NOT_THE_EXPECTED_SUCCESSFUL_IMMUTABLE_BASELINE"
        else
          if github_api "repos/kimjooyoon/gooo-self-improvement-ledger/actions/artifacts/$parent_artifact_id/zip" > "$parent_zip" 2>/dev/null; then
            if test "$(wc -c < "$parent_zip" | tr -d ' ')" != "$parent_artifact_size" || test "sha256:$(sha256sum "$parent_zip" | awk '{print $1}')" != "$parent_artifact_digest"; then
              primary_state=REFUTED
              unknown_class=PARENT_ARTIFACT_CONTRADICTION
              reason="PARENT_ARTIFACT_BYTES_OR_DIGEST_CONTRADICT_IMMUTABLE_METADATA"
            else
              mkdir -p "$parent_root"
              unzip -q "$parent_zip" -d "$parent_root"
              if ! jq -e '
                .schema=="gooo/self-improvement-portfolio/report/v1" and
                .summary=={total:62,closed:59,unknown:1,refuted:2} and
                .authority.runtime_repository_writes==0 and .authority.caller_owned_temp_output==true and .authority.cross_project_required_gates==0
              ' "$parent_root/report.json" >/dev/null || ! jq -e '
                .schema=="gooo/self-improvement-ledger/v049-product-integration/v1" and
                .adoption.parent_profile=={release_tag:"v0.48.0",lock_count:57} and .adoption.current_lock_count==59 and
                .adoption.baseline.selected==59 and .adoption.baseline.executed==59 and .adoption.baseline.reused==0 and
                .adoption.candidate.selected==2 and .adoption.candidate.executed==2 and .adoption.candidate.reused==57 and
                .adoption.canonical_comparison.status=="CLOSED" and .adoption.canonical_comparison.unknown_equal==true and
                .adoption.canonical_comparison.refuted_equal==true and .adoption.canonical_comparison.canonical_evidence_equal==true
              ' "$parent_root/v049-products/product-integration.json" >/dev/null || ! jq -e '
                .schema=="gooo/self-improvement-ledger/atomic-v0490-adoption-wave/v1" and .wave.release_tag=="v0.49.0" and .wave.atomic==true and .wave.cell_count==2 and .wave.ordinals==[61,62]
              ' "$parent_root/atomic-v0490-wave-v1.json" >/dev/null || ! jq -e '
                .schema=="gooo/self-improvement-portfolio/semantic-denominator/v1" and .scenario_denominator==62 and .state_counts=={total:62,closed:59,unknown:1,refuted:2}
              ' "$parent_root/semantic-denominator-projector/semantic-denominator.json" >/dev/null || ! jq -e '
                .summary=={total:59,verified:59,unknown:0,refuted:0} and .release_lock_snapshot.snapshot_semantic_equivalence.state=="CLOSED"
              ' "$parent_root/releases/verification.json" >/dev/null; then
                primary_state=REFUTED
                unknown_class=PARENT_ARTIFACT_CONTRADICTION
                reason="PARENT_ARTIFACT_SEMANTIC_ROOT_OR_STATUS_CONTRADICTS_GREEN_BASELINE"
              else
                primary_state=CLOSED
                reason="IMMUTABLE_GREEN_MAIN_ARTIFACT_AND_LOCK_SET_DIGEST_MATCHED"
                parent_semantic_root=$(jq -r '.adoption.canonical_comparison.semantic_root' "$parent_root/v049-products/product-integration.json")
                parent_semantic_status=$(jq -r '.adoption.canonical_comparison.status' "$parent_root/v049-products/product-integration.json")
                parent_canonical_equal=$(jq -r '.adoption.canonical_comparison.canonical_evidence_equal' "$parent_root/v049-products/product-integration.json")
                mkdir -p "$artifact_root/releases"
                cp -a "$parent_root/releases/." "$artifact_root/releases/"
              fi
            fi
          else
            reason="PARENT_ARTIFACT_DOWNLOAD_NOT_OBSERVED"
          fi
        fi
      else
        reason="PARENT_MAIN_RUN_NOT_OBSERVED"
      fi
    fi
  else
    reason="PARENT_ARTIFACT_METADATA_NOT_OBSERVED"
  fi
fi

rate_limit='{}'
if observed_rate=$(github_api rate_limit 2>/dev/null); then
  rate_limit="$observed_rate"
fi
rate_remaining=$(jq -r '.resources.core.remaining // .rate.remaining // null' <<< "$rate_limit")
rate_reset=$(jq -r '.resources.core.reset // .rate.reset // null' <<< "$rate_limit")

if [ "$primary_state" = CLOSED ]; then
  fallback_state=NOT_REQUIRED
  fallback_reason=""
  fallback_required=false
  reused=57
  selected=2
  executed=2
  matched_parent=$(jq -n --argjson id "$parent_artifact_id" --arg name "$parent_artifact_name" --arg digest "$parent_artifact_digest" --argjson size "$parent_artifact_size" --argjson run "$parent_run_id" --arg sha "$parent_sha" --arg branch "$parent_branch" --arg current "$current_lock_set_digest" --arg parent "$parent_lock_set_digest" --arg root "$parent_semantic_root" --arg status "$parent_semantic_status" --argjson canonical "$parent_canonical_equal" '{artifact_id:$id,artifact_name:$name,artifact_digest:$digest,artifact_size_bytes:$size,source_run_id:$run,source_sha:$sha,source_branch:$branch,immutable:true,current_lock_set_digest:$current,parent_lock_set_digest:$parent,semantic_root:$root,semantic_status:$status,canonical_evidence_equal:$canonical}')
else
  fallback_state=PENDING
  fallback_reason=RUN_FULL_59_LOCK_AUDIT
  fallback_required=true
  reused=0
  selected=59
  executed=59
  matched_parent=null
fi

jq -S -n \
  --arg schema "gooo/self-improvement-ledger/v049-release-audit-receipt/v1" \
  --arg state "$primary_state" --arg reason "$reason" --arg unknown_class "$unknown_class" \
  --arg current "$current_lock_set_digest" --arg parent "$parent_lock_set_digest" \
  --argjson api_requests "$api_requests" --argjson reused "$reused" --argjson selected "$selected" --argjson executed "$executed" \
  --argjson remaining "$rate_remaining" --argjson reset "$rate_reset" \
  --arg fallback_state "$fallback_state" --arg fallback_reason "$fallback_reason" --argjson fallback_required "$fallback_required" \
  --argjson matched_parent "$matched_parent" \
  '{schema:$schema,primary:{state:$state,mode:(if $state=="CLOSED" then "CONTENT_ADDRESSED_PARENT_ARTIFACT_REUSE" else "FULL_AUDIT_FALLBACK_REQUIRED" end),reason:$reason,unknown:(if $state=="UNKNOWN" then {blocked_by:"PARENT_MAIN_EVIDENCE_ARTIFACT_OR_LOCK_SET_NOT_OBSERVED",next_operation:"RUN_FULL_59_LOCK_AUDIT",reason:$reason,stage:"v0490-parent-artifact-preflight",step:"parent-evidence-cache",unknown_class:$unknown_class} else null end),refuted:(if $state=="REFUTED" then {blocked_by:"PARENT_MAIN_EVIDENCE_ARTIFACT_OR_LOCK_SET_CONTRADICTED",next_operation:"RUN_FULL_59_LOCK_AUDIT",reason:$reason,stage:"v0490-parent-artifact-preflight",step:"parent-evidence-cache",unknown_class:$unknown_class} else null end)},lock_set:{count:59,current_digest:$current,parent_digest:$parent,unchanged:($state=="CLOSED")},matched_parent:$matched_parent,full_fallback:{required:$fallback_required,state:$fallback_state,reason:$fallback_reason},api_observation:{requests:$api_requests,reused:$reused,selected:$selected,executed:$executed,rate_limit:{remaining:$remaining,reset:$reset,observed:($remaining!=null and $reset!=null)},source:(if $state=="CLOSED" then "PARENT_ARTIFACT_PREPARE" else "PENDING_FULL_59_LOCK_AUDIT" end)}}' \
  > "$receipt"

echo "v0.49 parent-cache preflight: primary=$primary_state lock_set_digest=$current_lock_set_digest requests=$api_requests reused=$reused selected=$selected executed=$executed"
