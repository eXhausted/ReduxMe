//
//  LoadMoreCards.swift
//  ReduxMe
//
//  Created by Bogdan Geleta on 10/5/17.
//  Copyright © 2017 Bogdan Geleta. All rights reserved.
//

import Foundation
import Gwent_API

let api = GwentAPI()
func loadMoreCards(from url: URL?) -> Future<Action> { 
    return api.getCards(url: url)
        .dispatch(on: .main)
        .map { (resunt: Result<GwentAPI.Response.Cards>) -> Action in
            switch resunt {
            case .value(let value): return HandleNewCards(cards: value)
            case .error(let error): return HandleError(error: error)
            }
    }
}

typealias Dispatch = (Action) -> ()
typealias Get<State> = () -> State
typealias ActionCreateor<State> = (Dispatch, Get<State>) -> ()

extension Store {
    func dispatch(actionCreator: @escaping ActionCreateor<State>) {
        actionCreator(dispatch, { return self.state })
    }
}

func loadMoreCards(dispatch: @escaping Dispatch, getState: Get<State>) {
    loadMoreCards(from: getState().loadedCardsState.nextURL)
        .onComplete(callback: dispatch)
}




