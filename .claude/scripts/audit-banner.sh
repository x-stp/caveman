#!/usr/bin/env bash
# Print a one-line audit posture banner at Claude Code session start.
# Silent-fail on every error so a missing file or missing jq never blocks the
# session.

set +e

manifest=".audited/manifest.json"
stamp=".audit-stamp"

verdict="PENDING"
sha="?"
if [ -f "$manifest" ] && command -v jq >/dev/null 2>&1; then
  v=$(jq -r '.verdict // "PENDING"' "$manifest" 2>/dev/null) && verdict="$v"
  s=$(jq -r '.upstream_sha // "?"' "$manifest" 2>/dev/null) && sha="$s"
fi

last_scan="never"
if [ -f "$stamp" ]; then
  if d=$(stat -f %Sm -t %Y-%m-%d "$stamp" 2>/dev/null); then
    last_scan="$d"
  elif d=$(stat -c %y "$stamp" 2>/dev/null); then
    last_scan="${d%% *}"
  fi
fi

printf '[caveman-audit] verdict=%s upstream=%s last-scan=%s\n' \
  "$verdict" "${sha:0:7}" "$last_scan"

exit 0
