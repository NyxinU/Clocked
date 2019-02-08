//
//  typeCoversions.swift
//  Clocked
//
//  Created by Nix on 1/10/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation

func priceToString(from price: Float) -> String {
    return String(Int(price * 100))
}

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

func timeCardsToString(managedTimeCards: [ManagedTimeCard], totalHours: Int32, managedPurchases: [ManagedPurchase]) -> String {
    var string = ""
    var purchases = ""
    var totalAmountOfExpenses: Float = 0.0
    
    let totalHours = "Total: \(hoursAndMins(from: Int(totalHours)))\n"
    let timeCards = managedTimeCards.reversed()
    
    for managedTimeCard in timeCards {
        let startTime: Date? = managedTimeCard.startTime
        let endTime: Date? = managedTimeCard.endTime
        let row: String = "\(startTime?.dateAsString() ?? "") \(startTime?.timeAsString() ?? "") - \(endTime?.timeAsString() ?? "") \(hoursAndMins(from: startTime, to: endTime))\n"
        string.append(contentsOf: row)
    }
    
    string.append(contentsOf: totalHours)
    
    for managedPurchase in managedPurchases {
        var row = "\(managedPurchase.name ?? "")"
        
        if managedPurchase.price > 0.0 {
            totalAmountOfExpenses += managedPurchase.price
            
            let amountString = priceToString(from: managedPurchase.price)
            let amountCurrency = stringToCurrency(from: amountString)
            row.append(contentsOf: " \(amountCurrency)")
        }
        row.append(contentsOf: "\n")
        
        purchases.append(contentsOf: row)
    }
    
    let totalAmount = stringToCurrency(from: priceToString(from: totalAmountOfExpenses))
    
    if purchases.count > 0 {
        string.append(contentsOf: "\n\(purchases)")
        string.append(contentsOf: "Total Expenses \(totalAmount)")
    }
    return string
}
