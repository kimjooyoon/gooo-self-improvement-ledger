#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.49 product verification failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: verify-v049-products.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
products="$artifact_root/v049-products"
measurement_root="$products/measurement-boundary"
reuse_root="$products/content-addressed-reuse"
mkdir -p "$measurement_root/assets" "$reuse_root/assets"

command -v gh >/dev/null
command -v curl >/dev/null
command -v git >/dev/null
command -v jq >/dev/null
command -v sha256sum >/dev/null
command -v tar >/dev/null
command -v unzip >/dev/null
test -n "${GH_TOKEN:-}"

download_locked_release() {
  local key=$1 destination=$2
  local repo tag release_json tag_ref tag_object tag_json refs
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$repository/contracts/release-locks-v1.json")
  tag=$(jq -r --arg key "$key" '.releases[$key].tag' "$repository/contracts/release-locks-v1.json")
  gh api "repos/$repo/releases/tags/$tag" > "$destination/release.json"
  release_json="$destination/release.json"
  jq -e --arg key "$key" --arg tag "$tag" --slurpfile locks "$repository/contracts/release-locks-v1.json" \
    '.id == $locks[0].releases[$key].release_id and .tag_name == $tag and .draft == false and .prerelease == false and .immutable == true' "$release_json" >/dev/null
  tag_ref=$(gh api "repos/$repo/git/ref/tags/$tag")
  tag_object=$(jq -r '.object.sha' <<< "$tag_ref")
  jq -e --arg expected "$(jq -r --arg key "$key" '.releases[$key].tag_object_sha' "$repository/contracts/release-locks-v1.json")" '.object.type=="tag" and .object.sha==$expected' <<< "$tag_ref" >/dev/null
  tag_json=$(gh api "repos/$repo/git/tags/$tag_object")
  jq -e --arg expected "$(jq -r --arg key "$key" '.releases[$key].target_commit_sha' "$repository/contracts/release-locks-v1.json")" '.object.type=="commit" and .object.sha==$expected' <<< "$tag_json" >/dev/null
  refs=$(git ls-remote "https://github.com/$repo.git" "refs/tags/$tag" "refs/tags/$tag^{}")
  test "$(awk -v ref="refs/tags/$tag" '$2==ref {print $1}' <<< "$refs")" = "$tag_object"
  test "$(awk -v ref="refs/tags/$tag^{}" '$2==ref {print $1}' <<< "$refs")" = "$(jq -r --arg key "$key" '.releases[$key].target_commit_sha' "$repository/contracts/release-locks-v1.json")"

  while read -r asset; do
    local name id size digest url path
    name=$(jq -r '.name' <<< "$asset")
    id=$(jq -r '.id' <<< "$asset")
    size=$(jq -r '.size_bytes' <<< "$asset")
    digest=$(jq -r '.sha256' <<< "$asset")
    url=$(jq -r '.download_url' <<< "$asset")
    jq -e --arg name "$name" --arg digest "$digest" --arg url "$url" --argjson id "$id" --argjson size "$size" \
      '[.assets[]|select(.id==$id and .name==$name and .size==$size and .digest==$digest and .browser_download_url==$url)]|length==1' "$release_json" >/dev/null
    path="$destination/assets/$name"
    curl --fail --location --retry 3 --silent --show-error "$url" -o "$path"
    test "$(wc -c < "$path" | tr -d ' ')" = "$size"
    test "sha256:$(sha256sum "$path" | awk '{print $1}')" = "$digest"
  done < <(jq -c --arg key "$key" '.releases[$key].assets[]' "$repository/contracts/release-locks-v1.json")

  jq -S -n --arg key "$key" --arg repo "$repo" --arg tag "$tag" --arg tag_object "$tag_object" \
    --slurpfile release "$release_json" --slurpfile locks "$repository/contracts/release-locks-v1.json" \
    '{release_key:$key,repository:$repo,tag:$tag,release_id:$release[0].id,immutable:$release[0].immutable,tag_object_sha:$tag_object,target_commit_sha:($locks[0].releases[$key].target_commit_sha),assets:($release[0].assets|map({id,name,size_bytes:.size,digest}))}' \
    > "$destination/coordinates.json"
}

fetch_run_and_job() {
  local key=$1 destination=$2 run_kind=$3
  local repo run_id job_id run_url head name job_url
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$repository/contracts/release-locks-v1.json")
  run_id=$(jq -r --arg key "$key" --arg kind "$run_kind" '.releases[$key][$kind].run_id' "$repository/contracts/release-locks-v1.json")
  job_id=$(jq -r --arg key "$key" --arg kind "$run_kind" '.releases[$key][$kind].job_id' "$repository/contracts/release-locks-v1.json")
  run_url=$(jq -r --arg key "$key" --arg kind "$run_kind" '.releases[$key][$kind].run_url' "$repository/contracts/release-locks-v1.json")
  job_url=$(jq -r --arg key "$key" --arg kind "$run_kind" '.releases[$key][$kind].job_url' "$repository/contracts/release-locks-v1.json")
  head=$(jq -r --arg key "$key" --arg kind "$run_kind" '.releases[$key][$kind].head_sha' "$repository/contracts/release-locks-v1.json")
  name=$(jq -r --arg key "$key" --arg kind "$run_kind" '.releases[$key][$kind].job_name' "$repository/contracts/release-locks-v1.json")
  gh api "repos/$repo/actions/runs/$run_id" > "$destination/$run_kind.json"
  gh api "repos/$repo/actions/jobs/$job_id" > "$destination/$run_kind-job.json"
  jq -e --argjson id "$run_id" --arg url "$run_url" --arg head "$head" \
    '.id==$id and .html_url==$url and .head_sha==$head and .status=="completed" and .conclusion=="success"' "$destination/$run_kind.json" >/dev/null
  jq -e --argjson id "$job_id" --argjson run "$run_id" --arg name "$name" --arg url "$job_url" --arg head "$head" \
    '.id==$id and .run_id==$run and .name==$name and .html_url==$url and .head_sha==$head and .status=="completed" and .conclusion=="success"' "$destination/$run_kind-job.json" >/dev/null
}

fetch_locked_artifact() {
  local key=$1 destination=$2 kind=$3
  local repo id run_id name size digest zip
  repo=$(jq -r --arg key "$key" '.releases[$key].repository' "$repository/contracts/release-locks-v1.json")
  run_id=$(jq -r --arg key "$key" --arg kind "$kind" '.releases[$key][$kind].run_id' "$repository/contracts/release-locks-v1.json")
  id=$(jq -r --arg key "$key" --arg kind "$kind" '.releases[$key][$kind].artifact_id' "$repository/contracts/release-locks-v1.json")
  name=$(jq -r --arg key "$key" --arg kind "$kind" '.releases[$key][$kind].name' "$repository/contracts/release-locks-v1.json")
  size=$(jq -r --arg key "$key" --arg kind "$kind" '.releases[$key][$kind].size_bytes' "$repository/contracts/release-locks-v1.json")
  digest=$(jq -r --arg key "$key" --arg kind "$kind" '.releases[$key][$kind].sha256' "$repository/contracts/release-locks-v1.json")
  gh api "repos/$repo/actions/artifacts/$id" > "$destination/$kind-artifact.json"
  jq -e --argjson id "$id" --argjson run "$run_id" --arg name "$name" --argjson size "$size" --arg digest "$digest" \
    '.id==$id and .workflow_run.id==$run and .name==$name and .size_in_bytes==$size and .digest==$digest and .expired==false' "$destination/$kind-artifact.json" >/dev/null
  zip="$destination/$kind-artifact.zip"
  gh api "repos/$repo/actions/artifacts/$id/zip" > "$zip"
  test "$(wc -c < "$zip" | tr -d ' ')" = "$size"
  test "sha256:$(sha256sum "$zip" | awk '{print $1}')" = "$digest"
  mkdir -p "$destination/$kind-artifact"
  unzip -q "$zip" -d "$destination/$kind-artifact"
}

measurement_key=measurement_boundary_projector_durable_release
reuse_key=content_addressed_proof_reuse_durable_release
download_locked_release "$measurement_key" "$measurement_root"
download_locked_release "$reuse_key" "$reuse_root"
fetch_run_and_job "$measurement_key" "$measurement_root" source_run
fetch_run_and_job "$measurement_key" "$measurement_root" release_run
fetch_run_and_job "$reuse_key" "$reuse_root" source_run
fetch_run_and_job "$reuse_key" "$reuse_root" release_run
fetch_locked_artifact "$measurement_key" "$measurement_root" source_artifact
fetch_locked_artifact "$measurement_key" "$measurement_root" release_artifact
fetch_locked_artifact "$reuse_key" "$reuse_root" source_artifact

measurement_archive="$measurement_root/assets/$(jq -r --arg key "$measurement_key" '.releases[$key].assets[0].name' "$repository/contracts/release-locks-v1.json")"
reuse_archive="$reuse_root/assets/$(jq -r --arg key "$reuse_key" '.releases[$key].assets[0].name' "$repository/contracts/release-locks-v1.json")"
measurement_manifest="$measurement_root/assets/release-manifest.json"
reuse_manifest="$reuse_root/assets/release-manifest.json"
measurement_lock=$(jq -c --arg key "$measurement_key" '.releases[$key]' "$repository/contracts/release-locks-v1.json")
reuse_lock=$(jq -c --arg key "$reuse_key" '.releases[$key]' "$repository/contracts/release-locks-v1.json")

jq -e --arg archive "$(basename "$measurement_archive")" \
  '.schema=="gooo/measurement-boundary/release-manifest/v1" and .tag=="v0.1.1" and .tag_object_sha=="1772a10b322590987f874319ba9d3fff96c64d2a" and .commit_sha=="5100200ff3d23a665f838847af68e6d4cca03547" and .archive==$archive and .asset_size_bytes==27434 and .asset_digest=="sha256:6ac9d76ad60d0ec993e22abcbe737b1912bc7e1f8547e4debe9898ad5be6eee4" and .self_asserted_immutable==true and .external_platform_authority=="github_release_api.immutable" and .pr_first_conformance=="REFUTED" and .historical_v0_1_0.transport_status=="REFUTED" and .historical_v0_1_0.tag_preserved==true and .historical_v0_1_0.assets_preserved==true and .historical_v0_1_0.deletion_attempted==false and .OPERATIONAL_REFUTED.exact_count==1 and .OPERATIONAL_REFUTED.reason=="INITIAL_IMPLEMENTATION_PUSH_PRECEDED_PR"' "$measurement_manifest" >/dev/null
jq -e '.schema=="gooo/content-addressed-proof-reuse/release-manifest/v1" and .tag=="v0.1.2" and .tag_object_sha=="c883340dc4649de59c614d0d71fbc8c6dbafcf2a" and .commit_sha=="1c84bd91613ac765a43396b6ab5b1da64e8b2097" and .asset_size_bytes==23101 and .asset_digest=="sha256:5c150df58732907729eafd81b10329ce1771a6441b09ea76a2d7f38677f75c26" and .immutable==true' "$reuse_manifest" >/dev/null

measurement_ci=$(find "$measurement_root/source_artifact-artifact" -name ci-evidence.json -type f -print -quit)
reuse_suite=$(find "$reuse_root/source_artifact-artifact" -name suite-evidence.json -type f -print -quit)
test -n "$measurement_ci" -a -n "$reuse_suite"
jq -e '
  .schema=="gooo/measurement-boundary/ci-evidence/v1" and
  .run.run_id=="33544032678" and .run.sha=="da72a5499046b27f5262ad22d2c88164ceae0bab" and .run.workflow=="Measurement boundary conformance" and
  .conformance.total==10 and .conformance.selected==10 and .conformance.executed==10 and .conformance.reused==0 and .conformance.closed==3 and .conformance.unknown==4 and .conformance.refuted==3 and
  .v048_conflict.decision=="UNKNOWN" and .v048_conflict.fail_closed==true and
  (.v048_conflict.unknown|keys|sort)==["blocked_by","next_operation","reason","stage","step","unknown_class"] and
  .generated_single_authority.decision=="CLOSED" and .generated_single_authority.consumer_receipts_exact==true and
  .generated_single_authority.generated_collector_ran==true and .generated_single_authority.measured_once_per_metric==true and
  .runtime_authority.repository_writes==0 and .runtime_authority.apply_authority==0 and .runtime_authority.commit_authority==0 and .runtime_authority.merge_authority==0 and .runtime_authority.tag_authority==0 and .runtime_authority.release_authority==0 and .runtime_authority.cross_project_required_gates==0 and .local_validation_commands==[] and
  .OPERATIONAL_REFUTED.exact_count==1 and .OPERATIONAL_REFUTED.reason=="INITIAL_IMPLEMENTATION_PUSH_PRECEDED_PR" and .OPERATIONAL_REFUTED.local_validation_commands==[] and
  ([.utility_states[]|select(.id=="external-utility" and .state=="UNKNOWN")]|length)==1 and .pr_first_conformance=="REFUTED"
' "$measurement_ci" >/dev/null
jq -e '
  .schema=="gooo/content-addressed-proof-reuse/suite-evidence/v1" and
  .summary=={CLOSED:3,UNKNOWN:3,REFUTED:3} and
  .tests.denominator==9 and .tests.closed==3 and .tests.unknown==3 and .tests.refuted==3 and .tests.local_executions==0 and
  .metrics.indicator_vector==["wall_ms","peak_rss_kib","requests","bytes_read","bytes_downloaded","selected","executed","reused","unknown","refuted"] and
  (.canonical_comparisons|length)==9 and all(.canonical_comparisons[]; .semantic_root != "" and .unknown_equal==true and .refuted_equal==true and .canonical_evidence_equal==true) and
  .authority.repository_writes==0 and .authority.local_build_executions==0 and .authority.local_test_executions==0 and .authority.local_verification_runs==0 and .authority.failed_history_preserved==true and
  .utility.status=="UNKNOWN" and .utility.matched_live_pair==false and .utility.cross_project_required_gates==0
' "$reuse_suite" >/dev/null

tar -xzf "$reuse_archive" -C "$reuse_root"
reuse_source=$(find "$reuse_root" -maxdepth 1 -type d -name 'gooo-content-addressed-proof-reuse-v0.1.2' -print -quit)
test -n "$reuse_source"
(cd "$reuse_source" && go build -trimpath -o "$reuse_root/released-consumer" ./cmd/gooo-content-addressed-proof-reuse)
"$reuse_root/released-consumer" suite --contract "$reuse_source/.gooo/content-addressed-proof-reuse.gooo" --bundle "$reuse_source/fixtures/fixture-bundle-v1.json" --repo-root "$reuse_source" --output-dir "$reuse_root/released-suite"
jq -e '.summary=={"CLOSED":3,"UNKNOWN":3,"REFUTED":3} and .tests.denominator==9 and .tests.local_executions==0' "$reuse_root/released-suite/suite-evidence.json" >/dev/null

measurement_lock_digest=$(jq -cS --arg key "$measurement_key" '.releases[$key]' "$repository/contracts/release-locks-v1.json" | sha256sum | awk '{print $1}')
reuse_lock_digest=$(jq -cS --arg key "$reuse_key" '.releases[$key]' "$repository/contracts/release-locks-v1.json" | sha256sum | awk '{print $1}')
verifier="$reuse_source/internal/reuse/verifier.go"
python3 - "$verifier" "$measurement_lock_digest" "$reuse_lock_digest" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
measurement = sys.argv[2]
reuse = sys.argv[3]
text = path.read_text()
needle = '\tcase "one-delta":\n'
insert = ('\tcase "v049":\n' +
          '\t\tlocks = append(locks,\n' +
          '\t\t\tLock{Ordinal: 58, Coordinate: "measurement_boundary_projector_durable_release", Digest: "sha256:' + measurement + '"},\n' +
          '\t\t\tLock{Ordinal: 59, Coordinate: "content_addressed_proof_reuse_durable_release", Digest: "sha256:' + reuse + '"},\n' +
          '\t\t)\n' +
          '\t\treturn locks, nil\n')
if 'case "v049":' in text:
    raise SystemExit("v049 adapter already present")
if needle not in text:
    raise SystemExit("CurrentLocks insertion point not found")
path.write_text(text.replace(needle, insert + needle, 1))
PY

mkdir -p "$reuse_source/cmd/v049-wave"
cat > "$reuse_source/cmd/v049-wave/main.go" <<'EOF'
package main

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/kimjooyoon/gooo-content-addressed-proof-reuse/internal/reuse"
)

type fetcher struct{ stats reuse.FetchStats }

func (f *fetcher) ResetStats() { f.stats = reuse.FetchStats{} }
func (f *fetcher) Stats() reuse.FetchStats { return f.stats }
func (f *fetcher) Fetch(lock reuse.Lock) ([]byte, error) {
	payload := []byte(lock.Coordinate + "|" + lock.Digest)
	f.stats.Requests++
	f.stats.BytesRead += int64(len(payload))
	f.stats.BytesDownloaded += int64(len(payload))
	return payload, nil
}

func main() {
	if len(os.Args) != 2 { panic("usage: v049-wave OUTPUT_JSON") }
	contract, _, err := reuse.ParseContract(".gooo/content-addressed-proof-reuse.gooo")
	if err != nil { panic(err) }
	bundle, _, err := reuse.LoadBundle("fixtures/fixture-bundle-v1.json")
	if err != nil { panic(err) }
	fixtureCase := reuse.FixtureCase{
		ID: "v049-current-ledger-lock-set", Description: "v0.48 parent fixture plus the two v0.49 ledger locks",
		ParentState: "valid", CurrentLockSet: "v049", CurrentDependencyDigest: bundle.ParentReceipt.DependencyDigest,
		CurrentAuthority: contract.CacheAuthority, CacheHit: true, ReplayObserved: true, HashObserved: true,
	}
	f := &fetcher{}
	baseline, candidate, comparison, err := reuse.RunPair(contract, bundle, fixtureCase, f, f)
	if err != nil { panic(err) }
	if len(bundle.ParentReceipt.Locks) != 57 || len(candidate.Plan.Reused) != 57 || len(candidate.Plan.Selected) != 2 || candidate.Metrics.Executed != 2 {
		panic(fmt.Sprintf("unexpected v049 pair: parent=%d reused=%d selected=%d executed=%d", len(bundle.ParentReceipt.Locks), len(candidate.Plan.Reused), len(candidate.Plan.Selected), candidate.Metrics.Executed))
	}
	output := map[string]any{
		"schema": "gooo/self-improvement-ledger/v049-content-reuse-observation/v1",
		"case": fixtureCase,
		"parent_lock_count": len(bundle.ParentReceipt.Locks),
		"current_lock_count": len(candidate.Plan.Reused) + len(candidate.Plan.Selected),
		"baseline": baseline, "candidate": candidate, "canonical_comparison": comparison,
		"adapter": map[string]any{"mode": "consumer_adapter_ephemeral", "repository_writes": 0, "parent_fixture_preserved": true},
	}
	data, err := json.MarshalIndent(output, "", "  ")
	if err != nil { panic(err) }
	if err := os.WriteFile(os.Args[1], append(data, '\n'), 0644); err != nil { panic(err) }
}
EOF
(cd "$reuse_source" && go build -trimpath -o "$reuse_root/v049-wave" ./cmd/v049-wave)
"$reuse_root/v049-wave" "$reuse_root/v049-content-reuse-observation.json"
jq -e '
  .schema=="gooo/self-improvement-ledger/v049-content-reuse-observation/v1" and .parent_lock_count==57 and .current_lock_count==59 and
  .baseline.status=="CLOSED" and .baseline.metrics.selected==59 and .baseline.metrics.executed==59 and .baseline.metrics.reused==0 and
  .candidate.status=="CLOSED" and .candidate.metrics.selected==2 and .candidate.metrics.executed==2 and .candidate.metrics.reused==57 and
  (.candidate.plan.reused|length)==57 and (.candidate.plan.selected|length)==2 and
  .canonical_comparison.semantic_root != "" and .canonical_comparison.status=="CLOSED" and .canonical_comparison.unknown_equal==true and .canonical_comparison.refuted_equal==true and .canonical_comparison.canonical_evidence_equal==true and
  .adapter.mode=="consumer_adapter_ephemeral" and .adapter.repository_writes==0 and .adapter.parent_fixture_preserved==true
' "$reuse_root/v049-content-reuse-observation.json" >/dev/null

tar -xzf "$measurement_archive" -C "$measurement_root"
measurement_source_root=$(find "$measurement_root" -maxdepth 1 -type d -name 'gooo-measurement-boundary-projector-v0.1.1' -print -quit)
test -n "$measurement_source_root"
(cd "$measurement_source_root" && go build -trimpath -o "$measurement_root/projector" ./cmd/measurement-boundary-projector)

measurement_source="$measurement_root/v049-adoption.gooo"
{
  cat <<'EOF'
package "v049_adoption"
namespace "gooo.measurement.boundary.v049"
EOF
  for metric in wall_ms peak_rss_kib requests bytes_read bytes_downloaded selected executed reused; do
    case "$metric" in
      wall_ms) unit=ms; direction=lower_is_better ;;
      peak_rss_kib) unit=KiB; direction=lower_is_better ;;
      requests|selected|executed) unit=count; direction=lower_is_better ;;
      bytes_read|bytes_downloaded) unit=bytes; direction=lower_is_better ;;
      reused) unit=count; direction=higher_is_better ;;
    esac
    cat <<EOF
measurement "gooo.metric.v049.content-reuse.$metric.v1" {
  stage "content-reuse"
  step "content-reuse/run"
  span "content-reuse.start" "content-reuse.end"
  include "content-reuse"
  exclude "release"
  unit "$unit"
  authority "content-reuse-run.json"
  method "deterministic-fixture"
  scope "v049/content-reuse"
  identity "repository" "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  identity "commit" "sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  direction "$direction"
  nullable "null+UNKNOWN"
  precedence "REFUTED" "UNKNOWN" "CLOSED"
}

EOF
  done
} > "$measurement_source"

reuse_observation="$reuse_root/v049-content-reuse-observation.json"
jq -n --argjson run "$(cat "$reuse_observation")" '
  def sample($m;$phase;$value): {
    metric_id:("gooo.metric.v049.content-reuse."+$m.key+".v1"), stage:"content-reuse", step:"content-reuse/run",
    start_boundary:"content-reuse.start", end_boundary:"content-reuse.end", included_operations:["content-reuse"], unit:$m.unit,
    source_authority:"content-reuse-run.json", observation_method:"deterministic-fixture", scope:"v049/content-reuse",
    identity_digests:{repository:"sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",commit:"sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"},
    direction:$m.direction, measured:true, value:$value, source_artifact:"content-reuse-run.json",
    consumer_artifacts:["content-reuse-run.json","v049-measurement-report.json"], external_utility_evidence:false,
    tamper_receipt:false, tamper_consumer:false, contradiction:false, phase:$phase, pair_id:"v049-content-reuse"
  };
  [
    {key:"wall_ms",unit:"ms",direction:"lower_is_better"}, {key:"peak_rss_kib",unit:"KiB",direction:"lower_is_better"},
    {key:"requests",unit:"count",direction:"lower_is_better"}, {key:"bytes_read",unit:"bytes",direction:"lower_is_better"},
    {key:"bytes_downloaded",unit:"bytes",direction:"lower_is_better"}, {key:"selected",unit:"count",direction:"lower_is_better"},
    {key:"executed",unit:"count",direction:"lower_is_better"}, {key:"reused",unit:"count",direction:"higher_is_better"}
  ] as $metrics |
  {schema:"gooo/measurement-boundary/fixture/v1",case_id:"v049-content-reuse-pair",name:"v0.49 same-CI observed pair",samples:[$metrics[] as $m | sample($m;"before";($run.baseline.metrics[$m.key]|tonumber)), sample($m;"after";($run.candidate.metrics[$m.key]|tonumber))]}
' > "$measurement_root/v049-fixture.json"
"$measurement_root/projector" run --source "$measurement_source" --fixture "$measurement_root/v049-fixture.json" --out "$measurement_root/run"
jq -e '
  .schema=="gooo/measurement-boundary/evaluation/v1" and .decision=="CLOSED" and .fail_closed==false and .closed_count==8 and .unknown_count==0 and .refuted_count==0 and
  .aggregate_policy=="FORBID_UNSCOPED_SCALAR" and (.metrics|length)==8 and
  all(.metrics[]; .state=="CLOSED" and .before!=null and .after!=null and .delta!=null and (.receipt_digests|length)==2 and (.consumer_artifacts|sort)==["content-reuse-run.json","v049-measurement-report.json"] and .authority=="content-reuse-run.json")
' "$measurement_root/run/evaluation.json" >/dev/null
jq -e '
  .collector.generated==true and .collector.measured_once==true and .collector.repository_writes==0 and .collector.apply_authority==0 and .collector.commit_authority==0 and .collector.merge_authority==0 and .collector.tag_authority==0 and .collector.release_authority==0 and
  (.receipts|length)==16 and all(.receipts[]; .source_authority=="content-reuse-run.json" and .source_artifact=="content-reuse-run.json") and
  all(.consumers[]; (.name=="content-reuse-run.json" or .name=="v049-measurement-report.json"))
' "$measurement_root/run/collection/collection.json" >/dev/null

jq -S -n --argjson evaluation "$(cat "$measurement_root/run/evaluation.json")" --argjson collection "$(cat "$measurement_root/run/collection/collection.json")" --argjson observation "$(cat "$reuse_observation")" --arg archive_digest "$(jq -r --arg key "$measurement_key" '.releases[$key].assets[0].sha256' "$repository/contracts/release-locks-v1.json")" \
  '{schema:"gooo/self-improvement-ledger/v049-measurement-receipt/v1",source:{release_asset:"gooo-measurement-boundary-projector-v0.1.1.tar.gz",release_asset_digest:$archive_digest,projector_source:"RELEASED_GOOO",observed_in_same_ci_job:true},observed_pairs:($evaluation.metrics|map({measurement_id,before,after,delta,unit,scope,authority,receipt_digests,consumer_artifacts})),metric_vector:["wall_ms","peak_rss_kib","requests","bytes_read","bytes_downloaded","selected","executed","reused"],semantic:{decision:$evaluation.decision,fail_closed:$evaluation.fail_closed,aggregate_policy:$evaluation.aggregate_policy},single_receipt_chain:{collector_generated:$collection.collector.generated,measured_once:$collection.collector.measured_once,source_authority:"content-reuse-run.json",report_authority:"measurement-evaluation.json",verification_authority:"measurement-evaluation.json",report_verification_authority_same:true,consumer_receipts_exact:true},content_reuse_observation:$observation,authority:{repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0,caller_owned_temp_output_only:true,verification:"GITHUB_ACTIONS",github_token:"github.token"}}' \
  > "$measurement_root/measurement-receipt.json"

measurement_lock=$(jq -c --arg key "$measurement_key" '.releases[$key]' "$repository/contracts/release-locks-v1.json")
reuse_lock=$(jq -c --arg key "$reuse_key" '.releases[$key]' "$repository/contracts/release-locks-v1.json")
jq -S -n --argjson measurement_lock "$measurement_lock" --argjson reuse_lock "$reuse_lock" \
  --argjson measurement_source_run "$(cat "$measurement_root/source_run.json")" --argjson measurement_source_job "$(cat "$measurement_root/source_run-job.json")" --argjson measurement_source_artifact "$(cat "$measurement_root/source_artifact-artifact.json")" --argjson measurement_release_run "$(cat "$measurement_root/release_run.json")" --argjson measurement_release_job "$(cat "$measurement_root/release_run-job.json")" --argjson measurement_release_artifact "$(cat "$measurement_root/release_artifact-artifact.json")" \
  --argjson reuse_source_run "$(cat "$reuse_root/source_run.json")" --argjson reuse_source_job "$(cat "$reuse_root/source_run-job.json")" --argjson reuse_source_artifact "$(cat "$reuse_root/source_artifact-artifact.json")" --argjson reuse_release_run "$(cat "$reuse_root/release_run.json")" --argjson reuse_release_job "$(cat "$reuse_root/release_run-job.json")" \
  --argjson observation "$(cat "$reuse_root/v049-content-reuse-observation.json")" --argjson receipt "$(cat "$measurement_root/measurement-receipt.json")" \
  '{schema:"gooo/self-improvement-ledger/v049-product-integration/v1",products:{measurement_boundary_projector:{lock:$measurement_lock,source_run:$measurement_source_run,source_job:$measurement_source_job,source_artifact:$measurement_source_artifact,release_run:$measurement_release_run,release_job:$measurement_release_job,release_artifact:$measurement_release_artifact},content_addressed_proof_reuse:{lock:$reuse_lock,source_run:$reuse_source_run,source_job:$reuse_source_job,source_artifact:$reuse_source_artifact,release_run:$reuse_release_run,release_job:$reuse_release_job}},adoption:{parent_profile:{release_tag:"v0.48.0",lock_count:57},current_lock_count:$observation.current_lock_count,baseline:$observation.baseline.metrics,candidate:$observation.candidate.metrics,canonical_comparison:$observation.canonical_comparison,measurement_receipt:$receipt},authority:{verification:"GITHUB_ACTIONS",github_token:"github.token",repository_writes:0,local_product_validation_executions:0,cross_project_required_gates:0,caller_owned_temp_output_only:true}}' \
  > "$products/product-integration.json"

jq -e '.schema=="gooo/self-improvement-ledger/v049-product-integration/v1" and .adoption.parent_profile.lock_count==57 and .adoption.current_lock_count==59 and .adoption.baseline.selected==59 and .adoption.candidate.selected==2 and .adoption.candidate.reused==57 and .adoption.canonical_comparison.canonical_evidence_equal==true and .adoption.measurement_receipt.semantic.decision=="CLOSED" and .authority.repository_writes==0 and .authority.local_product_validation_executions==0' "$products/product-integration.json" >/dev/null

echo "v0.49 product releases, source evidence, current-lock consumer observation, and single-authority measurement receipt verified"
