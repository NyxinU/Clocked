//
//  ViewController.swift
//  Clocked
//
//  Created by Nix on 11/12/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
class TimeCardsViewController: UITableViewController {
    
    let cellId = "cellId"
    var timecards: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TimeCardTableViewCell.self, forCellReuseIdentifier: cellId)
        
        navigationItem.title = "Time Cards"
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action:#selector(addTimeCardButtonAction(_:)))
        
        tableView.rowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<TimeCards>(entityName: "TimeCards")
        let sort = NSSortDescriptor(key: #keyPath(TimeCards.startTime), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            timecards = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return timecards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? TimeCardTableViewCell else {
            return UITableViewCell() }
        
        let startTime: Date? = timecards[indexPath.row].value(forKeyPath: "startTime") as? Date
        let endTime: Date? = timecards[indexPath.row].value(forKeyPath: "endTime") as? Date

        let timecard: TimeCard = TimeCard()
        timecard.startTime = startTime
        timecard.endTime = endTime
        
        cell.startDateLabel.text = "\(startTime?.dayOfWeek() ?? "") \(startTime?.dateAsString() ?? "")"
        cell.startTimeLabel.text = startTime?.timeAsString()
        cell.endTimeLabel.text = endTime?.timeAsString()
        cell.durationLabel.text = timecard.durationAsString
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timeCardDetails = TimeCardDetailsViewController()
        
        let startTime: Date? = timecards[indexPath.row].value(forKeyPath: "startTime") as? Date
        let endTime: Date? = timecards[indexPath.row].value(forKeyPath: "endTime") as? Date

        timeCardDetails.timeCard.startTime = startTime
        timeCardDetails.timeCard.endTime = endTime
        timeCardDetails.prevTimeCardObject = timecards[indexPath.row]        
        navigationController?.pushViewController(timeCardDetails, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            let timeCardObject: NSManagedObject = timecards[indexPath.row]
            
            timecards.remove(at: indexPath.row)
            managedContext.delete(timeCardObject)
            do {
                try managedContext.save()
                tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableView.RowAnimation.automatic)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    @objc func addTimeCardButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(TimeCardDetailsViewController(), animated: true)
    }

}

