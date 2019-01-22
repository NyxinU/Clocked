//
//  TableViewExtensions.swift
//  Clocked
//
//  Created by Nix on 1/22/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewController {
    func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: -19, left: 0, bottom: 0, right: 0)
        
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = 45
    }
}
