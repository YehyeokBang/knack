# Changelog

knack 플러그인의 버전별 변경 이력. 형식: [Keep a Changelog](https://keepachangelog.com/ko/1.1.0/), 버전: semver.

## [Unreleased]

### 도그푸딩 측정 메모

- /handoff: 실사용 시 새 세션 재질문 횟수 기록 (목표: 5회 중 4회 이상 0회)
  - (기록 예시) 2026-06-XX: 재질문 N회 — 원인:
- /retune: 실제 독자 전달 후 되묻기 횟수 기록 (목표: 5회 중 4회 이상 0건)
  - (기록 예시) 2026-06-XX: 독자 PM — 되묻기 N건:
- auto-update 실측: ① 패치 버전 push ② 새 세션 ③ `/plugin`으로 버전 확인 — 2회.
  2회 연속 불일치 시 v0.1.1에 업데이트 알림 훅 추가.

## [0.1.2] - 2026-08-02

### Changed

- /handoff: 최신 Claude 5 수신 세션에 맞춰 작업 배경, git·테스트 상태 재확인,
  전체 잔여 작업과 조사 범위, 범위 확장·과도한 위임·문서 팽창 방지 규칙 추가.
- handoff 길이 예산을 일반 15–45줄로 조정하고, 대화에만 출처가 있는 research는
  최대 55줄까지 허용. 결정론 fixture와 LLM-judge 루브릭을 새 계약에 맞게 강화.

## [0.1.1] - 2026-06-07

### Changed

- README 영/한 분리: 루트 README.md를 영문 메인으로 전환, 한글은 README.ko.md로
  이동 (상단 English | 한국어 전환 링크). plugins/knack/README.md 영문화.
- lint-plugin.sh: README 싱크 검사 대상에 README.ko.md 추가.

## [0.1.0] - 2026-06-07

### Added

- handoff 스킬: 세션 종료 시 다음 세션용 자기완결 handoff prompt 생성.
  zimssa-claude-plugins의 handoff(0.10.0)에서 포팅 — 회사 고유 맥락(업그레이드
  알림 섹션) 제거, 한국어 강제 → 세션 언어 따름, 비-git 디렉토리 graceful 생략 추가.
  세션 상태 3유형(실행/진행 중/조사·논의) 분류, 참조 실존 검증, 더티 워킹트리 가드,
  코드블록 출력 + pbcopy 병행 유지.
- retune 스킬 신규: 독자 맞춤 문서 윤문. 대상 독자(PM/비개발자/타 직군) 지정 시
  그 눈높이로 재작성. 교정 대상 4종(의미 없는 넘버링, 애매한 영어 줄임말,
  번역투/어색한 한글 문법, 독자가 모르는 전문용어) — 각 before/after 예시 내장.
- 레포 골격: 마켓플레이스 카탈로그, lint-plugin.sh(버전 동기화·README 싱크·500줄),
  pre-commit hook(plugins/ 변경 시 버전 미변경 커밋 거부), CLAUDE.md(범프 규칙·
  롤백 절차·브랜치 정책).
