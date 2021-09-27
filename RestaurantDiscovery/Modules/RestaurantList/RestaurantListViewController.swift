//
//  RestaurantListViewController.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import UIKit
import SnapKit
import RxSwift

class RestaurantListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RestaurantCell.self, forCellReuseIdentifier: RestaurantCell.reusableIdentifier)
        tableView.rowHeight = 140
        return tableView
    }()
    
    private lazy var btnMap: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Map", for: .normal)
        btn.backgroundColor = UIColor(red: 85 / 255, green: 135 / 255, blue: 45 / 255, alpha: 1)
        btn.layer.cornerRadius = 10
        btn.setImage(UIImage(named: "map-maker28x28")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = .white
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .black)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(self.btnMapPressed), for: .touchUpInside)
        return btn
    }()
    
    let disposeBag = DisposeBag()
    
    var viewModel: RestaurantListViewModelType = RestaurantListViewModel()
    
    private var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
        viewModel.input.viewDidLoad()
    }
    
    func makeUI() {
        self.view.backgroundColor = .systemGroupedBackground
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.view.addSubview(btnMap)

        btnMap.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-60)
            maker.width.equalTo(110)
            maker.height.equalTo(50)
        }
    }
    
    func bindViewModel() {
        viewModel.output.restaurants.subscribe(onNext: {
            [unowned self] items in
            self.restaurants = items
            self.tableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    //MARK: - selector
    @objc func btnMapPressed() {
        viewModel.input.changeToMapMode()
    }
}

extension RestaurantListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantCell.reusableIdentifier, for: indexPath) as! RestaurantCell
        cell.configure(self.restaurants[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
}

extension RestaurantListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.input.itemDidSelected(self.restaurants[indexPath.row])
    }
}
