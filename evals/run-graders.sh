#!/usr/bin/env bash
# Self-test for the deterministic graders — the regression gate lint-plugin.sh calls.
# Asserts that good fixtures PASS and bad fixtures FAIL. NO model calls, so it is
# fast and deterministic; safe to run on every commit.
#
# Each bad fixture isolates ONE failing check, so a green run proves every check
# both fires (catches its bad case) and does not over-fire (passes the good case).
set -uo pipefail
cd "$(dirname "$0")"                 # evals/
ROOT="$(cd .. && pwd)"               # repo root — resolves the fixtures' internal refs
GRADER="graders/handoff-checks.sh"
FAIL=0

assert_pass() {
  if bash "$GRADER" "$1" --root "$ROOT" >/dev/null 2>&1; then
    echo "✓ PASS as expected: $1"
  else
    echo "✘ expected PASS but got FAIL: $1"; bash "$GRADER" "$1" --root "$ROOT"; FAIL=1
  fi
}
assert_fail() {
  if bash "$GRADER" "$1" --root "$ROOT" >/dev/null 2>&1; then
    echo "✘ expected FAIL but got PASS: $1"; FAIL=1
  else
    echo "✓ FAIL as expected: $1"
  fi
}

echo "== handoff grader self-test =="
assert_pass "fixtures/handoff/good-midwork.txt"
assert_pass "fixtures/handoff/good-research-extended.txt"
assert_fail "fixtures/handoff/bad-nonresearch-extended.txt"
assert_fail "fixtures/handoff/bad-dangling-ref.txt"
assert_fail "fixtures/handoff/bad-not-selfcontained.txt"
assert_fail "fixtures/handoff/bad-no-first-action.txt"
assert_fail "fixtures/handoff/bad-too-short.txt"

echo
if [ "$FAIL" -eq 0 ]; then echo "GRADER SELF-TEST PASSED"; else echo "GRADER SELF-TEST FAILED"; exit 1; fi
