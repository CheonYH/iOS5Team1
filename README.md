# iOS5Team1 Backend

Swift + Vapor 기반 게임 커뮤니티 백엔드입니다.  
인증, 프로필, 리뷰, IGDB 프록시, Firebase 설정, R2 Presign API를 제공합니다.

## 주요 기능

- Auth: 회원가입/로그인/토큰 갱신/로그아웃/소셜 로그인
- Profile: 내 프로필 생성/조회/수정
- Review: 리뷰 CRUD, 게임별 리뷰/통계 조회
- IGDB Proxy: `/v4/multiquery`, `/v4/games`
- Firebase Config: 앱 초기화용 설정값 제공
- R2 Presign: 프로필 이미지 업로드용 Presigned URL 발급

## 기술 스택

- Swift 6, Vapor 4
- Fluent + FluentMySQLDriver
- JWT / JWTKit
- SotoS3 (Cloudflare R2)
- Docker / Docker Compose

## 로컬 실행

1) 의존성 설치 및 빌드

```sh
swift build
```

2) 환경 변수 설정 (`.env` 파일 생성)

```dotenv
PORT=8080
DATABASE_HOST=127.0.0.1
DATABASE_PORT=3306
DATABASE_USERNAME=vapor_username
DATABASE_PASSWORD=vapor_password
DATABASE_NAME=vapor_database
JWT_SECRET=<base64-encoded-secret>

IGDB_CLIENT_ID=<igdb-client-id>
IGDB_CLIENT_SECRET=<igdb-client-secret>

FIREBASE_API_KEY=<firebase-api-key>
FIREBASE_APP_ID=<firebase-app-id>
FIREBASE_GCM_SENDER_ID=<firebase-sender-id>
FIREBASE_PROJECT_ID=<firebase-project-id>
FIREBASE_STORAGE_BUCKET=<firebase-storage-bucket>
FIREBASE_CLIENT_ID=<firebase-client-id>

R2_ACCESS_KEY_ID=<r2-access-key>
R2_SECRET_ACCESS_KEY=<r2-secret-key>
R2_ACCOUNT_ID=<r2-account-id>
R2_BUCKET=<r2-bucket>
R2_PUBLIC_BASE_URL=<optional-public-base-url>
```

3) 실행

```sh
set -a && source .env && set +a
swift run
```

- Health Check: `GET /health`

## Docker 실행

```sh
docker compose build
docker compose up app db
```

- 앱: `http://localhost:8080`
- DB: `localhost:3306`

## API 요약

### Auth

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logout`
- `POST /auth/nickname-check`
- `POST /auth/social`
- `POST /auth/social-register`
- `POST /auth/nickname-update` (JWT)
- `POST /auth/onboarding-complete` (JWT)
- `GET /auth/me` (JWT)
- `DELETE /auth/me` (JWT)

### Profile

- `POST /profile` (JWT)
- `GET /profile` (JWT)
- `PATCH /profile` (JWT)

### Review

- `POST /reviews` (JWT)
- `PATCH /reviews/:id` (JWT)
- `DELETE /reviews/:id` (JWT)
- `GET /reviews/me` (JWT)
- `GET /reviews/game/:gameId`
- `GET /reviews/game/:gameId/stats`

### IGDB / Firebase / R2

- `POST /v4/multiquery`
- `POST /v4/games`
- `GET /firebase/config`
- `POST /r2/presign` (JWT, R2 환경 변수 설정 시 활성화)

## 문서

- 입문자 가이드: `docs/BEGINNER_GUIDE.md`
- Postman 컬렉션: `docs/postman_collection.json`
