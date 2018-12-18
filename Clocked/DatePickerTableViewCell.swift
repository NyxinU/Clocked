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
        
        datePicker.timeZone = NSTimeZone.local
        datePicker.minuteInterval = 5

        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
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
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        // set seconds to 00
        let date = sender.date
        let ti = floor(date.timeIntervalSinceReferenceDate/60.0) * 60.0
        let date1 = Date(timeIntervalSinceReferenceDate: ti)
        delegate?.dateTimeSelected(value: date1)
    }
}
