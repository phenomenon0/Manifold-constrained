#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-quality"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
log_file="${out_dir}/logs/quality.log"
run_regex="${MCSQOE_QUALITY_REGEX:-TestQSMoE(LayerCreation|ForwardBasic|RoutingDeterminism|Specialization|AuditEntropy|CombineMethods)$}"
timeout="${MCSQOE_QUALITY_TIMEOUT:-20m}"

mkdir -p "${out_dir}/logs"
cd "${repo_root}"

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "command=go test -v -count=1 -shuffle=off -timeout=${timeout} -run '${run_regex}' ./foundation_models"
	go test -v -count=1 -shuffle=off -timeout="${timeout}" -run "${run_regex}" ./foundation_models
} | tee "${log_file}"

echo "Wrote ${log_file}"
