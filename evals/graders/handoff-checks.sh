#!/usr/bin/env bash
# Deterministic grader for handoff outputs — a pure function: text in, pass/fail out.
# No model calls. Encodes the four UNIVERSAL invariants every handoff template
# (execution / midwork / research) must satisfy, per skills/handoff/SKILL.md:
#   1. Self-contained   — no back-references to the prior chat (원칙 #1)
#   2. Concrete first action — a "첫 액션:" line, never a bare "이어서 해줘" (원칙 #3)
#   3. Length budget    — 15–45 lines; sourced research may use 46–55 (원칙 #4)
#   4. Reference integrity — every file path / commit hash resolves (원칙 #2 / Step 3)
#
# Type-specific checks (correct template chosen, dirty-tree guard, etc.) are left
# to the LLM-as-judge rubric in graders/rubric-handoff.md (Task 2).
#
# Usage: handoff-checks.sh <handoff-file> [--root <dir>]
#   --root  directory to resolve relative file paths / git hashes against (default: cwd)
# Exit 0 = all checks pass · 1 = any check fails.
set -uo pipefail

FILE=""
ROOT="."
while [ $# -gt 0 ]; do
  case "$1" in
    --root) ROOT="${2:-}"; shift 2 ;;
    *)      FILE="$1"; shift ;;
  esac
done

[ -n "$FILE" ] && [ -f "$FILE" ] || { echo "✘ file not found: ${FILE:-<none>}"; exit 1; }

FAIL=0
err() { echo "  ✘ $1"; FAIL=1; }
ok()  { echo "  ✓ $1"; }

TEXT="$(cat "$FILE")"
NLINES=$(printf '%s\n' "$TEXT" | grep -c '')

echo "== handoff-checks: $FILE =="

# --- Check 1: self-contained (no reference to the current/prior conversation) ---
BACKREF='위에서 말한|위에서 언급|위에 말한|앞에서 말한|아까 논의|아까 그|아까 말한|앞서 논의|앞서 말한|방금 말한|위 대화|이전 대화에서|위 내용대로'
if printf '%s' "$TEXT" | grep -qE "$BACKREF"; then
  HIT=$(printf '%s' "$TEXT" | grep -oE "$BACKREF" | sort -u | paste -sd, -)
  err "self-contained 위반: 이전 대화 참조 표현 ($HIT)"
else
  ok "self-contained (이전 대화 참조 없음)"
fi

# --- Check 2: concrete first action ---
if printf '%s' "$TEXT" | grep -qE '이어서 해줘|이어서 해주세요|알아서 해줘|알아서 진행'; then
  err "첫 액션 모호: '이어서 해줘' 류 금지 표현"
elif printf '%s' "$TEXT" | grep -qE '^첫 액션[:：]'; then
  ok "구체적 첫 액션 줄 존재"
else
  err "첫 액션 줄 없음 ('첫 액션:' 으로 시작하는 줄 필요)"
fi

# --- Check 3: length budget (normal 15-45; conversation-sourced research 46-55) ---
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

# --- Check 4: reference integrity (paths + commit hashes) ---
# Paths: tokens with a '/' and a file extension (optional leading slash for absolute).
# A bare working-dir path with no extension is intentionally NOT checked.
PATHS=$(printf '%s' "$TEXT" | grep -oE '/?[A-Za-z0-9_.-]+/[A-Za-z0-9_./-]+\.[A-Za-z]{1,6}' | sort -u)
# Hashes: hex following "HEAD " or "커밋 " only — avoids matching arbitrary hex.
HASHES=$(printf '%s' "$TEXT" | grep -oE '(HEAD|커밋)[[:space:]]+[0-9a-f]{7,40}' | grep -oE '[0-9a-f]{7,40}' | sort -u)
REF_FAIL=0
if [ -n "$PATHS" ]; then
  while IFS= read -r p; do
    [ -z "$p" ] && continue
    if [ -e "$p" ] || [ -e "$ROOT/$p" ]; then :; else err "죽은 경로 참조: $p"; REF_FAIL=1; fi
  done <<< "$PATHS"
fi
if [ -n "$HASHES" ]; then
  while IFS= read -r h; do
    [ -z "$h" ] && continue
    if git -C "$ROOT" cat-file -t "$h" >/dev/null 2>&1; then :; else err "유효하지 않은 커밋 해시: $h"; REF_FAIL=1; fi
  done <<< "$HASHES"
fi
[ "$REF_FAIL" -eq 0 ] && ok "참조 무결성 (경로/해시 검증 통과)"

if [ "$FAIL" -eq 0 ]; then echo "  → PASS"; else echo "  → FAIL"; fi
exit $FAIL
