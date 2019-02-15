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
    var clockInButton: UIBarButtonItem!
    var clockOutButton: UIBarButtonItem!
    var items = [UIBarButtonItem]()
    
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

        super.init(style: .plain)
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
        tableView.register(TimeCardTableViewCell.self, forCellReuseIdentifier: TimeCardTableViewCell.reuseIdentifier())
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
        navigationItem.title = "Time Cards"
        
        let backItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTimeCardButtonAction(_:)))
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 50
        } else {
            return 45 
        }
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
        items = []
        navigationController?.setToolbarHidden(false, animated: true)
        let shareButton =  UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonAction(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        clockInButton = UIBarButtonItem(title: "Clock In Now", style: .plain, target: self, action: #selector(clockInButtonAction(_:)))
        clockOutButton = UIBarButtonItem(title: "Clock Out Now", style: .plain, target: self, action: #selector(clockOutButtonAction(_:)))
        
        items.append(shareButton)
        items.append(space)

        if payCycle.activeTimeCard == nil {
            items.append(clockInButton)
        } else {
            items.append(clockOutButton)
        }
        
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
    
    @objc func clockInButtonAction(_ sender: UIBarButtonItem) {
        let currentTime = Date().roundDownToNearestFiveMin()
        let newTimeCard = ManagedTimeCard(context: managedContext)
        newTimeCard.startTime = currentTime
        payCycle.activeTimeCard = newTimeCard
        
        do {
            try managedContext.save()
            
            _ = items.popLast()
            items.append(clockOutButton)
            setToolbarItems(items, animated: true)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    @objc func clockOutButtonAction(_ sender: UIBarButtonItem) {
        let currentTime = Date().roundDownToNearestFiveMin()
        guard let timeCard = payCycle.activeTimeCard else {
            return
        }
        timeCard.endTime = currentTime
        payCycle.addToTimeCards(timeCard)
        payCycle.activeTimeCard = nil
        
        do {
            try managedContext.save()
            
            timeCards.insert(timeCard, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
            _ = items.popLast()
            updatePayCycleAttrs(with: timeCards, for: payCycle, in: managedContext)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            items.append(clockInButton)
            setToolbarItems(items, animated: true)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
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
        if indexPath.section == 0 {
            return setupTotalHoursCell()
        } else {
            return setupTimeCardTableViewCell(for: timeCards[indexPath.row])
        }
    }
    
    func setupTotalHoursCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LRLabelTableViewCell.resuseIdentifier()) as? LRLabelTableViewCell else {
            return UITableViewCell()
        }
        let totalHours = Int(payCycle.totalHours)
        
        cell.leftLabel.text = "Total"
        cell.rightLabel.text = hoursAndMins(from: totalHours)
        
        return cell
    }
    
    func setupTimeCardTableViewCell(for timeCard: ManagedTimeCard) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCardTableViewCell.reuseIdentifier()) as? TimeCardTableViewCell else {
            return TimeCardTableViewCell()
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completion) in
            self.presentDeleteConfirmation(for: indexPath, completion: completion)
        }
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
    }
    
    func presentDeleteConfirmation(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this time card?", preferredStyle: .alert)
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
        if removed(from: &timeCards, at: indexPath, in: managedContext) {
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            updatePayCycleAttrs(with: timeCards, for: payCycle, in: managedContext)
        }
        tableView.endUpdates()
    }
    
    @objc func addTimeCardButtonAction(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(TimeCardDetailsViewController(payCycle: payCycle, prevTimeCard: nil, managedContext: childManagedObjectContext), animated: true)
    }
}

