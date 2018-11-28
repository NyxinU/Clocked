//
//  NewTimeCardViewController.swift
//  Clocked
//
//  Created by Nix on 11/14/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData

class TimeCardViewController: UITableViewController, DatePickerDelegate {
    var indexPath: Int?
    let cellId = "cellId"
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
            start = startTime.stringified()
        }
        
        if let endTime = timeCard.endTime {
            end = endTime.stringified()
        }

        if let timeElapsed = timeCard.duration {
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
        
        let entity = NSEntityDescription.entity(forEntityName: "TimeCards", in: managedContext)!
        
        let timeCardObject = NSManagedObject(entity: entity, insertInto: managedContext)
        
        if let startTime = timeCard.startTime {
            timeCardObject.setValue(startTime, forKey: "startTime")
        }
        
        if let endTime = timeCard.endTime {
            timeCardObject.setValue(endTime, forKey: "endTime")
        }
        
        do {
            try managedContext.save()
            print(managedContext.registeredObjects)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        navigationController?.popViewController(animated: true)
    }
}
