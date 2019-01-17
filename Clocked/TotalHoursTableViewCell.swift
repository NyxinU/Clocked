//
//  TotalHoursTableViewCell.swift
//  Clocked
//
//  Created by Nix on 1/16/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import UIKit

class TotalHoursTableViewCell: UITableViewCell {
    let totalLabel = UILabel()
    var amountLabel = UILabel()
    
    static func resuseIdentifier() -> String {
        return "TotalHoursTableViewCellResuseIdentifier"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        totalLabel.text = "Total"
        
        addSubview(totalLabel)
        addSubview(amountLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels = [totalLabel, amountLabel]
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let padding: CGFloat = 16
        
        amountLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            totalLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
            totalLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.65),
            totalLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            totalLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            
            amountLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding),
            amountLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.25),
            amountLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            amountLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor)
        ])
    }
}
