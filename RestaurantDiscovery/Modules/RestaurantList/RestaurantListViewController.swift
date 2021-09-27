//
//  RestaurantListViewController.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import UIKit
import SnapKit

class RestaurantListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(RestaurantCell.self, forCellReuseIdentifier: RestaurantCell.resuableIdentifier)
        tableView.rowHeight = 140
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        self.view.backgroundColor = .systemGroupedBackground
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bindViewModel() {
        
    }
}

extension RestaurantListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.resuableIdentifier, for: indexPath)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
}
