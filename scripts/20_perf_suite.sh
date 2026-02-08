#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-perf"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
log_file="${out_dir}/logs/perf.log"
bench_regex="${MCSQOE_PERF_REGEX:-Benchmark(QSMoEForward|QSMoEForwardLarge|ParallelForward_medium_b32|WorkspaceForward_medium_b32)$}"
timeout="${MCSQOE_PERF_TIMEOUT:-30m}"
benchtime="${MCSQOE_BENCHTIME:-1s}"

mkdir -p "${out_dir}/logs"
cd "${repo_root}"

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "command=go test -run '^$' -benchmem -benchtime=${benchtime} -count=1 -timeout=${timeout} -bench '${bench_regex}' ./foundation_models"
	go test -run '^$' -benchmem -benchtime="${benchtime}" -count=1 -timeout="${timeout}" -bench "${bench_regex}" ./foundation_models
} | tee "${log_file}"

echo "Wrote ${log_file}"
