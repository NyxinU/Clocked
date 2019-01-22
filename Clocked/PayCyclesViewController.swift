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
        tableView.register(LRLabelTableViewCell.self, forCellReuseIdentifier: LRLabelTableViewCell.resuseIdentifier())
        tableView.register(PayCycleTableViewCell.self, forCellReuseIdentifier: PayCycleTableViewCell.reuseIdentifier())

        tableView.estimatedRowHeight = 45
        tableView.rowHeight = 45
        
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
        
        if fetchedPayCycles(from: managedContext, to: &managedPayCycles) {
           tableView.reloadData()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return managedPayCycles.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return setupTotalHoursCell()
        } else {
            return setupPayCycleCell(for: managedPayCycles[indexPath.row])
        }

    }
    
    func setupTotalHoursCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LRLabelTableViewCell.resuseIdentifier()) as? LRLabelTableViewCell else {
            return LRLabelTableViewCell()
        }
        
        cell.leftLabel.text = "Total"
        
        return cell
    }
    
    func setupPayCycleCell(for payCycle: ManagedPayCycle) -> UITableViewCell {
        guard let payCycleCell = tableView.dequeueReusableCell(withIdentifier: PayCycleTableViewCell.reuseIdentifier()) as? PayCycleTableViewCell else {
            return PayCycleTableViewCell()
        }
        
        let startDate: String = payCycle.startDate?.dateAsString() ?? ""
        let endDate: String = payCycle.endDate?.dateAsString() ?? ""
        let totalHours: Int = Int(payCycle.totalHours)

        if startDate != "" && endDate != "" {
            payCycleCell.dateRangeLabel.text = "\(startDate) - \(endDate)"
            payCycleCell.totalHoursLabel.text = hoursAndMins(from: totalHours)
        } else {
            payCycleCell.textLabel?.text = "New Entry"
        }
        
        return payCycleCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            return
        }
        
        let timeCardViewController = TimeCardsViewController(payCycle: managedPayCycles[indexPath.row], managedContext: managedContext)
        
        navigationController?.pushViewController(timeCardViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            
            if removed(from: &managedPayCycles, at: indexPath, in: managedContext) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    @objc func addPayCycleButtonAction(_ sender: UIBarButtonItem) {
        tableView.beginUpdates()
        
        let payCycle: ManagedPayCycle = ManagedPayCycle(context: managedContext)
        
        
        do {
            try managedContext.save()
            let timeCardViewController = TimeCardsViewController(payCycle: payCycle, managedContext: managedContext)
            navigationController?.pushViewController(timeCardViewController, animated: true)
        } catch let error as NSError {
            print("Could not add. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
        }
        
        tableView.endUpdates()
    }
}

