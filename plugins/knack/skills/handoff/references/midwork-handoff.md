# Midwork Handoff Template

Use when implementation is partially done — some tasks committed, more remain.
The strongest signal to encode: **exact done/remaining boundary + current
working-tree state**.

## Template

```markdown
<작업 한 줄 요약> 작업을 이어서 진행해줘.

## 컨텍스트
- 작업 디렉토리: <절대 경로> (브랜치 <branch>, HEAD <hash>)
- 배경: <이 작업이 왜 필요한지 + 완료되면 무엇이 가능해지는지 한 줄>
- 시작 전 git status와 현재 브랜치를 확인하고, 위 브랜치/HEAD와 다르면 작업 전에 사용자에게 보고할 것
- 관련 문서: <검증된 스펙/계획 경로 + 커밋 해시. 없으면 이 줄 생략>

## 완료된 것
- <태스크/단계 이름> (커밋 <hash>)
- <태스크/단계 이름> (커밋 <hash>)

## 남은 것
- [ ] <다음 태스크 — 가장 먼저 할 것>
- [ ] <그 다음 태스크>
- [ ] <남은 태스크 전부 — 마지막 항목까지>

## 현재 상태
- 테스트: <통과/실패/미실행 — 실행 명령 포함>
- 워킹트리: <클린 / 더티 파일 목록과 그 이유>
- 알려진 깨짐/이슈: <있으면 명시, 없으면 "없음">
- 위 결과는 handoff 작성 시점 스냅샷 — 첫 액션 전에 테스트 명령을 재실행해 갱신할 것

## 주의
- <함정, 시도했다 실패한 접근("X 방식은 Y 때문에 실패 — 재시도 금지"), 제약>
- 남은 것 목록 밖의 리팩터링·범위 확장 금지. 작업 중 눈에 띈 개선점은 고치지 말고 보고할 것.
- 위임은 여러 파일에 걸친 독립·병렬 작업에만. 자기 작업 재확인 목적 서브에이전트 금지.
- 문서·리포트는 필요한 분량만. 채우기용 섹션·중복 요약 금지.

첫 액션: <남은 것 첫 항목의 구체적 시작 지점 — 예: Task 5부터, 계획 문서 해당 태스크 섹션 참조>
```

## Writing guidance

- 완료된 것 lists each finished unit WITH its commit hash (verified in Step 3)
  so the next session can diff/inspect instead of trusting prose.
- 배경 states WHY the work exists so the receiver can make bounded judgment
  calls without inventing intent.
- The git re-verification and snapshot lines are mandatory for git-backed
  handoffs. Branch, HEAD, and test results can be stale next session.
- Point into documents by task or section name, not line number; lines drift.
- 현재 상태 is mandatory all three bullets. "테스트 미실행" is a valid and
  useful answer; omitting the line is not.
- If the working tree is dirty (user chose to hand off anyway), list every
  dirty file and why it is uncommitted.
- Failed attempts go in 주의 with the failure reason — the next session must
  not burn time rediscovering dead ends.
- 남은 것 lists EVERY remaining task, not only the next one.
- The scope, delegation, and document-length guards are mandatory.
