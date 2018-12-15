//
//  ManagedTimeCardExtensions.swift
//  Clocked
//
//  Created by Nix on 12/13/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

protocol Duration {
//    func durationBetween(start: Date, end: Date) -> Int
//    func hoursAndMins(from: Int) -> String
}

extension Duration {
    func duration(from start: Date, to end: Date) -> Int {
        let dateInterval: DateInterval = DateInterval(start: start, end: end)
        let seconds: Int = Int(dateInterval.duration)
        return seconds
    }
    
    func hoursAndMins(from seconds: Int?) -> String {
        guard let seconds = seconds else {
            return ""
        }
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds / 60) % 60)
        
        return formatTime(hours: hours, minutes: minutes)
    }
    
    func hoursAndMins(from start: Date?, to end: Date?) -> String {
        guard let start = start, let end = end else {
            return ""
        }
        let seconds = duration(from: start, to: end)
        return hoursAndMins(from: seconds)
    }
    
    func formatTime(hours: Int, minutes: Int) -> String {
        var time = ""
        
        if hours > 0 {
            time += "\(String(hours))h"
        }
        
        if hours > 0 && minutes > 0 {
            time += " "
        }
        
        if minutes > 0 {
            time += "\(String(minutes))m"
        }
        
        return time
    }
}

extension ManagedTimeCard: Duration {}
extension ManagedPayCycle: Duration {}
