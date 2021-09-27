//
//  HomeViewController.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/16/21.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

class HomeViewController: UIViewController {
    
    let searchController = UISearchController()
    
    let listVC = RestaurantListViewController()
    let mapVC = RestaurantListMapViewController()
    
    let disposeBag = DisposeBag()
    
    var viewModel: HomeViewModelType = HomeViewModel()

    private lazy var loadingActivity: UIActivityIndicatorView = {
        let lView = UIActivityIndicatorView(style: .large)
        lView.hidesWhenStopped = true
        return lView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        makeUI()
        bindViewModel()
        
        viewModel.input.viewDidLoad()
    }
    
    func makeUI() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a restaurant"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.view.backgroundColor = .systemGroupedBackground
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.addChildVC(listVC)
        
        self.view.addSubview(loadingActivity)
        loadingActivity.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapViewHandler))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func bindViewModel() {
        searchController.searchBar
            .rx
            .text
            .skip(1)
            .filter({ $0 != nil })
            .map({ $0! })
            .distinctUntilChanged()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { text in
                self.viewModel.input.search(text)
            }).disposed(by: disposeBag)
        listVC.viewModel.output.viewMode.subscribe(onNext: {
            [unowned self] mode in
            self.changeMode(for: mode)
        }).disposed(by: disposeBag)
        
        mapVC.viewModel.output.viewMode.subscribe(onNext: {
            [unowned self] mode in
            self.changeMode(for: mode)
        }).disposed(by: disposeBag)
        
        listVC.viewModel.output.restaurantDidSelected.subscribe(onNext: {
           [unowned self] rest in
            let viewModel = RestaurantDetailViewModel(rest)
            let vc = RestaurantDetailViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        mapVC.viewModel.output.restaurantDidSelected.subscribe(onNext: {
           [unowned self] rest in
            let viewModel = RestaurantDetailViewModel(rest)
            let vc = RestaurantDetailViewController(viewModel: viewModel)
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        viewModel.output.restaurants.subscribe(onNext: {
            [unowned self] items in
            listVC.viewModel.input.received(restaurants: items)
            mapVC.viewModel.input.received(restaurants: items)
        }).disposed(by: disposeBag)
        
        viewModel.output.userLocation.subscribe(onNext: {
            [unowned self] location in
            listVC.viewModel.input.setUserLocation(location)
            mapVC.viewModel.input.setUserLocation(location)
        }).disposed(by: disposeBag)
        
        viewModel.output.isLoading.bind(to: self.loadingActivity.rx.isAnimating).disposed(by: disposeBag)
        
        viewModel.output.errorMessage.subscribe(onNext: {
            [weak self] errorMsg in
            guard let self = self else { return }
            self.showErrorMessage(errorMsg)
        }).disposed(by: disposeBag)
    }
    
    
    @objc func tapViewHandler() {
        searchController.searchBar.resignFirstResponder()
    }
    
    private func changeMode(for mode: ViewMode) {
        if mode == .map {
            self.removeChild(listVC)
            self.addChildVC(mapVC)
        } else {
            self.removeChild(mapVC)
            self.addChildVC(listVC)
        }
        self.view.bringSubviewToFront(loadingActivity)
    }
    
    private func addChildVC(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        self.view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    private func removeChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
        viewController.didMove(toParent: nil)
    }
    
    private func showErrorMessage(_ message: String) {
        let alertView = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .destructive, handler: { _ in })
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
}
