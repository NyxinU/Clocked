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

class TimeCardDetailsViewController: UITableViewController, DatePickerDelegate {
    let cellId = "cellId"
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
        self.newTimeCard = (prevTimeCard == nil)
        self.timeCardDetails = TimeCardDetailsModel(timeCard: self.timeCard, managedContext: managedContext)
        self.items = self.timeCardDetails.items
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: DatePickerTableViewCell.reuseIdentifier())
        
        navigationItem.title = "New Entry"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTimeCard(_:)))
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        
        if newTimeCard {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        
        let backgroundColor = #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)
        footerView.backgroundColor = backgroundColor
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch items[section].type {
//        case .timeStamps:
//            return "Time Stamps"
//        case .duration:
//            return "Duration"
//        case .purchases:
//            return "Purchases"
//        }
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items[section].type == .timeStamps && datePickerIndexPath != nil {
            return items[section].rowCount + 1
        }
        return items[section].rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if datePickerIndexPath == indexPath {
            let datePickerCell = setupDatePickerCell(indexPath: indexPath)

            return datePickerCell
        } else {
            // refactor and create custom cells
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            
            switch items[indexPath.section].type {
            case .timeStamps:
                let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
                let timeStamps = timeStampsItem.timeStamps
                
                cell.textLabel?.text = "\(timeStamps[indexPath.row]?.timeAsString() ?? "")"
                return cell
            case .duration:
                let durationItem = items[indexPath.section] as! TimeCardDetailsDurationItem
                
                // refactor better naming
                cell.textLabel?.text = durationItem.duration
                return cell
            case .purchases:
                return cell 
            }
        }
    }
    
    func setupDatePickerCell(indexPath: IndexPath) -> UITableViewCell {
        guard let datePickerCell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.reuseIdentifier()) as? DatePickerTableViewCell else {
            return UITableViewCell() }
        let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        
        datePickerCell.updateCell(date: timeStamps[indexPath.row - 1], indexPath: indexPath)
        datePickerCell.delegate = self
        
        return datePickerCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return DatePickerTableViewCell.height
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        // close open date picker
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
            tableView.deleteRows(at: [datePickerIndexPath], with: .automatic)
            self.datePickerIndexPath = nil
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            switch items[indexPath.section].type {
            case .timeStamps:
                // allow save after one time has been selected
                navigationItem.rightBarButtonItem?.isEnabled = true
                
                // close prev date picker
                if let datePickerIndexPath = datePickerIndexPath {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                }
                datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
                
                // add current time to cell if empty
                let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
                var timeStamps = timeStampsItem.timeStamps

                if timeStamps[datePickerIndexPath!.row - 1] == nil {
                    // fix for crash when delete and reload at same indexPath
                    tableView.endUpdates()
                    tableView.beginUpdates()
                    
                    timeStamps[datePickerIndexPath!.row - 1] = Date().roundDownToNearestFiveMin()
                    timeStampsItem.save(new: timeStamps)
                    tableView.reloadRows(at: [IndexPath(row: datePickerIndexPath!.row - 1, section: datePickerIndexPath!.section)], with: .automatic)
                    
                    updateDuration()
                }
            case .duration:
                tableView.deselectRow(at: indexPath, animated: false)
            case .purchases:
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
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        let section = datePickerIndexPath!.section
        let row = datePickerIndexPath!.row - 1
        let timeStampsItem = items[section] as! TimeCardDetailsTimeStampsItem
        var timeStamps = timeStampsItem.timeStamps

        timeStamps[row] = date
        timeStampsItem.save(new: timeStamps)
        
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        updateDuration()
    }
    
    func updateDuration() {
        let section = datePickerIndexPath!.section
        let timeStampsItem = items[section] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        
        guard let start = timeStamps[0], let end = timeStamps[1] else {
            return
        }
        
        let durationItem = items[1] as! TimeCardDetailsDurationItem
        
        durationItem.duration = hoursAndMins(from: start, to: end)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    @objc func saveTimeCard(_ sender: UIBarButtonItem) {
        let timeStampsItem = items[0] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        
        if let start = timeStamps[0], let end = timeStamps[1] {
            if duration(from: start, to: end) < 0 {
                presentAlert()
                return
            }
        }
        
        timeCard.startTime = timeStamps[0]
        timeCard.endTime = timeStamps[1]
        
        do {
            try managedContext.save()
            if newTimeCard {
                payCycle.addToTimeCards(timeCard)
            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        navigationController?.popViewController(animated: true)
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Invalid Time", message: "Entry's end cannot be before it's start.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

