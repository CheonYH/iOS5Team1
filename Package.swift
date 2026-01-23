// swift-tools-version:6.0
//  Package.swift
//  iOS5Team1
//
//  Swift Package Manager(SPM) 매니페스트 파일입니다.
//  서버 실행에 필요한 외부 라이브러리 의존성과 타깃을 정의합니다.
//
//  초보자 가이드
//  - dependencies: 이 프로젝트가 사용하는 외부 패키지 목록입니다.
//  - targets: 실제로 빌드되는 모듈(실행 타깃/테스트 타깃 등)을 정의합니다.
//  - products(name: "Vapor", package: "vapor"): 특정 패키지에서 제공하는 모듈을 선택해 의존합니다.

import PackageDescription

let package = Package(
    name: "iOS5Team1",
    platforms: [
       .macOS(.v13)
    ],
    // NOTE: SwiftOpenIDConnect는 사용하지 않습니다. Vapor JWT / JWTKit으로 대체되어 있습니다.
    dependencies: [
        // 💧 Vapor: 서버사이드 Swift 웹 프레임워크
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        // 🗄 Fluent: ORM(객체-관계 매핑) 프레임워크
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐬 Fluent-MySQL: MySQL 데이터베이스용 드라이버
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git", from: "4.4.0"),
        // 🔵 SwiftNIO: 논블로킹 네트워킹 라이브러리(실행기 등에서 사용)
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🔐 JWT: JSON Web Token(토큰 기반 인증) 라이브러리
        .package(url: "https://github.com/vapor/jwt.git", from: "5.1.2"),
        // 🔑 JWTKit: JWK/JWKS 처리용 라이브러리
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.1.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "5.10.0")
    ],
    targets: [
        // 실행 타깃: 서버 앱 본체
        .executableTarget(
            name: "iOS5Team1",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentMySQLDriver", package: "fluent-mysql-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "SotoS3", package: "soto")
            ],
            swiftSettings: swiftSettings
        ),
        // 테스트 타깃: 단위 테스트/통합 테스트를 위한 모듈
        .testTarget(
            name: "iOS5Team1Tests",
            dependencies: [
                .target(name: "iOS5Team1"),
                .product(name: "VaporTesting", package: "vapor"),
                .product(name: "JWT", package: "jwt")
            ],
            swiftSettings: swiftSettings
        )
    ]
)

/// 공통 Swift 설정(실험적 기능 등)을 정의합니다.
var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
