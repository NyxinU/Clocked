//
//  DateFormatter.swift
//  Clocked
//
//  Created by Nix on 11/22/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit

extension Date {
    func dayOfWeek() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEE"
        
        let dayOfWeek: String = dateFormatter.string(from: self)
        
        return dayOfWeek 
    }
    
    func dateAsString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "M/dd/yy"
        
        let stringifiedDate: String = dateFormatter.string(from: self)
        
        return stringifiedDate
    }
    
    func timeAsString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "h:mm a"
        
        let stringifiedTime: String = dateFormatter.string(from: self)
        
        return stringifiedTime
    }
    
    func roundDownToNearestFiveMin() -> Date {
        let newTime = floor(self.timeIntervalSinceReferenceDate/300.0) * 300.0
        let newDate = Date(timeIntervalSinceReferenceDate: newTime)
        
        return newDate
    }
    
    func setSecondsToZero() -> Date {
        let newTime = floor(self.timeIntervalSinceReferenceDate/60.0) * 60.0
        let newDate = Date(timeIntervalSinceReferenceDate: newTime)
        
        return newDate
    }
}

