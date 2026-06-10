# LLM-as-judge rubric — handoff

Used in Task 2 (cross-model harness) to grade what the deterministic
`handoff-checks.sh` cannot: template-type correctness, semantic completeness,
and the dirty-tree guard. Judge model is held FIXED to a strong model
(per research: judge robustness varies by model); score the OUTPUT, not the path.

Bias controls: randomize answer order in A/B comparisons, normalize for length.

Score each criterion `passed: true|false` with `evidence` (verbatim quote).
Output schema per criterion: `{ "text": <criterion>, "passed": <bool>, "evidence": <quote> }`.

## Criteria

1. **Correct template type** — The handoff matches the session state in `type`
   (execution / midwork / research). A research session must NOT produce an
   execution handoff, etc.
2. **Type-specific invariant present**
   - execution: explicit "do not re-discuss, just execute" line.
   - midwork: done/remaining boundary + all three 현재 상태 bullets.
   - research: 확정된 사실 vs 미결 질문 strictly separated; every fact has a source.
3. **No fabricated facts** — Nothing in the handoff contradicts or invents beyond
   the provided context.
4. **Rejected alternatives carried** — If the context names a rejected approach,
   it appears with "재제안 금지".
5. **Actionable for a cold start** — A fresh session with zero prior context could
   execute the first action without asking a clarifying question.

## Notes
- Deterministic checks (self-contained, 첫 액션, length, ref integrity) are already
  enforced by `handoff-checks.sh`; the judge need not re-score them.
- A case passes overall only if BOTH the deterministic grader passes AND all
  rubric criteria pass.
