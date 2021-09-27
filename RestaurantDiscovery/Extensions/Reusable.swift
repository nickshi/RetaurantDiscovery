//
//  Reusable.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import Foundation

protocol Reusable {
    static var resuableIdentifier: String { get }
}

extension Reusable {
    static var resuableIdentifier: String {
        return String(describing: Self.self)
    }
}
