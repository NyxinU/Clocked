//
//  NewTimeCardViewController.swift
//  Clocked
//
//  Created by Nix on 11/14/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
import Foundation

enum Rows: Int {
    case start = 0, end, duration
}

class TimeCardDetailsViewController: UITableViewController, DatePickerDelegate {
    let cellId = "cellId"
    let datePickerCellId = "datePickerCellId"
    let managedContext: NSManagedObjectContext
    let payCycle: ManagedPayCycle
    var timeCard: ManagedTimeCard
    let newTimeCard: Bool
    var timeCardDetails: [Any] = []
    var datePickerIndexPath: IndexPath?

    init (payCycle: ManagedPayCycle, prevTimeCard: ManagedTimeCard?, managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        self.payCycle = payCycle
        self.timeCard = prevTimeCard ?? ManagedTimeCard(context: managedContext)
        self.newTimeCard = prevTimeCard == nil
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(DatePickerTableViewCell.self,
                           forCellReuseIdentifier: datePickerCellId)
        
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "New Entry"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTimeCard(_:)))

        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        timeCardDetails = [timeCard.startTime as Any, timeCard.endTime as Any, timeCard.hoursAndMins(from: timeCard.startTime, to: timeCard.endTime) as Any]
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if datePickerIndexPath != nil {
            return timeCardDetails.count + 1
        } else {
            return timeCardDetails.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if datePickerIndexPath == indexPath {
            let datePickerCell = tableView.dequeueReusableCell(withIdentifier:   datePickerCellId) as!  DatePickerTableViewCell
            datePickerCell.updateCell(date: timeCardDetails[indexPath.row - 1] as? Date, indexPath: indexPath)
            datePickerCell.delegate = self
            
            return datePickerCell
        } else {
            let dateCell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
//            dateCell.updateText(text: inputTexts[indexPath.row], date:  timeCardDetails[indexPath.row])
            dateCell.textLabel?.text = "\(timeCardDetails[indexPath.row])"
            return dateCell
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
        // 1
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            self.datePickerIndexPath = nil
        } else {
            // 2
            if let datePickerIndexPath = datePickerIndexPath {
                tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            }
            datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
            tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
            tableView.deselectRow(at: indexPath, animated: true)
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
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // fix duration touch
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
//        let startTime: Date? = timeCard.startTime
//        let endTime: Date? = timeCard.endTime
//
//        var start: String = ""
//        var end: String = ""
//        let duration: String = timeCard.hoursAndMins(from: startTime, to: endTime)
//
//        if let startTime = startTime {
//            start = "\(startTime.dayOfWeek()) \(startTime.dateAsString()) at \(startTime.timeAsString())"
//        }
//
//        if let endTime = endTime {
//            end = "\(endTime.dayOfWeek()) \(endTime.dateAsString()) at \(endTime.timeAsString())"
//        }
//
//        if let row = Rows(rawValue: indexPath.row) {
//            switch row {
//            case .start:
//                cell.textLabel?.text = "Start \(start)"
//            case .end:
//                cell.textLabel?.text = "End \(end)"
//            case .duration:
//                cell.textLabel?.text = "Duration \(duration)"
//            }
//        }
//
//        return cell
//    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let datePicker = DatePickerViewController(indexPath: indexPath.row)
//        datePicker.delegate = self
//
//        if let row = Rows(rawValue: indexPath.row) {
//            switch row {
//            case .start:
//                if let startTime = timeCard.startTime {
//                    datePicker.datePicker.date = startTime
//                }
//            case .end:
//                if let endTime = timeCard.endTime {
//                    datePicker.datePicker.date = endTime
//                }
//            case .duration:
//                return
//            }
//        }
//
//        if indexPath.row != 2 {
//            navigationController?.pushViewController(datePicker, animated: true)
//        }
//    }
    
    func dateTimeSelected(value: Date) {
        if let row = Rows(rawValue: datePickerIndexPath!.row - 1) {
            // refactor
            switch row {
            case .start:
                timeCard.startTime = value
                timeCardDetails[datePickerIndexPath!.row - 1] = value
                tableView.reloadRows(at: [IndexPath(row: datePickerIndexPath!.row - 1, section: datePickerIndexPath!.section)], with: .automatic)
            case .end:
                timeCard.endTime = value
                timeCardDetails[datePickerIndexPath!.row - 1] = value
                tableView.reloadRows(at: [IndexPath(row: datePickerIndexPath!.row - 1, section: datePickerIndexPath!.section)], with: .automatic)
            default:
                return
            }
        }
    }
    
    @objc func saveTimeCard(_ sender: UIBarButtonItem) {
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
}
