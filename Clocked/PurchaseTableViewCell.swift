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
        
        let itemNameTextField = PurchaseTextField(option: .name)
        let priceTextField = PriceTextField()

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
        
        switch option {
        case .name:
            self.frame = CGRect(x: 20, y: 0, width: 180, height: 40)
            self.placeholder = "Item Name"
            self.keyboardType = UIKeyboardType.default
        case .price:
            self.frame = CGRect(x: 220, y: 0, width: 180, height: 40)
            self.placeholder = "$0"
            self.keyboardType = UIKeyboardType.numberPad
        }
        
        self.autocorrectionType = UITextAutocorrectionType.no
        self.returnKeyType = UIReturnKeyType.done
        self.clearButtonMode = UITextField.ViewMode.whileEditing
        self.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        print("TextField should return method called")
        textField.resignFirstResponder()
        return true
    }
}

class PriceTextField: PurchaseTextField {
    var amountTypedString: String?
    init() {
        super.init(option: .price)
        
        self.amountTypedString = self.text ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if string.count > 0 {
            amountTypedString = amountTypedString! + string
            let decNumber = NSDecimalNumber(string: amountTypedString).multiplying(by: 0.01)
            let newString = "$" + formatter.string(from: decNumber)!
            textField.text = newString
        } else {
            amountTypedString = String(amountTypedString!.dropLast())
            if amountTypedString!.count > 0 {
                let decNumber = NSDecimalNumber(string: amountTypedString).multiplying(by: 0.01)
                let newString = "$" +  formatter.string(from: decNumber)!
                textField.text = newString
            } else {
                textField.text = "$0.00"
            }
            
        }
        return false
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        amountTypedString = ""
        return true
    }
}
