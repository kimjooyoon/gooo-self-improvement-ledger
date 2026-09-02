#!/usr/bin/env bash
set -Eeuo pipefail
trap 'status=$?; echo "v0.55 frontier meta assertion generation failed at line ${LINENO}: ${BASH_COMMAND}" >&2; exit "$status"' ERR

if [ "$#" -ne 2 ]; then
  echo "usage: generate-v0550-frontier-meta-assertions.sh ARTIFACT_ROOT REPOSITORY_ROOT" >&2
  exit 64
fi

artifact_root=$(realpath "$1")
repository=$(realpath "$2")
assessment="$repository/evidence/assessment-v1.json"
source_gooo="$repository/examples/self-improvement-portfolio/main.gooo"
output="$artifact_root/frontier-resolution-meta-assertions.json"
mkdir -p "$artifact_root"
command -v jq >/dev/null
command -v sha256sum >/dev/null
test -s "$assessment"
test -s "$source_gooo"

source_digest="sha256:$(sha256sum "$source_gooo" | awk '{print $1}')"
v2_events=$(jq -c '[.refutation_resolution_events[] | select((.schema_version // 0) >= 2)]' "$assessment")
test "$(jq 'length' <<<"$v2_events")" -ge 1

jq -S -n \
  --arg source_path "examples/self-improvement-portfolio/main.gooo" \
  --arg source_digest "$source_digest" \
  --argjson events "$v2_events" '
  def nonempty_string: (type == "string" and length > 0);
  def edge_list:
    if (.edge_ids | type) == "array" then .edge_ids
    elif (.edge_id | type) == "string" then [.edge_id]
    else [] end;
  def immutable_identity:
    (type == "object") and
    (.cell_id | nonempty_string) and
    (.release_lock | nonempty_string) and
    (.release_lock_ordinal | type == "number") and
    (.product_release | nonempty_string) and
    (.release_id | type == "number") and
    (.immutable == true) and
    ((.adopted_asset | type) == "object") and
    (.adopted_asset.id | type == "number") and
    (.adopted_asset.name | nonempty_string) and
    (.adopted_asset.size_bytes | type == "number") and
    (.adopted_asset.digest | (type == "string" and startswith("sha256:")));
  def assertion($all_event_ids):
    . as $event |
    (edge_list) as $edges |
    {
      event_id: $event.event_id,
      cell_id: $event.cell_id,
      schema_version: $event.schema_version,
      checks: {
        stable_edge_ids: (($edges | length) > 0 and all($edges[]; nonempty_string)),
        supersedes_link: (($event.supersedes_event_id | nonempty_string) and (($all_event_ids | index($event.supersedes_event_id)) != null)),
        historical_cell: (($event.historical_cell_ordinal | type) == "number" and $event.historical_state == "REFUTED"),
        historical_refutation_preserved: ($event.historical_refutation_preserved == true),
        exact_next_operation: (($event.historical_next_operation | nonempty_string) and ($event.next_operation | nonempty_string) and ($event.historical_next_operation == $event.next_operation) and ($event.next_operation_match == true)),
        immutable_resolved_by: (($event.resolved_by | type) == "array" and ($event.resolved_by | length) > 0 and all($event.resolved_by[]; immutable_identity)),
        component_coverage: (($event.coverage | type) == "object" and ($event.coverage.components | type) == "array" and ($event.coverage.components | length) > 0 and ($event.coverage.denominator | type) == "number" and $event.coverage.denominator == ($event.coverage.components | length) and $event.coverage.covered == $event.coverage.denominator and $event.coverage.complete == true),
        resolution_closed: ($event.resolution_state == "CLOSED")
      }
    } |
    .pass = (all(.checks[]; . == true));
  ($events | map(.event_id)) as $all_event_ids |
  ($events | map(assertion($all_event_ids))) as $assertions |
  {
    schema: "gooo/self-improvement-ledger/frontier-resolution-generated-meta-assertions/v1",
    generated: true,
    source: {authority: "GOOO", path: $source_path, sha256: $source_digest},
    schema_policy: {
      frontier_resolution_schema_version_minimum: 2,
      stable_edge_ids_required: true,
      exact_historical_cell_required: true,
      supersedes_link_required: true,
      exact_next_operation_match_required: true,
      immutable_resolved_by_required: true,
      component_coverage_denominator_required: true,
      refutation_history_preservation_required: true
    },
    assertions: $assertions,
    summary: {
      schemas_observed: ($assertions | length),
      passed: ([$assertions[] | select(.pass == true)] | length),
      failed: ([$assertions[] | select(.pass != true)] | length)
    },
    authority: {
      verification: "GITHUB_ACTIONS_ONLY",
      token_source: "github.token",
      repository_writes: 0,
      local_validation_commands: 0,
      cross_project_required_gates: 0
    }
  }' > "$output"

jq -e '.generated==true and .source.authority=="GOOO" and .schema_policy.frontier_resolution_schema_version_minimum==2 and (.assertions|length)>=1 and .summary.failed==0 and all(.assertions[]; .pass==true)' "$output" >/dev/null
echo "v0.55 generic frontier-resolution meta assertions passed: schemas=$(jq -r '.summary.schemas_observed' "$output")"
