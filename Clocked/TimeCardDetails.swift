//
//  TimeCardDetails.swift
//  Clocked
//
//  Created by Nix on 12/19/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation
import CoreData

class TimeCardDetails {
    var timeStamps: [Date?] = []
    var duration: String?
    var purchases: [Purchase] = []
    
    init(timeCard: ManagedTimeCard, managedContext: NSManagedObjectContext) {
        self.timeStamps = [timeCard.startTime, timeCard.endTime]
        if let start = timeCard.startTime, let end = timeCard.endTime {
            self.duration = hoursAndMins(from: start, to: end)
        }
        self.purchases = fetchPurchases(timeCard: timeCard, managedContext: managedContext)
    }
    
    func fetchPurchases(timeCard: ManagedTimeCard, managedContext: NSManagedObjectContext) -> [Purchase] {
        var purchases: [Purchase] = []
        let fetchRequest = NSFetchRequest<ManagedPurchase>(entityName: "ManagedPurchase")
        
        fetchRequest.predicate = NSPredicate(format: "timeCard == %@", timeCard)
        
        do {
            let managedPurchases = try managedContext.fetch(fetchRequest)
            purchases = managedPurchases.map { Purchase(name: $0.name, price: $0.price, isNew: false)}
            return purchases
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
}

class Purchase {
    var isNew: Bool
    var name: String?
    var price: Double?

    init(name: String?, price: Double?, isNew bool: Bool) {
        self.name = name
        self.price = price
        self.isNew = bool
    }
}

enum TimeCardDetailsItemType {
    case timeStamps
    case duration
    case purchases
}

protocol TimeCardDetailsItem {
    var type: TimeCardDetailsItemType { get }
    var rowCount: Int { get }
}

class TimeCardDetailsTimeStampsItem: TimeCardDetailsItem {
    var type: TimeCardDetailsItemType {
        return .timeStamps
    }
    
    var rowCount: Int {
        return 2
    }
    
    var timeStamps: [Date?]
    
    init(timeStamps: [Date?]) {
        self.timeStamps = timeStamps
    }
    
    func save(new timeStamps: [Date?]) {
        self.timeStamps = timeStamps
    }
}

class TimeCardDetailsDurationItem: TimeCardDetailsItem {
    var type: TimeCardDetailsItemType {
        return .duration
    }
    
    let rowCount: Int = 1
    
    var duration: String?
    
    init(duration: String?) {
        self.duration = duration
    }
}

class TimeCardDetailsPurchaseItem: TimeCardDetailsItem {
    var type: TimeCardDetailsItemType {
        return .purchases
    }
    
    var rowCount: Int
    
    var purchases: [Purchase]
    
    init(purchases: [Purchase]) {
        self.purchases = purchases
        self.rowCount = purchases.count
    }
    
    func addToPurchases(newPurchase: Purchase) {
        purchases.append(newPurchase)
        rowCount = purchases.count
    }
    
    func removeFromPurchases(at index: Int) {
        purchases.remove(at: index)
        rowCount = purchases.count
    }
}

class TimeCardDetailsModel: NSObject {
    var items = [TimeCardDetailsItem]()
    
    init(timeCard: ManagedTimeCard, managedContext: NSManagedObjectContext) {
        let timeCardDetails = TimeCardDetails(timeCard: timeCard, managedContext: managedContext)
        
        let timeStamps = TimeCardDetailsTimeStampsItem(timeStamps: timeCardDetails.timeStamps)
        items.append(timeStamps)
        
        let duration = TimeCardDetailsDurationItem(duration: timeCardDetails.duration)
        items.append(duration)
        
        let purchases = TimeCardDetailsPurchaseItem(purchases: timeCardDetails.purchases)
        items.append(purchases)
    }
}
