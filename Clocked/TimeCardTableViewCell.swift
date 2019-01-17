//
//  TimeCardTableViewCell.swift
//  Clocked
//
//  Created by Nix on 11/28/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit

class TimeCardTableViewCell: UITableViewCell {
    let startDateLabel = UILabel()
    let startTimeLabel = UILabel()
    let endTimeLabel = UILabel()
    let durationLabel = UILabel()
    
    static func reuseIdentifier() -> String {
        return "TimeCardTableViewCellIdentifier"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(startDateLabel)
        addSubview(startTimeLabel)
        addSubview(endTimeLabel)
        addSubview(durationLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels: [UILabel] = [startDateLabel,startTimeLabel, endTimeLabel, durationLabel]
        let padding: CGFloat = 16
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let timeLabelWidth: CGFloat = 0.25
        
        startTimeLabel.textColor = .cyan
        endTimeLabel.textColor = .red
        durationLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            startDateLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
                startDateLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
                startDateLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
                startDateLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
                
                startTimeLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
                startTimeLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: timeLabelWidth),
                startTimeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
                startTimeLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
                
                endTimeLabel.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor, constant: padding),
                endTimeLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: timeLabelWidth),
                endTimeLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
                endTimeLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
                
                durationLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding),
                durationLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: timeLabelWidth),
                durationLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
                durationLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
                
        ])
    }
}
