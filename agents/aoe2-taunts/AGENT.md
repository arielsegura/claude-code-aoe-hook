# AoE2 Taunts Plugin — Agent

You are a specialized agent for iterating on the **aoe2-taunts** Claude Code plugin. You have full context of its architecture and can act autonomously to modify, debug, or extend it.

## Plugin Architecture

```
claude_code_aoe_hook/
├── .claude-plugin/plugin.json     # Plugin manifest (name: "aoe2-taunts")
├── agents/aoe2-taunts/AGENT.md   # This file
├── commands/configure/COMMAND.md  # /aoe2-taunts:configure interactive skill
├── config/sound-map.json          # Event → filename mapping (user editable)
├── hooks/hooks.json               # All 12 hook event registrations
├── scripts/play-sound.sh          # Core audio dispatch script (chmod +x)
├── sounds/*.mp3                   # 42 AoE2 taunt files
└── README.md
```

## How It Works

1. Claude Code fires a lifecycle hook event (e.g., `Stop`)
2. `hooks/hooks.json` runs `play-sound.sh <EventName>` asynchronously
3. `play-sound.sh` reads `config/sound-map.json` to look up the filename for that event
4. If a non-empty filename is found and the file exists, it plays via `afplay` (macOS) or `mpg123` (Linux)
5. All failures are silent no-ops — Claude is never disrupted

## Supported Hook Events

| Event | When it fires |
|-------|--------------|
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

## All 42 Available Sounds

```
1 Yes.mp3
2 No.mp3
3 Food Please.mp3
4 Wood Please.mp3
5 Gold Please.mp3
6 Stone Please.mp3
7 Ahh.mp3
8 All Hail, King of the Losers.mp3
9 Oooh.mp3
10 I'll Beat You Back to Age of Empires.mp3
11 Hahahahahah.mp3
12 Ack, Being Rushed.mp3
13 Sure Blame it on Your ISP.mp3
14 Start the Game Already.mp3
15 Don't Point That Thing at Me.mp3
16 Enemy Sighted.mp3
17 It is Good To be the King.mp3
18 Monk, I Need a Monk.mp3
19 Long Time, No Siege.mp3
20 My Granny Could Scrap Better Than That.mp3
21 Nice Town, I'll Take It.mp3
22 Quit Touchin Me.mp3
23 Raiding Party.mp3
24 Dadgum.mp3
25 Ehhh Smite Me.mp3
26 The Wonder, The Wonder, The Noooooo.mp3
27 You Played 2 Hours to Die Like This.mp3
28 Yeah Well You Should See the Other Guy.mp3
29 Roggan.mp3
30 WOLOLO.mp3
31 Attack an Enemy Now.mp3
32 Cease Creating Extra Villagers.mp3
33 Create Extra Villagers.mp3
34 Build a Navy.mp3
35 Stop Building a Navy.mp3
36 Wait for my Signal to Attack.mp3
37 Build a Wonder.mp3
38 Give Me Your Extra Resources.mp3
39 (Ally Sound).mp3
40 (Enemy Sound).mp3
41 (Neutral Sound).mp3
42 What Age are you in.mp3
```

## Modifying Sound Mappings

Edit `config/sound-map.json` directly:
```json
{
  "Stop": "30 WOLOLO.mp3",
  "Notification": "16 Enemy Sighted.mp3",
  "TaskCompleted": "17 It is Good To be the King.mp3"
}
```

Or use the interactive configure command: `/aoe2-taunts:configure`

## Testing

```bash
# Test a mapped event (should play WOLOLO)
bash scripts/play-sound.sh Stop

# Test a disabled event (silent, exits 0)
bash scripts/play-sound.sh UserPromptSubmit

# Test an unknown event (silent, exits 0)
bash scripts/play-sound.sh FakeEvent
```

## Troubleshooting

- **No sound plays**: Check that `afplay` is available (`which afplay`) and the file exists in `sounds/`
- **Wrong sound**: Check `config/sound-map.json` for the event mapping
- **Script errors**: Run with `bash -x scripts/play-sound.sh Stop` to debug
- **Hooks not firing**: Verify the plugin is loaded in Claude Code settings
