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
    var itemNameTextField: PurchaseTextField
    var priceTextField: PriceTextField
    
    static func reuseIdentifier() -> String {
        return "PurchaseTableViewCellIdentifier"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.itemNameTextField = PurchaseTextField(option: .name)
        self.priceTextField = PriceTextField()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(itemNameTextField)
        addSubview(priceTextField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PurchaseTextField: UITextField, UITextFieldDelegate {
    init(frame: CGRect = CGRect.zero, option: PurchaseTextFieldOptions) {
        super.init(frame: frame)
        
        // use auto layout instead of adjusting frame
        switch option {
        case .name:
            self.frame = CGRect(x: 20, y: 0, width: 180, height: 40)
            self.placeholder = "Item Name"
            self.keyboardType = UIKeyboardType.default
            self.clearButtonMode = UITextField.ViewMode.whileEditing
        case .price:
            self.frame = CGRect(x: 220, y: 0, width: 180, height: 40)
            self.placeholder = "$0.00"
            self.keyboardType = UIKeyboardType.numberPad
        }
        
        self.autocorrectionType = UITextAutocorrectionType.no
        self.returnKeyType = UIReturnKeyType.done
        self.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class PriceTextField: PurchaseTextField {
    var amountTypedString: String = ""
    init() {
        super.init(option: .price)
        
        if let text = self.text {
            self.amountTypedString = text
        }
        
        self.textAlignment = .right
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count > 0 {
            amountTypedString = amountTypedString + string
            let amount = formatAsCurrency(from: amountTypedString)
            textField.text = amount
        } else {
            amountTypedString = String(amountTypedString.dropLast())
            if amountTypedString.count > 0 {
                let amount = formatAsCurrency(from: amountTypedString)
                textField.text = amount
            } else {
                textField.text = ""
            }
        }
        return false
    }
}

extension PriceTextField {
    func formatAsCurrency(from string: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        let decNumber = NSDecimalNumber(string: string).multiplying(by: 0.01)
        let currency = formatter.string(from: decNumber)!
        
        return currency
    }
}
