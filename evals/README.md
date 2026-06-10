# evals/ — knack 스킬 평가

knack 스킬(`handoff`, `retune`)의 **행동 품질**을 측정·회귀 방지하는 평가 자산.
구조적 검증(`scripts/lint-plugin.sh`)이 못 잡는 영역 — 트리거 신뢰도, 출력 품질,
모델 간 일관성 — 을 다룬다.

설계 근거 문서: `../../ai_analyze/knack-skill-evaluation-framework.md`,
`../../ai_analyze/knack-eval-implementation-plan.md` (레포 외부, 따라야 할 기준).

## 레이어

| 레이어 | 무엇 | 모델 필요? | 상태 |
|---|---|---|---|
| **Task 1 — 결정론 그레이더** | 출력 텍스트의 불변식을 코드로 검증 | ❌ | ✅ 구현됨 |
| **Task 2 — 크로스모델 하네스** | 모델별로 출력 생성 → 그레이더+LLM-judge | ✅ | ⏳ 예정 |

핵심 분리: **그레이더 = 텍스트→합/불 순수 함수** (모델 무관, 지금 자가검증 가능).
**하네스 = 모델로 출력을 만들어 그레이더에 먹임** (Task 2, promptfoo).

## 디렉토리

```
graders/
  handoff-checks.sh    # 결정론 그레이더 (self-contained / 첫 액션 / 15-40줄 / 참조 무결성)
  rubric-handoff.md    # LLM-judge 루브릭 (템플릿 타입·완결성 — Task 2)
  rubric-retune.md     # LLM-judge 루브릭 (의미 보존·독자 이해 — Task 2)
fixtures/handoff/      # 그레이더 자가검증용 good/bad 샘플 (good 1 + bad 4, 각 1체크 격리)
cases/
  handoff/trigger.jsonl    # should-trigger / no-trigger(near-miss) — precision/recall (Task 2)
  handoff/golden/*.json    # midwork·execution·research 기대동작 루브릭
  retune/trigger.jsonl
  retune/golden/*.json     # PM·비개발자·경영진 독자별
run-graders.sh         # 그레이더 자가검증 (lint가 호출하는 회귀 게이트)
```

## 실행

```bash
# 그레이더 자가검증 (good는 PASS, bad는 FAIL이어야 함)
bash evals/run-graders.sh

# 단일 handoff 출력 채점
bash evals/graders/handoff-checks.sh <handoff.txt> --root <repo-root>

# 전체 lint (구조 + 그레이더 자가검증)
./scripts/lint-plugin.sh
```

## 그레이더가 검증하는 것 (handoff, 결정론)

| 체크 | 규칙 | 근거 (SKILL.md) |
|---|---|---|
| self-contained | 이전 대화 참조 표현 부재 | 원칙 #1 |
| 첫 액션 | `첫 액션:` 줄 존재 + `이어서 해줘` 부재 | 원칙 #3 |
| 길이 | 15–40줄 | 원칙 #4 |
| 참조 무결성 | 모든 파일 경로 `test -e`, 커밋 해시 `git cat-file` 통과 | 원칙 #2 / Step 3 |

bad fixture는 **각각 하나의 체크만 실패**하도록 설계되어, 자가검증 green은 모든 체크가
(나쁜 케이스를 잡고) + (좋은 케이스를 통과시킨다)를 동시에 증명한다.

## Task 2 — 크로스모델 트리거 평가 (✅ 구현됨)

`trigger_eval.py` — `claude -p`를 **격리 실행**해(아래) 모델별 트리거
precision/recall/accuracy를 측정. 결정론적 탐지(stream-json의 `Skill` tool 호출
파싱)라 LLM-judge 불필요.

```bash
# 바닥 모델 게이트 (handoff + retune)
python3 evals/trigger_eval.py --models haiku --gate

# 풀 래더
python3 evals/trigger_eval.py --models haiku,sonnet,opus --repeat 3

# 빠른 검증 (스킬당 N케이스)
python3 evals/trigger_eval.py --models sonnet --limit 2
```

### 스파이크 결정 사항 (2026-06-10, claude 2.1.170)

- **헤드리스 auto-trigger 작동함** — 설계안의 claude-code #32184(recall=0%) 우려는
  현 버전에서 재현되지 않음. promptfoo 없이 `claude -p`로 직접 측정.
- **격리 필수**: `--setting-sources project`(user 스코프 플러그인 제외) +
  `--plugin-dir <knack>`(명시 주입). 미격리 시 설치된 **`zimssa:handoff`가
  `"핸드오프"` 트리거를 가로챔** → 이는 실사용 환경의 precision 리스크이기도 함.
- promptfoo 대신 자작 하네스 채택: 격리 플래그 완전 제어 + 의존성 0.

### 첫 실행 결과 + 진단 루프 (실전 기록)

| 스킬 | haiku (바닥=게이트) | sonnet |
|---|---|---|
| handoff | precision=1.00 recall=1.00 | recall=1.00 |
| retune  | precision=1.00 recall=1.00 | recall=1.00 |

retune은 **처음엔 haiku recall=0.00**으로 나왔다. eval-driven 진단 루프:

1. 1차 가설 — under-trigger, description이 약하다 → "pushier"하게 수정. **재검증: 효과 없음**
   (recall 여전히 0). 리서치의 "description 명시성↑ ≠ recall↑" 경고와 일치.
2. 트레이스 진단 — haiku는 문서 없는 `"이 문서 다듬어줘"`에 스킬 대신 **"문서를 주세요"**로
   인라인 응답. 문서를 **붙이면** haiku도 `knack:retune`을 정상 호출.
3. 진짜 원인 — **테스트 케이스가 비현실적**(문서 누락). 스킬/모델 결함이 아니었음.
4. 올바른 수정 — 배포 스킬은 **무변경**(description 되돌림), 트리거 케이스에 실제 문서 포함
   → haiku recall 0.00 → **1.00**.

**교훈**: 트리거 케이스는 실제 호출 맥락을 반영해야 한다. handoff는 첨부물 없이 세션/git을
읽으므로 문서 불필요, retune은 대상 문서가 입력의 일부 → 케이스에 문서 포함 필수.
잘못된 진단으로 배포 스킬을 바꾸지 않은 것(테스트를 고친 것)이 핵심.

### 운영 메모

- 트리거 평가는 **실제 API 호출**(케이스당 ~25s, 비용 발생)이라 빠른 pre-commit
  `lint-plugin.sh`에는 **넣지 않음**. 결정론 그레이더 자가검증만 lint 게이트.
- 트리거 평가는 **수동/CI 게이트** — 스킬 description 변경 시, 머지 전 실행.

### 남은 것 (출력 품질, 차기)

- golden 케이스(`cases/*/golden/`)를 LLM-judge 루브릭(`graders/rubric-*.md`)으로
  채점 — 강한 모델 고정 + 순서 랜덤화·길이 정규화.
