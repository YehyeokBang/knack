# Latest-Model Handoff Tuning Design

## Goal

Improve `/knack:handoff` so a fresh Claude 5 session resumes with less drift,
unnecessary re-discussion, scope expansion, and stale-state assumptions while
preserving the current skill's useful portability and language behavior.

## Evidence and design rationale

The supplied Claude Opus 5, Sonnet 5, and Fable 5 prompting guides identify a
small set of behaviors that directly affect session handoffs:

- Opus 5 performs best when it receives the complete task specification up
  front, but may expand scope, over-delegate, and produce overlong written
  artifacts unless boundaries are explicit.
- Fable 5 benefits from knowing why a task exists, from grounding status claims
  in tool results, and from explicit boundaries on unrequested actions. It also
  benefits from being told not to reopen settled decisions once enough context
  exists to act.
- Sonnet 5 follows instructions more literally, especially at lower effort, so
  rules intended to apply to every remaining task or every fact must say so
  explicitly rather than relying on generalization.
- Opus 5 already self-corrects and self-verifies strongly. Generic instructions
  to double-check everything or spawn verifier agents can add cost without
  improving quality.

Therefore this change adds intent, completeness, state freshness, and scope
boundaries where they matter, but does not add blanket verification loops or
model-specific template branches.

## Chosen approach

Selectively update the existing shared workflow and three state-specific
templates. Keep one model-agnostic handoff format because the receiving model
may not be known when the handoff is generated and because the relevant
behavioral guidance is largely shared across the supplied model documents.

Rejected approaches:

- Copy another implementation wholesale: rejected because it would regress the
  current session-language behavior and graceful non-git handling.
- Maintain Opus-, Sonnet-, and Fable-specific templates: rejected because it
  duplicates policy, raises maintenance cost, and requires information the
  generator often does not have.

## Workflow changes

The four-step workflow remains unchanged: classify state, collect facts, verify
references, then generate and copy the handoff.

Update the common length target from 15–40 lines to 15–45 lines. A research
handoff may use up to 55 lines only when its sourced facts exist solely in the
conversation and cannot be replaced by a verified on-disk document reference.
Mandatory safety and continuity clauses are not removed to meet the budget;
low-value prose is trimmed first.

Preserve these existing behaviors:

- Generate the handoff and user communication in the session language.
- Read only the selected type template.
- Verify every path and commit hash before including it.
- In a non-git directory, omit git-only metadata while continuing to verify
  filesystem references.
- Stop on a dirty git tree and ask how it should be represented. A choice to
  ignore the warning still lists the dirty files in the handoff.

## Shared receiving-session guards

Every applicable template records the task's reason and intended outcome, not
only its mechanics. Every git-backed handoff tells the receiving session to
check its current branch and status before acting and to report a mismatch from
the recorded snapshot.

The templates constrain receiving behavior with concise, explicit rules:

- Do not expand into unrequested refactoring or adjacent improvements.
- Delegate only sizeable, genuinely independent work; do not delegate a few
  tool calls or use subagents merely to re-check the same work.
- Keep generated documents proportional to the task; do not add filler,
  duplicate summaries, or boilerplate.

These are receiving-session constraints, not instructions for the generator to
perform extra work.

## Type-specific design

### Execution handoff

Add a one-line background statement and mandatory git snapshot re-check. Keep
the existing instruction that approved design and planning must not be
re-litigated. Carry plan-level commands, commit/version ordering, rejected
alternatives, and explicit exclusions. If the plan is silent where two choices
would materially change scope, the receiver reports the ambiguity rather than
silently widening the task.

### Midwork handoff

Add background and mandatory git snapshot re-check. The remaining-work section
lists every known remaining task, ordered with the next task first. Preserve the
three mandatory status fields and add a statement that test and working-tree
results are generation-time snapshots; the first action re-runs the stated test
command. Refer to document task or section names rather than line numbers, which
can drift between sessions.

### Research handoff

Add git snapshot re-check when git metadata is available. Split research scope
into inspected and intentionally uninspected areas so the fact list is not
mistaken for exhaustive coverage. Source code facts by path plus symbol name
rather than unstable line number where possible. A conversation-only agreement
is labeled unverified and must be checked against code or existing design
documents before artifacts depend on it. Explicitly prohibit implementation or
refactoring until the user approves a resolved direction.

## Evaluation changes

Update the deterministic grader and fixtures so the universal line-budget check
accepts 15–45 lines and accepts 46–55 lines only for a recognizable research
handoff. Existing checks for self-containment, a concrete first action, and
reference integrity remain.

Extend the semantic rubric to check:

- background or intended outcome is present where the template requires it;
- recorded git/test state is explicitly treated as a snapshot and rechecked;
- midwork includes all remaining work provided by the source context;
- research distinguishes inspected from uninspected scope and labels the
  verification level of facts;
- scope, delegation, and document-length guards are present;
- no generic verifier-agent loop or fabricated fact was introduced.

Add or update fixtures to cover the normal 45-line ceiling and the conditional
research ceiling. Keep trigger evaluation unchanged because the activation
surface does not change.

## Repository and release changes

Modify the handoff skill, its three reference templates, handoff graders,
fixtures, and evaluation documentation. Update the user-facing README only
where its handoff behavior or length contract is described.

Because files under `plugins/` change, release this as patch version `0.1.2`:

- set `plugins/knack/.claude-plugin/plugin.json` to `0.1.2`;
- set `.claude-plugin/marketplace.json` to `0.1.2`;
- add a `0.1.2` entry to `CHANGELOG.md`.

The implementation must pass `./scripts/lint-plugin.sh` and the handoff grader
self-tests. No unrelated skill, hook, packaging, or cross-platform clipboard
work is in scope.
