//
//  FetchRequests.swift
//  Clocked
//
//  Created by Nix on 1/15/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import CoreData

func fetchPayCycles(from managedContext: NSManagedObjectContext, inAscending bool: Bool) -> [ManagedPayCycle] {
    var payCycles: [ManagedPayCycle] = []
    let fetchRequest = NSFetchRequest<ManagedPayCycle>(entityName: "ManagedPayCycle")
    let sort = NSSortDescriptor(key: #keyPath(ManagedPayCycle.startDate), ascending: bool)
    fetchRequest.sortDescriptors = [sort]
    
    do {
        let data = try managedContext.fetch(fetchRequest)
        payCycles = prependNewPayCycles(managedPayCycles: data)
    } catch let error as NSError {
        print("Could not fetch. \(error), \(error.localizedDescription), \(error.localizedFailureReason ?? "")")
    }
    return payCycles
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
