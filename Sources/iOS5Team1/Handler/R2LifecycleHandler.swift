//
//  R2LifecycleHandler.swift
//  iOS5Team1
//
//  앱 종료 시 R2 관련 리소스를 정리하는 핸들러입니다.

import SotoCore
import Vapor

/// AWSClient를 정상 종료하기 위한 LifecycleHandler입니다.
struct R2LifecycleHandler: LifecycleHandler {
    /// R2 서비스 인스턴스
    let service: R2Service

    /// 앱 종료 시 AWSClient를 shutdown 합니다.
    func shutdown(_ application: Application) {
        try? service.client.syncShutdown()
    }
}
