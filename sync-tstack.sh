#!/usr/bin/env bash
# Applies upstream t3dotgg/tstack skill changes to main and pushes them.
# tstack.rev records the last upstream commit applied. Cron runs this daily on
# one machine, pulling first so changes to this script apply too.
set -euo pipefail

cd "$(dirname "$0")"

log() { echo "$(date '+%F %T') $*"; }

git fetch -q origin
if [ "$(git branch --show-current)" != main ] || [ -n "$(git status --porcelain)" ] ||
  [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]; then
  log "skipped: checkout must be a clean main matching origin" >&2
  exit 1
fi

git fetch -q https://github.com/t3dotgg/tstack HEAD
latest="$(git rev-parse FETCH_HEAD)"
last="$(cat tstack.rev)"
[ "$latest" = "$last" ] && exit 0

# A conflict or rejected push leaves tstack.rev unchanged, so the next run retries.
trap 'git reset -q --hard "@{u}"; log "failed: tstack $latest not applied" >&2' ERR

if ! git diff --quiet "$last" "$latest" -- skills; then
  git diff --binary "$last" "$latest" -- skills | git apply --3way
fi
echo "$latest" > tstack.rev
git add tstack.rev
git -c user.name=tstack-sync -c user.email=tstack-sync@users.noreply.github.com \
  commit -qm "chore(skills): sync tstack to ${latest:0:7}"
git push -q origin main
log "applied tstack $latest"
