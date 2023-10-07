//
//  Mapper.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 06.10.2023.
//

import Foundation

public protocol MapperProtocol {
    associatedtype ParentAction: ActionProtocol
    associatedtype ChildrenAction: ActionProtocol
    associatedtype ParentState: StateProtocol
    associatedtype ChildrenState: StateProtocol

    typealias ParentActionResult = ActionResult<ParentAction>

    static func getState(_ parentState: ParentState.State) -> ChildrenState.State
    static func setState(
        _ childrenState: ChildrenState.State,
        toParentState parentState: ParentState.State
    ) -> ParentState.State
    static func mapAction(_ childrenAction: ChildrenAction.UIAction) -> ParentActionResult?
}
