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
    let managedContext: NSManagedObjectContext
    let payCycle: ManagedPayCycle
    var timeCard: ManagedTimeCard
    let newTimeCard: Bool

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
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "New Entry"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTimeCard(_:)))

        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if (timeCard.startTime == nil) && (timeCard.endTime == nil) {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // fix duration touch 
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let startTime: Date? = timeCard.startTime
        let endTime: Date? = timeCard.endTime

        var start: String = ""
        var end: String = ""
        let duration: String = timeCard.durationAsString(start: startTime, end: endTime)

        if let startTime = startTime {
            start = "\(startTime.dayOfWeek()) \(startTime.dateAsString()) at \(startTime.timeAsString())"
        }

        if let endTime = endTime {
            end = "\(endTime.dayOfWeek()) \(endTime.dateAsString()) at \(endTime.timeAsString())"
        }

        if let row = Rows(rawValue: indexPath.row) {
            switch row {
            case .start:
                cell.textLabel?.text = "Start \(start)"
            case .end:
                cell.textLabel?.text = "End \(end)"
            case .duration:
                cell.textLabel?.text = "Duration \(duration)"
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datePicker = DatePickerViewController(indexPath: indexPath.row)
        datePicker.delegate = self
//        self.indexPath = indexPath.row
        
        if let row = Rows(rawValue: indexPath.row) {
            switch row {
            case .start:
                if let startTime = timeCard.startTime {
                    datePicker.datePicker.date = startTime
                }
            case .end:
                if let endTime = timeCard.endTime {
                    datePicker.datePicker.date = endTime
                }
            case .duration:
                return
            }
        }
        
        if indexPath.row != 2 {
            navigationController?.pushViewController(datePicker, animated: true)
        }
    }
    
    func dateTimeSelected(value: Date, indexPath: Int) {
        switch indexPath {
        case 0:
            timeCard.startTime = value
        case 1:
            timeCard.endTime = value
        default:
            return
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
