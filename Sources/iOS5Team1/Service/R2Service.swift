//
//  R2Service.swift
//  iOS5Team1
//
//  R2(S3 호환) presigned URL 생성을 담당하는 서비스입니다.

import SotoS3
import Vapor

/// R2 presigned URL 생성과 S3 클라이언트를 캡슐화합니다.
final class R2Service: @unchecked Sendable {
    /// R2 연결 정보
    let config: R2Config
    /// Soto AWSClient 인스턴스
    let client: AWSClient
    /// S3 호환 클라이언트
    let s3: S3

    init(config: R2Config) {
        self.config = config
        self.client = AWSClient(
            credentialProvider: .static(
                accessKeyId: config.accessKeyId,
                secretAccessKey: config.secretAccessKey
            ),
            httpClientProvider: .createNew
        )
        self.s3 = S3(client: client, region: .init(rawValue: "auto"), endpoint: config.endPoint)
    }

    /// 지정한 키에 대한 PUT presigned URL을 생성합니다.
    func presignPutURL(key: String, expiresInSeconds: Int = 900) async throws -> String {
        let url = URL(string: "\(config.endPoint)/\(config.bucket)/\(key)")!
        let signed = try await s3.signURL(
            url: url,
            httpMethod: .PUT,
            expires: .seconds(Int64(expiresInSeconds))
        ).get()
        return signed.absoluteString
    }

    /// R2 객체를 삭제합니다.
    func deleteObject(key: String) async throws {
        _ = try await s3.deleteObject(.init(bucket: config.bucket, key: key)).get()
    }

    /// URL 또는 키에서 객체 키를 추출합니다.
    func extractKey(from urlOrKey: String) -> String? {
        if let url = URL(string: urlOrKey), let host = url.host {
            let path = url.path
            let prefix = "/\(config.bucket)/"
            if host.contains("r2.cloudflarestorage.com"), path.hasPrefix(prefix) {
                return String(path.dropFirst(prefix.count))
            }
            return nil
        }
        return urlOrKey.isEmpty ? nil : urlOrKey
    }
}
