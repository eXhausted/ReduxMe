//
//  Store.swift
//  ReduxMe
//
//  Created by Bogdan Geleta on 10/5/17.
//  Copyright © 2017 Bogdan Geleta. All rights reserved.
//

import Foundation

protocol Action {}

class Store<State> {
    private let reducer: (State, Action) -> State
    private(set) var state: State
    
    init(initialState: State, reducer: @escaping (State, Action) -> State) {
        self.state = initialState
        self.reducer = reducer
    }
    
    func dispatch(action: Action) {
        state = reducer(state, action)
        listeners.forEach{ $0.value(state) }
    }
    
    private var listeners: [Int: (State) -> ()] = [:]
    private var listenerIds = (0...).makeIterator()
    
    func subscribe(listener: @escaping (State) -> ()) -> Command {
        guard let newId = listenerIds.next() else {
            fatalError("wtf")
        }
        listeners[newId] = listener
        listener(state)
        return Command {  self.listeners[newId] = nil }
    }
}
