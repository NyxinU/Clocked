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
    
    let managedContext: NSManagedObjectContext
    let payCycle: ManagedPayCycle
    var timeCards: [ManagedTimeCard] = []
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
        
        setupTableView()
        setupNavigationItem()
    }
    
    func setupTableView() {
        tableView.register(TotalHoursTableViewCell.self, forCellReuseIdentifier: TotalHoursTableViewCell.resuseIdentifier())
        tableView.register(TimeCardTableViewCell.self, forCellReuseIdentifier: TimeCardTableViewCell.reuseIdentifier())

        tableView.rowHeight = 45.0
    }
    
    func setupNavigationItem() {
        navigationItem.title = "Time Cards"
        
        let backItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTimeCardButtonAction(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupToolbar()
        
        if fetchedTimeCards(from: managedContext, for: payCycle, to: &timeCards) {
            if timeCards.count > 0 {
                updatePayCycleAttrs(with: timeCards, for: payCycle, in: managedContext)
            }
            tableView.reloadData()
        }
    }
    
    func setupToolbar() {
        navigationController?.setToolbarHidden(false, animated: true)
        var items:[UIBarButtonItem] = []
        let shareButton =  UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonAction(_:)))
        
        items.append(shareButton)
        self.setToolbarItems(items, animated: true)
    }
    
    @objc func shareButtonAction(_ sender: UIBarButtonItem) {
        var items: [String] = []
        let purchases = fetchPurchases(from: managedContext, for: payCycle)
        let parsed = timeCardsToString(managedTimeCards: timeCards, totalHours: payCycle.totalHours, managedPurchases: purchases)

        items.append(parsed)
        
        let activityViewController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
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
            return setupTotalHoursCell()
        } else {
            return setupTimeCardTableViewCell(for: timeCards[indexPath.row])
        }
    }
    
    func setupTotalHoursCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TotalHoursTableViewCell.resuseIdentifier()) as? TotalHoursTableViewCell else {
            return UITableViewCell()
        }
        let totalHours = Int(payCycle.totalHours)
        
        cell.amountLabel.text = hoursAndMins(from: totalHours)
        
        return cell
    }
    
    func prepTimeCardCellForResuse(_ cell: TimeCardTableViewCell) {
        cell.textLabel?.text = nil
        cell.startDateLabel.text = nil
        cell.startTimeLabel.text = nil
        cell.endTimeLabel.text = nil
        cell.durationLabel.text = nil
    }
    
    func setupTimeCardTableViewCell(for timeCard: ManagedTimeCard) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCardTableViewCell.reuseIdentifier()) as? TimeCardTableViewCell else {
            return UITableViewCell()
        }
        
        let startTime: Date? = timeCard.startTime
        let endTime: Date? = timeCard.endTime
        
        cell.startDateLabel.text = "\(startTime?.dayOfWeek() ?? "") \(startTime?.dateAsString() ?? "")"
        cell.startTimeLabel.text = startTime?.timeAsString()
        cell.endTimeLabel.text = endTime?.timeAsString()
        cell.durationLabel.text = hoursAndMins(from: startTime, to: endTime)
        
        return cell
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
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            
            if removed(from: &timeCards, at: indexPath, in: managedContext) {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                updatePayCycleAttrs(with: timeCards, for: payCycle, in: managedContext)
            }
            tableView.endUpdates()
        }
    }
    
    @objc func addTimeCardButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(TimeCardDetailsViewController(payCycle: payCycle, prevTimeCard: nil, managedContext: childManagedObjectContext), animated: true)
    }
}

