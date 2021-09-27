//
//  Observable+UnWrap.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/24/21.
//

import Foundation
import RxSwift

extension Observable {
    func unwrap<T>() -> Observable<T> where Element == T? {
        return self.filter({ $0 != nil })
            .map({ $0! })
    }
}
