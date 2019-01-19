//
//  TotalHoursTableViewCell.swift
//  Clocked
//
//  Created by Nix on 1/16/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import UIKit

class LRLabelTableViewCell: UITableViewCell {
    let leftLabel = UILabel()
    var rightLabel = UILabel()
    
    static func resuseIdentifier() -> String {
        return "LRLabelTableViewCellResuseIdentifier"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(leftLabel)
        addSubview(rightLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels = [leftLabel, rightLabel]
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let padding: CGFloat = 16
        
        rightLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            leftLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
            leftLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.20),
            leftLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            leftLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            
            rightLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding),
            rightLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.70),
            rightLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            rightLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = nil
        rightLabel.text = nil 
    }
}
