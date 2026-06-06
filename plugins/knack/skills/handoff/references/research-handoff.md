# Research Handoff Template

Use when the session was research/analysis/discussion and decisions are NOT
final. The strongest signal to encode: **facts vs open questions, strictly
separated, with sources**.

## Template

```markdown
<주제 한 줄 요약>에 대한 조사/논의를 이어서 진행해줘.

## 컨텍스트
- 작업 디렉토리: <절대 경로> (브랜치 <branch>, HEAD <hash>)
- 목표: <이 조사가 끝나면 무엇이 결정되어야 하는지 한 줄>

## 확정된 사실
- <사실> (출처: <파일 경로:라인 / 문서명 / 코드 직접 확인>)
- <사실> (출처: <...>)

## 미결 질문
- Q1: <질문> — 현재 유력안: <안 + 근거 한 줄>
- Q2: <질문> — 현재 유력안: <미정이면 "미정">

## 주의
- 추측 금지. 모든 새 주장은 출처(파일명·라인 또는 코드 직접 확인) 명시.
  근거가 없으면 "확인 필요"로 표시.
- <기각된 안 — 예: X안은 Y 근거로 기각됨, 재제안 금지>

첫 액션: <Q1 해소를 위한 구체적 첫 단계 — 예: X 파일 Read, Y 명령으로 확인>
```

## Writing guidance

- 확정된 사실 entries MUST carry a source. A "fact" without a source goes to
  미결 질문 instead — this separation is the core value of this type.
- Each open question carries the current leading answer (or "미정") so the
  next session starts from the frontier, not from zero.
- The 추측 금지 clause is mandatory boilerplate — keep it verbatim. It mirrors
  the user's recurring instruction for fact-based research delegation.
- If sub-agent delegation was the working style (collection by sub-agents,
  judgment in main session), say so in 주의.
