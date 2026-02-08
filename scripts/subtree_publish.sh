#!/usr/bin/env bash
set -euo pipefail

PREFIX="foundation_models/paper_mcsqoe/github_release"
BRANCH="mcsqoe-paper-release"
REMOTE=""
REMOTE_BRANCH="main"

usage() {
  cat <<'EOF'
Usage: subtree_publish.sh [--branch BRANCH] [--remote REMOTE_OR_URL] [--remote-branch BRANCH]

Creates/updates a local split branch from:
  foundation_models/paper_mcsqoe/github_release

Examples:
  # Create/update local split branch only
  ./foundation_models/paper_mcsqoe/github_release/scripts/subtree_publish.sh

  # Create split branch and push directly to GitHub
  ./foundation_models/paper_mcsqoe/github_release/scripts/subtree_publish.sh \
    --remote git@github.com:YOUR_ORG/mcsqoe-paper-release.git \
    --remote-branch main
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      BRANCH="${2:-}"
      shift 2
      ;;
    --remote)
      REMOTE="${2:-}"
      shift 2
      ;;
    --remote-branch)
      REMOTE_BRANCH="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

if ! git subtree --help >/dev/null 2>&1; then
  echo "git subtree is not available in this environment." >&2
  echo "Primary path (when installed):" >&2
  echo "  git subtree split --prefix \"$PREFIX\" -b \"$BRANCH\"" >&2
  if command -v git-filter-repo >/dev/null 2>&1; then
    echo "" >&2
    echo "Fallback (available now with git-filter-repo):" >&2
    echo "  TMP_DIR=\$(mktemp -d)" >&2
    echo "  git clone --shared \"$ROOT_DIR\" \"\$TMP_DIR/mcsqoe-paper-release\"" >&2
    echo "  git -C \"\$TMP_DIR/mcsqoe-paper-release\" filter-repo --force --subdirectory-filter \"$PREFIX\"" >&2
    echo "  git -C \"\$TMP_DIR/mcsqoe-paper-release\" push <remote-or-url> HEAD:$REMOTE_BRANCH" >&2
  fi
  exit 1
fi

echo "Splitting subtree from prefix: $PREFIX"
SPLIT_COMMIT="$(git subtree split --prefix "$PREFIX")"

echo "Updating local branch: $BRANCH -> $SPLIT_COMMIT"
git branch -f "$BRANCH" "$SPLIT_COMMIT" >/dev/null

if [[ -n "$REMOTE" ]]; then
  echo "Pushing $BRANCH to $REMOTE:$REMOTE_BRANCH"
  git push "$REMOTE" "$BRANCH:$REMOTE_BRANCH"
  echo "Push complete."
else
  echo "Local split branch ready: $BRANCH"
  echo "To publish:"
  echo "  git push <remote-or-url> $BRANCH:$REMOTE_BRANCH"
fi
