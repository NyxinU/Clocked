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

class TimeCardDetailsViewController: UITableViewController, DatePickerDelegate {
    init (payCycle: ManagedPayCycle, prevTimeCardObject: ManagedTimeCard?) {
        self.payCycle = payCycle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var indexPath: Int?
    let cellId = "cellId"
    let payCycle: ManagedPayCycle
    var prevTimeCardObject: ManagedTimeCard?
    var timeCard: TimeCard = TimeCard()
    
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
        var start: String = ""
        var end: String = ""
        var duration: String = ""
        
        if let startTime = timeCard.startTime {
            start = "\(startTime.dayOfWeek()) \(startTime.dateAsString()) at \(startTime.timeAsString())"
        }
        
        if let endTime = timeCard.endTime {
            end = "\(endTime.dayOfWeek()) \(endTime.dateAsString()) at \(endTime.timeAsString())"
        }

        if let timeElapsed = timeCard.durationAsString {
            duration = timeElapsed
        }
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Start \(start)"
        case 1:
            cell.textLabel?.text = "End \(end)"
        case 2:
            cell.textLabel?.text = "Duration \(duration)"
        default:
            cell.textLabel?.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datePicker = DatePickerViewController()
        datePicker.delegate = self
        self.indexPath = indexPath.row
        
        switch indexPath.row {
        case 0:
            if let startTime = timeCard.startTime {
                datePicker.datePicker.date = startTime
            }
        case 1:
            if let endTime = timeCard.endTime {
                datePicker.datePicker.date = endTime
            }
        default:
            return 
        }
        
        if indexPath.row != 2 {
            navigationController?.pushViewController(datePicker, animated: true)
        }
	
        tableView.reloadData()
    }
    
    func DateTimeSelected(value: Date) {
        switch indexPath {
        case 0:
            timeCard.startTime = value
        case 1:
            timeCard.endTime = value
        default:
            return
        }
        tableView.reloadData()
    }
    
    @objc func saveTimeCard(_ sender: UIBarButtonItem) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        var timeCardObject: ManagedTimeCard
        
        if let prevTimeCardObject = prevTimeCardObject {
            timeCardObject = prevTimeCardObject
        } else {
            timeCardObject = ManagedTimeCard(context: managedContext)
        }
        
        if let startTime = timeCard.startTime {
            timeCardObject.startTime = startTime
            
        }
        
        if let endTime = timeCard.endTime {
            timeCardObject.endTime = endTime
        }

        do {
            payCycle.addToTimeCards(timeCardObject)
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        navigationController?.popViewController(animated: true)
    }
}
