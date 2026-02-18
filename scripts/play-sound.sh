#!/usr/bin/env bash
set -euo pipefail

EVENT="${1:-}"
[[ -z "$EVENT" ]] && exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG="${PLUGIN_ROOT}/config/sound-map.json"
[[ ! -f "$CONFIG" ]] && exit 0

SOUND_FILE=$(python3 -c "
import json, sys
try:
    data = json.load(open('${CONFIG}'))
    print(data.get('${EVENT}', ''))
except Exception:
    print('')
")
[[ -z "$SOUND_FILE" ]] && exit 0

SOUND_PATH="${PLUGIN_ROOT}/sounds/${SOUND_FILE}"
[[ ! -f "$SOUND_PATH" ]] && exit 0

if command -v afplay &>/dev/null; then
  afplay "$SOUND_PATH" &>/dev/null &
  disown $!
elif command -v mpg123 &>/dev/null; then
  mpg123 --quiet "$SOUND_PATH" &>/dev/null &
  disown $!
fi
exit 0
