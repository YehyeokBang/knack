---
name: retune
description: >
  Use when the user wants a document rewritten so a specific audience
  (PM, non-developer, another team) understands it in one read. Takes a target
  reader, then rewrites the document at that reader's level — fixing
  meaningless numbering, ambiguous English abbreviations, translationese, and
  unexplained jargon. Triggers: retune, 윤문, 독자 맞춤, 눈높이로 바꿔줘,
  PM이 이해하게, 비개발자용으로, 이 문서 다듬어줘.
---

# Retune — Audience-Targeted Rewriter

**Language rule**: Communication and the rewritten document follow the session
language. The skill exists primarily for Korean business documents.

## What this is (and is not)

Rewrite a document so the **target reader understands it in one read**.
The metric is reader comprehension — would this reader have to ask a
follow-up question? If yes, the rewrite failed.

This is NOT an AI-trace remover or a style disguiser. Do not chase
"sounding human"; chase "being understood by THIS reader".

## Step 1 — Get the document and the reader

Two inputs are required:

1. **Document**: pasted text, or a file path (verify with `test -f` before reading).
2. **Target reader**: who will read this — e.g. PM, 비개발자, 디자이너,
   타 팀 백엔드 개발자, 경영진.

If the reader is not specified, ask ONCE via `AskUserQuestion`
(load it first: `ToolSearch(query="select:AskUserQuestion", max_results=1)`)
with common presets: PM / 비개발자 / 프론트엔드 개발자 / 경영진.

Then fix the reader's knowledge boundary: what they know (their domain) and
what they don't (your domain's internals). Every correction below is judged
against that boundary.

## Step 2 — Rewrite against the four correction targets

Scan the document for all four target classes and fix every instance.
Keep the author's intent and factual content exactly; change only how it reads.

### Target 1 — Meaningless numbering

Labels like T1/T2, 1안/2안 carry zero meaning to a reader who wasn't in the
room. Replace with self-describing names.

- **Before**: "T1은 이번 주에 배포하고 T2는 QA 이후로 미룹니다."
- **After**: "결제 실패 재시도 기능은 이번 주에 배포하고, 환불 자동화는 QA 이후로 미룹니다."

### Target 2 — Ambiguous English abbreviations

Abbreviations obvious to the writer are noise to the reader. Expand on first
use, or replace with the plain word if the abbreviation adds nothing.

- **Before**: "EOD까지 ASAP으로 PR 머지 부탁드려요. CS팀 VOC 대응 건입니다."
- **After**: "오늘 퇴근 전까지 코드 반영(PR 머지)을 부탁드려요. 고객센터에 접수된 불만 대응 건이라 급합니다."

### Target 3 — Translationese / awkward Korean

Sentences shaped like translated English — passive voice, "~에 대하여",
"~지는" 구문 — read slowly in Korean. Rewrite as natural Korean.

- **Before**: "해당 기능에 대하여 검토가 이루어졌으며, 다음 주에 배포가 진행될 예정입니다."
- **After**: "이 기능은 검토를 마쳤고, 다음 주에 배포합니다."

### Target 4 — Jargon the reader doesn't know

Terms inside the writer's domain but outside the reader's knowledge boundary
(Step 1) need a plain-language explanation or substitution — judged per
reader, not per dictionary.

- **Before**: "레이스 컨디션 때문에 멱등성 보장이 안 돼서 중복 결제가 발생했습니다." (독자: PM)
- **After**: "같은 요청이 거의 동시에 두 번 들어오면 시스템이 한 번만 처리한다고 보장하지 못해서, 중복 결제가 발생했습니다."

## Step 3 — Output

1. Print the full rewritten document in a single fenced code block
   (ready to copy).
2. Below it, list the corrections made, grouped by the four targets — one
   line each ("T1/T2 → 기능 이름으로 교체" 수준). This lets the user verify
   nothing changed meaning.
3. Do not invent facts. If a numbering label or abbreviation cannot be
   resolved from the document, ask the user instead of guessing (via
   `AskUserQuestion` — load it the same way as Step 1 if not already loaded).
