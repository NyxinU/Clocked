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
    var items: [TimeCardDetailsItem]
    
    init (payCycle: ManagedPayCycle, prevTimeCard: ManagedTimeCard?, managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        self.payCycle = payCycle
        self.timeCard = prevTimeCard ?? ManagedTimeCard(context: managedContext)
        self.newTimeCard = prevTimeCard == nil
        self.timeCardDetails = TimeCardDetailsModel(timeCard: self.timeCard)
        self.items = self.timeCardDetails.items
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
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
                cell.textLabel?.text = "\(times.times[indexPath.row]?.timeAsString() ?? "")"
                return cell
            case .duration:
                let duration = items[indexPath.section] as! TimeCardDetailsDurationItem
                // refactor better naming
                cell.textLabel?.text = duration.duration
                return cell 
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return 216.0
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        
        // close date picker if open
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            self.datePickerIndexPath = nil
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            switch items[indexPath.section].type {
            case .times:
                if let datePickerIndexPath = datePickerIndexPath {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                }
                datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
                // refactor
                let times = items[indexPath.section] as! TimeCardDetailsTimesItem
                if times.times[datePickerIndexPath!.row - 1] == nil {
                    // fix for crash when delete and reload same at indexPath
                    tableView.endUpdates()
                    tableView.beginUpdates()
                    
                    times.times[datePickerIndexPath!.row - 1] = Date().asNearestFiveMin()
                    tableView.reloadRows(at: [IndexPath(row: datePickerIndexPath!.row - 1, section: datePickerIndexPath!.section)], with: .automatic)
                }
            case .duration:
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
        tableView.endUpdates()
    }
    
    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    func dateTimeSelected(date: Date) {
        let section = datePickerIndexPath!.section
        let row = datePickerIndexPath!.row - 1
        let times = items[section] as! TimeCardDetailsTimesItem
        
        times.times[row] = date
        
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        updateDuration()
    }
    
    func updateDuration() {
        let section = datePickerIndexPath!.section
        let times = items[section] as! TimeCardDetailsTimesItem
        
        guard let start = times.times[0], let end = times.times[1] else {
            return
        }
        
        let timeCardDetailsDurationItem = items[1] as! TimeCardDetailsDurationItem
        
        timeCardDetailsDurationItem.duration = hoursAndMins(from: start, to: end)
        
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    @objc func saveTimeCard(_ sender: UIBarButtonItem) {
        
    }
}


