//
//  Runtime.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 27.09.2023.
//

import Foundation

public protocol RuntimeProtocol {
    associatedtype Action: ActionProtocol
    typealias Result = ActionResult<Action>

    func execute(_ effect: Effect<Result>) async throws -> Result
}

public actor RuntimeActor<Action: ActionProtocol>: RuntimeProtocol {
    public typealias Result = ActionResult<Action>

    var queueTasks: [String: Task<Result, Error>] = [:]

    public init() {}

    public func execute(_ effect: Effect<Result>) async throws -> Result {
        let task = Task {
            let value = await effect.run()
            try Task.checkCancellation()
            return value
        }
        if queueTasks.keys.contains(effect.id) {
            queueTasks[effect.id]?.cancel()
        }
        queueTasks[effect.id] = task
        let value = try await task.value
        queueTasks.removeValue(forKey: effect.id)
        return value
    }
}
