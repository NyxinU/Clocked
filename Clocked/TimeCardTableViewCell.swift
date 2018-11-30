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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(startDateLabel)
        addSubview(startTimeLabel)
        addSubview(endTimeLabel)
        addSubview(durationLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let labels: [UILabel] = [startDateLabel,startTimeLabel, endTimeLabel, durationLabel]
        
        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        }
        
//        startDateLabel.translatesAutoresizingMaskIntoConstraints = false
//        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
//        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
//        startDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        startTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        endTimeLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        durationLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        durationLabel.textAlignment = .right
        
        let timeLabelWidth: CGFloat = 0.20
        let padding: CGFloat = 20
        
        NSLayoutConstraint.activate([
            startDateLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
                startDateLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
                startDateLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                startDateLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
                
                startTimeLabel.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: padding),
                startTimeLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: timeLabelWidth),
                startTimeLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor),
                startTimeLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                
                endTimeLabel.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor, constant: padding),
                endTimeLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: timeLabelWidth),
                endTimeLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor),
                endTimeLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                
                durationLabel.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -padding),
                durationLabel.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
                durationLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor),
                durationLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
