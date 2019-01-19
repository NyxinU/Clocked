//
//  TimeCardDetailsViewController.swift
//  Clocked
//
//  Created by Nix on 11/14/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class TimeCardDetailsViewController: UITableViewController, DatePickerDelegate, CloseDatePickerDelegate {
    let managedContext: NSManagedObjectContext
    let payCycle: ManagedPayCycle
    var timeCard: ManagedTimeCard
    let newTimeCard: Bool
    var datePickerIndexPath: IndexPath?
    let timeCardDetails: TimeCardDetailsModel
    var items: [TimeCardDetailsItem]
    
    init (payCycle: ManagedPayCycle, prevTimeCard: ManagedTimeCard?, managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        self.payCycle = payCycle
        self.timeCard = prevTimeCard ?? ManagedTimeCard(context: managedContext)
        self.newTimeCard = (prevTimeCard == nil)
        self.timeCardDetails = TimeCardDetailsModel(timeCard: self.timeCard, managedContext: managedContext)
        self.items = self.timeCardDetails.items
        
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
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: DatePickerTableViewCell.reuseIdentifier())
        tableView.register(PurchaseTableViewCell.self, forCellReuseIdentifier: PurchaseTableViewCell.reuseIdentifier())
        
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = 45
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //tap does not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    func setupNavigationItem() {
        if newTimeCard {
            navigationController?.title = "New Entry"
        } else {
            navigationController?.title = "Edit Entry"
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonAction(_:)))
        
        let backItem = UIBarButtonItem(barButtonSystemItem: .camera, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        
        if newTimeCard {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items[section].type == .timeStamps && datePickerIndexPath != nil {
            return items[section].rowCount + 1
        } else if items[section].type == .purchases {
            return items[section].rowCount + 1
        }
        return items[section].rowCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if datePickerIndexPath == indexPath {
            let datePickerCell = setupDatePickerCell(indexPath: indexPath)

            return datePickerCell
        } else {
            // refactor and create custom cells
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LRLabelTableViewCell.resuseIdentifier()) as? LRLabelTableViewCell else {
                return LRLabelTableViewCell()
            }
            
            switch items[indexPath.section].type {
            case .timeStamps:
                let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
                let timeStamps = timeStampsItem.timeStamps
                let timestamp = timeStamps[indexPath.row]
                
                if indexPath.row == 0 {
                    cell.leftLabel.text = "Start"
                } else if indexPath.row == 1 {
                    cell.leftLabel.text = "End"
                }
                
                cell.rightLabel.text = "\(timestamp?.dayOfWeek() ?? "") \(timestamp?.dateAsString() ?? "") at \(timestamp?.timeAsString() ?? "")"
                
                return cell
            case .duration:
                let durationItem = items[indexPath.section] as! TimeCardDetailsDurationItem
                
                cell.leftLabel.text = "Duration"
                cell.rightLabel.text = durationItem.duration
                
                return cell
            case .purchases:
                // refactor replace with add purchase button
                if indexPath.row == items[indexPath.section].rowCount {
                    cell.textLabel?.text = "Add Purchase"
                } else {
                    let purchaseItem = items[indexPath.section] as! TimeCardDetailsPurchaseItem
                    let managedPurchases = purchaseItem.managedPurchases
                    
                    return setupPurchaseCell(managedPurchase: managedPurchases[indexPath.row])
                }
                return cell 
            }
        }
    }
    
    func setupDatePickerCell(indexPath: IndexPath) -> UITableViewCell {
        guard let datePickerCell = tableView.dequeueReusableCell(withIdentifier: DatePickerTableViewCell.reuseIdentifier()) as? DatePickerTableViewCell else {
            return DatePickerTableViewCell() }
        
        let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        
        datePickerCell.updateCell(date: timeStamps[indexPath.row - 1], indexPath: indexPath)
        datePickerCell.delegate = self
        
        return datePickerCell
    }
    
    func setupPurchaseCell(managedPurchase: ManagedPurchase) -> UITableViewCell {
        guard let purchaseCell = tableView.dequeueReusableCell(withIdentifier: PurchaseTableViewCell.reuseIdentifier()) as? PurchaseTableViewCell else {
            return PurchaseTableViewCell()
        }
        
        purchaseCell.itemNameTextField.text = managedPurchase.name
        purchaseCell.itemNameTextField.closeDatePickerDelegate = self
        purchaseCell.priceTextField.updatePriceTextField(price: managedPurchase.price)
        purchaseCell.priceTextField.closeDatePickerDelegate = self
        
        return purchaseCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return DatePickerTableViewCell.height
        } else {
            return tableView.rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.section]
        
        if item.type == .purchases && item.rowCount != indexPath.row {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            let purchaseItem = items[indexPath.section] as! TimeCardDetailsPurchaseItem
            
            managedContext.delete(purchaseItem.managedPurchases[indexPath.row])
            purchaseItem.removeFromManagedPurchases(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        // close open date picker
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row - 1 == indexPath.row {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            self.datePickerIndexPath = nil
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            switch items[indexPath.section].type {
            case .timeStamps:
                // allow save after one time has been selected
                navigationItem.rightBarButtonItem?.isEnabled = true
                
                // close prev date picker
                if let datePickerIndexPath = datePickerIndexPath {
                    tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
                }
                datePickerIndexPath = indexPathToInsertDatePicker(indexPath: indexPath)
                guard let datePickerIndexPath = datePickerIndexPath else {
                    return
                }
                
                tableView.insertRows(at: [datePickerIndexPath], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
                
                // add current time to cell if empty
                let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
                var timeStamps = timeStampsItem.timeStamps

                if timeStamps[datePickerIndexPath.row - 1] == nil {
                    // fix for crash when delete and reload at same indexPath
                    tableView.endUpdates()
                    tableView.beginUpdates()
                    
                    timeStamps[datePickerIndexPath.row - 1] = Date().roundDownToNearestFiveMin()
                    timeStampsItem.save(new: timeStamps)
                    tableView.reloadRows(at: [IndexPath(row: datePickerIndexPath.row - 1, section: datePickerIndexPath.section)], with: .automatic)
                    
                    updateDuration()
                }
            case .duration:
                closeDatePicker()
                tableView.deselectRow(at: indexPath, animated: false)
            case .purchases:
                closeDatePicker()
                let purchaseItem = items[indexPath.section] as! TimeCardDetailsPurchaseItem
                
                if purchaseItem.rowCount == indexPath.row {
                    purchaseItem.addToManagedPurchases(newPurchase: ManagedPurchase(context: managedContext))
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
        tableView.endUpdates()
    }
    
    func indexPathToInsertDatePicker(indexPath: IndexPath) -> IndexPath {
        if let datePickerIndexPath = datePickerIndexPath, datePickerIndexPath.row < indexPath.row {
            return indexPath
        } else {
            return IndexPath(row: indexPath.row + 1, section: indexPath.section)
        }
    }
    
    func didChangeDate(date: Date, indexPath: IndexPath) {
        guard let datePickerIndexPath = datePickerIndexPath else {
            return
        }
        let section = datePickerIndexPath.section
        let row = datePickerIndexPath.row - 1
        let timeStampsItem = items[section] as! TimeCardDetailsTimeStampsItem
        var timeStamps = timeStampsItem.timeStamps

        timeStamps[row] = date
        timeStampsItem.save(new: timeStamps)
        
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        updateDuration()
    }
    
    func closeDatePicker() {
        tableView.beginUpdates()
        
        if let datePickerIndexPath = datePickerIndexPath {
            tableView.deleteRows(at: [datePickerIndexPath], with: .fade)
            self.datePickerIndexPath = nil
        }
        
        tableView.endUpdates()
    }
    
    func updateDuration() {
        guard let datePickerIndexPath = datePickerIndexPath else {
            return
        }
        let section = datePickerIndexPath.section
        guard let timeStampsItem = items[section] as? TimeCardDetailsTimeStampsItem else {
            return
        }
        let timeStamps = timeStampsItem.timeStamps
        
        guard let start = timeStamps[0], let end = timeStamps[1] else {
            return
        }
        
        let durationItem = items[1] as! TimeCardDetailsDurationItem
        
        durationItem.duration = hoursAndMins(from: start, to: end)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    @objc func saveButtonAction(_ sender: UIBarButtonItem) {
        saveTimeStamps()
        savePurchases()
        do {
            try managedContext.save()
            try managedContext.parent?.save()
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
        }
    }
    
    func saveTimeStamps() {
        guard let timeStampsItem = items[0] as? TimeCardDetailsTimeStampsItem else {
            return
        }
        let timeStamps = timeStampsItem.timeStamps
        
        if let start = timeStamps[0], let end = timeStamps[1] {
            if duration(from: start, to: end) < 0 {
                presentAlert()
                return
            }
        }
        
        timeCard.startTime = timeStamps[0]
        timeCard.endTime = timeStamps[1]
        
        if newTimeCard {
            guard let payCycleWithChildContext = managedContext.object(with: payCycle.objectID) as? ManagedPayCycle else {
                return
            }
            payCycleWithChildContext.addToTimeCards(timeCard)
        }
    }
    
    func savePurchases() {
        guard let purchaseItem = items[2] as? TimeCardDetailsPurchaseItem else {
            return
        }
        guard let timeCardWithChildContext = managedContext.object(with: timeCard.objectID) as? ManagedTimeCard else {
            return
        }
        let managedPurchases = purchaseItem.managedPurchases
        
        let cells = self.tableView.visibleCells
        let purchaseTableViewCells = cells.filter {
            $0 is PurchaseTableViewCell  }
        for idx in 0..<purchaseTableViewCells.count {
            guard let cell = purchaseTableViewCells[idx] as? PurchaseTableViewCell else {
                return
            }
            let managedPurchase = managedPurchases[idx]
            
            // do not add empty entries to timecard
            if cell.itemNameTextField.text!.count > 0 {
                managedPurchase.name = cell.itemNameTextField.text
                managedPurchase.price = currencyToFloat(from: cell.priceTextField.amountTypedString)
                if idx >= purchaseItem.indexOfMostRecentPurchase {
                    timeCardWithChildContext.addToPurchases(managedPurchase)
                }
            }
        }
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Invalid Time", message: "Entry's end cannot be before it's start.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

