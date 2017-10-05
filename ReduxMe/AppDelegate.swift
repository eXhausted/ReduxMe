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
    static let initial = State(error: nil, loadedCardsState: LoadedCardsState(loadedCards: [], nextURL: nil))
    let error: Error?
    let loadedCardsState: LoadedCardsState
}

struct LoadedCardsState {
    let loadedCards: [GwentAPI.Response.CardLink]
    let nextURL: URL?
}

func loadedCardsReducer(state: LoadedCardsState, action: Action) -> LoadedCardsState {
    switch action {
    case let action as HandleNewCards:
        return LoadedCardsState(loadedCards: state.loadedCards + action.cards.results,
                     nextURL: action.cards.next)
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
        
        let _ = store.subscribe { state in
            self.allCards.props = AllCardsViewController.select(from: state)
        }
        
        let _ = store.subscribe { state in
            
        }
        
        loadMoreCards(from: nil).onComplete(callback: store.dispatch)
        
//        loadMoreCards = Command {
//            api.getCards(url: store.state.nextURL)
//                .dispatch(on: .main)
//                .onSuccess{ store.dispatch(action: HandleNewCards(cards: $0)) }
//                .onError { [weak self] error in
//                    guard let strongSelf = self else { return }
//                    let alert = UIAlertController(title: "Can't receive card list", message: error.localizedDescription, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "ok :(", style: .cancel))
//                    strongSelf.allCards.present(alert, animated: true)
//            }
//        }
//
//        loadMoreCards?.perform()
        
        return true
    }
}

