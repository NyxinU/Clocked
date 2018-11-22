//
//  DatePickerDelegate.swift
//  Clocked
//
//  Created by Nix on 11/20/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation

protocol DatePickerDelegate {
    var indexPath: Int? { get set }
    func DateTimeSelected(value: String)
}
