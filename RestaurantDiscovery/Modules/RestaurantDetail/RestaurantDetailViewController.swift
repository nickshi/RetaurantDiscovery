//
//  RestaurantDetailViewController.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/24/21.
//

import UIKit
import RxSwift

class RestaurantDetailViewController: UIViewController {

    let disposeBag = DisposeBag()
    var viewModel: RestaurantDetailViewModelType
    
    
    private lazy var lblName: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .black)
        lbl.textColor = .label
        lbl.text = "Name"
        return lbl
    }()
    
    init(viewModel: RestaurantDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeUI()
        bindViewModel()
    }
    
    func makeUI() {
        self.view.backgroundColor = .systemGroupedBackground
        self.view.addSubview(lblName)
        lblName.snp.makeConstraints { maker in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
        }
    }
    
    func bindViewModel() {
        self.viewModel.output.name.bind(to: self.lblName.rx.text).disposed(by: self.disposeBag)
        self.viewModel.output.name.bind(to: self.navigationItem.rx.title).disposed(by: self.disposeBag)
    }
}
