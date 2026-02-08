#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-external-eval"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
external_dir="${out_dir}/external_eval"
log_file="${out_dir}/logs/external_eval.log"
dataset="${MCSQOE_EXTERNAL_DATASET:-mmlu-tiny}"
seed="${MCSQOE_EXTERNAL_SEED:-424242}"

mkdir -p "${out_dir}/logs" "${external_dir}"
cd "${repo_root}"

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "dataset=${dataset}"
	echo "seed=${seed}"
	echo "command=go run ./foundation_models/paper_mcsqoe/cmd/external_eval -output foundation_models/paper_mcsqoe/results/external_eval -dataset ${dataset} -seed ${seed}"
	go run ./foundation_models/paper_mcsqoe/cmd/external_eval -output foundation_models/paper_mcsqoe/results/external_eval -dataset "${dataset}" -seed "${seed}"
} | tee "${log_file}"

summary_md="${external_dir}/summary.md"
summary_json="${external_dir}/summary.json"

if [[ ! -f "${summary_md}" || ! -f "${summary_json}" ]]; then
	echo "EXTERNAL_EVAL_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=missing_summary_artifacts" | tee -a "${log_file}"
	exit 1
fi

echo "EXTERNAL_EVAL_STATUS=PASS" | tee -a "${log_file}"
echo "Wrote ${log_file}"
echo "Wrote ${summary_md}"
echo "Wrote ${summary_json}"
