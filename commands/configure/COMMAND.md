# /aoe2-configure

Configure which AoE2 taunt sounds play for Claude Code lifecycle events.

## Usage

```
/aoe2-configure              # Interactive mode
/aoe2-configure Stop 30      # Direct mode: map Stop event to sound #30 (WOLOLO)
/aoe2-configure Stop         # Disable the Stop event (empty mapping)
```

## Dynamic Context

Current sound mappings:
```
!`cat __PLUGIN_ROOT__/config/sound-map.json`
```

Available sounds:
```
!`ls __PLUGIN_ROOT__/sounds/ | sort`
```

## Instructions for Claude

You are helping the user configure AoE2 taunt sounds for Claude Code lifecycle events.

**Write the updated config to**: `__PLUGIN_ROOT__/config/sound-map.json`

### Supported Events

- Stop, SessionStart, SessionEnd, Notification, UserPromptSubmit
- PreToolUse, PostToolUse, PostToolUseFailure
- TaskCompleted, SubagentStop, SubagentStart, PreCompact

### Direct Argument Mode

If the user ran `/aoe2-configure <Event> <Number>`:
- Map the named event to the sound with that number
- Update `__PLUGIN_ROOT__/config/sound-map.json` using the Write tool
- Confirm with AoE2-themed flavor text (e.g., "WOLOLO! Stop is now mapped to...")

If the user ran `/aoe2-configure <Event>` with no number:
- Disable that event (set to empty string `""`)
- Confirm the change

### Interactive Mode

If no arguments were given, run the interactive flow:

1. **Show current config** as a formatted table:
   ```
   Event              | Sound
   -------------------|----------------------------------
   Stop               | 30 WOLOLO.mp3
   Notification       | 16 Enemy Sighted.mp3
   TaskCompleted      | (disabled)
   ...
   ```

2. **Show available sounds** numbered list (use the dynamic context above)

3. **Ask the user**:
   - Which event to configure? (or "done" to finish)
   - Which sound number to assign? (or "0" / blank to disable)

4. **Update** `__PLUGIN_ROOT__/config/sound-map.json` via the Write tool with the complete updated JSON

5. **Confirm** with AoE2-themed flavor text matching the chosen sound

6. **Loop** — ask if they want to configure another event, until "done"

### JSON Format Rules

Always write the complete `config/sound-map.json` (all 12 events + `_comment`). Never write partial JSON. Preserve the `_comment` key. Use exact filenames from the sounds directory.

Example of a valid write:
```json
{
  "_comment": "Map hook event names to MP3 filenames in sounds/. Empty string to disable.",
  "Stop":               "30 WOLOLO.mp3",
  "Notification":       "16 Enemy Sighted.mp3",
  "SessionStart":       "",
  "SessionEnd":         "",
  "UserPromptSubmit":   "",
  "PreToolUse":         "",
  "PostToolUse":        "",
  "PostToolUseFailure": "",
  "TaskCompleted":      "17 It is Good To be the King.mp3",
  "SubagentStop":       "",
  "SubagentStart":      "",
  "PreCompact":         ""
}
```

### AoE2 Flavor Text Examples

Match flavor text to the sound chosen:
- WOLOLO → "WOLOLO! The monks have converted your settings."
- Enemy Sighted → "Enemy sighted! Notification will now alert you."
- It is Good To be the King → "It is good to be the king! Task completion now celebrated."
- Hahahahahah → "Hahahahahah! Your enemies weep at this configuration."
- Yes → "Yes! The villagers have spoken."
- All Hail, King of the Losers → "All hail... well, someone had to configure this."
- Start the Game Already → "Start the game already! Session starts will now taunt you."
