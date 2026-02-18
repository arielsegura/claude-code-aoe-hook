# AoE2 Taunts — Claude Code Sound Hook Plugin

Play Age of Empires 2 taunt sounds when Claude Code lifecycle events fire. Hear **WOLOLO** every time Claude finishes responding.

## Installation

### 1. Clone the repo

```bash
git clone https://github.com/arielsegura/claude-code-aoe-hook.git ~/claude-code-aoe-hook
```

### 2. Install into a project

```bash
cd /your/project
~/claude-code-aoe-hook/scripts/install.sh
```

This writes absolute-path hook entries into `.claude/settings.json` in your project directory. Existing settings are preserved.

### 3. Restart Claude Code

Hooks activate on next session start.

### Uninstall from a project

```bash
~/claude-code-aoe-hook/scripts/install.sh --uninstall
# or for a specific directory:
~/claude-code-aoe-hook/scripts/install.sh --uninstall /your/project
```

---

> **Sound disclaimer:** The AoE2 taunt sounds included in this repository are from Age of Empires II © Microsoft Corporation. This is a fan project for personal use only, not affiliated with or endorsed by Microsoft. No commercial use intended.

---

## Quick Start

1. Install the plugin in Claude Code (add this directory as a plugin)
2. WOLOLO plays automatically when Claude finishes any response
3. Run `/aoe2-taunts:configure` to customize which sounds play for which events

## Default Sound Mappings

| Event | Sound | When |
|-------|-------|------|
| Stop | 30 WOLOLO.mp3 | Claude finishes responding |
| Notification | 16 Enemy Sighted.mp3 | Permission prompts / idle alerts |

All other events are disabled by default. Enable them via `/aoe2-taunts:configure`.

## Supported Events

| Event | Description |
|-------|-------------|
| Stop | Claude finishes responding |
| SessionStart | New Claude Code session begins |
| SessionEnd | Session ends |
| Notification | Permission prompt or idle notification |
| UserPromptSubmit | User submits a message |
| PreToolUse | Before any tool call |
| PostToolUse | After successful tool call |
| PostToolUseFailure | After failed tool call |
| TaskCompleted | Task/todo item completed |
| SubagentStop | Subagent finishes |
| SubagentStart | Subagent starts |
| PreCompact | Before context compaction |

## Interactive Configuration

```
/aoe2-taunts:configure
```

This command lets you:
- View current event → sound mappings
- Browse all 42 available sounds
- Interactively assign sounds to events
- Disable events by setting them to empty

**Direct mode** (skip the interactive flow):
```
/aoe2-taunts:configure Stop 30       # Map Stop to sound #30 (WOLOLO)
/aoe2-taunts:configure TaskCompleted 17  # Map TaskCompleted to "It is Good To be the King"
/aoe2-taunts:configure PreToolUse    # Disable PreToolUse
```

## Manual Configuration

Edit `config/sound-map.json` directly:

```json
{
  "_comment": "Map hook event names to MP3 filenames in sounds/. Empty string to disable.",
  "Stop": "30 WOLOLO.mp3",
  "Notification": "16 Enemy Sighted.mp3",
  "TaskCompleted": "17 It is Good To be the King.mp3",
  "SessionStart": ""
}
```

Use the exact filename from the `sounds/` directory.

## All 42 Sounds

| # | Sound |
|---|-------|
| 1 | Yes |
| 2 | No |
| 3 | Food Please |
| 4 | Wood Please |
| 5 | Gold Please |
| 6 | Stone Please |
| 7 | Ahh |
| 8 | All Hail, King of the Losers |
| 9 | Oooh |
| 10 | I'll Beat You Back to Age of Empires |
| 11 | Hahahahahah |
| 12 | Ack, Being Rushed |
| 13 | Sure Blame it on Your ISP |
| 14 | Start the Game Already |
| 15 | Don't Point That Thing at Me |
| 16 | Enemy Sighted |
| 17 | It is Good To be the King |
| 18 | Monk, I Need a Monk |
| 19 | Long Time, No Siege |
| 20 | My Granny Could Scrap Better Than That |
| 21 | Nice Town, I'll Take It |
| 22 | Quit Touchin Me |
| 23 | Raiding Party |
| 24 | Dadgum |
| 25 | Ehhh Smite Me |
| 26 | The Wonder, The Wonder, The Noooooo |
| 27 | You Played 2 Hours to Die Like This |
| 28 | Yeah Well You Should See the Other Guy |
| 29 | Roggan |
| 30 | WOLOLO |
| 31 | Attack an Enemy Now |
| 32 | Cease Creating Extra Villagers |
| 33 | Create Extra Villagers |
| 34 | Build a Navy |
| 35 | Stop Building a Navy |
| 36 | Wait for my Signal to Attack |
| 37 | Build a Wonder |
| 38 | Give Me Your Extra Resources |
| 39 | (Ally Sound) |
| 40 | (Enemy Sound) |
| 41 | (Neutral Sound) |
| 42 | What Age are you in |

## Platform Requirements

- **macOS**: Uses `afplay` (built-in, no install required)
- **Linux**: Uses `mpg123` (`sudo apt install mpg123` or `brew install mpg123`)

## How It Works

1. Claude Code fires a lifecycle hook event
2. `hooks/hooks.json` runs `scripts/play-sound.sh <EventName>` asynchronously
3. The script reads `config/sound-map.json` for the filename
4. Plays via `afplay` or `mpg123` in a detached background process
5. All failures are silent — Claude is never blocked or disrupted

Hooks run with `async: true`, so audio playback never delays Claude's response.

## Troubleshooting

**No sound plays:**
- Check `afplay` is available: `which afplay`
- Verify the file exists: `ls sounds/`
- Test the script: `bash scripts/play-sound.sh Stop`

**Sound plays but wrong one:**
- Check `config/sound-map.json` for the event mapping
- Verify the filename matches exactly (case-sensitive)

**Script errors:**
- Debug mode: `bash -x scripts/play-sound.sh Stop`

**Hooks not firing:**
- Verify the plugin is loaded in Claude Code settings
- Check `hooks/hooks.json` is correctly formatted

## Verification

```bash
# Should play WOLOLO immediately
bash scripts/play-sound.sh Stop

# Should be silent, exit 0
bash scripts/play-sound.sh UserPromptSubmit
```
