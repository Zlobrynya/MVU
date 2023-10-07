//
//  Store.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 27.09.2023.
//

import Combine
import Foundation
import SwiftUI

public final class Store<
    Reducer: ReducerProtocol,
    RuntimeP: RuntimeProtocol
>: ObservableObject, @unchecked Sendable where RuntimeP.Action == Reducer.Action {
    public typealias State = Reducer.State
    public typealias Action = Reducer.Action

    @Published
    public internal(set) var state: State.State
    @Published
    public var navState: State.NavState

    private let reducer: Reducer
    private let runtime: RuntimeP

    public init(reducer: Reducer, state: State, runtime: RuntimeP = RuntimeActor<Reducer.Action>()) {
        self.state = state.state
        navState = state.navState
        self.reducer = reducer
        self.runtime = runtime
    }

    public func update(action: Action.UIAction) {
        guard let effect = reducer.reduce(state: &state, action: action) else {
            return
        }
        executeEffect(effect)
    }

    public func update(action: Action.NavAction) {
        reducer.reduce(state: &navState, action: action)
    }

    private func update(action: Action.InternalAction) {
        guard let effect = reducer.reduce(state: &state, action: action) else {
            return
        }
        executeEffect(effect)
    }

    private func executeEffect(_ effect: Reducer.ReturnEffect) {
        Task { @MainActor [weak self, runtime] in
            guard let nextAction = try? await runtime.execute(effect) else {
                return
            }
            self?.next(nextAction)
        }
    }

    private func next(_ nextAction: Reducer.Result) {
        switch nextAction {
        case let .uiAction(action):
            update(action: action)
        case let .internalAction(action):
            update(action: action)
        case let .navAction(action):
            update(action: action)
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

public extension Store {
    func children<ChildrenReducer: ReducerProtocol, Runtime: RuntimeProtocol>(
        reducer: ChildrenReducer,
        runtime: Runtime = RuntimeActor<ChildrenReducer.Action>(),
        getState: @escaping (State.State) -> ChildrenReducer.State.State,
        setState: @escaping (ChildrenReducer.State.State, State.State) -> State.State,
        mapAction: @escaping (ChildrenReducer.Action.UIAction) -> Reducer.Result?
    ) -> ChildStore<ChildrenReducer, Runtime> {
        return .init(
            reducer: reducer,
            getState: {
                getState(self.state)
            },
            setState: { [weak self] children in
                guard let self else {
                    return
                }
                self.state = setState(children, self.state)
            },
            toParent: { [weak self] childAction in
                guard let action = mapAction(childAction) else {
                    return
                }
                self?.next(action)
            },
            runtime: runtime
        )
    }
}
