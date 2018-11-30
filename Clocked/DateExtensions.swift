//
//  DateFormatter.swift
//  Clocked
//
//  Created by Nix on 11/22/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit

extension Date {
    func stringified() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEE MMM dd, yyyy hh:mm a"
        
        let stringifiedDate: String = dateFormatter.string(from: self)
        
        return stringifiedDate
    }
    
    func dayOfWeek() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEE"
        
        let dayOfWeek: String = dateFormatter.string(from: self)
        
        return dayOfWeek 
    }
    
    func dateAsString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let stringifiedDate: String = dateFormatter.string(from: self)
        
        return stringifiedDate
    }
    
    func timeAsString() -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "hh:mm a"
        
        let stringifiedTime: String = dateFormatter.string(from: self)
        
        return stringifiedTime
    }
}
