//
//  RestaurantListViewModel.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import Foundation
import RxSwift
import RxCocoa

enum ViewMode {
    case list
    case map
    
    func change() -> Self{
        return self == .list ? .map : .list
    }
}
protocol RestaurantListViewModelInput {
    func viewDidLoad()
    func changeToMapMode()
    
    func received(restaurants: [Restaurant])
    
    func itemDidSelected(_ restaurant: Restaurant)
    
    func setUserLocation(_ location: Location)
}

protocol RestaurantListViewModelOutput {
    var restaurants: Observable<[Restaurant]> { get }
    var userLocation: Observable<Location> { get }
    var viewMode: Observable<ViewMode> { get }
    var restaurantDidSelected: Observable<Restaurant> { get }
}

protocol RestaurantListViewModelType {
    var input: RestaurantListViewModelInput { get }
    var output: RestaurantListViewModelOutput { get }
}

class RestaurantListViewModel: RestaurantListViewModelType, RestaurantListViewModelInput, RestaurantListViewModelOutput {
    
    var input: RestaurantListViewModelInput { return self }
    var output: RestaurantListViewModelOutput { return self }
    
    //output
    var restaurants: Observable<[Restaurant]>
    var viewMode: Observable<ViewMode>
    var restaurantDidSelected: Observable<Restaurant>
    var userLocation: Observable<Location>
    //private
    private var restaurantsProperty = BehaviorSubject<[Restaurant]>(value: [])
    private var viewModeProperty = PublishSubject<ViewMode>()
    private var restaurantDidSelectedProperty = PublishSubject<Restaurant>()
    private var userLocationProperty = BehaviorSubject<Location>(value: Location(latitude: 0, longitude: 0))
    
    private var modeState: ViewMode = .list
    
    init(_ modeState: ViewMode = .list) {
        self.restaurants = restaurantsProperty.asObservable()
        self.viewMode = viewModeProperty.asObservable()
        self.restaurantDidSelected = restaurantDidSelectedProperty.asObservable()
        self.modeState = modeState
        self.userLocation = userLocationProperty.asObservable()
    }
    
    
    //Input
    func viewDidLoad() {
        //loadRestarantFromLocal()
    }
    
    func changeToMapMode() {
        self.viewModeProperty.onNext(self.modeState.change())
    }
    
    func received(restaurants: [Restaurant]) {
        self.restaurantsProperty.onNext(restaurants)
    }
    
    func setUserLocation(_ location: Location) {
        self.userLocationProperty.onNext(location)
    }
    
    func itemDidSelected(_ restaurant: Restaurant) {
        restaurantDidSelectedProperty.onNext(restaurant)
    }

    private func loadRestarantFromLocal() {
        if let url = Bundle.main.url(forResource: "restaurants", withExtension: "json"), let data = try? Data(contentsOf: url) {
            let jsonDecoder = JSONDecoder()
            do {
                let envelope = try jsonDecoder.decode(RestaurantEnvelope.self, from: data)
                self.restaurantsProperty.onNext(envelope.results)
            } catch {
                print(error)
            }
           
        }
    }
}
