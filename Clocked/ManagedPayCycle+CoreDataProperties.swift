//
//  ManagedPayCycle+CoreDataProperties.swift
//  Clocked
//
//  Created by Nix on 1/24/19.
//  Copyright © 2019 NXN. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedPayCycle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPayCycle> {
        return NSFetchRequest<ManagedPayCycle>(entityName: "ManagedPayCycle")
    }

    @NSManaged public var endDate: NSDate?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var totalHours: Int32
    @NSManaged public var timeCards: NSSet?

}

// MARK: Generated accessors for timeCards
extension ManagedPayCycle {

    @objc(addTimeCardsObject:)
    @NSManaged public func addToTimeCards(_ value: ManagedTimeCard)

    @objc(removeTimeCardsObject:)
    @NSManaged public func removeFromTimeCards(_ value: ManagedTimeCard)

    @objc(addTimeCards:)
    @NSManaged public func addToTimeCards(_ values: NSSet)

    @objc(removeTimeCards:)
    @NSManaged public func removeFromTimeCards(_ values: NSSet)

}
