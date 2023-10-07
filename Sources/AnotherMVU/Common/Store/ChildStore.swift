//
//  ChildStore.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 06.10.2023.
//

import SwiftUI

public final class ChildStore<
    Reducer: ReducerProtocol,
    Runtime: RuntimeProtocol
>: @unchecked Sendable where Runtime.Action == Reducer.Action {
    public typealias State = Reducer.State
    public typealias Action = Reducer.Action

    public var state: State.State {
        getState()
    }

    private let reducer: Reducer
    private let getState: () -> State.State
    private let setState: (State.State) -> Void
    private let toParent: (Action.UIAction) -> Void
    private let runtime: Runtime

    public init(
        reducer: Reducer,
        getState: @escaping () -> State.State,
        setState: @escaping (State.State) -> Void,
        toParent: @escaping (Action.UIAction) -> Void,
        runtime: Runtime = RuntimeActor<Reducer.Action>()
    ) {
        self.setState = setState
        self.getState = getState
        self.toParent = toParent
        self.reducer = reducer
        self.runtime = runtime
    }

    public func update(action: Action.UIAction) {
        var state = getState()
        let effect = reducer.reduce(state: &state, action: action)
        setState(state)
        guard let effect else {
            return
        }
        executeEffect(effect)
    }

    public func update(action: Action.NavAction) {}

    private func update(action: Action.InternalAction) {
        var state = self.state
        let effect = reducer.reduce(state: &state, action: action)
        setState(state)
        guard let effect else {
            return
        }
        executeEffect(effect)
    }

    private func executeEffect(_ effect: Reducer.ReturnEffect) {
        Task { @MainActor [runtime, toParent] in
            guard let nextAction = try? await runtime.execute(effect) else {
                return
            }
            switch nextAction {
            case let .uiAction(action):
                if effect.kind == .toParent {
                    toParent(action)
                } else {
                    self.update(action: action)
                }
            case let .internalAction(action):
                self.update(action: action)
            case let .navAction(action):
                self.update(action: action)
            }
        }
    }

    // MARK: - UI Value - action binding

    public func binding<SubState: Equatable>(
        get: @escaping (State.State) -> SubState,
        onChange: @escaping (SubState) -> Action.UIAction?
    ) -> Binding<SubState> {
        Binding<SubState>(
            get: {
                get(self.state)
            },
            set: { value, transaction in
                guard get(self.state) != value, let action = onChange(value) else {
                    return
                }
                withTransaction(transaction) {
                    self.update(action: action)
                }
            }
        )
    }
}
