# knack

**English** | [한국어](./README.ko.md)

A knack — a trick of the trade, a skill that lives in your hands.
A personal Claude Code plugin marketplace that turns everyday workflow
habits into skills, managed and shipped from one place.

## Installation

Run these two lines in Claude Code, in order:

```
/plugin marketplace add YehyeokBang/knack
/plugin install knack@knack
```

Once installed, invoke skills as `/knack:<skill-name>`.

## Updates (auto-update)

Third-party marketplaces have **auto-update OFF by default**. With it
turned on, a push is picked up automatically in the next session:

```
/plugin  →  in marketplace settings, turn on auto-update for knack
```

The update trigger is the `version` value in `plugin.json` — a push
without a version bump is never applied to installed copies.

## Skills

> See the [CHANGELOG](./CHANGELOG.md) for version history and [plugin.json](./plugins/knack/.claude-plugin/plugin.json) for the current version.
> All skills ship and update together as a single plugin.

| Command | Description | Docs |
|---------|-------------|------|
| `/knack:handoff` | Generates a zero re-explanation handoff prompt for the next session at session end — verifies that paths and commit hashes exist, prints a code block, and copies it to the clipboard | [SKILL.md](./plugins/knack/skills/handoff/SKILL.md) |
| `/knack:retune` | Reader-tailored document rewriting — rewrites for the target audience (PM / non-developer / other roles). Fixes meaningless numbering, vague English abbreviations, translationese, and unexplained jargon | [SKILL.md](./plugins/knack/skills/retune/SKILL.md) |

## Repository structure

```
knack/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace catalog (version kept in sync with plugin.json)
├── plugins/
│   └── knack/                   # Plugin (name: "knack")
│       ├── .claude-plugin/
│       │   └── plugin.json      # version — ★ auto-update trigger
│       ├── skills/
│       │   ├── handoff/         # /knack:handoff
│       │   │   ├── SKILL.md
│       │   │   └── references/  # 3 handoff-type templates
│       │   └── retune/          # /knack:retune
│       │       └── SKILL.md
│       └── README.md            # Skill index
├── scripts/
│   └── lint-plugin.sh           # Version sync, README sync, 500-line checks
├── CHANGELOG.md
├── CLAUDE.md                    # Version bump rules, rollback procedure, branch policy
├── README.md                    # English (main)
└── README.ko.md                 # Korean
```

> To add a new skill, just add a directory under `skills/` — it is auto-registered as `/knack:<directory-name>`.

## Requirements

- macOS (the clipboard copy in `/knack:handoff` depends on `pbcopy` — cross-platform support is on the roadmap)

## Contact

- Bugs and feature requests: [knack Issues](https://github.com/YehyeokBang/knack/issues)
