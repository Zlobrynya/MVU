//
//  StateProtocol.swift
//  mvutest
//
//  Created by Nikitin Nikita Andreevich on 04.10.2023.
//

import Foundation

public protocol StateProtocol {
    associatedtype State
    // TODO: Нужно переименовать в более корректное имя
    // Отвечает за временные ui эффекты, попап, навигация, sheet и т.п
    associatedtype NavState

    var state: State { get set }
    var navState: NavState { get set }
}
