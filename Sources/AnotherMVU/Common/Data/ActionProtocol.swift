//
//  ActionProtocol.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 04.10.2023.
//

import Foundation

public protocol ActionProtocol {
    associatedtype UIAction: Sendable
    associatedtype InternalAction: Sendable
    // TODO: Нужно переименовать в более корректное имя
    // Отвечает за временные ui эффекты, попап, навигация, sheet и т.п
    associatedtype NavAction: Sendable
}

public enum ActionResult<Action: ActionProtocol>: Sendable {
    case uiAction(Action.UIAction)
    case internalAction(Action.InternalAction)
    case navAction(Action.NavAction)
}
