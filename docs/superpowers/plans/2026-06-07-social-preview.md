# knack GitHub 소셜 프리뷰 썸네일 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 디자인 스펙(docs/superpowers/specs/2026-06-07-social-preview-design.md)대로 1280×640 소셜 프리뷰 PNG를 생성해 레포에 커밋한다.

**Architecture:** standalone HTML 1장(`assets/social-preview.html`)을 headless Chrome으로 1280×640 스크린샷 → `assets/social-preview.png`. 폰트는 Google Fonts에서 렌더 시 로드. 검증은 sips(크기)와 이미지 육안 확인(원본 + 400px 축소판).

**Tech Stack:** HTML/CSS, headless Google Chrome (확인됨: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`), sips (macOS 내장, 확인됨)

**전제:** 브랜치 `feature/social-preview`에서 작업 (이미 체크아웃됨). `plugins/` 미변경이므로 버전 범프 불필요 — pre-commit lint만 통과하면 된다.

---

### Task 1: standalone HTML 작성

**Files:**
- Create: `assets/social-preview.html`

- [ ] **Step 1: HTML 파일 작성**

아래 내용 그대로 생성. 디자인 스펙의 모든 수치(레이아웃 36%/4.5%/4%, translateY(-28px), 폰트·색상값)가 반영된 최종본이다.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="utf-8">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Caveat:wght@700&family=Nanum+Pen+Script&family=JetBrains+Mono:wght@400;700&display=swap">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 1280px; height: 640px; overflow: hidden; }
  .render {
    width: 1280px; height: 640px;
    background: #f5f0e4;
    display: flex; align-items: center;
    padding: 0 4.5%; gap: 4%;
  }
  .left {
    flex: 0 0 36%; display: flex; flex-direction: column;
    transform: translateY(-28px);
  }
  .right { flex: 1; }
  .wordmark {
    font-family: 'Caveat', cursive; font-size: 150px; font-weight: 700;
    color: #2b2620; transform: rotate(-2deg);
    -webkit-text-stroke: 2px #2b2620;
  }
  .sub {
    font-family: 'Nanum Pen Script', cursive; font-size: 60px;
    color: #2f2922; margin-top: 14px; line-height: 1.45;
    transform: rotate(-1deg);
    -webkit-text-stroke: 1.4px #2f2922;
  }
  .term {
    background: #161b22; border: 2px solid #30363d; border-radius: 16px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 24px; line-height: 1.7; color: #e6edf3;
    box-shadow: 0 10px 36px rgba(43,38,32,0.22);
  }
  .term-bar {
    background: #21262d; padding: 12px 22px; display: flex; gap: 12px;
    border-radius: 14px 14px 0 0;
  }
  .dot { width: 20px; height: 20px; border-radius: 50%; background: #30363d; }
  .term-body { padding: 26px 32px; }
  .cmd { color: #7ee787; font-weight: 700; }
  .quote { color: #9aa4b2; }
  .gap { margin-top: 14px; }
</style>
</head>
<body>
<div class="render">
  <div class="left">
    <div class="wordmark">Knack</div>
    <div class="sub">말로 하기 어려운<br>나만의 요령들</div>
  </div>
  <div class="right">
    <div class="term">
      <div class="term-bar"><div class="dot"></div><div class="dot"></div><div class="dot"></div></div>
      <div class="term-body">
        <div><span class="cmd">&gt; /knack:handoff</span></div>
        <div class="quote">붙여넣기 한 번, 새 세션에서 하던 작업 그대로</div>
        <div class="gap"><span class="cmd">&gt; /knack:retune</span></div>
        <div class="quote">이 내용을 PM이 이해하기 쉽게</div>
      </div>
    </div>
  </div>
</div>
</body>
</html>
```

- [ ] **Step 2: 커밋**

```bash
git add assets/social-preview.html
git commit -m "feat: 소셜 프리뷰 썸네일 소스 HTML"
```

Expected: pre-commit lint `ALL CHECKS PASSED` 후 커밋 성공.

---

### Task 2: PNG 렌더 + 크기 검증

**Files:**
- Create: `assets/social-preview.png` (생성물)

- [ ] **Step 1: headless Chrome으로 스크린샷**

```bash
cd /Users/yehyeok/Desktop/work/knack && "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 \
  --window-size=1280,640 \
  --virtual-time-budget=10000 \
  --screenshot=assets/social-preview.png \
  "file:///Users/yehyeok/Desktop/work/knack/assets/social-preview.html"
```

`--virtual-time-budget=10000`은 Google Fonts 로드 완료를 기다리기 위한 것.
Expected: `assets/social-preview.png` 생성. stderr에 "Written to file" 류 메시지.

- [ ] **Step 2: 크기 검증**

```bash
sips -g pixelWidth -g pixelHeight assets/social-preview.png
```

Expected:
```
  pixelWidth: 1280
  pixelHeight: 640
```

- [ ] **Step 3: 육안 검증 (Read 도구로 PNG 열기)**

`assets/social-preview.png`를 Read 도구로 열어 체크리스트 확인:
- [ ] 워드마크 "Knack"가 손글씨(Caveat)로 렌더됨 — 기본 폰트(serif/sans) 대체가 아님
- [ ] 한글 서브카피가 나눔펜스크립트로 렌더됨 — 고딕 대체가 아님
- [ ] 터미널 두 줄 모두 줄바꿈 없이 한 줄씩
- [ ] 좌측 블록과 터미널의 수직 중심이 맞음
- [ ] 배경 크림(#f5f0e4), 터미널 다크

폰트가 대체 글꼴로 보이면: `--virtual-time-budget`을 20000으로 올려 Step 1 재실행 (네트워크 폰트 로드 미완료가 원인).

---

### Task 3: 400px 축소 가독성 검증

**Files:**
- 임시 파일만 생성 (`/tmp/social-preview-400.png`) — 커밋하지 않음

- [ ] **Step 1: 400px 축소판 생성**

```bash
sips -Z 400 assets/social-preview.png --out /tmp/social-preview-400.png
```

Expected: `/tmp/social-preview-400.png` (400×200) 생성.

- [ ] **Step 2: 육안 검증 (Read 도구로 열기)**

`/tmp/social-preview-400.png`를 Read 도구로 열어 확인:
- [ ] "Knack" 워드마크 식별 가능
- [ ] 터미널 명령어 `/knack:handoff`, `/knack:retune` 읽힘
- [ ] handoff 설명 줄("붙여넣기 한 번, …")이 한 줄 유지

실패 시(글자 뭉개짐·줄바꿈): 스펙의 축소 검증 기준 위반 — 사용자에게 보고하고 폰트 크기/칼럼 비율 조정 논의 (임의 변경 금지, 디자인 확정값이므로).

---

### Task 4: PNG 커밋 + 마무리

- [ ] **Step 1: PNG 커밋**

```bash
git add assets/social-preview.png
git commit -m "feat: 소셜 프리뷰 썸네일 PNG (1280×640)"
```

Expected: pre-commit lint 통과 후 커밋 성공.

- [ ] **Step 2: 작업 완료 보고**

사용자에게 보고할 잔여 수동 단계 (git으로 불가능):
1. main으로 squash merge (finishing-a-development-branch 흐름)
2. GitHub repo Settings > Social preview에 `assets/social-preview.png` 업로드
3. 후속 작업: README 영/한 분리 (스펙의 후속 작업 1번)
