//
//  PayCycleTableViewCell.swift
//  Clocked
//
//  Created by Nix on 1/15/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import UIKit

class PayCycleTableViewCell: UITableViewCell {
    var dateRangeLabel = UILabel()
//    var startDateLabel = UILabel()
//    var endDateLabel = UILabel()
    var totalHoursLabel = UILabel()
    
    static func reuseIdentifier() -> String {
        return "PayCycleTableViewCellReuseIdentifier"
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(dateRangeLabel)
//        addSubview(startDateLabel)
//        addSubview(endDateLabel)
        addSubview(totalHoursLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels: [UILabel] = [dateRangeLabel, totalHoursLabel]
        let padding: CGFloat = 20
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        totalHoursLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
//            startDateLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
//            startDateLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
//            startDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//            startDateLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
//
//            endDateLabel.leftAnchor.constraint(equalTo: startDateLabel.rightAnchor, constant: padding),
//            endDateLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: padding),
//            endDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
//            endDateLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),

            dateRangeLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
            dateRangeLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.75),
            dateRangeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            dateRangeLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            totalHoursLabel.leftAnchor.constraint(equalTo: dateRangeLabel.rightAnchor),
            totalHoursLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding),
            totalHoursLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            totalHoursLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
//            totalHoursLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
//            totalHoursLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: padding),
//            totalHoursLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
//            totalHoursLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
        ])
    }
}
