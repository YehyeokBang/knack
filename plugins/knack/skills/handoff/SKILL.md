---
name: handoff
description: >
  Use when the user is wrapping up a session and wants a copy-paste prompt to
  continue the work in a fresh session. Generates a self-contained handoff
  prompt in the session language. Triggers: handoff, 핸드오프, 인계 프롬프트,
  handoff prompt 작성해줘, 다음 세션에서 시작, 새 세션에서 이어서,
  복붙해서 시작, 클립보드 복사.
---

# Session Handoff Prompt Generator

**Language rule**: The generated handoff prompt body and all communication with
the user follow the language the session is conducted in. Skill definition
files and internal instructions are in English.

## Overview

**Flow:** 1. Classify session state → 2. Collect facts → 3. Verify references → 4. Output + clipboard

SKILL.md holds the full workflow. Read ONE reference file (the matching
template) at Step 4 — never load all three.

## Common Principles

### 1. Self-contained
The next session cannot see this conversation. Never write "위에서 말한 대로",
"아까 논의한", or any reference to the current chat. Every fact the next
session needs must be in the handoff body.

### 2. Verified references only
Every file path and commit hash in the handoff must pass Step 3 verification.
An unverified reference must be fixed or removed — a dead reference derails
the next session.

### 3. Concrete first action
End with one executable first step ("Task 1부터 진행", "X 파일 Read부터").
"이어서 해줘" is forbidden.

### 4. Length budget
Target 15–45 lines. Too short starves context; too long won't be read.
Mandatory continuity clauses are never what you trim to fit — cut low-value
prose and duplicate facts first. Research handoffs may extend to 55 lines only
when sourced facts exist solely in this conversation and there is no verified
on-disk spec or plan to reference. The extra room is for facts with source
labels, never for prose.

## Step 1 — Classify session state

Review the current conversation and pick ONE type:

| Signal | Type | Template |
|--------|------|----------|
| Spec/plan approved & committed, execution not started | execution | `references/execution-handoff.md` |
| Implementation in progress (some tasks/commits done, more remain) | midwork | `references/midwork-handoff.md` |
| Research/analysis/discussion, decisions not yet final | research | `references/research-handoff.md` |

If ambiguous, do NOT guess — ask once via `AskUserQuestion` (a deferred tool;
load it first with `ToolSearch(query="select:AskUserQuestion", max_results=1)`).
Use these options and descriptions verbatim:

- 실행 인계 — "계획 승인 완료, 다음 세션은 실행만 하면 되는 상태"
- 진행 중 인계 — "구현 중간, 일부 커밋 완료·일부 남은 상태"
- 조사·논의 인계 — "결정 미확정, 사실과 미결 질문을 넘기는 상태"

## Step 2 — Collect facts

From the conversation:
- The background: why the work matters and what completion enables
- Agreed decisions (and WHO approved — the user)
- Rejected alternatives, so the next session does not re-propose them
- Open questions (research type only)
- What was and was not inspected (research type only)
- The concrete next action

From git (run in the working directory):

```bash
git rev-parse --abbrev-ref HEAD     # branch
git rev-parse --short HEAD          # HEAD commit
git status --porcelain              # dirty files
```

**Non-git rule**: if the working directory is not a git repository, gracefully
skip the branch/HEAD/dirty sections (and the dirty-file rule below) — file
path verification in Step 3 still applies.

**Dirty-file rule**: if `git status --porcelain` is non-empty, STOP before
generating. Warn the user and ask via `AskUserQuestion`: 커밋하고 진행 /
handoff에 더티 상태 명시 / 무시. If the user picks "무시", treat it the same
as "더티 상태 명시" for the handoff body — list the dirty files; the only
difference is proceeding without further discussion. A handoff that hides
uncommitted state breaks the next session.

## Step 3 — Verify references

For EVERY path and hash you intend to write into the handoff:

```bash
test -f <path> && echo OK || echo MISSING    # files (test -d for dirs)
git cat-file -t <hash>                       # commits — expect "commit"
```

Drop or fix anything that fails. Do not silently keep it.

## Step 4 — Generate and output

1. Read the ONE template file matching the Step 1 type.
2. Fill it with Step 2 facts (in the session language). Respect the length budget.
3. Print the handoff in a single fenced code block.
4. Copy to clipboard:

```bash
pbcopy <<'HANDOFF_EOF'
<handoff body exactly as printed>
HANDOFF_EOF
```

5. Tell the user: "클립보드에 복사됨 — 새 세션에서 ⌘V로 시작하세요." (in the
   session language).
