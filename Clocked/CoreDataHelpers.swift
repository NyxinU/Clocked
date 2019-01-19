//
//  CoreDataHelpers.swift
//  Clocked
//
//  Created by Nix on 1/15/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import CoreData

func fetchedPayCycles(from managedContext: NSManagedObjectContext, to payCycles: inout [ManagedPayCycle]) -> Bool {
    let fetchRequest = NSFetchRequest<ManagedPayCycle>(entityName: "ManagedPayCycle")
    let sort = NSSortDescriptor(key: #keyPath(ManagedPayCycle.startDate), ascending: false)
    fetchRequest.sortDescriptors = [sort]
    
    do {
        let data = try managedContext.fetch(fetchRequest)
        payCycles = prependNewPayCycles(managedPayCycles: data)
        return true
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
        return false
    }
}

func prependNewPayCycles(managedPayCycles: [ManagedPayCycle]) -> [ManagedPayCycle] {
    var copy = managedPayCycles
    var newPayCycles: [ManagedPayCycle] = []
    
    if copy.count > 0 {
        while(copy[copy.count - 1].startDate == nil) {
            if let last = copy.popLast() {
                newPayCycles.append(last)
            }
        }
    }
    return newPayCycles + copy
}

func removed<T>(from array: inout [T], at indexPath: IndexPath, in managedContext: NSManagedObjectContext) -> Bool {
    
    let managedObject: T = array[indexPath.row]
    managedContext.delete(managedObject as! NSManagedObject)
    
    do {
        try managedContext.save()
        array.remove(at: indexPath.row)
        return true
    } catch let error as NSError {
        print("Could not delete. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
        return false
    }
}

func fetchedTimeCards(from managedContext: NSManagedObjectContext, for payCycle: ManagedPayCycle, to timeCards: inout [ManagedTimeCard]) -> Bool {
    let fetchRequest = NSFetchRequest<ManagedTimeCard>(entityName: "ManagedTimeCard")
    let sort = NSSortDescriptor(key: #keyPath(ManagedTimeCard.startTime), ascending: false)
    fetchRequest.predicate = NSPredicate(format: "payCycle == %@", payCycle)
    fetchRequest.sortDescriptors = [sort]
    
    do {
        timeCards = try managedContext.fetch(fetchRequest)
        return true
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
        return false
    }
}

func fetchPurchases<T: NSManagedObject>(from managedContext: NSManagedObjectContext, for obj: T) -> [ManagedPurchase] {
    var purchases: [ManagedPurchase] = []
    let purchasesRequest = NSFetchRequest<ManagedPurchase>(entityName: "ManagedPurchase")
    
    purchasesRequest.predicate = {
        switch NSStringFromClass(T.self) {
        case "ManagedTimeCard":
            return NSPredicate(format: "timeCard == %@", obj as! ManagedTimeCard)
        case "ManagedPayCyle":
            return NSPredicate(format: "timeCard.payCycle == %@", obj as! ManagedPayCycle)
        default:
            return nil
        }
    }()
    
    do {
        purchases = try managedContext.fetch(purchasesRequest)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
    }
    return purchases
}

func updatePayCycleAttrs(with timeCards: [ManagedTimeCard], for payCycle: ManagedPayCycle, in managedContext: NSManagedObjectContext) {
    var totalHours: Int = 0
    
    for index in stride(from: timeCards.count - 1, through: 0, by: -1) {
        if let startDate = timeCards[index].startTime {
            payCycle.startDate = startDate
            break
        }
    }
    
    for timeCard in timeCards {
        if let endDate = timeCard.endTime {
            payCycle.endDate = endDate
            break
        }
    }
    
    for managedTimeCard in timeCards {
        if let start = managedTimeCard.startTime, let end = managedTimeCard.endTime {
            totalHours += duration(from: start, to: end)
        }
    }
    
    payCycle.totalHours = Int32(totalHours)
    
    do {
        try managedContext.save()
    } catch let error as NSError {
        print("Could not save. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
    }
}
