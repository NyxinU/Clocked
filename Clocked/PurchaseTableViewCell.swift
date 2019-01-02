//
//  PurchaseTableViewCell.swift
//  Clocked
//
//  Created by Nix on 12/28/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import Foundation
import UIKit

enum PurchaseTextFieldOptions {
    case name
    case price
}

class PurchaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let itemNameTextField = UITextField.purchaseTextField(option: .name)
        let priceTextField = UITextField.purchaseTextField(option: .price)

        addSubview(itemNameTextField)
        addSubview(priceTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UITextField {
    class func purchaseTextField(option: PurchaseTextFieldOptions) -> UITextField {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        
        switch option {
        case .name:
            textField.placeholder = "Item Name"
            textField.keyboardType = UIKeyboardType.default
        case .price:
            textField.frame = CGRect(x: 200, y: 0, width: 200, height: 40)
            textField.placeholder = "$0"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        return textField
    }
}
