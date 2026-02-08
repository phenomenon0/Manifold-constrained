#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bundle_dir="$(cd "${script_dir}/.." && pwd)"
repo_root="$(cd "${bundle_dir}/../../.." && pwd)"
source_dir="${repo_root}/foundation_models/paper_mcsqoe/results"

dest_env="${bundle_dir}/artifacts/env"
dest_logs="${bundle_dir}/artifacts/logs"
dest_bench="${bundle_dir}/artifacts/bench"
dest_reports="${bundle_dir}/artifacts/reports"

mkdir -p "${dest_env}" "${dest_logs}" "${dest_bench}" "${dest_reports}"

cp "${source_dir}/env_snapshot.txt" "${dest_env}/"
cp "${source_dir}/logs/"*.log "${dest_logs}/"
cp "${source_dir}/perf_multirun_samples.tsv" "${dest_bench}/"
cp "${source_dir}/perf_multirun_stats.csv" "${dest_bench}/"
cp "${source_dir}/summary.md" "${dest_reports}/"
cp "${source_dir}/summary.json" "${dest_reports}/"
cp "${source_dir}/perf_multirun_summary.md" "${dest_reports}/"
cp "${source_dir}/perf_multirun_summary.json" "${dest_reports}/"
cp "${repo_root}/foundation_models/paper_mcsqoe/MCQSMOE_DEEP_DIVE_REPORT.html" "${dest_reports}/"

echo "Synced artifacts from ${source_dir}"
