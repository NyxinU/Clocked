//
//  DatePickerViewController.swift
//  Clocked
//
//  Created by Nix on 11/15/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {    
    let datePicker: UIDatePicker = UIDatePicker()
    var delegate: DatePickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateTime(_:)))
        
        let datePickerContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))

        datePickerContainer.backgroundColor = .white
        
        
        datePicker.timeZone = NSTimeZone.local
        datePicker.datePickerMode = .dateAndTime

        datePickerContainer.addSubview(datePicker)
        
        view.addSubview(datePickerContainer)
    }
    
    @objc func saveDateTime(_ sender: UIBarButtonItem) {
        if isValidDate() {
            delegate?.DateTimeSelected(value: datePicker.date)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func isValidDate() -> Bool {
        let indexPath = delegate?.indexPath
        
        if indexPath == 0 {
            let endTime = delegate?.timeCard.endTime
            if let endTime = endTime {
                if datePicker.date > endTime {
                    presentAlert()
                } else {
                    return true
                }
            }
        } else  {
            let startTime = delegate?.timeCard.startTime
            if let startTime = startTime {
                if startTime > datePicker.date {
                    presentAlert()
                } else {
                    return true
                }
            }
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
