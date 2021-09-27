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
    
    let locationManager = CLLocationManager()
    
    var service: NetworkType = NetworkService()
    
    var userLocation: CLLocationCoordinate2D = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // 1
        searchController.searchResultsUpdater = self
        // 2
        searchController.obscuresBackgroundDuringPresentation = false
        // 3
        searchController.searchBar.placeholder = "Search Candies"
        // 4
        navigationItem.searchController = searchController
        // 5
        definesPresentationContext = true
        
        self.navigationItem.searchController = searchController
        
        self.addChildVC(listVC)
        
        listVC.viewModel.output.viewMode.subscribe(onNext: {
            [unowned self] mode in
            if mode == .map {
                self.removeChild(listVC)
                self.addChildVC(mapVC)
            } else {
                self.removeChild(mapVC)
                self.addChildVC(listVC)
            }
        }).disposed(by: disposeBag)
        
        mapVC.viewModel.output.viewMode.subscribe(onNext: {
            [unowned self] mode in
            if mode == .map {
                self.removeChild(listVC)
                self.addChildVC(mapVC)
            } else {
                self.removeChild(mapVC)
                self.addChildVC(listVC)
            }
        }).disposed(by: disposeBag)
        
        self.locationManager.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
    }
    
    
    func addChildVC(_ viewController: UIViewController) {
        viewController.willMove(toParent: self)
        self.view.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { maker in
            maker.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func removeChild(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.removeFromParent()
        viewController.view.removeFromSuperview()
        viewController.didMove(toParent: nil)
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        locationManager.stopUpdatingLocation()
        userLocation = locValue
        service.getNearByResturants(locValue.latitude, locValue.longitude, "Italian") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let envelope):
                self.listVC.viewModel.input.received(restaurants: envelope.results)
                self.mapVC.viewModel.input.received(restaurants: envelope.results)
            case .failure(let error):
                print(error)
            }
            
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension HomeViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = searchController.searchBar.text else { return }
    searchController.searchBar
        .rx
        .text
        .filter({ $0 != nil })
        .map({ $0! })
        .distinctUntilChanged()
        .flatMapLatest({ text -> Observable<RestaurantEnvelope> in
            print(text)
            return Observable<RestaurantEnvelope>.create { observer in
                self.service.getNearByResturants(self.userLocation.latitude, self.userLocation.longitude, searchText) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let envelope):
                        observer.onNext(envelope)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                    
                }
                return Disposables.create()
            }
        })
        .map({ $0.results })
        .subscribe(onNext: { items in
            self.listVC.viewModel.input.received(restaurants: items)
            self.mapVC.viewModel.input.received(restaurants: items)
        }).disposed(by: disposeBag)
    
  }
}
