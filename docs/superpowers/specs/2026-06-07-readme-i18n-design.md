# README 영/한 분리 설계

날짜: 2026-06-07
상태: 사용자 승인 완료
선행 작업: [소셜 프리뷰 썸네일](./2026-06-07-social-preview-design.md) 후속 작업 1번

## 목표

루트 README를 영문 메인(README.md) + 한글(README.ko.md)로 분리한다.
각 문서는 해당 언어 단독 표기 — 혼용(한글 문서에 영문 병기 등)은 기각됨.

## 문서 구조 (3개 파일)

| 파일 | 언어 | 내용 |
|------|------|------|
| `README.md` (루트) | 영문 | 현행 한글 README 71줄의 **전문 번역** (구조 1:1 대응) |
| `README.ko.md` (루트, 신규) | 한글 | 현행 한글 README 그대로 이동 + 전환 링크 헤더 추가 |
| `plugins/knack/README.md` | 영문 | 현행 한글 30줄을 영문으로 전환 (분리 없음, 단일 영문) |

영문 README는 재구성 없이 전문 번역으로 한다 — 두 문서가 1:1 대응이라
향후 동기화 관리가 쉽고, lint 검사도 대칭적으로 적용된다.

## 전환 링크 헤더

각 루트 문서 최상단(H1 바로 아래)에:

- `README.md`: `**English** | [한국어](./README.ko.md)`
- `README.ko.md`: `[English](./README.md) | **한국어**`

`plugins/knack/README.md`는 단일 영문이므로 전환 링크 없음.

## lint 확장

`scripts/lint-plugin.sh:16`의 하드코딩 루프에 `README.ko.md` 추가:

```bash
for README in README.md README.ko.md "$PLUGIN_DIR/README.md"; do
```

기존 양방향 grep 검사(① 모든 skills/ 디렉토리가 `/knack:<스킬명>`으로 등장,
② README의 `/knack:` 명령이 실제 디렉토리로 존재)를 그대로 재사용한다.
한글 문서의 스킬 표도 `/knack:` 문자열을 포함하므로 통과한다.

## 버전 범프

`plugins/knack/README.md` 변경이 포함되므로 **patch 범프** 대상 (CLAUDE.md 규칙):

- `plugins/knack/.claude-plugin/plugin.json` version 범프
- `.claude-plugin/marketplace.json` 동기화
- `CHANGELOG.md` 항목 추가
- squash 머지 직전 마지막 커밋에 1회만 포함

루트 README.md / README.ko.md / scripts/는 plugins/ 밖이지만,
같은 커밋에 plugins/ 변경이 섞이므로 범프 규칙이 발동한다.

## 작업 흐름

`feature/readme-i18n` 브랜치 → 구현 → `./scripts/lint-plugin.sh` 통과 확인
→ 버전 범프 커밋 → main으로 squash merge

## 링크 검증

- 루트 README의 `[SKILL.md](./plugins/knack/skills/...)` 상대 링크는 번역 후에도 경로 불변
- `README.ko.md`도 루트 위치라 현행 상대 링크 그대로 유효

## 기각된 대안

- 영문 README 재구성 (영문 독자용 구조 변경) — 한/영 구조가 어긋나 동기화 비용 증가
- README.ko.md를 lint 검사에서 제외 — 한글 표 드리프트를 못 잡음
- plugins/knack/README.md 한글 유지 — 루트(영문)↔플러그인(한글) 언어 불일치
- plugins/knack/README.md 영/한 분리 — 30줄 인덱스 문서에 과한 구조
