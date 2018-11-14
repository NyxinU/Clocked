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
    var timecards: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        positionAddButton()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timecards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
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
        print("Button Tapped")
        present(TimeCardViewController(), animated: true)
    }
}

