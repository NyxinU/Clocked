////
////  PayCycleViewController.swift
////  Clocked
////
////  Created by Nix on 12/4/18.
////  Copyright © 2018 NXN. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class PayCycleViewController: UITableViewController {
//    let cellId = "cellId"
//    var payCycles: [NSManagedObject] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return payCycles.count
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
//        
//        return cell 
//    }
//}
//
