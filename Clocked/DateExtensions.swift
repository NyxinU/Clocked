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
        
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        
        let StringifiedDate: String = dateFormatter.string(from: self)
        
        return StringifiedDate
    }
}

