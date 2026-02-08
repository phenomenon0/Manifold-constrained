#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0
failures=()

"${script_dir}/00_env_snapshot.sh"
"${script_dir}/10_quality_suite.sh"
if ! "${script_dir}/15_quality_multiseed_suite.sh"; then
	status=1
	failures+=("quality_multiseed")
fi
"${script_dir}/20_perf_suite.sh"
if ! "${script_dir}/22_perf_multirun_ci_suite.sh"; then
	status=1
	failures+=("perf_multirun")
fi
if ! "${script_dir}/23_dense_baseline_suite.sh"; then
	status=1
	failures+=("dense_baseline")
fi
if ! "${script_dir}/25_track_t_artifact_suite.sh"; then
	status=1
	failures+=("track_t")
fi
if ! "${script_dir}/26_external_eval_suite.sh"; then
	status=1
	failures+=("external_eval")
fi
"${script_dir}/30_collect_summary.sh"

if [[ "${status}" -ne 0 ]]; then
	echo "MCQSMoE paper-rigor run complete with failures: ${failures[*]}"
	exit "${status}"
fi

echo "MCQSMoE paper-rigor run complete."
