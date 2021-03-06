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
    var managedPurchases: [ManagedPurchase] = []
    
    init(timeCard: ManagedTimeCard, managedContext: NSManagedObjectContext) {
        self.timeStamps = [timeCard.startTime, timeCard.endTime]
        if let start = timeCard.startTime, let end = timeCard.endTime {
            self.duration = hoursAndMins(from: start, to: end)
        }
        self.managedPurchases = fetchPurchases(from: managedContext, for: timeCard)
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
    var indexOfMostRecentPurchase: Int
    
    var managedPurchases: [ManagedPurchase]
    
    init(managedPurchases: [ManagedPurchase]) {
        self.managedPurchases = managedPurchases
        self.rowCount = managedPurchases.count
        self.indexOfMostRecentPurchase = managedPurchases.count - 1
    }
    
    func addToManagedPurchases(newPurchase: ManagedPurchase) {
        managedPurchases.append(newPurchase)
        rowCount = managedPurchases.count
    }
    
    func removeFromManagedPurchases(at index: Int) {
        managedPurchases.remove(at: index)
        rowCount = managedPurchases.count
        
        // decrement most recent if deleteing existing purchase 
        if index < indexOfMostRecentPurchase {
            indexOfMostRecentPurchase -= 1
        }
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
        
        let purchases = TimeCardDetailsPurchaseItem(managedPurchases: timeCardDetails.managedPurchases)
        items.append(purchases)
    }
}
