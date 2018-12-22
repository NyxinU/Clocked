//
//  TimeCardDetails.swift
//  Clocked
//
//  Created by Nix on 12/19/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

class TimeCardDetails {
    var timeStamps: [Date?] = []
    var duration: String?
//    var purchases: [Purchase]()
    
    init(timeCard: ManagedTimeCard) {
        self.timeStamps = [timeCard.startTime, timeCard.endTime]
        guard let start = timeCard.startTime, let end = timeCard.endTime else {
            return
        }
        self.duration = hoursAndMins(from: start, to: end)
    }
}

//class Purchase {
//    var name: String?
//    var price: Double?
//}

enum TimeCardDetailsItemType {
    case timeStamps
    case duration
//    case purchases
}

protocol TimeCardDetailsItem {
    var type: TimeCardDetailsItemType { get }
    var rowCount: Int { get }
}

extension TimeCardDetailsItem {
    var rowCount: Int {
        return 1
    }
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
    
    var duration: String?
    
    init(duration: String?) {
        self.duration = duration
    }
}

class TimeCardDetailsModel: NSObject {
    var items = [TimeCardDetailsItem]()
    
    init(timeCard: ManagedTimeCard) {
        let timeCardDetails = TimeCardDetails(timeCard: timeCard)
        
        let timeStamps = TimeCardDetailsTimeStampsItem(timeStamps: timeCardDetails.timeStamps)
        items.append(timeStamps)
        
        let duration = TimeCardDetailsDurationItem(duration: timeCardDetails.duration)
        
        items.append(duration)
    }
}
