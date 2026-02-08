#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-perf-multirun"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
log_file="${out_dir}/logs/perf_multirun.log"
run_logs_dir="${out_dir}/logs/perf_runs"
samples_tsv="${out_dir}/perf_multirun_samples.tsv"
stats_csv="${out_dir}/perf_multirun_stats.csv"
stats_md="${out_dir}/perf_multirun_summary.md"
stats_json="${out_dir}/perf_multirun_summary.json"

bench_regex="${MCSQOE_PERF_REGEX:-Benchmark(QSMoEForward|QSMoEForwardLarge|ParallelForward_medium_b32|WorkspaceForward_medium_b32)$}"
timeout="${MCSQOE_PERF_TIMEOUT:-30m}"
benchtime="${MCSQOE_BENCHTIME:-1s}"
runs="${MCSQOE_MULTI_RUNS:-5}"

if ! [[ "${runs}" =~ ^[0-9]+$ ]] || [[ "${runs}" -lt 2 ]]; then
	echo "MCSQOE_MULTI_RUNS must be an integer >= 2, got: ${runs}" >&2
	exit 1
fi

mkdir -p "${out_dir}/logs" "${run_logs_dir}"
cd "${repo_root}"

: > "${samples_tsv}"
overall_status=0

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "runs=${runs}"
	echo "benchtime=${benchtime}"
	echo "timeout=${timeout}"

	for run_id in $(seq 1 "${runs}"); do
		run_log="${run_logs_dir}/run_${run_id}.log"
		echo "phase=run index=${run_id}"
		echo "command=go test -run '^$' -benchmem -benchtime=${benchtime} -count=1 -timeout=${timeout} -bench '${bench_regex}' ./foundation_models"

		if go test -run '^$' -benchmem -benchtime="${benchtime}" -count=1 -timeout="${timeout}" -bench "${bench_regex}" ./foundation_models | tee "${run_log}"; then
			echo "run_status=PASS index=${run_id}"
		else
			echo "run_status=FAIL index=${run_id}"
			overall_status=1
			continue
		fi

		awk -v run="${run_id}" '
			/^Benchmark(QSMoEForward|QSMoEForwardLarge|ParallelForward_medium_b32|WorkspaceForward_medium_b32)/ {
				name=$1
				ns=""
				tok="NA"
				for (i=1; i<=NF; i++) {
					if ($i=="ns/op" && i>1) ns=$(i-1)
					if ($i=="tok/s" && i>1) tok=$(i-1)
				}
				if (ns != "") {
					printf "%s\t%s\t%s\t%s\n", run, name, ns, tok
				}
			}
		' "${run_log}" >> "${samples_tsv}"
	done
} | tee "${log_file}"

if [[ "${overall_status}" -ne 0 ]]; then
	echo "PERF_MULTI_RUN_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=run_failed" | tee -a "${log_file}"
	exit 1
fi

declare -a expected=(
	"BenchmarkParallelForward_medium_b32/Serial"
	"BenchmarkParallelForward_medium_b32/Parallel"
	"BenchmarkParallelForward_medium_b32/ParallelZeroCopy"
	"BenchmarkQSMoEForward"
	"BenchmarkQSMoEForwardLarge"
	"BenchmarkWorkspaceForward_medium_b32"
)

missing=0
for key in "${expected[@]}"; do
	count="$(awk -F'\t' -v target="${key}" '
		{
			name=$2
			sub(/-[0-9]+$/, "", name)
			if (name == target) n++
		}
		END { print n+0 }
	' "${samples_tsv}")"
	echo "coverage ${key}=${count}/${runs}" | tee -a "${log_file}"
	if [[ "${count}" -ne "${runs}" ]]; then
		missing=$((missing + 1))
	fi
done

if [[ "${missing}" -ne 0 ]]; then
	echo "PERF_MULTI_RUN_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=coverage_missing count=${missing}" | tee -a "${log_file}"
	exit 1
fi

{
	echo "benchmark,n,mean_ns_per_op,std_ns_per_op,ci95_ns_per_op,mean_tok_s,std_tok_s,ci95_tok_s"
	awk -F'\t' '
		function canon(name,   out) {
			out=name
			sub(/-[0-9]+$/, "", out)
			return out
		}
		{
			key=canon($2)
			ns=$3+0
			n_ns[key]++
			sum_ns[key]+=ns
			sumsq_ns[key]+=ns*ns
			if ($4 != "NA") {
				tok=$4+0
				n_tok[key]++
				sum_tok[key]+=tok
				sumsq_tok[key]+=tok*tok
			}
		}
		END {
			for (k in n_ns) {
				n=n_ns[k]
				mean_ns=sum_ns[k]/n
				if (n > 1) {
					var_ns=(sumsq_ns[k]-((sum_ns[k]*sum_ns[k])/n))/(n-1)
					if (var_ns < 0) var_ns=0
					std_ns=sqrt(var_ns)
				} else {
					std_ns=0
				}
				ci_ns=1.96*std_ns/sqrt(n)

				if (n_tok[k] > 0) {
					nt=n_tok[k]
					mean_tok=sum_tok[k]/nt
					if (nt > 1) {
						var_tok=(sumsq_tok[k]-((sum_tok[k]*sum_tok[k])/nt))/(nt-1)
						if (var_tok < 0) var_tok=0
						std_tok=sqrt(var_tok)
					} else {
						std_tok=0
					}
					ci_tok=1.96*std_tok/sqrt(nt)
					printf "%s,%d,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n", k, n, mean_ns, std_ns, ci_ns, mean_tok, std_tok, ci_tok
				} else {
					printf "%s,%d,%.6f,%.6f,%.6f,NA,NA,NA\n", k, n, mean_ns, std_ns, ci_ns
				}
			}
		}
	' "${samples_tsv}" | sort
} > "${stats_csv}"

{
	echo "# MCQSMoE Multi-Run Performance Summary"
	echo
	echo "- timestamp_utc: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "- runs: ${runs}"
	echo "- benchtime: ${benchtime}"
	echo
	echo "| Benchmark | N | Mean ns/op | Std ns/op | 95% CI ns/op | Mean tok/s | Std tok/s | 95% CI tok/s |"
	echo "|---|---:|---:|---:|---:|---:|---:|---:|"
	awk -F',' '
		NR == 1 { next }
		{
			mean_tok=$6
			std_tok=$7
			ci_tok=$8
			if (mean_tok == "NA") {
				mean_tok="-"
				std_tok="-"
				ci_tok="-"
			} else {
				mean_tok=sprintf("%.3f", mean_tok)
				std_tok=sprintf("%.3f", std_tok)
				ci_tok=sprintf("%.3f", ci_tok)
			}
			printf "| `%s` | %d | %.3f | %.3f | %.3f | %s | %s | %s |\n", $1, $2, $3, $4, $5, mean_tok, std_tok, ci_tok
		}
	' "${stats_csv}"
	echo
	echo "Artifacts:"
	echo "- \`foundation_models/paper_mcsqoe/results/perf_multirun_samples.tsv\`"
	echo "- \`foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv\`"
} > "${stats_md}"

{
	echo "{"
	echo "  \"timestamp_utc\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
	echo "  \"runs\": ${runs},"
	echo "  \"benchtime\": \"${benchtime}\","
	echo "  \"stats\": ["
	awk -F',' '
		NR == 1 { next }
		{
			if (c++ > 0) print ","
			printf "    {\"benchmark\":\"%s\",\"n\":%d,\"mean_ns_per_op\":%s,\"std_ns_per_op\":%s,\"ci95_ns_per_op\":%s,", $1, $2, $3, $4, $5
			if ($6 == "NA") {
				printf "\"mean_tok_s\":null,\"std_tok_s\":null,\"ci95_tok_s\":null}"
			} else {
				printf "\"mean_tok_s\":%s,\"std_tok_s\":%s,\"ci95_tok_s\":%s}", $6, $7, $8
			}
		}
	' "${stats_csv}"
	echo
	echo "  ],"
	echo "  \"artifacts\": {"
	echo "    \"samples_tsv\": \"foundation_models/paper_mcsqoe/results/perf_multirun_samples.tsv\","
	echo "    \"stats_csv\": \"foundation_models/paper_mcsqoe/results/perf_multirun_stats.csv\","
	echo "    \"summary_md\": \"foundation_models/paper_mcsqoe/results/perf_multirun_summary.md\""
	echo "  }"
	echo "}"
} > "${stats_json}"

echo "PERF_MULTI_RUN_STATUS=PASS" | tee -a "${log_file}"
echo "Wrote ${log_file}"
echo "Wrote ${stats_csv}"
echo "Wrote ${stats_md}"
echo "Wrote ${stats_json}"
