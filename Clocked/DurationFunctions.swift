//
//  DurationFunctions.swift
//  Clocked
//
//  Created by Nix on 12/13/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

func duration(from start: Date, to end: Date) -> Int {
    let dateInterval: DateInterval
    if end < start {
        dateInterval = DateInterval(start: end, end: start)
        let seconds: Int = Int(dateInterval.duration)
        return -seconds
    } else {
        dateInterval = DateInterval(start: start, end: end)
        let seconds: Int = Int(dateInterval.duration)
        return seconds
    }
}

func hoursAndMins(from seconds: Int?) -> String {
    guard let seconds = seconds else {
        return ""
    }
    let hours = Int(seconds / 3600)
    let minutes = Int((seconds / 60) % 60)
    return formatTime(hours: hours, minutes: minutes)
}

func hoursAndMinsInParenthesis(from start: Date?, to end: Date?) -> String {
    guard let start = start, let end = end else {
        return ""
    }
    let seconds = duration(from: start, to: end)
    
    let hours = Int(seconds / 3600)
    let minutes = Int((seconds / 60) % 60)
    let minutesInString: String = minutes < 10 ? "0\(minutes)" : "\(minutes)"
    
    return "(\(hours):\(minutesInString))"
}

func hoursAndMinsInDecimal(from seconds: Int?) -> String {
    guard let seconds = seconds else {
        return "0.0"
    }
    let hours = Float(seconds / 3600)
    let minutes = Float((seconds / 60) % 60)
    let decimalMins =  minutes / 60
    let hoursAnMins: String = String(format: "%.2f", hours + decimalMins)
    
    return hoursAnMins
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
    var minutes = minutes
    
    if hours != 0 {
        time += "\(String(hours))h"
    }
    
    if hours != 0 && minutes != 0 {
        time += " "
    }
    
    // prevent negative hours and minutes
    if hours < 0 && minutes < 0 {
        minutes *= -1
    }
    
    if hours != 0 && minutes == 0 {
        return time
    } else {
        time += "\(String(minutes))m"
    }
    
    return time
}
