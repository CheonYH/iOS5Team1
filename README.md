# iOS5Team1 Backend (Vapor)

Swift/Vapor 기반의 인증/리뷰/IGDB 프록시/Firebase 설정 API 서버입니다.

## 빠른 시작

- 로컬 실행: `swift run`
- Docker 실행: `docker compose up app`

## 환경 변수

필요한 환경 변수는 `.env.example`에 정리되어 있습니다.

간단한 사용 순서:

```sh
cp .env.example .env
set -a && source .env && set +a
```

Docker Compose는 `.env`를 자동으로 읽습니다.

## 입문자 가이드

프로젝트 구조와 파일 설명은 아래 문서를 참고하세요.

- `docs/BEGINNER_GUIDE.md`
