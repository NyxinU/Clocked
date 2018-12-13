//
//  PayCycleViewController.swift
//  Clocked
//
//  Created by Nix on 12/4/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData

class PayCyclesViewController: UITableViewController {
    // what does this cellId mean?
    let cellId = "cellId"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext: NSManagedObjectContext
    var payCycles: [ManagedPayCycle] = []
    
    init() {
        self.managedContext = appDelegate.persistentContainer.viewContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
        
        navigationItem.title = "Pay Cycles"
        
        let backItem = UIBarButtonItem()
        backItem.title = "Pay Cycles"
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addPayCycleButtonAction(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<ManagedPayCycle>(entityName: "ManagedPayCycle")
        
        let sort = NSSortDescriptor(key: #keyPath(ManagedPayCycle.startDate), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            payCycles = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payCycles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        cell.textLabel?.text = "New Pay Cycle"
        
        let startDate = payCycles[indexPath.row].startDate?.dateAsString() ?? ""
        let endDate = payCycles[indexPath.row].endDate?.dateAsString() ?? ""
        let totalHours = payCycles[indexPath.row].totalHours
        
        let hours = Int(totalHours / 3600)
        let minutes = Int((totalHours / 60).truncatingRemainder(dividingBy: 60))
        
        if startDate != "" && endDate != "" {
           cell.textLabel?.text = "Start: \(startDate) End: \(endDate) \(hours) h \(minutes) m"
        }
        
        return cell 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timeCardViewController = TimeCardsViewController(payCycle: payCycles[indexPath.row])
        
        navigationController?.pushViewController(timeCardViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            let payCycleObject: ManagedPayCycle = payCycles[indexPath.row]
            
            payCycles.remove(at: indexPath.row)
            managedContext.delete(payCycleObject)
            do {
                try managedContext.save()
                tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableView.RowAnimation.automatic)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    @objc func addPayCycleButtonAction(_ sender: UIBarButtonItem) {
        let payCycle: ManagedPayCycle = ManagedPayCycle(context: managedContext)
        
        do {
            try managedContext.save()
            payCycles.append(payCycle)
            tableView.insertRows(at: [IndexPath(row: payCycles.count - 1, section: 0)], with: .automatic)
        } catch let error as NSError {
            print("Could not add. \(error), \(error.userInfo)")
        }
    }
}

