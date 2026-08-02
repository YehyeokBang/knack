# Execution Handoff Template

Use when spec/plan are approved and committed, and the next session's job is
pure execution. The strongest signal to encode: **re-discussion is forbidden**.

## Template

```markdown
<작업 한 줄 요약>을 실행해줘.

## 컨텍스트
- 작업 디렉토리: <절대 경로> (브랜치 <branch>, HEAD <hash>)
- 배경: <이 작업이 왜 필요한지 + 완료되면 무엇이 가능해지는지 한 줄>
- 시작 전 git status와 현재 브랜치를 확인하고, 위 브랜치/HEAD와 다르면 작업 전에 사용자에게 보고할 것
- 워킹트리: <더티 파일 목록과 미커밋 이유 — 클린이면 이 줄 생략>
- 브레인스토밍/설계/계획은 이전 세션에서 완료·승인됨. 다시 논의하지 말고 바로 실행 단계로.
- 스펙: <검증된 경로> (커밋 <hash>)
- 구현 계획: <검증된 경로> (커밋 <hash>) → <N>개 태스크, 체크박스 단위. 이 계획을 그대로 따를 것.

## 실행 방법
<실행 스킬/방식 — 예: superpowers:subagent-driven-development 스킬로 태스크별
서브에이전트 디스패치 + 태스크 간 리뷰. 소형 태스크는 인라인 처리 가능>
- 위임은 여러 파일에 걸친 독립·병렬 태스크에만. 툴 호출 몇 번으로 끝낼 일은 직접 처리하고,
  자기 작업 재확인 목적으로는 서브에이전트를 쓰지 말 것. 한 에이전트로 끝나면 하나만 띄운다.

## 핵심 원칙
- <계획에 명시된 검증 명령 — 예: ./scripts/lint-plugin.sh 통과 필수>
- <커밋 규칙 — 예: 태스크마다 계획에 적힌 커밋 메시지로 커밋>
- <버전/순서 제약 — 예: 버전 bump는 Task N에서만>
- 문서·리포트는 필요한 분량만. 채우기용 섹션·중복 요약·보일러플레이트 금지.

## 주의
- <함정 + fallback — 예: X 실패 시 계획 Task N-M의 fallback 적용>
- 계획에 없는 리팩터링·범위 확장 금지. <추가 범위 제외 항목 — 예: Y는 명시적으로 범위 제외됨>
  계획이 침묵하는 지점에서 판단이 갈리면 임의 확장 대신 사용자에게 보고할 것.
- <기각된 대안 — 예: Z 방식은 검토 후 기각됨, 재제안 금지>

첫 액션: <스펙·계획 문서 Read 후 Task 1부터 순서대로 진행>
```

## Writing guidance

- The "다시 논의하지 말고 바로 실행" line is mandatory — it is the whole point
  of this type. Without it the next session re-opens settled decisions.
- 배경 states WHY the work exists, not what it is. It guides judgment when the
  plan is silent without inviting the receiver to redesign the task.
- The git re-verification line is mandatory for git-backed handoffs. Recorded
  branch and HEAD are generation-time snapshots and can be stale next session.
- 핵심 원칙 carries plan-level constraints the executor must not violate
  (verification commands, commit rules, ordering). Pull them from the plan
  document, not from memory.
- 주의 must include rejected alternatives with "재제안 금지" so the next
  session does not waste turns re-proposing them.
- The delegation bound, document-length line, and scope-limit line are mandatory.
- 첫 액션 names the exact documents to Read and the exact first task.
