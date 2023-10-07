//
//  ReducerProtocol.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 27.09.2023.
//

import Foundation

public protocol ReducerProtocol<State, Action> {
    associatedtype State: StateProtocol
    associatedtype Action: ActionProtocol
    typealias Result = ActionResult<Action>
    typealias ReturnEffect = Effect<Result>

    func reduce(state: inout State.State, action: Action.UIAction) -> ReturnEffect?
    func reduce(state: inout State.State, action: Action.InternalAction) -> ReturnEffect?
    func reduce(state: inout State.NavState, action: Action.NavAction)
}
