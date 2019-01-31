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
    var delegate: DatePickerDelegate?
    var indexPath: IndexPath!
    static let height: CGFloat = 216.0
    
    // Reuser identifier
    static func reuseIdentifier() -> String {
        return "DatePickerTableViewCellIdentifier"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        datePicker.timeZone = NSTimeZone.local
        datePicker.minuteInterval = 5
        
        datePicker.addTarget(self, action: #selector(dateDidChanged(_:)), for: .valueChanged)
        
        addSubview(datePicker)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func updateCell(date: Date?, indexPath: IndexPath) {
        if let date = date {
            datePicker.date = date
        }
        self.indexPath = indexPath
    }
    
    @objc func dateDidChanged(_ sender: UIDatePicker) {        let date = sender.date
        let newDate = date.setSecondsToZero()

        let indexPathForDisplayDate = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        delegate?.didChangeDate(date: newDate, indexPath: indexPathForDisplayDate)
    }
}
