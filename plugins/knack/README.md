# knack 플러그인 — 스킬 인덱스

이 플러그인이 제공하는 스킬 목록. 설치·업데이트 등 마켓플레이스 관련 안내는
[레포 루트 README](../../README.md) 참조.

## 제공 스킬

| 호출 명령 | 설명 | 문서 |
|-----------|------|------|
| `/knack:handoff` | 세션 종료 시 다음 세션용 제로 재설명 handoff prompt 생성 (검증 + 클립보드 복사) | [SKILL.md](./skills/handoff/SKILL.md) |
| `/knack:retune` | 독자 맞춤 문서 윤문 — 대상 독자 눈높이로 재작성 | [SKILL.md](./skills/retune/SKILL.md) |

플러그인 단일 버전은 [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json) 참조.

## 디렉토리 구조

```
plugins/knack/
├── .claude-plugin/
│   └── plugin.json          # 버전 관리 — auto-update 트리거
├── skills/
│   ├── handoff/
│   │   ├── SKILL.md
│   │   └── references/      # execution / midwork / research 템플릿
│   └── retune/
│       └── SKILL.md
└── README.md                # 이 파일 (인덱스)
```

각 스킬 디렉토리의 `SKILL.md`는 Claude 에이전트가 따르는 워크플로우 정의다.
