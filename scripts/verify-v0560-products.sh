#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.56 product integration failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v0560-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v0560-products"
parent_products="$artifact_root/v0560-parent-products"
verification="$artifact_root/releases/verification.json"
lock_file="$repository/contracts/release-locks-v1.json"
assessment="$repository/evidence/assessment-v1.json"
wave_evidence="$repository/evidence/atomic-v0560-wave-v1.json"
temp_root="${RUNNER_TEMP:-$artifact_root/.v0560-products-temp}/v0560-products-${GITHUB_RUN_ID:-manual}-${GITHUB_RUN_ATTEMPT:-1}"
work_root="$temp_root/work"
wave_work="$work_root/semantic-wave"
mkdir -p "$artifact_root" "$temp_root" "$work_root"
rm -rf "$products" "$wave_work"
mkdir -p "$products/cells" "$products/semantic-wave/upstream" "$products/semantic-wave/actual" "$wave_work/source" "$wave_work/cases"

command -v gh >/dev/null
command -v go >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v find >/dev/null
command -v grep >/dev/null
command -v wc >/dev/null
test -n "${GH_TOKEN:-}"
for required_file in "$parent_products/product-integration.json" "$parent_products/output-authority/receipt.json" "$parent_products/protected-change-gate/receipt.json" "$parent_products/semantic-wave/receipt.json" "$verification" "$lock_file" "$assessment" "$wave_evidence"; do test -s "$required_file"; done

jq -e '.schema=="gooo/self-improvement-ledger/v0550-product-integration/v1" and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.semantic_wave_merge_projector.adoption_state=="CLOSED" and .authority.repository_writes==0' "$parent_products/product-integration.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-output-authority-projector-receipt/v1" and .adoption_state=="CLOSED" and .release.release_id==380949449 and .authority.repository_writes==0' "$parent_products/output-authority/receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0540-protected-change-gate-projector-receipt/v1" and .adoption_state=="CLOSED" and .release.release_id==380957875 and .authority.repository_writes==0' "$parent_products/protected-change-gate/receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-ledger/v0550-semantic-wave-merge-receipt/v1" and .adoption_state=="CLOSED" and .release.release_id==380905719 and .fixed_suite.scenario_denominator==12 and .fixed_suite.upstream_state_counts=={closed:4,refuted:4,total:12,unknown:4} and .authority.repository_writes==0' "$parent_products/semantic-wave/receipt.json" >/dev/null
jq -e '.schema=="gooo/self-improvement-portfolio/release-verification/v1" and .summary=={total:77,verified:77,unknown:0,refuted:0} and (.releases|length)==77 and .release_lock_snapshot.parent_reuse.reused==72 and .release_lock_snapshot.changed_live.selected==5 and .release_lock_snapshot.changed_live.executed==5 and .release_lock_snapshot.full_historical_reexecution.executed==false' "$verification" >/dev/null
kernel_job=$(gh api "repos/kimjooyoon/gooo-self-hosted-semantic-kernel/actions/jobs/100145084538")
jq -e '.id==100145084538 and .run_id==33597926498 and .name=="actionlint" and .status=="completed" and .conclusion=="success" and .head_sha=="14949f52b9c55d21841fada27f4cbde7d6593711"' <<<"$kernel_job" >/dev/null

sha256_prefixed() { printf 'sha256:%s\n' "$(sha256sum "$1" | awk '{print $1}')"; }

# The released guard has no independently executable plan-check command in the
# adopted asset. Actions therefore runs the same literal policy conformance
# assertion that the generated .gooo assertion exposes, and records the
# limitation as UNKNOWN instead of inferring a stronger product result.
guard_asset="$artifact_root/releases/release_lineage_guard_release/assets/gooo-release-lineage-guard-v0.1.0.tar.gz"
guard_executable_path=""
if test -s "$guard_asset"; then
  guard_list="$wave_work/release-lineage-guard-assets.txt"
  tar -tzf "$guard_asset" > "$guard_list"
  guard_executable_path=$(awk '/(^|\/)(guard|plan|release-lineage-guard)([^/]*|\/[^/]*)$/ {print; exit}' "$guard_list" || true)
fi
policy_pass=false
if grep -F 'NO_DELETE_NO_OVERWRITE' "$repository/README.md" >/dev/null 2>&1 && \
   grep -F 'release_lock=release-lock/73' "$repository/examples/self-improvement-portfolio/main.gooo" >/dev/null && \
   grep -F 'release_lock=release-lock/77' "$repository/examples/self-improvement-portfolio/main.gooo" >/dev/null && \
   grep -F 'release_lock=null' "$repository/examples/self-improvement-portfolio/main.gooo" >/dev/null && \
   jq -e '.releases|length==77 and has("claim_discharge_calculus_release") and has("self_hosted_semantic_kernel_release") and has("incremental_conformance_planner_release") and has("opentofu_service_contract_bridge_release") and has("release_lineage_guard_release")' "$lock_file" >/dev/null; then
  policy_pass=true
fi
test "$policy_pass" = true
jq -S -n --arg path "${guard_executable_path:-}" --argjson observed "$(if test -n "$guard_executable_path"; then echo true; else echo false; fi)" \
  '{schema:"gooo/self-improvement-ledger/v0560-release-lineage-guard-plan-assertions/v1",generated:true,product_release:{repository:"kimjooyoon/gooo-release-lineage-guard",release_id:381017586,tag:"v0.1.0",immutable:true},executable_guard:{observed:$observed,path:(if $path=="" then null else $path end)},policy_conformance:{pass:true,method:"LITERAL_GOOO_POLICY_ASSERTION",checks:{no_delete_no_overwrite:true,no_release_recreation:true,immutable_lock_set_bound:true,incident_refutations_preserved:true},limitations:{state:"UNKNOWN",reason:"RELEASE_ASSET_EXECUTABLE_GUARD_NOT_OBSERVED",unknown_class:"EXECUTABLE_GUARD_UNAVAILABLE",next_operation:"PUBLISH_EXECUTABLE_RELEASE_LINEAGE_PLAN_CHECK",blocked_by:["release-lineage-guard-plan-executable"]}},authority:{verification:"GITHUB_ACTIONS_ONLY",repository_writes:0,local_validation_commands:0,cross_project_required_gates:0}}' > "$products/release-lineage-guard-plan-assertions.json"
jq -e '.schema=="gooo/self-improvement-ledger/v0560-release-lineage-guard-plan-assertions/v1" and .policy_conformance.pass==true and .policy_conformance.method=="LITERAL_GOOO_POLICY_ASSERTION" and .policy_conformance.limitations.state=="UNKNOWN" and .authority.repository_writes==0' "$products/release-lineage-guard-plan-assertions.json" >/dev/null

# Replay the released semantic-wave projector using its fixed 12-case corpus.
wave_receipt="$parent_products/semantic-wave/receipt.json"
wave_release_id=$(jq -r '.release.release_id' "$wave_receipt")
wave_asset_id=$(jq -r '.release.assets[0].id' "$wave_receipt")
wave_asset_name=$(jq -r '.release.assets[0].name' "$wave_receipt")
wave_asset_digest=$(jq -r '.asset_observed_digest' "$wave_receipt")
wave_target=$(jq -r '.release.target_commit_sha' "$wave_receipt")
test "$wave_release_id" = 380905719
test "$wave_asset_id" = 540372611
test "$wave_asset_name" = gooo-semantic-wave-merge-projector-v0.1.3.tar.gz
test "$wave_asset_digest" = sha256:fe55255e0337c8625f4c1fee42608fbcea20b3057f05a4f5370617147abf1744
test "$wave_target" = d1abdcba2e72ca8aaf2992887ede753884b88c7f

wave_archive="$wave_work/$wave_asset_name"
wave_source_archive="$wave_work/semantic-wave-source.tar.gz"
wave_bin="$wave_work/semantic-wave-projector"
gh api -H 'Accept: application/octet-stream' "repos/kimjooyoon/gooo-semantic-wave-merge-projector/releases/assets/$wave_asset_id" > "$wave_archive"
test "$(sha256_prefixed "$wave_archive")" = "$wave_asset_digest"
test "$(wc -c <"$wave_archive" | tr -d ' ')" = "$(jq -r '.release.assets[0].size_bytes' "$wave_receipt")"
gh api -H 'Accept: application/vnd.github.raw+json' "repos/kimjooyoon/gooo-semantic-wave-merge-projector/tarball/$wave_target" > "$wave_source_archive"
tar --no-xattrs -xzf "$wave_source_archive" -C "$wave_work/source"
wave_source_dir=$(find "$wave_work/source" -mindepth 1 -maxdepth 1 -type d -print -quit)
test -n "$wave_source_dir"
wave_graph="$wave_source_dir/.gooo/semantic-wave-merge-projector.gooo"
test -s "$wave_graph"
cp "$wave_source_dir"/fixtures/cases/*.json "$wave_work/cases/"
test "$(find "$wave_work/cases" -type f -name '*.json' | wc -l | tr -d ' ')" = 12

jq -S -n '
  {fixture_id:"independent-merge",expected_state:"CLOSED",base_ledger_digest:"ledger:wave-v1",evidence_digests:["sha256:4bc34e27f2bdd1944d8efd1053fb7e5f17ba64876b58633e07f4b23f1d1bd675","sha256:e1758574126f3e5ebdcac1030ad7dd613aedac2caf92d1a6888a83ea2b79e45d","sha256:be66a8fb529bcddcf2880751eb9812cf1b02c988a37219188e259ba3c6ce87d7","sha256:af8e1a88a06c11aebb1d6e53d812b1c1aa77f5df94339e26a6b2235c480f7456","sha256:a3cf3f470f912201335cef950682b308523f1861a7ad225cf7fd4f29f66cc5f7"],proposals:[
    {proposal_id:"proposal-cell-82",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","product-adoption/claim-discharge-calculus"],semantic_write_set:["cell/82","product-adoption/claim-discharge-calculus"],required_evidence_digests:["sha256:4bc34e27f2bdd1944d8efd1053fb7e5f17ba64876b58633e07f4b23f1d1bd675"],tool_release_locks:[{tool_id:"CLAIM_DISCHARGE_CALCULUS",release_digest:"sha256:4bc34e27f2bdd1944d8efd1053fb7e5f17ba64876b58633e07f4b23f1d1bd675",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-83",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","product-adoption/self-hosted-semantic-kernel"],semantic_write_set:["cell/83","product-adoption/self-hosted-semantic-kernel"],required_evidence_digests:["sha256:e1758574126f3e5ebdcac1030ad7dd613aedac2caf92d1a6888a83ea2b79e45d"],tool_release_locks:[{tool_id:"SELF_HOSTED_SEMANTIC_KERNEL",release_digest:"sha256:e1758574126f3e5ebdcac1030ad7dd613aedac2caf92d1a6888a83ea2b79e45d",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-84",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","product-adoption/incremental-conformance-planner"],semantic_write_set:["cell/84","product-adoption/incremental-conformance-planner"],required_evidence_digests:["sha256:be66a8fb529bcddcf2880751eb9812cf1b02c988a37219188e259ba3c6ce87d7"],tool_release_locks:[{tool_id:"INCREMENTAL_CONFORMANCE_PLANNER",release_digest:"sha256:be66a8fb529bcddcf2880751eb9812cf1b02c988a37219188e259ba3c6ce87d7",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-85",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","product-adoption/opentofu-service-contract-bridge"],semantic_write_set:["cell/85","product-adoption/opentofu-service-contract-bridge"],required_evidence_digests:["sha256:af8e1a88a06c11aebb1d6e53d812b1c1aa77f5df94339e26a6b2235c480f7456"],tool_release_locks:[{tool_id:"OPENTOFU_SERVICE_CONTRACT_BRIDGE",release_digest:"sha256:af8e1a88a06c11aebb1d6e53d812b1c1aa77f5df94339e26a6b2235c480f7456",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-86",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-locks","product-adoption/release-lineage-guard"],semantic_write_set:["cell/86","product-adoption/release-lineage-guard"],required_evidence_digests:["sha256:a3cf3f470f912201335cef950682b308523f1861a7ad225cf7fd4f29f66cc5f7"],tool_release_locks:[{tool_id:"RELEASE_LINEAGE_GUARD",release_digest:"sha256:a3cf3f470f912201335cef950682b308523f1861a7ad225cf7fd4f29f66cc5f7",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-87",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-history","operational-refutation/public-release-delete/claim-discharge"],semantic_write_set:["cell/87","operational-refutation/public-release-delete/claim-discharge"],required_evidence_digests:[],tool_release_locks:[{tool_id:"gooo-evaluator",release_digest:"sha256:tool-v1",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]},
    {proposal_id:"proposal-cell-88",base_ledger_digest:"ledger:wave-v1",semantic_read_set:["ledger/profile","ledger/release-history","operational-refutation/public-release-delete/opentofu-bridge"],semantic_write_set:["cell/88","operational-refutation/public-release-delete/opentofu-bridge"],required_evidence_digests:[],tool_release_locks:[{tool_id:"gooo-evaluator",release_digest:"sha256:tool-v1",mutable:false,verified:true}],causal_dependencies:[],authority_scope:["self-improvement.proposal.create","self-improvement.proposal.inspect","self-improvement.wave.project"]}
  ]}' > "$wave_work/cases/01-independent-merge.json"
jq -e --slurpfile wave "$wave_evidence" '
  (.proposals|length)==7 and (([.proposals[].semantic_write_set[]]|unique|length)==([.proposals[].semantic_write_set[]]|length)) and (([.proposals[].semantic_write_set[]|select(startswith("release-lock/"))]|length)==0) and
  ($wave[0].semantic_wave.fixture_mode=="REPLACE_NORMAL_FIXTURE") and ($wave[0].semantic_wave.scenario_denominator==12) and ($wave[0].semantic_wave.new_release_lock_writes==0)
' "$wave_work/cases/01-independent-merge.json" >/dev/null

(cd "$wave_source_dir" && go build -trimpath -o "$wave_bin" ./cmd/projector)
wave_cli="$products/semantic-wave/actual-cli-output.json"
/usr/bin/time -f '%M' -o "$products/semantic-wave/actual-peak-rss" "$wave_bin" generate --source "$wave_graph" --cases "$wave_work/cases" --output "$products/semantic-wave/actual" --root "$wave_source_dir" --reviewed-pr 4 --reviewed-merge-sha "$wave_target" --release-tag v0.1.3 > "$wave_cli"
jq -e '.decision=="CONFORMANT" and .scenario_denominator==12 and .closed==4 and .unknown==4 and .refuted==4 and .replay_match==true' "$wave_cli" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/wave-projection/v1" and .scenario_denominator==12 and (.cases|length)==12 and .state_counts=={total:12,closed:4,unknown:4,refuted:4} and .cases[0].case_id=="independent-merge" and .cases[0].state=="CLOSED" and .cases[0].accepted_wave==["proposal-cell-82","proposal-cell-83","proposal-cell-84","proposal-cell-85","proposal-cell-86","proposal-cell-87","proposal-cell-88"] and .cases[0].deferred_frontier==[] and .cases[0].conflict_witnesses==null' "$products/semantic-wave/actual/wave-projection.json" >/dev/null
jq -e '.schema=="gooo/semantic-wave-merge-projector/replay-receipt/v1" and .match==true and .immutable==true' "$products/semantic-wave/actual/replay-receipt.json" >/dev/null

actual_rss=$(cat "$products/semantic-wave/actual-peak-rss")
actual_source_digest=$(sha256_prefixed "$wave_graph")
jq -S -n --arg asset_digest "$wave_asset_digest" --arg source_digest "$actual_source_digest" --arg target "$wave_target" --argjson rss "$actual_rss" --slurpfile parent "$wave_receipt" --slurpfile actual "$products/semantic-wave/actual/wave-projection.json" --slurpfile replay "$products/semantic-wave/actual/replay-receipt.json" --slurpfile cli "$wave_cli" --slurpfile proposals "$wave_work/cases/01-independent-merge.json" '
  {schema:"gooo/self-improvement-ledger/v0560-semantic-wave-merge-receipt/v1",release:$parent[0].release,asset_observed_digest:$asset_digest,source:{target_commit_sha:$target,graph_digest:$source_digest,reviewed_pr:4,reviewed_merge_sha:$target,release_tag:"v0.1.3"},adoption_state:"CLOSED",fixed_suite:{scenario_denominator:12,upstream_state_counts:{total:12,closed:4,unknown:4,refuted:4},upstream_replay_match:true,parent_receipt_reused:true},actual_projection:{cli:$cli[0],projection:$actual[0],replay:$replay[0],fixture_mode:"REPLACE_NORMAL_FIXTURE",wall_ms:null,peak_rss_kib:$rss},proposal_envelopes:{count:7,write_sets:($proposals[0].proposals|map(.semantic_write_set)),accepted_wave_order:["proposal-cell-82","proposal-cell-83","proposal-cell-84","proposal-cell-85","proposal-cell-86","proposal-cell-87","proposal-cell-88"],disjoint:true,conflict_witnesses:[],deferred_frontier:[],new_release_lock_writes:0},improvement:{state:"UNKNOWN",reason:"semantic wave confluence is not a same-scenario before-after performance claim"},external_utility:{state:"UNKNOWN"},authority:{verification:"GITHUB_ACTIONS_ONLY",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' > "$products/semantic-wave/receipt.json"
jq -e '.schema=="gooo/self-improvement-ledger/v0560-semantic-wave-merge-receipt/v1" and .adoption_state=="CLOSED" and .release.release_id==380905719 and .fixed_suite=={parent_receipt_reused:true,scenario_denominator:12,upstream_replay_match:true,upstream_state_counts:{closed:4,refuted:4,total:12,unknown:4}} and .proposal_envelopes=={accepted_wave_order:["proposal-cell-82","proposal-cell-83","proposal-cell-84","proposal-cell-85","proposal-cell-86","proposal-cell-87","proposal-cell-88"],conflict_witnesses:[],count:7,deferred_frontier:[],disjoint:true,new_release_lock_writes:0,write_sets:[["cell/82","product-adoption/claim-discharge-calculus"],["cell/83","product-adoption/self-hosted-semantic-kernel"],["cell/84","product-adoption/incremental-conformance-planner"],["cell/85","product-adoption/opentofu-service-contract-bridge"],["cell/86","product-adoption/release-lineage-guard"],["cell/87","operational-refutation/public-release-delete/claim-discharge"],["cell/88","operational-refutation/public-release-delete/opentofu-bridge"]]} and .authority.repository_writes==0' "$products/semantic-wave/receipt.json" >/dev/null

# Verify the two deleted historical release IDs are still absent and that their
# immutable recreated releases are the only current identities used by the
# refutation receipts.
check_deleted_release() {
  local repo=$1 release_id=$2 output=$3
  if gh api "repos/$repo/releases/$release_id" > "$output" 2>/dev/null; then
    echo "deleted release unexpectedly present: $repo/$release_id" >&2
    exit 1
  fi
  jq -e '.message=="Not Found" and (.status==404 or .status=="404")' "$output" >/dev/null
}
check_deleted_release "kimjooyoon/gooo-claim-discharge-calculus" 381008767 "$products/cells/claim-discharge-deleted-release.json"
check_deleted_release "kimjooyoon/gooo-opentofu-service-contract-bridge" 381006306 "$products/cells/opentofu-bridge-deleted-release.json"
claim_current=$(gh api "repos/kimjooyoon/gooo-claim-discharge-calculus/releases/381009887")
bridge_current=$(gh api "repos/kimjooyoon/gooo-opentofu-service-contract-bridge/releases/381006835")
jq -e '.id==381009887 and .tag_name=="v0.1.0" and .draft==false and .prerelease==false and .immutable==true' <<<"$claim_current" >/dev/null
jq -e '.id==381006835 and .tag_name=="v0.1.0" and .draft==false and .prerelease==false and .immutable==true' <<<"$bridge_current" >/dev/null

lineage_target=$(jq -r '.releases.incremental_conformance_planner_release.lineage.tag_target_commit_sha' "$lock_file")
lineage_head=$(jq -r '.releases.incremental_conformance_planner_release.lineage.current_main_head_sha' "$lock_file")
lineage_compare=$(gh api "repos/kimjooyoon/gooo-incremental-conformance-planner/compare/${lineage_target}...${lineage_head}")
lineage_main=$(gh api "repos/kimjooyoon/gooo-incremental-conformance-planner/git/ref/heads/main")
jq -e --arg base "$lineage_target" --arg head "$lineage_head" '.base_commit.sha==$base and .merge_base_commit.sha==$base and .status=="ahead" and .ahead_by==15 and .behind_by==0 and .total_commits==15 and .merge_base_commit.sha==$base' <<<"$lineage_compare" >/dev/null
jq -e --arg head "$lineage_head" '.object.sha==$head and .object.type=="commit"' <<<"$lineage_main" >/dev/null
jq -S -n --argjson compare "$lineage_compare" --argjson main "$lineage_main" --arg target "$lineage_target" --arg head "$lineage_head" \
  '{tag_target_commit_sha:$target,recovery_source_head_sha:$head,current_main_head_sha:$head,current_main_ref_observed:$main.object.sha,compare:{status:$compare.status,ahead_by:$compare.ahead_by,behind_by:$compare.behind_by,total_commits:$compare.total_commits,merge_base_sha:$compare.merge_base_commit.sha},target_and_recovery_source_kept_separate:true}' > "$products/cells/incremental-conformance-planner-lineage.json"

release_receipt() {
  local key=$1 cell_id=$2 ordinal=$3 edge=$4 proof=$5 indicator=$6 output=$7
  local release_json lock_json
  release_json=$(jq -c --arg key "$key" '.releases[$key]' "$verification")
  lock_json=$(jq -c --arg key "$key" '.releases[$key]' "$lock_file")
  jq -S -n --arg key "$key" --arg cell "$cell_id" --argjson ordinal "$ordinal" --arg edge "$edge" --arg proof "$proof" --arg indicator "$indicator" --argjson release "$release_json" --argjson lock "$lock_json" \
    '{schema:"gooo/self-improvement-ledger/v0560-product-adoption-receipt/v1",cell_id:$cell,ordinal:$ordinal,adoption_state:"CLOSED",dependency_edge:$edge,release_lock_id:("release-lock/" + (($ordinal-9)|tostring)),release_key:$key,proof:$proof,indicator:$indicator,release:{repository:$release.repository,tag:$release.tag,release_id:$release.release_id,immutable:true,tag_object_sha:$release.tag_object_sha,target_commit_sha:$release.target_commit_sha,release_url:$release.release_url,assets:$release.assets},source_run:$release.source_run,source_artifact:$release.source_artifact,source_artifact_observation:(if $release.source_artifact==null then {state:"UNKNOWN",reason:"NO_ACTIONS_ARTIFACT_OBSERVED",unknown_class:"SOURCE_ARTIFACT_UNOBSERVED"} else {state:"CLOSED",observed:true} end),locked_asset:$lock.assets[0],inventory:{dirs:null,files:null,go_files:null,go_lines:null,gooo_files:null,gooo_lines:null,root_readme_excluded:true,measurement_state:{state:"UNKNOWN",stage:"PRODUCT_ADOPTION",step:"READ_UPSTREAM_INVENTORY",reason:"UPSTREAM_INVENTORY_NOT_REQUIRED_FOR_LEDGER_BINDING",unknown_class:"MEASUREMENT_NOT_OBSERVED",next_operation:"PUBLISH_EXACT_UPSTREAM_INVENTORY_RECEIPT",blocked_by:["upstream-inventory"]}},claims:{general_program_equivalence:false,whole_language_improvement:"UNKNOWN",external_utility:"UNKNOWN",improvement:"UNKNOWN"},authority:{verification:"GITHUB_ACTIONS_ONLY",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' > "$output"
}
release_receipt claim_discharge_calculus_release PRODUCT_CLAIM_DISCHARGE_CALCULUS_ADOPTION 82 adoption-edge/claim-discharge-calculus/v1 COHERENCE OUTCOME "$products/cells/claim-discharge-calculus.json"
release_receipt self_hosted_semantic_kernel_release PRODUCT_SELF_HOSTED_SEMANTIC_KERNEL_ADOPTION 83 adoption-edge/self-hosted-semantic-kernel/v1 FOUNDATION DRIVER "$products/cells/self-hosted-semantic-kernel.json"
release_receipt incremental_conformance_planner_release PRODUCT_INCREMENTAL_CONFORMANCE_PLANNER_ADOPTION 84 adoption-edge/incremental-conformance-planner/v1 COHERENCE OUTCOME "$products/cells/incremental-conformance-planner.json"
release_receipt opentofu_service_contract_bridge_release PRODUCT_OPENTOFU_SERVICE_CONTRACT_BRIDGE_ADOPTION 85 adoption-edge/opentofu-service-contract-bridge/v1 COHERENCE OUTCOME "$products/cells/opentofu-service-contract-bridge.json"
release_receipt release_lineage_guard_release PRODUCT_RELEASE_LINEAGE_GUARD_ADOPTION 86 adoption-edge/release-lineage-guard/v1 REGRESSION GUARDRAIL "$products/cells/release-lineage-guard.json"

jq -S -n --argjson claim "$(cat "$products/cells/claim-discharge-calculus.json")" --argjson kernel "$(cat "$products/cells/self-hosted-semantic-kernel.json")" --argjson planner "$(cat "$products/cells/incremental-conformance-planner.json")" --argjson bridge "$(cat "$products/cells/opentofu-service-contract-bridge.json")" --argjson guard "$(cat "$products/cells/release-lineage-guard.json")" --argjson lineage "$(cat "$products/cells/incremental-conformance-planner-lineage.json")" --argjson guard_plan "$(cat "$products/release-lineage-guard-plan-assertions.json")" --slurpfile parent "$parent_products/product-integration.json" --slurpfile wave "$products/semantic-wave/receipt.json" \
  '{schema:"gooo/self-improvement-ledger/v0560-product-integration/v1",products:["PRODUCT_CLAIM_DISCHARGE_CALCULUS_ADOPTION","PRODUCT_SELF_HOSTED_SEMANTIC_KERNEL_ADOPTION","PRODUCT_INCREMENTAL_CONFORMANCE_PLANNER_ADOPTION","PRODUCT_OPENTOFU_SERVICE_CONTRACT_BRIDGE_ADOPTION","PRODUCT_RELEASE_LINEAGE_GUARD_ADOPTION","OPERATIONAL_PUBLIC_RELEASE_DELETE_CLAIM_DISCHARGE","OPERATIONAL_PUBLIC_RELEASE_DELETE_OPENTOFU_BRIDGE"],receipts:{output_authority_projector:$parent[0].receipts.output_authority_projector,protected_change_gate_projector:$parent[0].receipts.protected_change_gate_projector,claim_discharge_calculus:$claim,self_hosted_semantic_kernel:$kernel,incremental_conformance_planner:$planner,opentofu_service_contract_bridge:$bridge,release_lineage_guard:$guard,semantic_wave_merge_projector:$wave[0]},incidents:{claim_discharge_release_deletion:{cell_id:"OPERATIONAL_PUBLIC_RELEASE_DELETE_CLAIM_DISCHARGE",state:"REFUTED",dependency_edge:"operational-edge/public-release-delete/claim-discharge/v1",deleted_original:{repository:"kimjooyoon/gooo-claim-discharge-calculus",release_id:381008767,api_status:404,tag:null,assets:null,tag_state:"UNKNOWN",asset_state:"UNKNOWN"},recreated_current:{repository:"kimjooyoon/gooo-claim-discharge-calculus",release_id:381009887,tag:"v0.1.0",immutable:true},next_operation:"FORBID_PUBLIC_RELEASE_DELETE_AND_ADVANCE_PATCH_VERSION"},opentofu_bridge_release_deletion:{cell_id:"OPERATIONAL_PUBLIC_RELEASE_DELETE_OPENTOFU_BRIDGE",state:"REFUTED",dependency_edge:"operational-edge/public-release-delete/opentofu-bridge/v1",deleted_original:{repository:"kimjooyoon/gooo-opentofu-service-contract-bridge",release_id:381006306,api_status:404,tag:null,assets:null,tag_state:"UNKNOWN",asset_state:"UNKNOWN"},recreated_current:{repository:"kimjooyoon/gooo-opentofu-service-contract-bridge",release_id:381006835,tag:"v0.1.0",immutable:true},next_operation:"FORBID_PUBLIC_RELEASE_DELETE_AND_ADVANCE_PATCH_VERSION"}},parent_receipt_reuse:{source_release:"v0.55.0",source_release_id:380997346,parent_lock_count:72,parent_selected:0,parent_executed:0,changed_lock_count:5,changed_selected:5,changed_executed:5,full_historical_reexecution:false,output_authority:true,protected_change_gate:true,semantic_wave:true},lineage:$lineage,guard_plan_assertions:$guard_plan,semantic_wave:$wave[0].proposal_envelopes,claims:{general_program_equivalence:false,whole_language_improvement:"UNKNOWN",external_utility:"UNKNOWN",improvement_aggregation:"NOT_CLAIMED",exact_before_after_pair:"UNKNOWN"},preserved_parent_product_integration_schema:$parent[0].schema,authority:{verification:"GITHUB_ACTIONS_ONLY",token_source:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0}}' > "$products/product-integration.json"

jq -e '.schema=="gooo/self-improvement-ledger/v0560-product-integration/v1" and (.products|length)==7 and .receipts.output_authority_projector.adoption_state=="CLOSED" and .receipts.protected_change_gate_projector.adoption_state=="CLOSED" and .receipts.claim_discharge_calculus.adoption_state=="CLOSED" and .receipts.self_hosted_semantic_kernel.adoption_state=="CLOSED" and .receipts.incremental_conformance_planner.adoption_state=="CLOSED" and .receipts.opentofu_service_contract_bridge.adoption_state=="CLOSED" and .receipts.release_lineage_guard.adoption_state=="CLOSED" and .incidents.claim_discharge_release_deletion.deleted_original.api_status==404 and .incidents.claim_discharge_release_deletion.deleted_original.tag==null and .incidents.opentofu_bridge_release_deletion.deleted_original.assets==null and .parent_receipt_reuse=={changed_executed:5,changed_lock_count:5,changed_selected:5,full_historical_reexecution:false,output_authority:true,parent_executed:0,parent_lock_count:72,parent_selected:0,protected_change_gate:true,semantic_wave:true,source_release:"v0.55.0",source_release_id:380997346} and .semantic_wave.new_release_lock_writes==0 and .guard_plan_assertions.policy_conformance.pass==true and .guard_plan_assertions.policy_conformance.limitations.state=="UNKNOWN" and .authority.repository_writes==0' "$products/product-integration.json" >/dev/null
echo "v0.56 products verified: five immutable product adoptions, two deleted-release refutations, planner lineage separation, Actions literal guard assertion, and seven disjoint semantic-wave proposals"
