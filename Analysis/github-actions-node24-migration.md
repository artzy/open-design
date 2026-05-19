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

## 참고

- 메인 `ci.yml`은 이미 `checkout@v6.0.2`, `setup-node@v6.4.0`, Node 24 사용 중이었음.
- 임시 우회: 워크플로에 `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` 환경 변수 (액션 업데이트가 더 권장됨).

## 검증

PR/푸시 후 Actions 로그에서 Node.js 20 deprecation 경고가 사라졌는지 확인.
