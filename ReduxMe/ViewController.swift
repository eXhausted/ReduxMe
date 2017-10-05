//
//  ViewController.swift
//  ReduxMe
//
//  Created by Bogdan Geleta on 10/5/17.
//  Copyright © 2017 Bogdan Geleta. All rights reserved.
//

import UIKit
import Gwent_API

struct Command {
//    let file: StaticString
//    let function: StaticString
//    let line: Int
    
    let perform: () -> ()
    
    init(
//        file: StaticString = #file,
//         function: StaticString = #function,
//         line: Int = #line,
         _ perform: @escaping ()-> ()) {
        self.perform = perform
//        self.file = file
//        self.function = function
//        self.line = line
    }
}

class AllCardsViewController: UIViewController {
    @IBOutlet var tableView: UITableView?
    struct Props {
        ///#1
        let cards: [String]
        let onLastCardDisplay: Command?
        let onDeinit: Command?
    }
    
    var props = Props(cards: [], onLastCardDisplay: nil, onDeinit: nil) {
        didSet { tableView?.reloadData() } // setNeedsLayout
    }
    
    deinit {
        props.onDeinit?.perform()
    }
}

extension AllCardsViewController: UITableViewDelegate {}

extension AllCardsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return props.cards.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(props.cards.indices.contains(indexPath.row), "Out of range")
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else {
            fatalError("Can't get card cell from \(tableView)")
        }
        
        cell.textLabel?.text = props.cards[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(props.cards.indices.last, indexPath.row)
        guard props.cards.indices.last == indexPath.row else { return }
        props.onLastCardDisplay?.perform()
    }
}

extension AllCardsViewController {
    static func select(from state: State, onLastCardDisplay: Command?, onDeinit: Command?) -> Props {
        let names = state.loadedCardsState.loadedCards.map { $0.name }
        return Props(cards: names, onLastCardDisplay: onLastCardDisplay, onDeinit: onDeinit)
    }
}
