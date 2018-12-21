//
//  TimeCardDetailsViewController.swift
//  Clocked
//
//  Created by Nix on 11/14/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class TimeCardDetailsViewController: UITableViewController {
    let cellId = "cellId"
    let datePickerCellId = "datePickerCellId"
    let managedContext: NSManagedObjectContext
    let payCycle: ManagedPayCycle
    var timeCard: ManagedTimeCard
    let newTimeCard: Bool
    var datePickerIndexPath: IndexPath?
    let timeCardDetails: TimeCardDetailsModel
    
    init (payCycle: ManagedPayCycle, prevTimeCard: ManagedTimeCard?, managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        self.payCycle = payCycle
        self.timeCard = prevTimeCard ?? ManagedTimeCard(context: managedContext)
        self.newTimeCard = prevTimeCard == nil
        self.timeCardDetails = TimeCardDetailsModel(timeCard: self.timeCard)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableView.self, forCellReuseIdentifier: cellId)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: datePickerCellId)
        
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "New Entry"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTimeCard(_:)))
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return timeCardDetails.items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && datePickerIndexPath != nil {
            return timeCardDetails.items[section].rowCount + 1
        }
        return timeCardDetails.items[section].rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = timeCardDetails.items
        
        if datePickerIndexPath == indexPath {
            guard let datePickerCell = tableView.dequeueReusableCell(withIdentifier: datePickerCellId) as? DatePickerTableViewCell else {
                return UITableViewCell() }
            let times = items[indexPath.section] as! TimeCardDetailsTimesItem
            datePickerCell.updateCell(date: times.times[indexPath.row - 1], indexPath: indexPath)
            datePickerCell.delegate = self
            return datePickerCell
        } else {
            // refactor and create custom cells
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            
            switch items[indexPath.section].type {
            case .times:
                let times = items[indexPath.section] as! TimeCardDetailsTimesItem
                cell.textLabel?.text = "\(times.times[indexPath.row])"
                return cell
            case .duration:
                let duration = items[indexPath.section] as! TimeCardDetailsDurationItem
                // refactor better naming
                cell.textLabel?.text = duration.hoursAndMins(from: duration.duration.duration)
            }
        }
    }
    
    @objc func saveTimeCard(_ sender: UIBarButtonItem) {
        
    }
}


