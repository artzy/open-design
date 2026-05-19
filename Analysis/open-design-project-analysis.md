# Open Design 프로젝트 분석

**분석 일자:** 2026-05-18  
**저장소 루트:** `open-design` (Apache-2.0)

---

## 1. 한줄 요약

**Open Design(OD)**은 Claude Design과 유사한 **에이전트 네이티브 디자인 제품**의 오픈소스 대안이다. 사용자 머신에 설치된 **코딩 에이전트 CLI**(Claude Code, Codex, Cursor 등)를 감지·실행하고, **스킬(Skill)**과 **디자인 시스템**을 조합해 브리프에서 아티팩트(HTML 덱·프로토타입 등)까지 이어지는 워크플로를 **로컬 우선**으로 제공한다. 웹은 Next.js, 권한·프로세스·파일 시스템은 **로컬 데몬**이 담당하는 구조다.

---

## 2. 제품 목적과 차별점

- **목적:** LLM이 “글”이 아니라 **디자인 산출물**을 만들도록 안내하는 루프(발견 폼, 방향 선택, TodoWrite, 샌드박스 미리보기, 내보내기).
- **차별:** 자체 모델을 내장하지 않고 **기존 CLI + BYOK**에 연동; 클로즈드/클라우드 전용 모델에 묶이지 않도록 설계.
- **참고 철학·자산:** README에 명시된 바와 같이 huashu-design, guizang-ppt-skill, open-codesign, multica 등 오픈소스 위에 서 있으며, 프롬프트·스킬·아키텍처가 이를 반영한다.

---

## 3. 기술 스택

| 영역 | 선택 |
|------|------|
| 런타임 | Node **~24**, **pnpm 10.33.2** (Corepack 고정) |
| 언어 | **TypeScript 우선** (가드·스크립트로 JS 잔존 제한) |
| 웹 | **Next.js 16** (App Router), **React 18** |
| 데몬 | **Express**, **better-sqlite3**, 에이전트 스폰·REST/SSE |
| 데스크톱 | **Electron** (`apps/desktop`, `apps/packaged`) |
| 계약/IPC | `packages/contracts`, `sidecar-proto`, `sidecar`, `platform` |
| E2E | `e2e` 패키지 (Vitest·Playwright 등, 상세는 `e2e/AGENTS.md`) |

루트 `package.json`의 `bin`은 `./apps/daemon/dist/cli.js`로 **`od` CLI** 진입점을 노출한다.

---

## 4. 워크스페이스 구조 (`pnpm-workspace.yaml`)

```
packages/*   — 공유 라이브러리·프로토콜
apps/*       — web, daemon, desktop, packaged, landing-page, telemetry-worker
tools/*      — dev(로컬 라이프사이클), pack(패키징), pr(PR duty)
e2e          — 엔드투엔드·UI 자동화
```

**루트 외 주요 콘텐츠 디렉터리**(AGENTS.md 기준):

- `skills/` — 에이전트가 호출하는 기능 스킬
- `design-templates/` — 덱·프로토타입·미디어 템플릿 카탈로그
- `design-systems/` — 브랜드 `DESIGN.md` 등
- `craft/` — 스킬이 옵트인하는 보편 크래프트 규칙

---

## 5. 핵심 앱 역할

| 패키지 | 역할 |
|--------|------|
| **apps/web** | 채팅·아티팩트 트리·iframe 미리보기 등 UI. 로컬에서 `/api/*` 등을 데몬으로 프록시 |
| **apps/daemon** | `/api/*`, 에이전트 실행, 스킬/디자인 시스템, SQLite 영속화, 정적 서빙; `.od/` 데이터 소유 |
| **apps/desktop** | Electron 셸; 웹 URL은 **사이드카 IPC**로 조회 (포트 추측 없음) |
| **apps/packaged** | 패키징된 런타임 진입; `od://` 등 글루 |
| **tools/dev** | **단일 개발 진입점** `pnpm tools-dev` — 데몬·웹·데스크톱 기동, 포트·네임스페이스 |
| **tools/pack** | macOS/Windows/Linux 패키징 파이프 |
| **tools/pr** | 메인테이너용 PR 분류·체크리스트 래퍼(`gh`) |

**제거·비활성 주의:** `apps/nextjs`, `packages/shared`는 복원 금지.

---

## 6. 배포·런타임 토폴로지 (`docs/architecture.md` 요약)

1. **완전 로컬:** 브라우저 → Next(개발 서버) → HTTP → 데몬 → PATH 상 CLI.
2. **Vercel 웹 + 로컬 데몬:** 배포 UI에서 터널 URL로 데몬 연결; 시크릿은 데몬 측.
3. **브라우저 전용(데몬 없음):** API 직접 호출·IndexedDB 등 **기능 축소** 경로.

동일 웹 번들, **전송 계층**(데몬 SSE / api-direct / browser)만 바뀐다.

---

## 7. 데이터와 설정

- 기본 SQLite: **`.od/app.sqlite`** (프로젝트·대화·메시지·탭 등).
- 재배치: `OD_DATA_DIR`, 또는 `OD_MEDIA_CONFIG_DIR`(미디어 설정만).
- 에이전트 CWD·아티팩트 등은 README·AGENTS.md에 정의된 대로 `.od/` 트리 하위.

---

## 8. 개발 워크플로 (저장소 규칙)

- 로컬 개발: **`pnpm tools-dev`** 만 사용 (`pnpm dev` 등 루트 별칭 추가 금지).
- 검증 루틴: `pnpm guard`, `pnpm typecheck`; 빌드/테스트는 **`pnpm --filter <패키지>`** 스코프.
- 계약 변경 시 **`packages/contracts`** 우선 정의 후 웹/데몬 연동.
- 웹은 **`apps/daemon/src`를 직접 import하지 않음** — HTTP·contracts 경계 유지.

---

## 9. 릴리스 채널 (AGENTS.md)

- **beta** — 빠른 R&D 검증
- **nightly** — 스테이블 게이트용 내부 검증
- **preview** — 조기 채널, 버전·R2·업데이터 정책 별도
- **스테이블** — 공식 배포; 앱 표시명이 채널별로 구분됨 (예: Open Design vs Beta vs Preview)

---

## 10. 문서 인덱스 (추가 학습용)

- 제품·온보딩: `README.md`, `QUICKSTART.md`
- 스펙·프로토콜: `docs/spec.md`, `docs/skills-protocol.md`, `docs/agent-adapters.md`, `docs/modes.md`
- 기여: `CONTRIBUTING.md`
- 에이전트 규약: 루트 `AGENTS.md` 및 각 레이어 `apps/AGENTS.md`, `packages/AGENTS.md`, `e2e/AGENTS.md` 등

---

## 11. 요약

이 저장소는 **모노레포**로, **Next 웹 UI + Node 데몬 + 선택 Electron**이 **사이드카·contracts**로 분리되어 있고, 디자인 자산은 **`skills` / `design-systems` / `design-templates` / `craft`**에 모듈화되어 있다. 확장·기여 시 **경계(웹↔데몬, contracts 순서, tools-dev 단일 진입)**를 지키는 것이 유지보수 핵심이다.
