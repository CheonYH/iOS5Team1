//  iOS5Team1Tests.swift
//  iOS5Team1Tests
//
//  서버 앱의 주요 기능을 검증하는 테스트 예제입니다.
//
//  초보자 가이드
//  - Testing 프레임워크: Swift의 경량 테스트 프레임워크를 사용합니다.
//  - @Suite: 테스트 묶음(스위트)을 정의합니다.
//  - @Test: 개별 테스트 케이스를 정의합니다.
//  - withApp: 테스트마다 앱을 생성/부팅/종료하는 헬퍼입니다.

@testable import iOS5Team1
import VaporTesting
import Testing
import Fluent

@Suite("App Tests with DB", .serialized)
struct iOS5Team1Tests {
    /// 앱을 생성하고 구성(configure) 후, 테스트 본문을 실행하는 헬퍼 함수입니다.
    /// 테스트가 끝나면 마이그레이션 롤백과 함께 앱을 안전하게 종료합니다.
    private func withApp(_ test: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await app.autoMigrate()
            try await test(app)
            try await app.autoRevert()
        } catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    /// 예제: 간단한 헬스 체크/인사 라우트가 정상 동작하는지 확인합니다.
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }
    
    /// 예제: 모든 Todo 항목을 조회하는 API가 기대대로 동작하는지 확인합니다.
    @Test("Getting all the Todos")
    func getAllTodos() async throws {
        try await withApp { app in
            let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
            try await sampleTodos.create(on: app.db)
            
            try await app.testing().test(.GET, "todos", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try
                    res.content.decode([TodoDTO].self).sorted(by: { ($0.title ?? "") < ($1.title ?? "") }) ==
                    sampleTodos.map { $0.toDTO() }.sorted(by: { ($0.title ?? "") < ($1.title ?? "") })
                )
            })
        }
    }
    
    /// 예제: 새로운 Todo 항목을 생성하는 API를 검증합니다.
    @Test("Creating a Todo")
    func createTodo() async throws {
        let newDTO = TodoDTO(id: nil, title: "test")
        
        try await withApp { app in
            try await app.testing().test(.POST, "todos", beforeRequest: { req in
                try req.content.encode(newDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let models = try await Todo.query(on: app.db).all()
                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
            })
        }
    }
    
    /// 예제: 특정 Todo 항목을 삭제하는 API를 검증합니다.
    @Test("Deleting a Todo")
    func deleteTodo() async throws {
        let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
        
        try await withApp { app in
            try await testTodos.create(on: app.db)
            
            try await app.testing().test(.DELETE, "todos/\(testTodos[0].requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let model = try await Todo.find(testTodos[0].id, on: app.db)
                #expect(model == nil)
            })
        }
    }
}

// MARK: - 테스트 편의: DTO 비교를 위한 Equatable 구현
extension TodoDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
