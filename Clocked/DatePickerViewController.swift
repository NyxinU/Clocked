////
////  DatePickerViewController.swift
////  Clocked
////
////  Created by Nix on 11/15/18.
////  Copyright © 2018 NXN. All rights reserved.
////
//
//import UIKit
//
//class DatePickerViewController: UIViewController {    
//    let datePicker: UIDatePicker = UIDatePicker()
//    var delegate: DatePickerDelegate?
//    var indexPath: Int
//    
//    init(indexPath: Int) {
//        self.indexPath = indexPath
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveDateTime(_:)))
//        
//        let datePickerContainer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
//
//        datePickerContainer.backgroundColor = .white
//        
//        datePicker.timeZone = NSTimeZone.local
//        datePicker.datePickerMode = .dateAndTime
//        datePicker.minuteInterval = 5
//
//        datePickerContainer.addSubview(datePicker)
//        
//        view.addSubview(datePickerContainer)
//    }
//    
//    @objc func saveDateTime(_ sender: UIBarButtonItem) {
//        if isValidDate() {
//            delegate?.dateTimeSelected(value: datePicker.date, indexPath: indexPath)
//            navigationController?.popViewController(animated: true)
//        }
//    }
//    
//    func isValidDate() -> Bool {
//        
//        let startTime = delegate?.timeCard.startTime
//        let endTime = delegate?.timeCard.endTime
//
//        if indexPath == 0 {
//            if let endTime = endTime {
//                if datePicker.date > endTime {
//                    presentAlert()
//                    return false
//                }
//            }
//        } else {
//            if let startTime = startTime {
//                if startTime > datePicker.date {
//                    presentAlert()
//                    return false
//                }
//            }
//        }
//        return true
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    func presentAlert() {
//        let alert = UIAlertController(title: "Invalid Time", message: "Entry's end cannot be before it's start.", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//    
//}
