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
    var durationInMs: Double? {get}
    var durationAsString: String? {get}
}

class TimeCard: TimeCardModel {
    var startTime: Date?
    var endTime: Date?
    var durationInMs: Double? {
        get {
            if let startTime = startTime, let endTime = endTime {
                return DateInterval(start: startTime, end: endTime).duration
            } else {
                return nil
            }
        }
    }
    var durationAsString: String? {
        get {
            if let startTime = startTime, let endTime = endTime {
                let seconds = DateInterval(start: startTime, end: endTime).duration
                
                let hours = Int(seconds / 3600)
                let minutes = Int((seconds / 60).truncatingRemainder(dividingBy: 60))
                
                return "\(hours) h \(minutes) m"
            } else {
                return ""
            }
        }
    }
}
