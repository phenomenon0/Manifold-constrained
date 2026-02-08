#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-dense-baseline"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
log_file="${out_dir}/logs/dense_baseline.log"
summary_md="${out_dir}/dense_baseline_summary.md"
summary_json="${out_dir}/dense_baseline_summary.json"
timeout="${MCSQOE_PERF_TIMEOUT:-30m}"
benchtime="${MCSQOE_BENCHTIME:-1s}"
bench_regex="${MCSQOE_DENSE_BASELINE_REGEX:-Benchmark(QSMoEForward|QSMoEForwardLarge|DenseMatchedForward|DenseMatchedForwardLarge)$}"

mkdir -p "${out_dir}/logs"
cd "${repo_root}"

bench_output="$(
	go test -run '^$' -benchmem -benchtime="${benchtime}" -count=1 -timeout="${timeout}" -bench "${bench_regex}" ./foundation_models
)"

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "command=go test -run '^$' -benchmem -benchtime=${benchtime} -count=1 -timeout=${timeout} -bench '${bench_regex}' ./foundation_models"
	printf "%s\n" "${bench_output}"
} | tee "${log_file}"

extract_ns() {
	local pattern="$1"
	printf "%s\n" "${bench_output}" | awk -v p="${pattern}" '
		$1 ~ p {
			for (i=1; i<=NF; i++) {
				if ($i=="ns/op" && i>1) {
					print $(i-1)
					exit
				}
			}
		}
	'
}

q_small_ns="$(extract_ns "^BenchmarkQSMoEForward-[0-9]+$")"
q_large_ns="$(extract_ns "^BenchmarkQSMoEForwardLarge-[0-9]+$")"
d_small_ns="$(extract_ns "^BenchmarkDenseMatchedForward-[0-9]+$")"
d_large_ns="$(extract_ns "^BenchmarkDenseMatchedForwardLarge-[0-9]+$")"

missing=0
for v in q_small_ns q_large_ns d_small_ns d_large_ns; do
	if [[ -z "${!v}" ]]; then
		missing=$((missing + 1))
	fi
done

if [[ "${missing}" -ne 0 ]]; then
	echo "DENSE_BASELINE_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=missing_coverage count=${missing}" | tee -a "${log_file}"
	exit 1
fi

speedup_small="$(awk -v d="${d_small_ns}" -v q="${q_small_ns}" 'BEGIN{printf "%.4f", d/q}')"
speedup_large="$(awk -v d="${d_large_ns}" -v q="${q_large_ns}" 'BEGIN{printf "%.4f", d/q}')"

{
	echo "# Dense Matched Baseline Summary"
	echo
	echo "- timestamp_utc: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "- benchmark_mode: matched_parameter_budget"
	echo "- q_small_ns_per_op: ${q_small_ns}"
	echo "- dense_small_ns_per_op: ${d_small_ns}"
	echo "- q_large_ns_per_op: ${q_large_ns}"
	echo "- dense_large_ns_per_op: ${d_large_ns}"
	echo "- speedup_small_dense_over_q: ${speedup_small}x"
	echo "- speedup_large_dense_over_q: ${speedup_large}x"
	echo
	echo "| Case | QSMoE ns/op | Dense Matched ns/op | Dense/QSMoE Speedup |"
	echo "|---|---:|---:|---:|"
	echo "| small | ${q_small_ns} | ${d_small_ns} | ${speedup_small}x |"
	echo "| large | ${q_large_ns} | ${d_large_ns} | ${speedup_large}x |"
	echo
	echo "Artifacts:"
	echo "- \`foundation_models/paper_mcsqoe/results/logs/dense_baseline.log\`"
	echo "- \`foundation_models/paper_mcsqoe/results/dense_baseline_summary.md\`"
	echo "- \`foundation_models/paper_mcsqoe/results/dense_baseline_summary.json\`"
} > "${summary_md}"

cat > "${summary_json}" <<JSON
{
  "timestamp_utc": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "q_small_ns_per_op": ${q_small_ns},
  "dense_small_ns_per_op": ${d_small_ns},
  "q_large_ns_per_op": ${q_large_ns},
  "dense_large_ns_per_op": ${d_large_ns},
  "speedup_small_dense_over_q": ${speedup_small},
  "speedup_large_dense_over_q": ${speedup_large},
  "artifacts": {
    "log": "foundation_models/paper_mcsqoe/results/logs/dense_baseline.log",
    "summary_md": "foundation_models/paper_mcsqoe/results/dense_baseline_summary.md",
    "summary_json": "foundation_models/paper_mcsqoe/results/dense_baseline_summary.json"
  }
}
JSON

echo "DENSE_BASELINE_STATUS=PASS" | tee -a "${log_file}"
echo "Wrote ${log_file}"
echo "Wrote ${summary_md}"
echo "Wrote ${summary_json}"
