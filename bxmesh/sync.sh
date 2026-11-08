#!/usr/bin/env bash
# Merges an upstream CoreScope release into a new branch off bxmesh, ready for a pull request:
#   bxmesh/sync.sh v3.16.0
# Upstream's workflows stay out of this fork (BXMESH.md), so any it adds or changes are removed
# again. Any other conflict stops here, for a person to resolve. Run from a clone of this repo
# with a clean tree; it pushes nothing.
set -euo pipefail
release=${1:?usage: bxmesh/sync.sh vX.Y.Z}
[[ $release =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "not a release: $release" >&2; exit 1; }
cd "$(git rev-parse --show-toplevel)"
[ -z "$(git status --porcelain)" ] || { echo "the working tree isn't clean" >&2; exit 1; }

git fetch -q origin bxmesh
git fetch -q --no-tags https://github.com/Kpa-clawbot/CoreScope.git "refs/tags/$release:refs/tags/$release"
git switch -q -c "upstream-$release" origin/bxmesh

git merge -q --no-ff --no-commit "$release" || echo "the merge conflicts; checking where"
# Upstream's own workflows: everything in .github/workflows that isn't ours, conflicting or not.
git ls-files -- .github/workflows | { grep -v '^\.github/workflows/bxmesh-' || true; } | sort -u | xargs -r git rm -qf --
if [ -n "$(git diff --name-only --diff-filter=U)" ]; then
  echo "these still conflict; resolve them, then git commit:" >&2
  git diff --name-only --diff-filter=U >&2
  exit 1
fi
git commit -q -m "Merge upstream CoreScope $release"

echo "$release" > bxmesh/UPSTREAM_RELEASE
git commit -q -m "bxmesh: upstream $release" bxmesh/UPSTREAM_RELEASE

# The patch must have survived the merge.
node tests/unit/test-live.js | tail -3
echo "ready: push upstream-$release and open a pull request to bxmesh"
