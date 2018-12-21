//
//  TimeCardDetails.swift
//  Clocked
//
//  Created by Nix on 12/19/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

class TimeCardDetails {
    var times: [Date?] = []
    var duration: String
//    var purchases: [Purchase]()
    
    init(timeCard: ManagedTimeCard) {
        self.times = [timeCard.startTime, timeCard.endTime]
        guard let start = timeCard.startTime, let end = timeCard.endTime else {
            return
        }
        self.duration = hoursAndMins(from: <#T##Date?#>, to: <#T##Date?#>)
    }
}

//class Purchase {
//    var name: String?
//    var price: Double?
//}

enum TimeCardDetailsItemType {
    case times
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

class TimeCardDetailsTimesItem: TimeCardDetailsItem {
    var type: TimeCardDetailsItemType {
        return .times
    }
    
    var rowCount: Int {
        return 2
    }
    
    var times: [Date?]
    
    init(times: [Date?]) {
        self.times = times
    }
}

class TimeCardDetailsDurationItem: TimeCardDetailsItem {
    var type: TimeCardDetailsItemType {
        return .duration
    }
    
    var duration: Double?
    
    init(duration: DateInterval?) {
        self.duration = duration?.duration
    }
}

class TimeCardDetailsModel: NSObject {
    var items = [TimeCardDetailsItem]()
    
    init(timeCard: ManagedTimeCard) {
        let timeCardDetails = TimeCardDetails(timeCard: timeCard)
        
        let times = TimeCardDetailsTimesItem(times: timeCardDetails.times)
        items.append(times)
        
        let duration = TimeCardDetailsDurationItem(duration: timeCardDetails.duration)
        
        items.append(duration)
    }
}
