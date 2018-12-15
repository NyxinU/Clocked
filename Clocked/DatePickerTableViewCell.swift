//
//  DatePickerViewCell.swift
//  Clocked
//
//  Created by Nix on 12/14/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {
    let datePicker: UIDatePicker = UIDatePicker()
    var delegate: TimeCardDetailsViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(datePicker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(date: Date?, indexPath: IndexPath) {
        if let date = date {
            datePicker.date = date
        }
    }
}
