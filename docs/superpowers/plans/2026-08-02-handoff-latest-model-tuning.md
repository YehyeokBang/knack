# Latest-Model Handoff Tuning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tune `/knack:handoff` for Claude 5 receiving sessions, cover the new contracts with deterministic and semantic evals, and release version 0.1.2 with complete Git tags.

**Architecture:** Preserve the existing classifier → fact collection → reference verification → type-template flow. Add shared model-behavior boundaries in `SKILL.md`, keep type-specific continuity fields in the three reference templates, and evolve the existing shell grader so its length rule matches the new conditional research budget.

**Tech Stack:** Markdown Claude Code skills, Bash deterministic grader, JSON plugin manifests, Git.

## Global Constraints

- Preserve session-language output and graceful non-git behavior.
- Read only the selected handoff reference template at generation time.
- Normal handoffs must contain 15–45 lines; research handoffs may contain 46–55 lines only when conversation-only sourced facts require the extra space.
- Do not add generic double-check loops or verifier subagents.
- Do not change trigger behavior, clipboard behavior, hooks, or unrelated skills.
- `plugins/` changes require synchronized version `0.1.2` in both manifests and a `CHANGELOG.md` entry.
- `./scripts/lint-plugin.sh` and `bash evals/run-graders.sh` must pass.

---

### Task 1: Encode and test the conditional line-budget contract

**Files:**
- Modify: `evals/graders/handoff-checks.sh`
- Create: `evals/fixtures/handoff/good-research-extended.txt`
- Create: `evals/fixtures/handoff/bad-nonresearch-extended.txt`
- Modify: `evals/run-graders.sh`
- Modify: `evals/README.md`

**Interfaces:**
- Consumes: handoff text file and optional `--root` directory accepted by `handoff-checks.sh`.
- Produces: exit 0 for 15–45-line handoffs and sourced research handoffs up to 55 lines; exit 1 for other handoffs above 45 lines.

- [ ] **Step 1: Add one expected-pass and one expected-fail fixture to the self-test**

Add these calls after the existing good fixture assertion:

```bash
assert_pass "fixtures/handoff/good-research-extended.txt"
assert_fail "fixtures/handoff/bad-nonresearch-extended.txt"
```

- [ ] **Step 2: Create two 46-line-or-longer fixtures with valid first actions and no external references**

The passing fixture must identify itself with `## 확정된 사실`, `## 조사 범위`, and sourced fact labels. The failing fixture must use execution sections and exceed 45 lines. Both remain at or below 55 lines so the test isolates the type exception.

- [ ] **Step 3: Run the self-test and verify the new passing research fixture fails under the old 40-line rule**

Run: `bash evals/run-graders.sh`

Expected: FAIL because `good-research-extended.txt` exceeds the current 40-line maximum.

- [ ] **Step 4: Implement the conditional budget**

Replace the current fixed length check with the following behavior:

```bash
if [ "$NLINES" -ge 15 ] && [ "$NLINES" -le 45 ]; then
  ok "길이 ${NLINES}줄 (15-45 예산 내)"
elif [ "$NLINES" -ge 46 ] && [ "$NLINES" -le 55 ] \
  && printf '%s' "$TEXT" | grep -q '^## 확정된 사실' \
  && printf '%s' "$TEXT" | grep -q '^## 조사 범위' \
  && printf '%s' "$TEXT" | grep -qE '\(출처: (대화 합의|conversation agreement)'; then
  ok "길이 ${NLINES}줄 (대화에만 근거가 있는 research 예외 46-55 적용)"
else
  err "길이 ${NLINES}줄 (일반 15-45 / 대화 근거 research 46-55 예산 밖)"
fi
```

- [ ] **Step 5: Update evaluation documentation and run the self-test**

Document the conditional budget and both boundary fixtures in `evals/README.md`.

Run: `bash evals/run-graders.sh`

Expected: `GRADER SELF-TEST PASSED`.

### Task 2: Tune the handoff workflow and templates

**Files:**
- Modify: `plugins/knack/skills/handoff/SKILL.md`
- Modify: `plugins/knack/skills/handoff/references/execution-handoff.md`
- Modify: `plugins/knack/skills/handoff/references/midwork-handoff.md`
- Modify: `plugins/knack/skills/handoff/references/research-handoff.md`

**Interfaces:**
- Consumes: current conversation facts, git metadata when available, and one selected reference template.
- Produces: a session-language, self-contained handoff prompt matching the selected state type and the new continuity constraints.

- [ ] **Step 1: Update shared collection and generation rules**

In `SKILL.md`, add background/desired outcome and inspected/uninspected scope to collected facts. Change the normal budget to 15–45 lines, document the narrow research exception, and state that mandatory continuity clauses are retained while low-value prose is trimmed.

- [ ] **Step 2: Update the execution template**

Add background, the receiving-session branch/status comparison, bounded delegation, proportional document length, explicit scope limits, and the rule to report materially scope-changing ambiguity. Keep the approved-plan and rejected-alternative invariants.

- [ ] **Step 3: Update the midwork template**

Add background, branch/status comparison, every remaining task, snapshot freshness for tests and working-tree state, section-name references instead of line numbers, and scope/delegation/document guards.

- [ ] **Step 4: Update the research template**

Add inspected/uninspected research scope, source verification levels, path-plus-symbol guidance, branch/status comparison, and an explicit ban on implementation before user approval.

- [ ] **Step 5: Check skill size and stale contract text**

Run:

```bash
wc -l plugins/knack/skills/handoff/SKILL.md
rg -n '15–40|15-40|line number|라인 번호' plugins/knack/skills/handoff evals
```

Expected: `SKILL.md` is at most 500 lines; no stale universal 15–40 contract or positive line-number guidance remains.

### Task 3: Strengthen semantic coverage and release documentation

**Files:**
- Modify: `evals/graders/rubric-handoff.md`
- Modify: `README.md`
- Modify: `README.ko.md`
- Modify: `plugins/knack/README.md`
- Modify: `CHANGELOG.md`
- Modify: `plugins/knack/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

**Interfaces:**
- Consumes: the tuned handoff contract from Tasks 1–2.
- Produces: judge criteria and user-facing release metadata that describe the same contract; synchronized plugin version 0.1.2.

- [ ] **Step 1: Expand the LLM-as-judge rubric**

Add criteria for task intent/background, receiving-state freshness, complete remaining-work coverage, research scope and verification levels, and scope/delegation/document-length boundaries. Explicitly reject fabricated facts and generic verifier-agent loops.

- [ ] **Step 2: Update user-facing documentation**

Keep the README summaries concise. Mention that handoffs preserve task intent and re-check snapshot state; document the 15–45 normal budget and narrow 55-line research exception in `plugins/knack/README.md`.

- [ ] **Step 3: Bump and synchronize the release version**

Set both JSON version fields to `0.1.2`. Add a dated `0.1.2` changelog entry covering latest-model handoff tuning and evaluation changes.

- [ ] **Step 4: Run repository validation**

Run:

```bash
bash evals/run-graders.sh
./scripts/lint-plugin.sh
git diff --check
```

Expected: all commands exit 0.

### Task 4: Review, amend one main commit, tag, and push the release

**Files:**
- Review: all files changed by Tasks 1–3

**Interfaces:**
- Consumes: verified working tree and the historical 0.1.1 release commit `80515aa`.
- Produces: one amended release commit on `main`, remote tags `v0.1.1` and
  `v0.1.2`, and pushed `main` state.

- [ ] **Step 1: Review the complete diff and repository state**

Run:

```bash
git diff --check
git diff --stat
git status --short
git log -3 --oneline --decorate
```

Expected: only planned files are changed on `main`; local commit `cc3b885` has
not been pushed and is safe to amend.

- [ ] **Step 2: Amend the implementation into the local design commit**

Run:

```bash
git add plugins/knack/skills/handoff evals README.md README.ko.md plugins/knack/README.md CHANGELOG.md plugins/knack/.claude-plugin/plugin.json .claude-plugin/marketplace.json docs/superpowers/plans/2026-08-02-handoff-latest-model-tuning.md
git commit --amend -m "feat: tune handoff for latest Claude models"
```

- [ ] **Step 3: Re-run validation against the committed tree**

Run:

```bash
bash evals/run-graders.sh
./scripts/lint-plugin.sh
git status --short
```

Expected: both suites pass and the working tree is clean.

- [ ] **Step 4: Create missing and current release tags**

Run:

```bash
git tag -a v0.1.1 80515aa -m "Release v0.1.1"
git tag -a v0.1.2 HEAD -m "Release v0.1.2"
git show-ref --tags --dereference
```

Expected: `v0.1.1` resolves to commit `80515aa`; `v0.1.2` resolves to the verified implementation commit.

- [ ] **Step 5: Push the commit and both tags**

Run:

```bash
git push origin main
git push origin v0.1.1 v0.1.2
git ls-remote --tags origin
```

Expected: the remote main branch contains the release commit and both tag refs are present.
