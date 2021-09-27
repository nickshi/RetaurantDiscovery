//
//  RestaurantDetailViewModel.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/24/21.
//

import Foundation
import RxSwift
import RxCocoa

protocol RestaurantDetailViewModelType {
    var input: RestaurantDetailViewModelInput { get }
    var output: RestaurantDetailViewModelOutput { get }
}

protocol RestaurantDetailViewModelInput {
    
}

protocol RestaurantDetailViewModelOutput {
    var name: Observable<String> { get }
}

class RestaurantDetailViewModel: RestaurantDetailViewModelType, RestaurantDetailViewModelInput, RestaurantDetailViewModelOutput {
    
    var input: RestaurantDetailViewModelInput { return self }
    var output: RestaurantDetailViewModelOutput { return self }
    
    var name: Observable<String>
    
    
    var restaurantProperty = BehaviorRelay<Restaurant?>(value: nil)

    init(_ restaurant: Restaurant) {
        name = restaurantProperty.asObservable().unwrap().map({ $0.name })
        
        restaurantProperty.accept(restaurant)
    }
}
