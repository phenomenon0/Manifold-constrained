#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bundle_dir="$(cd "${script_dir}/.." && pwd)"
repo_root="$(cd "${bundle_dir}/../../.." && pwd)"

(
  cd "${repo_root}"
  ./foundation_models/paper_mcsqoe/scripts/40_run_all.sh
)

"${script_dir}/sync_artifacts.sh"
