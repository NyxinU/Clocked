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
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext: NSManagedObjectContext
    var managedPayCycles: [ManagedPayCycle] = []
    
    init() {
        self.managedContext = appDelegate.persistentContainer.viewContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationItem()
    }
    
    func setupTableView() {
        tableView.register(PayCycleTableViewCell.self, forCellReuseIdentifier: PayCycleTableViewCell.reuseIdentifier())
        tableView.rowHeight = 45.0
        
        tableView.tableFooterView = UIView()
    }
    
    func setupNavigationItem() {
        navigationItem.title = "Pay Cycles"
        
        let backItem = UIBarButtonItem(title: "Pay Cycles", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPayCycleButtonAction(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        managedPayCycles = fetchPayCycles(from: managedContext, inAscending: false)
        tableView.reloadData()
        print(managedPayCycles)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return managedPayCycles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let payCycle: ManagedPayCycle = managedPayCycles[indexPath.row]
        let cell = setupPayCycleCell(for: payCycle)
        
        return cell 
    }
    
    func setupPayCycleCell(for payCycle: ManagedPayCycle) -> UITableViewCell {
        guard let payCycleCell = tableView.dequeueReusableCell(withIdentifier: PayCycleTableViewCell.reuseIdentifier()) as? PayCycleTableViewCell else {
            return UITableViewCell()
        }
        
        let startDate: String = payCycle.startDate?.dateAsString() ?? ""
        let endDate: String = payCycle.endDate?.dateAsString() ?? ""
        let totalHours: Int = Int(payCycle.totalHours)

        if startDate != "" && endDate != "" {
            payCycleCell.textLabel?.text = nil
            payCycleCell.dateRangeLabel.text = "\(startDate) - \(endDate)"
            payCycleCell.totalHoursLabel.text = hoursAndMins(from: totalHours)
        } else {
            payCycleCell.textLabel?.text = "New Entry"
        }
        
        return payCycleCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let timeCardViewController = TimeCardsViewController(payCycle: managedPayCycles[indexPath.row], managedContext: managedContext)
        
        navigationController?.pushViewController(timeCardViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            tableView.beginUpdates()
            
            let payCycleObject: ManagedPayCycle = managedPayCycles[indexPath.row]
            
            managedContext.delete(payCycleObject)
            do {
                try managedContext.save()
                managedPayCycles.remove(at: indexPath.row)
                tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: UITableView.RowAnimation.automatic)
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
            }
            
            tableView.endUpdates()
        }
    }
    
    @objc func addPayCycleButtonAction(_ sender: UIBarButtonItem) {
        tableView.beginUpdates()
        let payCycle: ManagedPayCycle = ManagedPayCycle(context: managedContext)
        
        do {
            try managedContext.save()
            managedPayCycles.insert(payCycle, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } catch let error as NSError {
            print("Could not add. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
        }
        
        tableView.endUpdates()
    }
}

