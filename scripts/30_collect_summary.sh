#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../../" && pwd)"
results_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
quality_log="${results_dir}/logs/quality.log"
perf_log="${results_dir}/logs/perf.log"
quality_multiseed_log="${results_dir}/logs/quality_multiseed.log"
perf_multirun_log="${results_dir}/logs/perf_multirun.log"
track_t_log="${results_dir}/logs/track_t.log"
perf_multirun_md="${results_dir}/perf_multirun_summary.md"
perf_multirun_csv="${results_dir}/perf_multirun_stats.csv"
summary_md="${results_dir}/summary.md"
summary_json="${results_dir}/summary.json"

if [[ ! -f "${quality_log}" ]]; then
	echo "missing quality log: ${quality_log}" >&2
	exit 1
fi
if [[ ! -f "${perf_log}" ]]; then
	echo "missing perf log: ${perf_log}" >&2
	exit 1
fi

quality_status="FAIL"
if rg -q "^PASS$" "${quality_log}"; then
	quality_status="PASS"
fi
quality_count="$(rg -n "^--- PASS: TestQSMoE" "${quality_log}" | wc -l | tr -d ' ')"

perf_status="FAIL"
if rg -q "^PASS$" "${perf_log}"; then
	perf_status="PASS"
fi

benchmark_lines="$(rg '^Benchmark(QSMoEForward|QSMoEForwardLarge|ParallelForward_medium_b32|WorkspaceForward_medium_b32)' "${perf_log}" || true)"
benchmark_count="$(printf "%s\n" "${benchmark_lines}" | sed '/^$/d' | wc -l | tr -d ' ')"

track_t_status="NOT_RUN"
if [[ -f "${track_t_log}" ]]; then
	if rg -q "TRACK_T_STATUS=PASS" "${track_t_log}"; then
		track_t_status="PASS"
	elif rg -q "TRACK_T_STATUS=FAIL" "${track_t_log}"; then
		track_t_status="FAIL"
	else
		track_t_status="UNKNOWN"
	fi
fi

quality_multiseed_status="NOT_RUN"
quality_multiseed_seeds=0
if [[ -f "${quality_multiseed_log}" ]]; then
	if rg -q "QUALITY_MULTI_SEED_STATUS=PASS" "${quality_multiseed_log}"; then
		quality_multiseed_status="PASS"
	elif rg -q "QUALITY_MULTI_SEED_STATUS=FAIL" "${quality_multiseed_log}"; then
		quality_multiseed_status="FAIL"
	else
		quality_multiseed_status="UNKNOWN"
	fi
	quality_multiseed_seeds="$(rg -n "^phase=run seed=" "${quality_multiseed_log}" | wc -l | tr -d ' ')"
fi

perf_multirun_status="NOT_RUN"
perf_multirun_runs=0
if [[ -f "${perf_multirun_log}" ]]; then
	if rg -q "PERF_MULTI_RUN_STATUS=PASS" "${perf_multirun_log}"; then
		perf_multirun_status="PASS"
	elif rg -q "PERF_MULTI_RUN_STATUS=FAIL" "${perf_multirun_log}"; then
		perf_multirun_status="FAIL"
	else
		perf_multirun_status="UNKNOWN"
	fi
	perf_multirun_runs="$(rg -n "^phase=run index=" "${perf_multirun_log}" | wc -l | tr -d ' ')"
fi

{
	echo "# MCQSMoE Paper-Rigor Summary"
	echo
	echo "- timestamp_utc: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "- quality_status: ${quality_status}"
	echo "- quality_tests_passed: ${quality_count}"
	echo "- quality_multiseed_status: ${quality_multiseed_status}"
	echo "- quality_multiseed_seeds: ${quality_multiseed_seeds}"
	echo "- perf_status: ${perf_status}"
	echo "- benchmark_lines_captured: ${benchmark_count}"
	echo "- perf_multirun_status: ${perf_multirun_status}"
	echo "- perf_multirun_runs: ${perf_multirun_runs}"
	echo "- track_t_status: ${track_t_status}"
	echo
	echo "## Benchmarks"
	echo
	if [[ -n "${benchmark_lines}" ]]; then
		echo '```text'
		echo "${benchmark_lines}"
		echo '```'
	else
		echo "_No benchmark lines matched expected patterns._"
	fi
	echo
	echo "## Artifacts"
	echo
	echo "- \`foundation_models/paper_mcsqoe/results/env_snapshot.txt\`"
	echo "- \`foundation_models/paper_mcsqoe/results/logs/quality.log\`"
	echo "- \`foundation_models/paper_mcsqoe/results/logs/quality_multiseed.log\`"
	echo "- \`foundation_models/paper_mcsqoe/results/logs/perf.log\`"
	echo "- \`foundation_models/paper_mcsqoe/results/logs/perf_multirun.log\`"
	echo "- \`foundation_models/paper_mcsqoe/results/perf_multirun_summary.md\`"
	echo "- \`foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv\`"
	echo "- \`foundation_models/paper_mcsqoe/results/logs/track_t.log\`"
} >"${summary_md}"

cat >"${summary_json}" <<JSON
{
  "timestamp_utc": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "quality_status": "${quality_status}",
  "quality_tests_passed": ${quality_count},
  "quality_multiseed_status": "${quality_multiseed_status}",
  "quality_multiseed_seeds": ${quality_multiseed_seeds},
  "perf_status": "${perf_status}",
  "benchmark_lines_captured": ${benchmark_count},
  "perf_multirun_status": "${perf_multirun_status}",
  "perf_multirun_runs": ${perf_multirun_runs},
  "track_t_status": "${track_t_status}",
  "artifacts": {
    "env_snapshot": "foundation_models/paper_mcsqoe/results/env_snapshot.txt",
    "quality_log": "foundation_models/paper_mcsqoe/results/logs/quality.log",
    "quality_multiseed_log": "foundation_models/paper_mcsqoe/results/logs/quality_multiseed.log",
    "perf_log": "foundation_models/paper_mcsqoe/results/logs/perf.log",
    "perf_multirun_log": "foundation_models/paper_mcsqoe/results/logs/perf_multirun.log",
    "perf_multirun_summary_md": "foundation_models/paper_mcsqoe/results/perf_multirun_summary.md",
    "perf_multirun_stats_csv": "foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv",
    "track_t_log": "foundation_models/paper_mcsqoe/results/logs/track_t.log",
    "summary_md": "foundation_models/paper_mcsqoe/results/summary.md"
  }
}
JSON

echo "Wrote ${summary_md}"
echo "Wrote ${summary_json}"
