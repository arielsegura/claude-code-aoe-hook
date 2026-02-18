#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAY_SOUND="${PLUGIN_ROOT}/scripts/play-sound.sh"

UNINSTALL=false
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=true ;;
    *) TARGET="$arg" ;;
  esac
done

TARGET="${TARGET:-$(pwd)}"
SETTINGS_DIR="${TARGET}/.claude"
SETTINGS_FILE="${SETTINGS_DIR}/settings.json"

EVENTS=(
  Stop SessionStart SessionEnd Notification
  UserPromptSubmit PreToolUse PostToolUse PostToolUseFailure
  TaskCompleted SubagentStop SubagentStart PreCompact
)

if $UNINSTALL; then
  if [[ ! -f "$SETTINGS_FILE" ]]; then
    echo "Nothing to uninstall: $SETTINGS_FILE does not exist."
    exit 0
  fi
  python3 - "$SETTINGS_FILE" "$PLAY_SOUND" <<'EOF'
import json, sys

settings_file = sys.argv[1]
play_sound_path = sys.argv[2]

with open(settings_file) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
for event, entries in list(hooks.items()):
    filtered = []
    for entry in entries:
        inner = entry.get("hooks", [])
        cleaned = [h for h in inner if play_sound_path not in h.get("command", "")]
        if cleaned:
            filtered.append({**entry, "hooks": cleaned})
        elif len(inner) == 0:
            filtered.append(entry)
    if filtered:
        hooks[event] = filtered
    else:
        del hooks[event]

if hooks:
    settings["hooks"] = hooks
elif "hooks" in settings:
    del settings["hooks"]

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"Uninstalled hooks from {settings_file}")
EOF
  rm -f "$HOME/.claude/commands/aoe2-configure.md"
  echo "Removed ~/.claude/commands/aoe2-configure.md"
  exit 0
fi

mkdir -p "$SETTINGS_DIR"

python3 - "$SETTINGS_FILE" "$PLAY_SOUND" "${EVENTS[@]}" <<'EOF'
import json, sys, os

settings_file = sys.argv[1]
play_sound_path = sys.argv[2]
events = sys.argv[3:]

if os.path.exists(settings_file):
    with open(settings_file) as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.setdefault("hooks", {})

for event in events:
    command = f"{play_sound_path} {event}"
    new_hook = {"type": "command", "command": command, "async": True}
    new_entry = {"hooks": [new_hook]}

    existing = hooks.get(event, [])
    # Skip if already installed
    already = any(
        any(play_sound_path in h.get("command", "") for h in e.get("hooks", []))
        for e in existing
    )
    if not already:
        hooks[event] = existing + [new_entry]

settings["hooks"] = hooks

with open(settings_file, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"Installed hooks into {settings_file}")
EOF

COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"
sed "s|__PLUGIN_ROOT__|${PLUGIN_ROOT}|g" \
  "${PLUGIN_ROOT}/commands/configure/COMMAND.md" \
  > "${COMMANDS_DIR}/aoe2-configure.md"
echo "Installed ~/.claude/commands/aoe2-configure.md"
