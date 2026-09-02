#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.56 lock-reuse verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0560-lock-reuse.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
parent_receipt="$artifact_root/v0560-parent-lock-receipt.json"
parent_verification="$artifact_root/releases/v0550-parent-verification.json"
lock_file="$repository/contracts/release-locks-v1.json"
live_receipt="$artifact_root/v0560-live-lock-receipt.json"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0560-lock-reuse-temp}/v0560-lock-reuse-${GITHUB_RUN_ID:-manual}-${GITHUB_RUN_ATTEMPT:-1}"
changed_lock="$temp_root/changed-locks.json"
changed_output="$temp_root/changed-live"
mkdir -p "$artifact_root/releases" "$temp_root"
rm -f "$changed_lock"
rm -rf "$changed_output"
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v bash >/dev/null
test -s "$parent_receipt" -a -s "$parent_verification" -a -s "$lock_file"
test -n "${GH_TOKEN:-}"

jq -e '.schema=="gooo/self-improvement-ledger/v0560-parent-lock-receipt/v1" and .primary.state=="CLOSED" and .parent.release_id==380997346 and .parent.target_commit_sha=="a6591498d5096b73586d06760e1008370fae5eef" and .parent.release_asset.id==540679512 and .parent.release_asset.sha256=="sha256:804ed35da651c369deb491ecbb7313bff24027e1f25e2916a4a7e16ce75d23c0" and .lock_set.current_count==77 and .lock_set.parent_count==72 and .lock_set.unchanged_72_lock_set==true and .primary.api_observation.selected==0 and .primary.api_observation.executed==0 and .primary.api_observation.reused==72 and .primary.api_observation.source=="PARENT_V0550_RELEASE_RECEIPT_REUSE" and .full_fallback.executed==0 and .full_fallback.required==false and .full_fallback.reused==72 and .full_fallback.state=="NOT_REQUIRED"' "$parent_receipt" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:72,verified:72,unknown:0,refuted:0} and (.releases|length)==72' "$parent_verification" >/dev/null

changed_keys='["claim_discharge_calculus_release","incremental_conformance_planner_release","opentofu_service_contract_bridge_release","release_lineage_guard_release","self_hosted_semantic_kernel_release"]'
jq -S --argjson keys "$changed_keys" ' {schema, releases:(.releases|with_entries(select(.key as $key | ($keys|index($key)) != null)))} ' "$lock_file" > "$changed_lock"
jq -e --argjson keys "$changed_keys" '(.releases|length)==5 and ((.releases|keys|sort)==($keys|sort)) and all(.releases[]; .immutable==true and (.assets|length)==1)' "$changed_lock" >/dev/null

release_start=$(date +%s%N)
(cd "$repository" && bash scripts/verify-releases-parallel.sh "$changed_lock" "$changed_output")
release_end=$(date +%s%N)
test -s "$changed_output/verification.json"
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:5,verified:5,unknown:0,refuted:0} and (.releases|length)==5' "$changed_output/verification.json" >/dev/null

changed_verification="$changed_output/verification.json"
changed_live_keys='["claim_discharge_calculus_release","self_hosted_semantic_kernel_release","incremental_conformance_planner_release","opentofu_service_contract_bridge_release","release_lineage_guard_release"]'
parent_ids=$(jq -c '.releases|keys|sort' "$parent_verification")
parent_key_digest=$(jq -cS '.releases|keys|sort' "$parent_verification" | sha256sum | awk '{print "sha256:"$1}')
changed_key_digest=$(jq -cS '.releases|keys|sort' "$changed_verification" | sha256sum | awk '{print "sha256:"$1}')
jq -S -n --slurpfile parent "$parent_verification" --slurpfile changed "$changed_verification" --argjson parent_ids "$parent_ids" --argjson changed_ids "$changed_live_keys" \
  --argjson wall "$(( (release_end - release_start) / 1000000 ))" --argjson raw "$((release_end - release_start))" \
  --arg parent_key_digest "$parent_key_digest" --arg changed_key_digest "$changed_key_digest" \
  '
    ($parent[0]) as $p | ($changed[0]) as $c |
    {schema:"gooo/self-improvement-portfolio/release-verification/v1",
     releases:($p.releases + $c.releases),
     counterexamples:($p.counterexamples // {}),
     counterexample_runs:($p.counterexample_runs // {}),
     failed_release_triggers:($p.failed_release_triggers // {}),
     summary:{total:77,verified:77,unknown:0,refuted:0},
     timing:{fetch:{wall_ms:$wall,duration_ns:$raw,peak_rss_kib:$c.timing.fetch.peak_rss_kib},verify:$c.timing.verify,report:{wall_ms:0,duration_ns:0,peak_rss_kib:0}},
     release_lock_snapshot:{snapshot_single_fetch:true,canonical_order_exact:true,completion_order_ignored:true,
       parent_reuse:{mode:"PARENT_V0550_RELEASE_RECEIPT_REUSE",selected:0,executed:0,reused:72,reused_lock_ids:$parent_ids,parent_key_digest:$parent_key_digest,parent_input_api_requests:0,parent_metadata_api_requests:0},
       changed_live:{selected:5,executed:5,reused:0,live_verified:5,unknown:0,refuted:0,changed_lock_ids:$changed_ids,changed_key_digest:$changed_key_digest,parallel_live_metrics:$c.release_lock_snapshot.parallel_live_metrics},
       full_historical_reexecution:{executed:false,required:false,reason:"PARENT_REUSE_PLUS_FIVE_CHANGED_LOCKS_ONLY"}}
    }' > "$artifact_root/releases/verification.json"

jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:77,verified:77,unknown:0,refuted:0} and (.releases|length)==77 and .release_lock_snapshot.parent_reuse.reused==72 and .release_lock_snapshot.parent_reuse.selected==0 and .release_lock_snapshot.parent_reuse.executed==0 and .release_lock_snapshot.changed_live.selected==5 and .release_lock_snapshot.changed_live.executed==5 and .release_lock_snapshot.changed_live.reused==0 and .release_lock_snapshot.changed_live.live_verified==5 and .release_lock_snapshot.full_historical_reexecution.executed==false' "$artifact_root/releases/verification.json" >/dev/null
jq -S -n --arg schema "gooo/self-improvement-ledger/v0560-live-lock-receipt/v1" --argjson parent_ids "$parent_ids" --argjson changed_ids "$changed_live_keys" --arg parent_key_digest "$parent_key_digest" --arg changed_key_digest "$changed_key_digest" \
  '{schema:$schema,parent_reuse:{mode:"PARENT_V0550_RELEASE_RECEIPT_REUSE",selected:0,executed:0,reused:72,reused_lock_ids:$parent_ids,key_digest:$parent_key_digest},changed_live:{selected:5,executed:5,reused:0,live_verified:5,unknown:0,refuted:0,changed_lock_ids:$changed_ids,key_digest:$changed_key_digest},full_historical_reexecution:{executed:false,required:false,reason:"PARENT_REUSE_PLUS_FIVE_CHANGED_LOCKS_ONLY"},authority:{verification:"GITHUB_ACTIONS_ONLY",repository_writes:0,local_validation_commands:0,cross_project_required_gates:0}}' > "$live_receipt"
jq -e '.schema=="gooo/self-improvement-ledger/v0560-live-lock-receipt/v1" and .parent_reuse=={executed:0,key_digest:.parent_reuse.key_digest,mode:"PARENT_V0550_RELEASE_RECEIPT_REUSE",reused:72,reused_lock_ids:.parent_reuse.reused_lock_ids,selected:0} and .changed_live.selected==5 and .changed_live.executed==5 and .changed_live.reused==0 and .changed_live.live_verified==5 and .full_historical_reexecution.executed==false and .authority.repository_writes==0' "$live_receipt" >/dev/null
echo "v0.56 lock reuse verified: parent_reused=72 changed_selected=5 changed_executed=5 full_historical_reexecution=false"
