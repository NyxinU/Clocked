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

class TimeCardDetailsViewController: UITableViewController, DatePickerDelegate {
    let cellId = "cellId"
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.register(DatePickerTableViewCell.self, forCellReuseIdentifier: DatePickerTableViewCell.reuseIdentifier())
        tableView.register(PurchaseTableViewCell.self, forCellReuseIdentifier: PurchaseTableViewCell.reuseIdentifier())
        
        navigationItem.title = "New Entry"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTimeCard(_:)))
        
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
        
        if newTimeCard {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or orne of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        
        let backgroundColor = #colorLiteral(red: 0.9800000191, green: 0.9800000191, blue: 0.9800000191, alpha: 1)
        footerView.backgroundColor = backgroundColor
        
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            
            switch items[indexPath.section].type {
            case .timeStamps:
                let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
                let timeStamps = timeStampsItem.timeStamps
                
                cell.textLabel?.text = "\(timeStamps[indexPath.row]?.timeAsString() ?? "")"
                return cell
            case .duration:
                let durationItem = items[indexPath.section] as! TimeCardDetailsDurationItem
                
                // refactor better naming
                cell.textLabel?.text = durationItem.duration
                return cell
            case .purchases:
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
            return UITableViewCell() }
        let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        
        datePickerCell.updateCell(date: timeStamps[indexPath.row - 1], indexPath: indexPath)
        datePickerCell.delegate = self
        
        return datePickerCell
    }
    
    func setupPurchaseCell(managedPurchase: ManagedPurchase) -> UITableViewCell {
        guard let purchaseCell = tableView.dequeueReusableCell(withIdentifier: PurchaseTableViewCell.reuseIdentifier()) as? PurchaseTableViewCell else {
            return UITableViewCell()
        }
        purchaseCell.itemNameTextField.text = managedPurchase.name
        return purchaseCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == datePickerIndexPath {
            return DatePickerTableViewCell.height
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.section]
        
        if item.type == .purchases && item.rowCount != indexPath.row {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {

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
                tableView.insertRows(at: [datePickerIndexPath!], with: .fade)
                tableView.deselectRow(at: indexPath, animated: true)
                
                // add current time to cell if empty
                let timeStampsItem = items[indexPath.section] as! TimeCardDetailsTimeStampsItem
                var timeStamps = timeStampsItem.timeStamps

                if timeStamps[datePickerIndexPath!.row - 1] == nil {
                    // fix for crash when delete and reload at same indexPath
                    tableView.endUpdates()
                    tableView.beginUpdates()
                    
                    timeStamps[datePickerIndexPath!.row - 1] = Date().roundDownToNearestFiveMin()
                    timeStampsItem.save(new: timeStamps)
                    tableView.reloadRows(at: [IndexPath(row: datePickerIndexPath!.row - 1, section: datePickerIndexPath!.section)], with: .automatic)
                    
                    updateDuration()
                }
            case .duration:
                tableView.deselectRow(at: indexPath, animated: false)
            case .purchases:
                let purchaseItem = items[indexPath.section] as! TimeCardDetailsPurchaseItem
                
                if purchaseItem.rowCount == indexPath.row {
                    purchaseItem.addTomanagedPurchases(newPurchase: ManagedPurchase(context: managedContext))
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
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
        let section = datePickerIndexPath!.section
        let row = datePickerIndexPath!.row - 1
        let timeStampsItem = items[section] as! TimeCardDetailsTimeStampsItem
        var timeStamps = timeStampsItem.timeStamps

        timeStamps[row] = date
        timeStampsItem.save(new: timeStamps)
        
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        updateDuration()
    }
    
    func updateDuration() {
        let section = datePickerIndexPath!.section
        let timeStampsItem = items[section] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        
        guard let start = timeStamps[0], let end = timeStamps[1] else {
            return
        }
        
        let durationItem = items[1] as! TimeCardDetailsDurationItem
        
        durationItem.duration = hoursAndMins(from: start, to: end)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
    }
    
    @objc func saveTimeCard(_ sender: UIBarButtonItem) {
        let timeStampsItem = items[0] as! TimeCardDetailsTimeStampsItem
        let timeStamps = timeStampsItem.timeStamps
        let purchaseItem = items[2] as! TimeCardDetailsPurchaseItem
        let managedPurchases = purchaseItem.managedPurchases
        
        if let start = timeStamps[0], let end = timeStamps[1] {
            if duration(from: start, to: end) < 0 {
                presentAlert()
                return
            }
        }
        
        timeCard.startTime = timeStamps[0]
        timeCard.endTime = timeStamps[1]
        
        do {
            try managedContext.save()
            try managedContext.parent?.save()
            if newTimeCard {
                payCycle.addToTimeCards(timeCard)
            }
            
            let cells = self.tableView.visibleCells as! Array<UITableViewCell>
            
            for cell in cells {
                print(cell.subviews)
            }
//            if purchaseItem.indexOfMostRecentPurchase < purchaseItem.rowCount {
//                for idx in purchaseItem.indexOfMostRecentPurchase..<purchaseItem.rowCount {
//                    timeCard.addToPurchases(managedPurchases[idx])
//                }
//            }
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        navigationController?.popViewController(animated: true)
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Invalid Time", message: "Entry's end cannot be before it's start.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

