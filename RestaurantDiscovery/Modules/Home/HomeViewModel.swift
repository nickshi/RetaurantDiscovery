//
//  HomeViewModel.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/24/21.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation


protocol HomeViewModelType {
    var input: HomeViewModelInput { get }
    var output: HomeViewModelOutput { get }
}

protocol HomeViewModelInput {
    func viewDidLoad()
    func search(_ keyword: String)
}

protocol HomeViewModelOutput {
    var restaurants: Observable<[Restaurant]> { get }
    var userLocation: Observable<Location> { get }
    var isLoading: Observable<Bool> { get }
    var errorMessage: Observable<String> { get }
}

class HomeViewModel: HomeViewModelType, HomeViewModelInput, HomeViewModelOutput {
    
    var input: HomeViewModelInput { return self }
    var output: HomeViewModelOutput { return self}
    
    var restaurants: Observable<[Restaurant]>
    var userLocation: Observable<Location>
    var isLoading: Observable<Bool>
    var errorMessage: Observable<String>
    
    var restaurantsProperty = BehaviorSubject<[Restaurant]>(value: [])
    var searchTextProperty = PublishSubject<String>()
    private var userLocationProperty = BehaviorRelay<Location?>(value: nil)
    private var errorMessageProperty = PublishSubject<String>()
    private var isLoadingActivity = ActivityIndicator()
    private var isLoadingProperty = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    private let networkService: NetworkType
    private let locationService: LocationService
    
    init(service: NetworkType = NetworkService(), locationService: LocationService = LocationManager()) {
        self.networkService = service
        self.locationService = locationService
        self.restaurants = restaurantsProperty.asObservable()
        self.userLocation = userLocationProperty.asObservable().unwrap()
        self.isLoading = isLoadingActivity.asObservable()
        self.isLoading = isLoadingProperty.asObservable()
        self.errorMessage = errorMessageProperty.asObservable()
        self.searchTextProperty.flatMapLatest { [unowned self] searchText -> Observable<RestaurantEnvelope> in
            self.isLoadingProperty.onNext(true)
            return Observable<RestaurantEnvelope>.create { [unowned self] observer in
                self.networkService.getNearByResturants(self.userLocationProperty.value!.latitude, self.userLocationProperty.value!.longitude, searchText) { result in
                    self.isLoadingProperty.onNext(false)
                   // guard let self = self else { return }
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
        }
        //.trackActivity(isLoadingActivity)
        .map({ $0.results })
        .subscribe(onNext: {
            [unowned self] items in
            self.restaurantsProperty.onNext(items)
        }) { [unowned self] err in
            print(err)
            self.errorMessageProperty.onNext(err.localizedDescription)
        }.disposed(by: disposeBag)
    }
    
    //Input
    func search(_ keyword: String) {
        guard let _ = self.userLocationProperty.value else {
            self.errorMessageProperty.onNext(NSLocalizedString("location-turn-on-tip", comment: "location tip"))
            return }
        searchTextProperty.onNext(keyword)
    }
    
    func viewDidLoad() {
        locationService.fetchLocation {[unowned self] location, error in
            if let _ = error {
                self.errorMessageProperty.onNext(NSLocalizedString("location-turn-on-tip", comment: "location tip"))
            } else if let location = location {
                self.userLocationProperty.accept(location)
                self.searchTextProperty.onNext("")
            }
        }
    }
}

