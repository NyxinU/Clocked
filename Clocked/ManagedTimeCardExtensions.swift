//
//  ManagedTimeCardExtensions.swift
//  Clocked
//
//  Created by Nix on 12/13/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

extension ManagedTimeCard {
    func durationBetween(start: Date, end: Date) -> Int {
        let dateInterval: DateInterval = DateInterval(start: start, end: end)
        let seconds: Int = Int(dateInterval.duration)
        return seconds
    }
    
    func durationAsString(start: Date?, end: Date?) -> String {
        guard let start = start, let end = end else {
            return ""
        }
        let seconds = durationBetween(start: start, end: end)
        let hours = Int(seconds / 3600)
        let minutes = Int((seconds / 60) % 60)
        
        return "\(hours) h \(minutes) m"
    }
}
