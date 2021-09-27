//
//  RestaurantListViewModel.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import Foundation

protocol RestaurantListViewModelInput {
    
}

protocol RestaurantListViewModelOutput {
    
}

protocol RestaurantListViewModelType {
    var input: RestaurantListViewModelInput { get }
    var output: RestaurantListViewModelOutput { get }
}

class RestaurantListViewModel: RestaurantListViewModelType, RestaurantListViewModelInput, RestaurantListViewModelOutput {
    
    var input: RestaurantListViewModelInput { return self }
    var output: RestaurantListViewModelOutput { return self }
    
}
