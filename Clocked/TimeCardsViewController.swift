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
        
//        tableView.rowHeight = 60
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return timeCards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? TimeCardTableViewCell else {
            return UITableViewCell() }
        
        if indexPath.section == 0 {
            let totalHours = Int(payCycle.totalHours)
            cell.textLabel?.text = "Total: \(payCycle.hoursAndMins(from: totalHours))"
            return cell
        }
        
        let timeCard = timeCards[indexPath.row]
        let startTime: Date? = timeCard.startTime
        let endTime: Date? = timeCard.endTime
        
        cell.startDateLabel.text = "\(startTime?.dayOfWeek() ?? "") \(startTime?.dateAsString() ?? "")"
        cell.startTimeLabel.text = startTime?.timeAsString()
        cell.endTimeLabel.text = endTime?.timeAsString()
        cell.durationLabel.text = timeCard.hoursAndMins(from: startTime, to: endTime)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            return
        }
        let timeCardDetails = TimeCardDetailsViewController(payCycle: payCycle, prevTimeCard: timeCards[indexPath.row], managedContext: managedContext)
        
        navigationController?.pushViewController(timeCardDetails, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

            let timeCard: ManagedTimeCard = timeCards[indexPath.row]
            
            managedContext.delete(timeCard)
            do {
                try managedContext.save()
                timeCards.remove(at: indexPath.row)
                tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                updatePayCycle()
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    @objc func addTimeCardButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(TimeCardDetailsViewController(payCycle: payCycle, prevTimeCard: nil, managedContext: managedContext), animated: true)
    }
    
    func updatePayCycle() {
        var totalHours: Int = 0
        
        for index in stride(from: timeCards.count - 1, through: 0, by: -1) {
            if let startDate = timeCards[index].startTime {
                payCycle.startDate = startDate
                break
            }
        }
        
        for timeCard in timeCards {
            if let endDate = timeCard.endTime {
                payCycle.endDate = endDate
                break
            }
        }
        
        for managedTimeCard in timeCards {
            if let start = managedTimeCard.startTime, let end = managedTimeCard.endTime {
                totalHours += managedTimeCard.duration(from: start, to: end)
            }
        }
        
        payCycle.totalHours = Int64(totalHours)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

