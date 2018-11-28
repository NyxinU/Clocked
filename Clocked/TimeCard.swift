//
//  TimeCard.swift
//  Clocked
//
//  Created by Nix on 11/27/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

protocol TimeCardModel {
    var startTime: Date? {get set}
    var endTime: Date? {get set}
    var duration: String? {get}
}

class TimeCard: TimeCardModel {
    var startTime: Date?
    var endTime: Date?
    var duration: String? {
        get {
            if let startTime = startTime, let endTime = endTime {
                let seconds = DateInterval(start: startTime, end: endTime).duration
                
                let hours = Int(seconds / 3600)
                let minutes = Int((seconds / 60).truncatingRemainder(dividingBy: 60))
                
                return "\(hours) hours \(minutes) minutes"
            } else {
                return nil
            }
        }
    }
}
