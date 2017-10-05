//
//  AppDelegate.swift
//  ReduxMe
//
//  Created by Bogdan Geleta on 10/5/17.
//  Copyright © 2017 Bogdan Geleta. All rights reserved.
//

import UIKit
import Gwent_API

struct State {
    static let initial = State(error: nil, loadedCardsState: LoadedCardsState(loadedCards: [], nextURL: nil, hasMore: true))
    let error: Error?
    let loadedCardsState: LoadedCardsState
}

struct LoadedCardsState {
    let loadedCards: [GwentAPI.Response.CardLink]
    let nextURL: URL?
    let hasMore: Bool
}

func loadedCardsReducer(state: LoadedCardsState, action: Action) -> LoadedCardsState {
    switch action {
    case let action as HandleNewCards:
        return LoadedCardsState(loadedCards: state.loadedCards + action.cards.results,
                                nextURL: action.cards.next,
                                hasMore: action.cards.hasMore)
    default:
        return state
    }
}

func errorReducer(state: Error?, action: Action) -> Error? {
    switch action {
    case let action as HandleError: return action.error
    case is DismissError: return nil
    default: return state}
}

func stateReducer(state: State, action: Action) -> State {
    return State(error: errorReducer(state: state.error, action: action),
                 loadedCardsState: loadedCardsReducer(state: state.loadedCardsState, action: action))
}

struct HandleNewCards: Action {
    let cards: GwentAPI.Response.Cards
}

struct HandleEndCards: Action {}

struct HandleError: Action {
    let error: Error
}

struct DismissError: Action {}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var allCards: AllCardsViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigation = storyboard.instantiateInitialViewController() as! UINavigationController
        allCards = navigation.viewControllers.first! as! AllCardsViewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        
        let store = Store<State>(initialState: State.initial,
                                 reducer: stateReducer)
        
        let command = Command {
            store.dispatch(loadMoreCards)
        }
        
        var id: Command? = nil
        id = store.subscribe { state in
            self.allCards.props = AllCardsViewController.select(from: state, onLastCardDisplay: command, onDeinit: id)
        }
        
        let _ = store.subscribe { [weak self] state in
            guard let error = state.error,
                let strongSelf = self else { return }
            let alert = UIAlertController(title: "Error",
                                          message: error.localizedDescription,
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: { _ in
                                            store.dispatch(action: DismissError())
            }))
            
            strongSelf.allCards.present(alert, animated: true)
        }
        
        command.perform()
        
        return true
    }
}

