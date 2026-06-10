# LLM-as-judge rubric — retune

retune output is inherently subjective (reader comprehension), so it is graded
primarily by LLM-as-judge. Judge model held FIXED to a strong model. Score the
OUTPUT, not the path. The north-star metric is: **would THIS reader have to ask a
follow-up question?** If yes, the rewrite failed.

Score each criterion `{ "text": <criterion>, "passed": <bool>, "evidence": <quote> }`.

## Criteria

1. **Meaning preserved (highest weight)** — Every fact and the author's intent are
   unchanged. The rewrite must not add, drop, or distort information. A meaning
   change is an automatic overall FAIL even if readability improved.
2. **Target 1 — numbering** — Meaningless labels (T1/T2, 1안/2안) replaced with
   self-describing names, IF present in the input.
3. **Target 2 — abbreviations** — Ambiguous English abbreviations expanded on first
   use or replaced, IF present.
4. **Target 3 — translationese** — Awkward/translated-English phrasing rewritten as
   natural Korean, IF present.
5. **Target 4 — jargon** — Terms outside the stated reader's knowledge boundary
   explained or substituted, judged per THIS reader (not per dictionary).
6. **Output format** — Rewritten doc in a single fenced code block, followed by a
   corrections list grouped by the four targets (one line each).
7. **Reader comprehension** — A reader at the stated level understands it in one
   read with no follow-up question.

## Notes
- Criteria 2–5 are conditional: if a target class is absent from the input, mark it
  `passed: true` with evidence "해당 입력에 없음".
- Anti-criterion: do NOT reward "sounds more human" or AI-trace removal — that is
  explicitly out of scope per the skill.
