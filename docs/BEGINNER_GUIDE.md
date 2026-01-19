# iOS5Team1 백엔드 입문자 가이드

이 문서는 Vapor 기반 서버 프로젝트를 처음 보는 입문자를 대상으로, 코드의 큰 흐름과 주요 파일 역할을 설명합니다.

## 1) 이 프로젝트가 하는 일

- 사용자 인증(회원가입/로그인/토큰 갱신)
- 리뷰 작성/수정/삭제 및 조회
- IGDB API 프록시 호출
- Firebase 초기화 설정값 제공
- Google 소셜 로그인(토큰 검증 기반)

## 2) 실행 흐름(요청이 처리되는 길)

요청이 서버에 들어오면 아래 순서로 처리됩니다.

1. `entrypoint.swift`가 앱을 시작합니다.
2. `configure.swift`가 환경 변수/DB/JWT/서비스/라우트를 초기화합니다.
3. `routes.swift`와 각 컨트롤러가 API 경로를 등록합니다.
4. 컨트롤러가 요청을 받고, 서비스가 비즈니스 로직을 수행합니다.
5. 서비스가 리포지토리(Repository)를 통해 DB에 접근합니다.

핵심 경로:

- `Sources/iOS5Team1/entrypoint.swift`
- `Sources/iOS5Team1/configure.swift`
- `Sources/iOS5Team1/routes.swift`

## 3) 폴더 구조 개요

- `Sources/iOS5Team1/Controllers/` : HTTP API를 정의하는 곳
- `Sources/iOS5Team1/Service/` : 비즈니스 로직(인증, 리뷰, IGDB 등)
- `Sources/iOS5Team1/Respository/` : DB 접근 계층(쿼리 실행)
- `Sources/iOS5Team1/Models/` : 서버 내부 모델/토큰 페이로드
- `Sources/iOS5Team1/DTOs/` : 요청/응답 데이터 구조
- `Tests/` : 테스트 코드
- `Public/` : 정적 파일(현재 비어 있거나 빌드 산출물에 포함될 수 있음)

## 3-1) 파일 목록(상세, API 기준 정렬)

아래는 저장소의 모든 파일을 API 흐름 중심으로 재정렬한 목록입니다.

### 공통 부팅/라우팅

- `Sources/iOS5Team1/entrypoint.swift`  
  `@main` 진입점으로 앱을 시작하고 종료를 관리합니다.  
  `configure` 호출 후 서버 실행 흐름을 제어합니다.
- `Sources/iOS5Team1/configure.swift`  
  환경 변수, DB 연결, JWT 키, 의존성 주입을 초기화합니다.  
  컨트롤러와 라우트를 등록하는 핵심 부팅 파일입니다.
- `Sources/iOS5Team1/routes.swift`  
  컨트롤러들을 앱에 등록하는 라우팅 파일입니다.  
  필요한 서비스/리포지토리를 `app.storage`에서 꺼내 사용합니다.
- `Sources/iOS5Team1/StorageKey/StorageKey.swift`  
  앱 전역 저장소에 의존성을 등록하기 위한 키 모음입니다.  
  리포지토리/서비스를 타입 안전하게 꺼내도록 돕습니다.

### Auth API (회원가입/로그인/토큰/닉네임)

- `Sources/iOS5Team1/Controllers/AuthController.swift`  
  회원가입/로그인/토큰 갱신/닉네임 검사/소셜 로그인 API를 담당합니다.  
  요청을 받아 서비스에 위임하고 응답 형태로 돌려줍니다.
- `Sources/iOS5Team1/Service/AuthService.swift`  
  인증 서비스가 구현해야 할 기능(로그인/갱신/로그아웃)을 정의합니다.  
  실제 구현은 `MyAuthService`에서 수행됩니다.
- `Sources/iOS5Team1/Service/MyAuthService.swift`  
  이메일 로그인, 토큰 발급/갱신/로그아웃을 처리합니다.  
  리프레시 토큰을 DB에 저장하고 검증합니다.
- `Sources/iOS5Team1/Respository/UserRepository.swift`  
  사용자 조회/생성/중복 확인 기능을 정의합니다.  
  실제 구현은 MySQL 기반 리포지토리입니다.
- `Sources/iOS5Team1/Respository/MySQLUserRepository.swift`  
  사용자 관련 SQL 쿼리를 실행합니다.  
  이메일/소셜 UID로 조회하고 신규 유저를 생성합니다.
- `Sources/iOS5Team1/Respository/RefreshTokenRepository.swift`  
  리프레시 토큰 저장/조회/폐기를 위한 인터페이스입니다.  
  보안 관련 로직을 이 계층에서 통제합니다.
- `Sources/iOS5Team1/Respository/MySQLRefreshTokenRepository.swift`  
  리프레시 토큰을 DB에 저장하고 상태를 갱신합니다.  
  사용됨/폐기됨/만료 정리를 SQL로 수행합니다.
- `Sources/iOS5Team1/Models/User.swift`  
  사용자 정보를 담는 모델입니다.  
  로컬/소셜 로그인 공통 필드를 포함합니다.
- `Sources/iOS5Team1/Models/TokenPair.swift`  
  액세스/리프레시 토큰을 한 번에 반환하는 모델입니다.  
  로그인 및 재발급 API의 응답으로 사용됩니다.
- `Sources/iOS5Team1/Models/RegisterResponse.swift`  
  회원가입 성공 여부와 메시지를 담는 응답 모델입니다.  
  간단한 API 응답에 사용됩니다.
- `Sources/iOS5Team1/Models/RefreshToken.swift`  
  리프레시 토큰 레코드를 표현합니다.  
  만료/폐기/사용 시각을 포함합니다.
- `Sources/iOS5Team1/Models/AccessTokenPayload.swift`  
  JWT 액세스 토큰의 페이로드 정의입니다.  
  만료(exp)와 사용자 식별(sub)을 포함합니다.
- `Sources/iOS5Team1/Models/JWTMiddleware.swift`  
  보호된 라우트에서 JWT를 검증하는 미들웨어입니다.  
  토큰이 유효하지 않으면 요청을 차단합니다.
- `Sources/iOS5Team1/Models/RepositoryError.swift`  
  리포지토리 계층 오류를 일관되게 표현합니다.  
  쿼리 실패/중복/데이터 오류 등을 구분합니다.
- `Sources/iOS5Team1/DTOs/RegisterRequest.swift`  
  회원가입 요청 바디 구조입니다.  
  이메일/비밀번호/닉네임을 받습니다.
- `Sources/iOS5Team1/DTOs/LoginRequest.swift`  
  로그인 요청 바디 구조입니다.  
  이메일과 비밀번호를 전달합니다.
- `Sources/iOS5Team1/DTOs/LoginResponse.swift`  
  로그인 성공 여부와 메시지를 담는 응답 DTO입니다.  
  사용자에게 보여줄 안내 문구에 활용합니다.
- `Sources/iOS5Team1/DTOs/RefreshRequest.swift`  
  토큰 재발급 요청 바디입니다.  
  리프레시 토큰 문자열을 전달합니다.
- `Sources/iOS5Team1/DTOs/NicknameCheckRequest.swift`  
  닉네임 중복 검사 요청 DTO입니다.  
  검사할 닉네임 하나만 전달합니다.
- `Sources/iOS5Team1/DTOs/NicknameAvailabilityResponse.swift`  
  닉네임 사용 가능 여부 응답 DTO입니다.  
  true면 사용 가능, false면 중복입니다.

### Social Auth API (Google 등)

- `Sources/iOS5Team1/Service/SocialAuthProvider.swift`  
  소셜 로그인 제공자 프로토콜과 provider enum을 정의합니다.  
  Google/Apple/Kakao/Naver 등 확장 가능하게 설계되어 있습니다.
- `Sources/iOS5Team1/Service/SocialAuthService.swift`  
  소셜 로그인 검증 및 가입 흐름을 묶어 처리합니다.  
  존재하는 사용자는 로그인, 없으면 가입 필요로 분기합니다.
- `Sources/iOS5Team1/Service/GoogleAuthProvider.swift`  
  Google ID Token을 검증하는 구체 구현체입니다.  
  JWKS 매니저를 사용해 토큰 페이로드를 확인합니다.
- `Sources/iOS5Team1/Service/GoogleJWKSManager.swift`  
  Google JWT 검증 로직을 담당합니다.  
  aud/iss 검증으로 토큰 유효성을 확인합니다.
- `Sources/iOS5Team1/Models/GoogleIDPayload.swift`  
  Google ID Token의 페이로드 구조입니다.  
  이메일/발급자/대상(aud) 정보를 검증합니다.
- `Sources/iOS5Team1/Models/GoogleOAuthConfig.swift`  
  Google OAuth 설정 값을 묶어 전달합니다.  
  Client ID/Secret/Redirect URI를 포함합니다.
- `Sources/iOS5Team1/Models/VerifiedSocialUser.swift`  
  소셜 로그인 검증이 끝난 사용자 정보를 담습니다.  
  provider와 UID를 함께 보관합니다.
- `Sources/iOS5Team1/DTOs/SocialIdTokenLoginRequest.swift`  
  소셜 로그인 요청 바디입니다.  
  ID Token과 provider 타입을 받습니다.
- `Sources/iOS5Team1/DTOs/SocialRegisterRequest.swift`  
  소셜 회원가입 요청 바디입니다.  
  provider 정보와 닉네임, 이메일을 포함합니다.
- `Sources/iOS5Team1/DTOs/RegistrationNeededResponse.swift`  
  소셜 가입이 필요할 때 보내는 응답 DTO입니다.  
  이메일을 포함해 다음 단계로 안내합니다.

### Review API

- `Sources/iOS5Team1/Controllers/ReviewController.swift`  
  리뷰 생성/수정/삭제 및 조회/통계 API를 처리합니다.  
  JWT 미들웨어로 보호된 라우트를 구분합니다.
- `Sources/iOS5Team1/Service/ReviewService.swift`  
  리뷰 서비스의 인터페이스를 정의합니다.  
  기본 구현은 `DefaultReviewService`가 제공합니다.
- `Sources/iOS5Team1/Service/DefaultReviewService.swift`  
  리뷰 CRUD와 통계 로직을 구현합니다.  
  실제 SQL 작업은 `ReviewRepository`에 위임합니다.
- `Sources/iOS5Team1/Respository/ReviewRepository.swift`  
  리뷰 CRUD와 통계 조회의 인터페이스를 정의합니다.  
  정렬 옵션을 받는 형태로 설계되어 있습니다.
- `Sources/iOS5Team1/Respository/MySQLReviewRepository.swift`  
  리뷰 관련 SQL을 실행하는 구현체입니다.  
  게임별 정렬, 평균/개수 통계를 계산합니다.
- `Sources/iOS5Team1/DTOs/CreateReviewRequest.swift`  
  리뷰 생성 요청 바디입니다.  
  게임 ID, 평점, 내용을 전달합니다.
- `Sources/iOS5Team1/DTOs/UpdateReviewRequest.swift`  
  리뷰 수정 요청 바디입니다.  
  평점과 내용을 갱신합니다.
- `Sources/iOS5Team1/DTOs/ReviewResponse.swift`  
  리뷰 상세 응답 DTO입니다.  
  작성자/게임/평점/시간 정보를 포함합니다.
- `Sources/iOS5Team1/DTOs/ReviewStats.swift`  
  내부용 리뷰 통계 모델과 정렬 enum이 들어 있습니다.  
  정렬 기준을 서버에서 공유하는 용도입니다.
- `Sources/iOS5Team1/DTOs/ReviewStatsResponse.swift`  
  리뷰 통계를 응답으로 전달하는 DTO입니다.  
  평균 평점과 리뷰 개수를 포함합니다.

### IGDB API

- `Sources/iOS5Team1/Controllers/IGDBController.swift`  
  IGDB 외부 API를 서버가 대신 호출하는 프록시입니다.  
  클라이언트 요청 본문을 그대로 전달하고 응답을 반환합니다.
- `Sources/iOS5Team1/Service/IGDBService.swift`  
  IGDB OAuth 토큰을 발급하고 캐시합니다.  
  토큰 만료 전에는 캐시를 재사용합니다.
- `Sources/iOS5Team1/DTOs/IGDBToken.swift`  
  IGDB OAuth 토큰 응답 구조입니다.  
  access token과 만료 시간 필드를 담습니다.

### Firebase API

- `Sources/iOS5Team1/Controllers/FirebaseController.swift`  
  Firebase 초기화에 필요한 설정값을 내려주는 엔드포인트입니다.  
  저장된 환경 변수를 응답 DTO로 변환합니다.
- `Sources/iOS5Team1/DTOs/FirebaseConfig.swift`  
  서버 내부에서 사용하는 Firebase 설정 모델입니다.  
  `StorageKey`를 함께 정의해 저장소에 보관합니다.
- `Sources/iOS5Team1/DTOs/FirebaseConfigResponse.swift`  
  Firebase 설정을 클라이언트로 내려주는 DTO입니다.  
  필요한 필드만 노출하도록 구성합니다.

### 인프라/개발 환경

- `Dockerfile`  
  빌드 단계에서 Swift 앱을 컴파일하고, 런타임 단계에서 실행하도록 구성된 멀티스테이지 Docker 설정입니다.  
  `/staging`에 바이너리/리소스를 모아 최종 이미지를 가볍게 유지합니다.
- `docker-compose.yml`  
  로컬에서 앱과 MySQL DB를 함께 띄우기 위한 구성입니다.  
  `app`, `db`, `migrate` 등의 서비스가 정의되어 있습니다.
- `Package.swift`  
  SwiftPM 패키지 정의 파일로 의존성/타깃/플랫폼 정보를 담습니다.  
  서버 빌드에 필요한 외부 라이브러리(Vapor 등)를 여기서 선언합니다.
- `Package.resolved`  
  의존성 버전이 고정된 스냅샷입니다.  
  동일한 버전으로 재현 가능한 빌드를 위해 사용됩니다.

### 문서/테스트

- `README.md`  
  프로젝트 소개와 실행 방법을 담는 문서입니다.  
  빠른 시작과 가이드 링크를 제공합니다.
- `docs/BEGINNER_GUIDE.md`  
  입문자 대상 가이드 문서입니다.  
  구조/흐름/파일 역할을 단계적으로 설명합니다.
- `Tests/iOS5Team1Tests/iOS5Team1Tests.swift`  
  VaporTesting 기반의 테스트 예제 모음입니다.  
  앱 부팅/마이그레이션/요청 테스트 흐름을 보여줍니다.

## 4) 인증(Auth) 흐름 요약

- 회원가입: `POST /auth/register`
- 로그인: `POST /auth/login`
- 토큰 갱신: `POST /auth/refresh`
- 로그아웃: `POST /auth/logout`
- 닉네임 중복 확인: `POST /auth/nickname-check`

로그인은 `AuthController` → `MyAuthService` → `UserRepository` 순서로 처리됩니다.

토큰은 JWT(HMAC) 기반이며, 보호가 필요한 라우트는 `JWTMiddleware`가 먼저 검증합니다.

## 5) 소셜 로그인 흐름 요약

- `POST /auth/social`: ID Token 검증 → 계정 존재 여부 확인
- `POST /auth/social-register`: 가입이 필요한 경우 회원 생성

`SocialAuthService`가 제공자(Google 등)별 토큰 검증을 처리합니다.

## 6) 리뷰(Review) 흐름 요약

- 생성: `POST /reviews` (JWT 필요)
- 수정: `PATCH /reviews/:id` (JWT 필요)
- 삭제: `DELETE /reviews/:id` (JWT 필요)
- 특정 게임 리뷰 조회: `GET /reviews/game/:gameId`
- 통계 조회: `GET /reviews/game/:gameId/stats`
- 내 리뷰 조회: `GET /reviews/me` (JWT 필요)

`ReviewController` → `DefaultReviewService` → `ReviewRepository` 순서로 처리됩니다.

## 7) IGDB 프록시 요약

- `POST /v4/multiquery`
- `POST /v4/games`

서버가 IGDB 토큰을 받아서 캐시하고, 클라이언트 대신 외부 API를 호출해 결과를 그대로 전달합니다.

관련 파일:

- `Sources/iOS5Team1/Controllers/IGDBController.swift`
- `Sources/iOS5Team1/Service/IGDBService.swift`

## 8) Firebase 설정 제공

- `GET /firebase/config`

`configure.swift`에서 읽은 Firebase 환경 변수를 안전하게 DTO로 내려줍니다.

관련 파일:

- `Sources/iOS5Team1/Controllers/FirebaseController.swift`
- `Sources/iOS5Team1/DTOs/FirebaseConfigResponse.swift`

## 9) 필수 환경 변수

서버는 아래 환경 변수를 사용합니다(일부는 선택/개발용).

- `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`, `DATABASE_NAME`
- `JWT_SECRET`
- `IGDB_CLIENT_ID`, `IGDB_CLIENT_SECRET`
- `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_GCM_SENDER_ID`, `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_ID`
- `FIREBASE_STORAGE_BUCKET` (선택)

## 9-1) .env 예시 사용법

1. `.env.example`을 복사해서 `.env` 파일을 만듭니다.
2. 각 값을 실제 키/비밀번호로 채웁니다.
3. 로컬 실행 시 쉘에 환경 변수를 로드합니다.

예시(로컬 실행 전):

```sh
cp .env.example .env
set -a && source .env && set +a
```

Docker Compose는 `.env`를 자동으로 읽습니다.

## 10) 로컬 실행 힌트

- Swift 직접 실행: `swift run`
- Docker 사용: `docker compose up app`

DB까지 함께 띄우려면 `docker compose up db`를 먼저 실행하세요.

## 10-1) API 요청/응답 예시

아래는 입문자가 테스트해 보기 쉬운 간단한 예시입니다.

### 회원가입

```http
POST /auth/register
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123",
  "nickname": "tester"
}
```

응답 예시:

```json
{ "success": true, "message": "회원가입 성공" }
```

### 로그인

```http
POST /auth/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "password123"
}
```

응답 예시:

```json
{ "access": "JWT_ACCESS_TOKEN", "refresh": "REFRESH_TOKEN" }
```

### 리뷰 생성(로그인 필요)

```http
POST /reviews
Authorization: Bearer JWT_ACCESS_TOKEN
Content-Type: application/json

{
  "gameId": 123,
  "rating": 5,
  "content": "Great game!"
}
```

응답 예시:

```json
{
  "id": 1,
  "userId": 10,
  "gameId": 123,
  "rating": 5,
  "content": "Great game!",
  "createdAt": "2025-01-01T12:00:00Z",
  "updatedAt": null
}
```

### IGDB 프록시 호출

```http
POST /v4/games
Content-Type: text/plain

fields name,first_release_date;
where id = 1942;
```

응답 예시(요약):

```json
[{ "id": 1942, "name": "Example Game" }]
```

### Firebase 설정 조회

```http
GET /firebase/config
```

응답 예시:

```json
{
  "apiKey": "AIza...",
  "appId": "1:xxx:web:yyy",
  "gcmSenderId": "123456789",
  "projectId": "your-project",
  "storageBucket": "your-project.appspot.com",
  "clientId": "your-client-id"
}
```

## 11) 처음 보는 사람이 보면 좋은 파일 순서

1. `Sources/iOS5Team1/entrypoint.swift`
2. `Sources/iOS5Team1/configure.swift`
3. `Sources/iOS5Team1/routes.swift`
4. `Sources/iOS5Team1/Controllers/AuthController.swift`
5. `Sources/iOS5Team1/Service/MyAuthService.swift`
6. `Sources/iOS5Team1/Respository/MySQLUserRepository.swift`
