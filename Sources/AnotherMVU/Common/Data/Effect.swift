//
//  Effect.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 29.09.2023.
//

import Foundation

public struct Effect<Action: Sendable>: Sendable {
    public enum Kind: Sendable {
        case effect
        case action
        case toParent
    }

    public var id: String
    public var kind: Kind
    public var run: @MainActor @Sendable () async -> Action
}

public extension Effect {
    static func run(
        id: String,
        _ action: @escaping @MainActor @Sendable () async -> Action
    ) -> Self {
        return Effect(id: id, kind: .effect, run: action)
    }

    static func action(_ action: Action) -> Self {
        // TODO: Temporary id
        return Effect(id: "", kind: .action, run: {
            action
        })
    }

    static func toParent(_ action: Action) -> Self {
        // TODO: Temporary id
        return Effect(id: "", kind: .toParent, run: {
            action
        })
    }
}
