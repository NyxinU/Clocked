//
//  ManagedTimeCard+CoreDataProperties.swift
//  Clocked
//
//  Created by Nix on 1/24/19.
//  Copyright © 2019 NXN. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedTimeCard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedTimeCard> {
        return NSFetchRequest<ManagedTimeCard>(entityName: "ManagedTimeCard")
    }

    @NSManaged public var endTime: NSDate?
    @NSManaged public var startTime: NSDate?
    @NSManaged public var payCycle: ManagedPayCycle?
    @NSManaged public var purchases: NSSet?

}

// MARK: Generated accessors for purchases
extension ManagedTimeCard {

    @objc(addPurchasesObject:)
    @NSManaged public func addToPurchases(_ value: ManagedPurchase)

    @objc(removePurchasesObject:)
    @NSManaged public func removeFromPurchases(_ value: ManagedPurchase)

    @objc(addPurchases:)
    @NSManaged public func addToPurchases(_ values: NSSet)

    @objc(removePurchases:)
    @NSManaged public func removeFromPurchases(_ values: NSSet)

}
