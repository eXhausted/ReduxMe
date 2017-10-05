//
//  AppDelegate.swift
//  ReduxMe
//
//  Created by Bogdan Geleta on 10/5/17.
//  Copyright © 2017 Bogdan Geleta. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigation = storyboard.instantiateInitialViewController() as! UINavigationController
        let allCards = navigation.viewControllers.first! as! AllCardsViewController
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        
        let names = GwentAPI().getCards(url: nil).map { (cards: GwentAPI.Response.Cards) in
            return cards.results.map { $0.name }
        }
        
        names.dispatch(on: .main)
            .onSuccess{ allCards.props = .init(cards: $0) }
            .onError { error in
                let alert = UIAlertController(title: "Can't receive card list", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok :(", style: .cancel))
                allCards.present(alert, animated: true)
        }
        
        allCards.props = .init(cards: ["1", "2", "3"])
        
        return true
    }

}

