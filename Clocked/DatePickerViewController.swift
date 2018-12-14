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
    var indexPath: Int
    
    init(indexPath: Int) {
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            delegate?.dateTimeSelected(value: datePicker.date, indexPath: indexPath)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func isValidDate() -> Bool {
        // is it possible to use alert to halt code?
        
        let startTime = delegate?.timeCard.startTime
        let endTime = delegate?.timeCard.endTime
//        let indexPath = delegate?.indexPath
//
        if (startTime == nil) || (endTime == nil) {
            return true
        }
//        // refactor this later
        if indexPath == 0 {
            // allow editing on new entry
//            if endTime == nil { return true }
            if let endTime = endTime {
                if datePicker.date > endTime {
                    presentAlert()
                } else {
                    return true
                }
            }
        } else {
//            if startTime == nil { return true }
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
        let alert = UIAlertController(title: "Invalid Time", message: "Entry's end cannot be before it's start.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
