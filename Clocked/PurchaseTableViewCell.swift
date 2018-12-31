//
//  PurchaseTableViewCell.swift
//  Clocked
//
//  Created by Nix on 12/28/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation
import UIKit

class PurchaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let sampleTextField =  UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        sampleTextField.placeholder = "Item Name"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        let sampleTextField2 =  UITextField(frame: CGRect(x: 200, y: 0, width: 200, height: 40))
        sampleTextField2.placeholder = "Price"
        sampleTextField2.font = UIFont.systemFont(ofSize: 15)
        sampleTextField2.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField2.keyboardType = UIKeyboardType.numberPad
        sampleTextField2.returnKeyType = UIReturnKeyType.done
        sampleTextField2.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField2.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center

        
        addSubview(sampleTextField)
        addSubview(sampleTextField2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
