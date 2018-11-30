//
//  ViewController.swift
//  Clocked
//
//  Created by Nix on 11/12/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
class TimeCardsViewController: UITableViewController {
    
    let cellId = "cellId"
    var timecards: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(TimeCardTableViewCell.self, forCellReuseIdentifier: cellId)
        positionAddButton()
        
        // change back button to say cancel 
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "TimeCards")
        
        do {
            timecards = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print(timecards)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timecards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? TimeCardTableViewCell else {
            return UITableViewCell() }
        
        let startTime: Date? = timecards[indexPath.row].value(forKeyPath: "startTime") as? Date
        let endTime: Date? = timecards[indexPath.row].value(forKeyPath: "endTime") as? Date
        
        let timecard: TimeCard = TimeCard()
        timecard.startTime = startTime
        timecard.endTime = endTime
        
        cell.startDateLabel.text = "\(startTime?.dayOfWeek() ?? "") \(startTime?.dateAsString() ?? "")"
        cell.startTimeLabel.text = startTime?.timeAsString()
        cell.endTimeLabel.text = endTime?.timeAsString()
        cell.durationLabel.text = timecard.durationAsString
//        cell.textLabel?.text = startTime?.stringified()

        return cell
    }
    
    
    let addTimeCardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .green
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTimeCardButtonAction), for: .touchUpInside)
        
        return button
    }()
    
    func positionAddButton() {
        view.addSubview(addTimeCardButton)
        
        NSLayoutConstraint.activate([
            addTimeCardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addTimeCardButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            addTimeCardButton.heightAnchor.constraint(equalToConstant: 60),
            addTimeCardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func addTimeCardButtonAction(sender: UIButton!) {
        navigationController?.pushViewController(TimeCardDetailsViewController(), animated: true)
    }

}

