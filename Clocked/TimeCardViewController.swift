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
    var timeLabel: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "New Entry"
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        cell.textLabel?.text = "\(descriptions[indexPath.row]): \(timeLabel)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datePicker = DatePickerViewController()
        datePicker.delegate = self	
        navigationController?.pushViewController(datePicker, animated: true)
	
        tableView.reloadData()
    }
}

extension TimeCardViewController: DatePickerDelegate {
    func DateTimeSelected(value: String) {
        timeLabel = value
        tableView.reloadData()
    }
    
}
