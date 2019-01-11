//
//  typeCoversions.swift
//  Clocked
//
//  Created by Nix on 1/10/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation

func stringToCurrency(from string: String) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    
    let decNumber = NSDecimalNumber(string: string).multiplying(by: 0.01)
    let currency = formatter.string(from: decNumber)!
    
    return currency
}

func currencyToFloat(from string: String) -> Float {
    if string.count == 0 {
        return 0.0
    } else {
        return NSDecimalNumber(string: string).multiplying(by: 0.01).floatValue
    }
}
