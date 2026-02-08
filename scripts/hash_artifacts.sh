#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bundle_dir="$(cd "${script_dir}/.." && pwd)"
out="${bundle_dir}/artifacts/MANIFEST_SHA256.txt"

(
  cd "${bundle_dir}"
  find artifacts -type f | sort | xargs sha256sum > "${out}"
)

echo "Wrote ${out}"
