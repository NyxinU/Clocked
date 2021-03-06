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
    var totalHoursLabel = UILabel()
    
    static func reuseIdentifier() -> String {
        return "PayCycleTableViewCellReuseIdentifier"
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(dateRangeLabel)
        addSubview(totalHoursLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels: [UILabel] = [dateRangeLabel, totalHoursLabel]
        let padding: CGFloat = 16
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        totalHoursLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            dateRangeLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
            dateRangeLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.65, constant: padding),
            dateRangeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            dateRangeLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            
            totalHoursLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding),
            totalHoursLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.25),
            totalHoursLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            totalHoursLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.textLabel?.text = nil
        self.dateRangeLabel.text = nil
        self.totalHoursLabel.text = nil
    }
}
