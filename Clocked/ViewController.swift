//
//  ViewController.swift
//  Clocked
//
//  Created by Nix on 11/12/18.
//  Copyright © 2018 NXN. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UITableViewController {
    
    let cellId = "cellId"
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        setupUIBarButtons()
    }
    
    func setupUIBarButtons() {
//        let rightBarButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(ViewController.myRightSideBarButtonItemTapped(_:)))
//        navigationItem.rightBarButtonItem = rightBarButton
        let addTimeButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(ViewController.addTime(_:)))
        navigationItem.rightBarButtonItem = addTimeButton
        
        let leftBarButton = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(ViewController.myLeftSideBarButtonItemTapped(_:)))
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
//    @objc func myRightSideBarButtonItemTapped(_ sender:UIBarButtonItem)
//    {
//        print("myRightSideBarButtonItemTapped")
//        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
//
//        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
//            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
//                return
//            }
//
//            self.save(name: nameToSave)
//            self.tableView.reloadData()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//
//        alert.addTextField()
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//
//        present(alert, animated: true)
//    }
    
    @objc func addTime(_ sender:UIBarButtonItem) {
        let timePicker = UIDatePicker(frame: CGRect(x: 10, y: 50, width: self.view.frame.width, height: 200))
        
        self.view.addSubview(timePicker)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKeyPath: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @objc func myLeftSideBarButtonItemTapped(_ sender:UIBarButtonItem)
    {
        print("myLeftSideBarButtonItemTapped")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        if let last = people.popLast() {
            managedContext.delete(last)
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.tableView.reloadData()
        print(people)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let name = person.value(forKeyPath: "name") as? String
        
        if let name = name {
            cell.textLabel?.text = "hi\nim\n\(name)"
        }
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}

