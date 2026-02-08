#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../../" && pwd)"
out_dir="${repo_root}/foundation_models/paper_mcsqoe/results"
out_file="${out_dir}/env_snapshot.txt"

mkdir -p "${out_dir}" "${out_dir}/logs"

{
	echo "timestamp_utc: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
	echo "cwd: ${repo_root}"
	echo "hostname: $(hostname)"
	echo "kernel: $(uname -srmo)"
	echo "go_version: $(go version 2>/dev/null || echo unavailable)"
	echo "git_commit: $(git -C "${repo_root}" rev-parse HEAD 2>/dev/null || echo unavailable)"
	echo "git_branch: $(git -C "${repo_root}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unavailable)"
	echo "cpu_model: $(lscpu 2>/dev/null | awk -F: '/Model name/ {gsub(/^[ \t]+/, "", $2); print $2; exit}' || true)"
	echo "cpu_cores: $(nproc 2>/dev/null || echo unknown)"
	echo "memory_mib: $(free -m 2>/dev/null | awk '/Mem:/ {print $2}' || echo unknown)"
	echo "gpu_info:"
	tmp_nvsmi="$(mktemp)"
	if nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader >"${tmp_nvsmi}" 2>/dev/null; then
		cat "${tmp_nvsmi}"
	else
		echo "nvidia-smi unavailable"
	fi
	rm -f "${tmp_nvsmi}"
} >"${out_file}"

echo "Wrote ${out_file}"
