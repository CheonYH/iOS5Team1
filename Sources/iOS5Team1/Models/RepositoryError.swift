//  RepositoryError.swift
//  iOS5Team1
//
//  리포지토리 계층에서 발생할 수 있는 에러를 모아둔 열거형입니다.
//
//  초보자 가이드
//  - queryFailed: DB 질의 실패
//  - insertFailed: 레코드 생성 후 재조회 실패 등
//  - notFound: 요청한 데이터가 없음
//  - conflict: 중복/무결성 위반 등 충돌 상황
//  - invalidData: 형식이 잘못된 데이터

import Vapor

enum RepositoryError: Error {
    case queryFailed
    case insertFailed
    case notFound
    case conflict
    case invalidData
}
