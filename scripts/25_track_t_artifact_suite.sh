#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${script_dir}/../../scripts/common.sh"

fm_prepare_go_env "mcsqoe-track-t"

repo_root="${fm_agent_go_root}"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
log_file="${out_dir}/logs/track_t.log"
timeout="${MCSQOE_TRACK_T_TIMEOUT:-30m}"
run_regex="${MCSQOE_TRACK_T_REGEX:-Test(LoadExportedModel|ExportedModelInference|ImportRealPyTorchExport|ImportFullFFN|GoldenPyTorchComparison|ManifoldInvariants|GoldenDeterminism|E2EPyTorchGolden)$}"

required_files=(
	"examples/toy_mcqsmoe/exports/moe_v2_optimized/manifest.json"
	"examples/toy_mcqsmoe/exports/run_001/manifest.json"
	"examples/toy_mcqsmoe/exports/proof/manifest.json"
	"examples/toy_mcqsmoe/exports/proof/golden/golden_manifest.json"
	"testdata/golden_qmln.shard"
)

mkdir -p "${out_dir}/logs"
cd "${repo_root}"

{
	echo "timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "track=TrackT"
	echo "phase=precheck"
	missing=0
	for p in "${required_files[@]}"; do
		if [[ -f "${p}" ]]; then
			echo "artifact=FOUND path=${p}"
		else
			echo "artifact=MISSING path=${p}"
			missing=$((missing + 1))
		fi
	done

	if [[ "${missing}" -gt 0 ]]; then
		echo "TRACK_T_STATUS=FAIL"
		echo "reason=missing_artifacts count=${missing}"
		exit 1
	fi

	echo "phase=test"
	echo "command=go test -v -count=1 -shuffle=off -timeout=${timeout} -run '${run_regex}' ./foundation_models"
	go test -v -count=1 -shuffle=off -timeout="${timeout}" -run "${run_regex}" ./foundation_models
} | tee "${log_file}"

# Fail if any skip sneaks in; Track T is strict.
if rg -q "^--- SKIP:" "${log_file}"; then
	echo "TRACK_T_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=skip_detected" | tee -a "${log_file}"
	exit 1
fi

if ! rg -q "^PASS$" "${log_file}"; then
	echo "TRACK_T_STATUS=FAIL" | tee -a "${log_file}"
	echo "reason=tests_not_passed" | tee -a "${log_file}"
	exit 1
fi

echo "TRACK_T_STATUS=PASS" | tee -a "${log_file}"
echo "Wrote ${log_file}"
