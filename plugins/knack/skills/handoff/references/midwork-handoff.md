# Midwork Handoff Template

Use when implementation is partially done — some tasks committed, more remain.
The strongest signal to encode: **exact done/remaining boundary + current
working-tree state**.

## Template

```markdown
<작업 한 줄 요약> 작업을 이어서 진행해줘.

## 컨텍스트
- 작업 디렉토리: <절대 경로> (브랜치 <branch>, HEAD <hash>)
- 관련 문서: <검증된 스펙/계획 경로 + 커밋 해시. 없으면 이 줄 생략>

## 완료된 것
- <태스크/단계 이름> (커밋 <hash>)
- <태스크/단계 이름> (커밋 <hash>)

## 남은 것
- [ ] <다음 태스크 — 가장 먼저 할 것>
- [ ] <그 다음 태스크>

## 현재 상태
- 테스트: <통과/실패/미실행 — 실행 명령 포함>
- 워킹트리: <클린 / 더티 파일 목록과 그 이유>
- 알려진 깨짐/이슈: <있으면 명시, 없으면 "없음">

## 주의
- <함정, 시도했다 실패한 접근("X 방식은 Y 때문에 실패 — 재시도 금지"), 제약>

첫 액션: <남은 것 첫 항목의 구체적 시작 지점 — 예: Task 5부터, 계획 문서 N행 참조>
```

## Writing guidance

- 완료된 것 lists each finished unit WITH its commit hash (verified in Step 3)
  so the next session can diff/inspect instead of trusting prose.
- 현재 상태 is mandatory all three bullets. "테스트 미실행" is a valid and
  useful answer; omitting the line is not.
- If the working tree is dirty (user chose to hand off anyway), list every
  dirty file and why it is uncommitted.
- Failed attempts go in 주의 with the failure reason — the next session must
  not burn time rediscovering dead ends.
