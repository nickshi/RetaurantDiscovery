//
//  RestaurantCellViewModel.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/25/21.
//

import Foundation
import RxSwift

protocol RestaurantCellViewModelType {
    var input: RestaurantCellViewModelInput { get }
    var output: RestaurantCellViewModelOutput { get }
}

protocol RestaurantCellViewModelInput {
    func configure(_ restaurant: Restaurant)
}

protocol RestaurantCellViewModelOutput {
    var title: Observable<String> { get }
    var rating: Observable<Double> { get }
    var subTitle: Observable<String> { get }
    var imageUrl: Observable<URL?> { get }
    var userRatingsTotal: Observable<String> { get }
}

class RestaurantCellViewModel: RestaurantCellViewModelType, RestaurantCellViewModelInput, RestaurantCellViewModelOutput {

    
    //MARK: - Output
    var title: Observable<String>
    var rating: Observable<Double>
    var subTitle: Observable<String>
    var imageUrl: Observable<URL?>
    var userRatingsTotal: Observable<String>
    
    var input: RestaurantCellViewModelInput { return self }
    var output: RestaurantCellViewModelOutput { return self }
    
    //private
    
    private var restaurantProperty = PublishSubject<Restaurant>()
    
    
    init() {
        self.title = restaurantProperty.map({ $0.name })
        self.rating = restaurantProperty.map({ $0.rating })
        self.subTitle = restaurantProperty.map({
            "\($0.priceLevel == 0 ? "$" : $0.priceLevel.repeating("$")) Supporting Text"
        })
        self.imageUrl = restaurantProperty.map({ $0.photoURL != nil ? URL(string: $0.photoURL!) : nil })
        self.userRatingsTotal = restaurantProperty.map({ "(\($0.userRatingsTotal))"})
    }
    
    
    func configure(_ restaurant: Restaurant) {
        self.restaurantProperty.onNext(restaurant)
    }

}

extension Int {
    func repeating(_ str: String) -> String {
        var ret = ""
        for _ in 0..<self {
            ret += str
        }
        return ret
    }
}
