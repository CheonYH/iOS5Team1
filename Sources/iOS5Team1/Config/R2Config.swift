//
//  R2Config.swift
//  iOS5Team1
//
//  R2 환경변수 기반 설정을 담는 모델입니다.

import Vapor

/// R2 연결 정보를 보관합니다.
///
/// - Important:
/// Access Key/Secret 등 민감 정보는 반드시 환경변수로만 주입합니다.
struct R2Config {
    /// R2 Access Key ID
    let accessKeyId: String
    /// R2 Secret Access Key
    let secretAccessKey: String
    /// Cloudflare Account ID
    let accountId: String
    /// R2 버킷 이름
    let bucket: String
    /// 공개 접근용 베이스 URL(선택)
    let publicBaseUrl: String?

    /// R2 S3 호환 엔드포인트 URL
    var endPoint: String {
        "https://\(accountId).r2.cloudflarestorage.com"
    }

    /// 환경변수에서 설정을 로드합니다.
    static func fromEnv() -> R2Config? {
        guard
            let accessKeyId = Environment.get("R2_ACCESS_KEY_ID"),
            let secretAccessKey = Environment.get("R2_SECRET_ACCESS_KEY"),
            let accountId = Environment.get("R2_ACCOUNT_ID"),
            let bucket = Environment.get("R2_BUCKET")
        else {
            return nil
        }

        let publicBaseUrl = Environment.get("R2_PUBLIC_BASE_URL")

        return R2Config(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            accountId: accountId,
            bucket: bucket,
            publicBaseUrl: publicBaseUrl
        )
    }
}
