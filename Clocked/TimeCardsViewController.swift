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
    let managedContext: NSManagedObjectContext
    let payCycle: ManagedPayCycle
    var timeCards: [ManagedTimeCard] = []
    
    init (payCycle: ManagedPayCycle, managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        self.payCycle = payCycle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        let fetchRequest = NSFetchRequest<ManagedTimeCard>(entityName: "ManagedTimeCard")
        
        let sort = NSSortDescriptor(key: #keyPath(ManagedTimeCard.startTime), ascending: false)
        fetchRequest.predicate = NSPredicate(format: "payCycle == %@", payCycle)
        fetchRequest.sortDescriptors = [sort]
        do {
            timeCards = try managedContext.fetch(fetchRequest)
            if timeCards.count > 0 {
                updatePayCycle()
            }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return timeCards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? TimeCardTableViewCell else {
            return UITableViewCell() }
        
        let startTime: Date? = timeCards[indexPath.row].value(forKeyPath: "startTime") as? Date
        let endTime: Date? = timeCards[indexPath.row].value(forKeyPath: "endTime") as? Date

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
        let timeCardDetails = TimeCardDetailsViewController(payCycle: payCycle, prevTimeCardObject: timeCards[indexPath.row])
        
        let startTime: Date? = timeCards[indexPath.row].value(forKeyPath: "startTime") as? Date
        let endTime: Date? = timeCards[indexPath.row].value(forKeyPath: "endTime") as? Date

        timeCardDetails.timeCard.startTime = startTime
        timeCardDetails.timeCard.endTime = endTime
        navigationController?.pushViewController(timeCardDetails, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            let timeCardObject: ManagedTimeCard = timeCards[indexPath.row]
            
            timeCards.remove(at: indexPath.row)
            managedContext.delete(timeCardObject)
            do {
                try managedContext.save()
                tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                updatePayCycle()
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    @objc func addTimeCardButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(TimeCardDetailsViewController(payCycle: payCycle, prevTimeCardObject: nil), animated: true)
    }
    
    func updatePayCycle() {
        var totalHours: Double = 0.0
        payCycle.startDate = timeCards.last?.startTime
        
        for timeCard in timeCards {
            if let endDate = timeCard.endTime {
                payCycle.endDate = endDate
                break
            }
        }
        
        for managedTimeCard in timeCards {
            if let startTime = managedTimeCard.startTime, let endTime = managedTimeCard.endTime {
                let timeCard = TimeCard()
                timeCard.startTime = startTime
                timeCard.endTime = endTime
                
                totalHours += timeCard.durationInMins!
            }
        }
        payCycle.totalHours = totalHours
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

