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
    var cummulativeHours: Int = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let managedContext: NSManagedObjectContext
    var managedPayCycles: [ManagedPayCycle] = []
    
    init() {
        self.managedContext = appDelegate.persistentContainer.viewContext
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pushVCWithFirstPayCycle()
        
        setupTableView()
        setupNavigationItem()
    }
    
    func pushVCWithFirstPayCycle() {
        if fetchedPayCycles(from: managedContext, to: &managedPayCycles), managedPayCycles.count > 0 {
            let timeCardViewController = TimeCardsViewController(payCycle: managedPayCycles[0], managedContext: managedContext)
            navigationController?.pushViewController(timeCardViewController, animated: false)
        }
    }
    
    func setupTableView() {
        tableView.register(LRLabelTableViewCell.self, forCellReuseIdentifier: LRLabelTableViewCell.resuseIdentifier())
        tableView.register(PayCycleTableViewCell.self, forCellReuseIdentifier: PayCycleTableViewCell.reuseIdentifier())
        tableView.register(HeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderFooterView.reuseIdentifier())
        
        let footerView = { () -> HeaderFooterView in
            guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderFooterView.reuseIdentifier()) as? HeaderFooterView else {
                return HeaderFooterView()
            }
            return view
        }()
        
        tableView.backgroundColor = #colorLiteral(red: 0.9418308139, green: 0.9425446987, blue: 0.9419413209, alpha: 1)
        tableView.tableFooterView = footerView
        
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = 45
    }
    
    func setupNavigationItem() {
        navigationItem.title = "Pay Cycles"
        
        let backItem = UIBarButtonItem(title: "Pay Cycles", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPayCycleButtonAction(_:)))
    }
    
    func dismissToolbar() {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissToolbar()
        if fetchedPayCycles(from: managedContext, to: &managedPayCycles) {
            calculateCumulativeHours()
            tableView.reloadData()
        }
    }
    
    func calculateCumulativeHours() {
        cummulativeHours = Int(managedPayCycles.reduce(0, { $0 + $1.totalHours }))
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
        cell.rightLabel.text = "\(hoursAndMins(from: cummulativeHours))"
        
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            self.presentDeleteConfirmation(for: indexPath, completion: completion)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    func presentDeleteConfirmation(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this pay cycle?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) in
            completion(false)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (alert: UIAlertAction!) in
            self.handleDelete(at: indexPath, completion: completion)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func handleDelete(at indexPath: IndexPath, completion: (Bool) -> Void) {
        tableView.beginUpdates()

        if removed(from: &managedPayCycles, at: indexPath, in: managedContext) {
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
            calculateCumulativeHours()
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        tableView.endUpdates()
    }
    
    @objc func addPayCycleButtonAction(_ sender: UIBarButtonItem) {
        tableView.beginUpdates()
        
        let payCycle: ManagedPayCycle = ManagedPayCycle(context: managedContext)
        
        
        do {
            try managedContext.save()
            let timeCardViewController = TimeCardsViewController(payCycle: payCycle, managedContext: managedContext)
            navigationController?.pushViewController(timeCardViewController, animated: true)
        } catch let error as NSError {
            print("Could not add. \(error), \(error.userInfo)")
        }
        
        tableView.endUpdates()
    }
}

