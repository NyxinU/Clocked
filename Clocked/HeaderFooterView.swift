//
//  HeaderFooterView.swift
//  Clocked
//
//  Created by Nix on 1/22/19.
//  Copyright © 2019 NXN. All rights reserved.
//

import Foundation
import UIKit

class HeaderFooterView: UITableViewHeaderFooterView {
    static func reuseIdentifier() -> String {
        return "HeaderFooterViewReuseIdentifier"
    }
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            self.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            self.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            self.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
        ])
    }
}
