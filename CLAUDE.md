# knack 레포 작업 규칙

## 버전 범프 규칙 (가장 중요)

`plugins/` 아래 파일을 변경하는 모든 커밋은 **반드시** 아래 3개를 함께 포함한다:

1. `plugins/knack/.claude-plugin/plugin.json`의 `version` 범프 (semver)
2. `.claude-plugin/marketplace.json`의 `plugins[0].version`을 같은 값으로 동기화
3. `CHANGELOG.md`에 해당 버전 항목 추가

**이유**: Claude Code auto-update는 `plugin.json`의 `version` 변경으로만 트리거된다.
범프 없는 push는 설치본에 조용히 무시된다 (footgun).

범프 기준: 스킬 추가/제거 = minor, 스킬 수정·버그 수정 = patch,
호환성 깨지는 구조 변경 = major.

스킬 디렉토리 이름은 **소문자 + 하이픈만** 사용한다 (언더스코어 금지 —
lint의 README 싱크 검사가 `[a-z0-9-]` 패턴만 인식).

## 커밋 전 검증

```bash
./scripts/lint-plugin.sh
```

통과 필수. pre-commit hook이 자동 실행하며, **main 브랜치에서는** "plugins/
변경인데 버전 미변경"인 커밋을 추가로 거부한다 (feature 브랜치 중간 커밋은
lint만 — 범프는 squash 머지 직전 1회). clone 후 1회 수동 설치:

```bash
ln -sf ../../scripts/pre-commit .git/hooks/pre-commit
```

## 브랜치 정책

- **main + feature/** — develop 없음. main이 배포 브랜치 (auto-update 대상).
- 작업은 `feature/<이름>` 브랜치에서, 완료 시 main으로 **squash merge**.
- 버전 범프 + CHANGELOG는 squash 전 **마지막 커밋에 1회**만 포함
  (feature 브랜치 중간 커밋마다 범프하지 않는다).
- 릴리스 게이트는 버전 범프 그 자체 — 범프 없는 머지는 배포되지 않는다.

## 롤백 절차

배포된 버전에 문제가 있으면:

1. `git revert`로 문제 커밋을 되돌린다 (force push 금지)
2. 패치 버전 범프 (plugin.json + marketplace.json + CHANGELOG)
3. main에 push → auto-update가 다음 세션에 롤백 버전을 배포

## 개발본/설치본 분리

개발은 이 로컬 clone에서, 사용은 마켓플레이스 설치본(`~/.claude/plugins/cache/...`)에서.
스킬 수정은 항상 **로컬 clone 커밋 → push → auto-update** 단방향 흐름만 사용한다.
설치본 캐시를 직접 수정하지 않는다 (업데이트 시 덮어써짐).
