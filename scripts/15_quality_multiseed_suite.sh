#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-quality-multiseed"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
log_file="${out_dir}/logs/quality_multiseed.log"
quality_regex="${MCSQOE_QUALITY_REGEX:-TestQSMoE(LayerCreation|ForwardBasic|RoutingDeterminism|Specialization|AuditEntropy|CombineMethods)$}"
timeout="${MCSQOE_QUALITY_TIMEOUT:-20m}"
seed_list="${MCSQOE_QUALITY_SEEDS:-11 23 47 101 211}"

mkdir -p "${out_dir}/logs"
cd "${repo_root}"

overall_status=0

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "seeds=${seed_list}"

	for seed in ${seed_list}; do
		echo "phase=run seed=${seed}"
		echo "command=go test -v -count=1 -shuffle=${seed} -timeout=${timeout} -run '${quality_regex}' ./foundation_models"
		if go test -v -count=1 -shuffle="${seed}" -timeout="${timeout}" -run "${quality_regex}" ./foundation_models; then
			echo "run_status=PASS seed=${seed}"
		else
			echo "run_status=FAIL seed=${seed}"
			overall_status=1
		fi
	done
} | tee "${log_file}"

if rg -q "^--- SKIP:" "${log_file}"; then
	echo "QUALITY_MULTI_SEED_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=skip_detected" | tee -a "${log_file}"
	exit 1
fi

if [[ "${overall_status}" -ne 0 ]]; then
	echo "QUALITY_MULTI_SEED_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=run_failed" | tee -a "${log_file}"
	exit 1
fi

echo "QUALITY_MULTI_SEED_STATUS=PASS" | tee -a "${log_file}"
echo "Wrote ${log_file}"
