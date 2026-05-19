# GitHub Actions Node.js 20 → 24 마이그레이션

**날짜:** 2026-05-19

## 배경

GitHub Actions 러너에서 Node.js 20 기반 JavaScript 액션이 deprecated 되었습니다.

- 2026-06-02: Node.js 24가 기본값
- 2026-09-16: Node.js 20 제거

경고 예시: `actions/checkout@v4` 등이 Node.js 20에서 실행 중.

## 조치

`ci.yml` / 릴리스 워크플로에 맞춰 구버전 액션을 갱신했습니다.

| 워크플로 | 변경 |
|---------|------|
| `nix-check.yml` | `checkout@v4` → `@v6.0.2` |
| `docker-image.yml` | `checkout@v4` → `@v6.0.2` |
| `critique-conformance.yml` | checkout, pnpm, setup-node, upload-artifact 일괄 갱신 |
| `landing-page-ci.yml`, `landing-page-deploy.yml` | `cache@v4` → `@v5` |
| `blog-3day-report.yml`, `blog-indexing-on-deploy.yml` | `upload-artifact@v4` → `@v7` |
| `contributor-card-bot.yml` | `node-version: 22` → `24` |

## 추가 조치 (2026-05-19)

- 모든 `.github/workflows/*.yml`에 `env.FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` 추가 — 서드파티 액션 내부의 `checkout@v4` 등도 Node 24로 실행.
- `contributor-card-bot.yml`: `pnpm/action-setup@v4` → `@v6.0.8`.

## 참고

- 메인 `ci.yml`은 이미 `checkout@v6.0.2`, `setup-node@v6.4.0`, Node 24 사용 중이었음.
- upstream `nexu-io/open-design` `main`에는 아직 `nix-check` / `critique-conformance` / `docker-image`에 `checkout@v4`가 남아 있을 수 있음 — PR에 워크플로 변경을 포함해야 해당 저장소 CI에서도 경고가 사라짐.

## 검증

PR/푸시 후 Actions 로그에서 Node.js 20 deprecation 경고가 사라졌는지 확인.
