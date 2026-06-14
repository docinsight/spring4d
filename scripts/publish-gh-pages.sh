#!/usr/bin/env bash
set -euo pipefail

branch="gh-pages"
remote="origin"
message="Publish docs site"
push_remote=0

usage() {
  cat <<'USAGE'
Usage: scripts/publish-gh-pages.sh [options]

Build the DocInsight site, create a fresh orphan gh-pages commit without
switching the current worktree, and optionally push it to the remote.

Options:
  --push              Push gh-pages to the remote with --force-with-lease
  --remote REMOTE     Remote to push to (default: origin)
  -m, --message TEXT  Commit message (default: Publish docs site)
  -h, --help          Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --push)
      push_remote=1
      shift
      ;;
    --branch)
      branch="${2:?missing value for --branch}"
      shift 2
      ;;
    --remote)
      remote="${2:?missing value for --remote}"
      shift 2
      ;;
    -m|--message)
      message="${2:?missing value for $1}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$branch" != "gh-pages" ]]; then
  echo "Refusing to publish to branch '$branch'. This script only publishes to gh-pages." >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir/.." rev-parse --show-toplevel)"
git_dir="$(git -C "$repo_root" rev-parse --absolute-git-dir)"
site_dir="$repo_root/dist/docs/site"
tmp_dir=""

cleanup() {
  local status=$?

  if [[ -n "$tmp_dir" && -d "$tmp_dir" ]]; then
    rm -rf "$tmp_dir"
  fi

  exit "$status"
}
trap cleanup EXIT

ensure_clean() {
  if [[ -n "$(git -C "$repo_root" status --porcelain --untracked-files=all)" ]]; then
    echo "Working tree is not clean. Commit, stash, or remove changes before publishing." >&2
    git -C "$repo_root" status --short
    exit 1
  fi
}

cd "$repo_root"

git check-ref-format --branch "$branch" >/dev/null

current_branch="$(git symbolic-ref --quiet --short HEAD || true)"
if [[ "$current_branch" == "$branch" ]]; then
  echo "Current branch is already $branch. Switch to another branch before publishing." >&2
  exit 1
fi

ensure_clean

echo "Building DocInsight site..."
docinsight build --target site

ensure_clean

if [[ ! -d "$site_dir" ]]; then
  echo "Site directory not found: $site_dir" >&2
  exit 1
fi

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/spring4d-gh-pages.XXXXXX")"
publish_dir="$tmp_dir/site"
index_file="$tmp_dir/index"
mkdir -p "$publish_dir"

rsync -a --delete \
  --exclude='/.docinsight.build' \
  --exclude='/.docinsight-build' \
  "$site_dir/" "$publish_dir/"

if [[ -z "$(find "$publish_dir" -mindepth 1 -print -quit)" ]]; then
  echo "Built site is empty: $site_dir" >&2
  exit 1
fi

if [[ ! -f "$publish_dir/index.html" ]]; then
  echo "index.html not found in built site: $site_dir" >&2
  exit 1
fi

touch "$publish_dir/.nojekyll"

git var GIT_AUTHOR_IDENT >/dev/null
git var GIT_COMMITTER_IDENT >/dev/null

(
  cd "$publish_dir"
  GIT_INDEX_FILE="$index_file" git --git-dir="$git_dir" --work-tree="$publish_dir" read-tree --empty
  GIT_INDEX_FILE="$index_file" git --git-dir="$git_dir" --work-tree="$publish_dir" add -A -f .
)

echo "Creating orphan commit on $branch..."
tree_id="$(GIT_INDEX_FILE="$index_file" git write-tree)"
commit_id="$(printf '%s\n' "$message" | git commit-tree "$tree_id")"
git branch -f "$branch" "$commit_id"

if [[ $push_remote -eq 1 ]]; then
  remote_url="$(git -C "$repo_root" remote get-url "$remote")"

  case "$remote_url" in
    *github.com:docinsight/spring4d.git|*github.com/docinsight/spring4d.git)
      ;;
    *)
      echo "Refusing to push to unexpected remote URL: $remote_url" >&2
      exit 1
      ;;
  esac

  echo "Pushing $branch to $remote..."
  git push --force-with-lease "$remote" "$branch:$branch"
else
  echo "Created local $branch branch."
  echo "Push with: git push --force-with-lease $remote $branch:$branch"
fi
