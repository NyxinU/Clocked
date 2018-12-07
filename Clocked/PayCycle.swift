//
//  PayCycle.swift
//  Clocked
//
//  Created by Nix on 12/4/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

protocol PayCycleProtocol {
    var startDate: Date? { get set }
    var endDate: Date? { get set }
    var totalHours: Double? { get }
}

class PayCycle: PayCycleProtocol {
    var startDate: Date?
    var endDate: Date?
    var totalHours: Double?
}
