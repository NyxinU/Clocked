//
//  NewTimeCardViewController.swift
//  Clocked
//
//  Created by Nix on 11/14/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
class TimeCardViewController: UITableViewController {
    
    let cellId = "cellId"
    var descriptions: [String] = ["Start", "End", "Duration"]
    var times: [String] = ["","",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "New Entry"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // do i need to cast?
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell

        cell.textLabel?.text = "\(descriptions[indexPath.row]): \(times[indexPath.row])"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-DD HH:mm:ss"
        
        times[indexPath.row] = formatter.string(from: Date())
        
        tableView.reloadData()
    }
}
