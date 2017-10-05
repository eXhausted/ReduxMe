//
//  ViewController.swift
//  ReduxMe
//
//  Created by Bogdan Geleta on 10/5/17.
//  Copyright © 2017 Bogdan Geleta. All rights reserved.
//

import UIKit

class AllCardsViewController: UIViewController {
    @IBOutlet var tableView: UITableView?
    struct Props {
        ///#1
        let cards: [String]
    }
    
    var props = Props(cards: []) {
        didSet { tableView?.reloadData() } // setNeedsLayout
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
}
