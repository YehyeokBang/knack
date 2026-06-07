# knack plugin — skill index

The skills this plugin provides. For installation, updates, and other
marketplace-level guidance, see the [repository root README](../../README.md).

## Skills

| Command | Description | Docs |
|---------|-------------|------|
| `/knack:handoff` | Generates a zero re-explanation handoff prompt for the next session at session end (verification + clipboard copy) | [SKILL.md](./skills/handoff/SKILL.md) |
| `/knack:retune` | Reader-tailored document rewriting — rewrites for the target audience | [SKILL.md](./skills/retune/SKILL.md) |

See [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) for the single plugin version.

## Directory layout

```
plugins/knack/
├── .claude-plugin/
│   └── plugin.json          # Version — auto-update trigger
├── skills/
│   ├── handoff/
│   │   ├── SKILL.md
│   │   └── references/      # execution / midwork / research templates
│   └── retune/
│       └── SKILL.md
└── README.md                # This file (index)
```

Each skill directory's `SKILL.md` defines the workflow the Claude agent follows.
