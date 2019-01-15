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
    var purchases: [ManagedPurchase] = []
    private lazy var childManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.parent = self.managedContext
        
        return managedObjectContext
    }()
    
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(TimeCardTableViewCell.self, forCellReuseIdentifier: TimeCardTableViewCell.reuseIdentifier())
        
        navigationItem.title = "Time Cards"
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        backItem.target = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action:#selector(addTimeCardButtonAction(_:)))
        
//        tableView.rowHeight = 60
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // add toolbar
        navigationController?.setToolbarHidden(false, animated: true)
        var items:[UIBarButtonItem] = []
        let shareButton =  UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonAction(_:)))
        items.append(shareButton)
        self.setToolbarItems(items, animated: true)
        
        // fetch timecards
        let fetchRequest = NSFetchRequest<ManagedTimeCard>(entityName: "ManagedTimeCard")
        
        let sort = NSSortDescriptor(key: #keyPath(ManagedTimeCard.startTime), ascending: false)
        fetchRequest.predicate = NSPredicate(format: "payCycle == %@", payCycle)
        fetchRequest.sortDescriptors = [sort]
//        fetchRequest.relationshipKeyPathsForPrefetching = ["purchases"]
        let purchasesRequest = NSFetchRequest<ManagedPurchase>(entityName: "ManagedPurchase")
        purchasesRequest.predicate = NSPredicate(format: "timeCard.payCycle == %@", payCycle)
        
        
        do {
            timeCards = try managedContext.fetch(fetchRequest)
            purchases = try managedContext.fetch(purchasesRequest)
            if timeCards.count > 0 {
                updatePayCycle()
            }
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc func shareButtonAction(_ sender: UIBarButtonItem) {
        var items: [String] = []
        let parsed = timeCardsToString(managedTimeCards: timeCards, totalHours: payCycle.totalHours, managedPurchases: purchases)
        items.append(parsed)
        
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
//        if let popoverPresentationController = activityViewController.popoverPresentationController {
//            popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
//        }
        present(activityViewController, animated: true, completion: nil)
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
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            let totalHours = Int(payCycle.totalHours)
            
            cell.textLabel?.text = "Total: \(hoursAndMins(from: totalHours))"
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCardTableViewCell.reuseIdentifier()) as? TimeCardTableViewCell else {
                return UITableViewCell()
            }
            let timeCard = timeCards[indexPath.row]
            let startTime: Date? = timeCard.startTime
            let endTime: Date? = timeCard.endTime
            
            cell.startDateLabel.text = "\(startTime?.dayOfWeek() ?? "") \(startTime?.dateAsString() ?? "")"
            cell.startTimeLabel.text = startTime?.timeAsString()
            cell.endTimeLabel.text = endTime?.timeAsString()
            cell.durationLabel.text = hoursAndMins(from: startTime, to: endTime)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        let timeCardDetails = TimeCardDetailsViewController(payCycle: payCycle, prevTimeCard: timeCards[indexPath.row], managedContext: childManagedObjectContext)
        
        navigationController?.pushViewController(timeCardDetails, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != 0 {
            return true
        }
        return false 
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            
            let timeCard: ManagedTimeCard = timeCards[indexPath.row]
            
            managedContext.delete(timeCard)

            do {
                try managedContext.save()
                timeCards.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                updatePayCycle()
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
        tableView.endUpdates()
    }
    
    @objc func addTimeCardButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(TimeCardDetailsViewController(payCycle: payCycle, prevTimeCard: nil, managedContext: childManagedObjectContext), animated: true)
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
                totalHours += duration(from: start, to: end)
            }
        }
        
        payCycle.totalHours = Int32(totalHours)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

