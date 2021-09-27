//
//  UIView+Shadow.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import UIKit

extension UIView {
    public func addShadow(offset: CGSize = .zero, opacity: Float = 0.65, radius: CGFloat = 20, color: UIColor = .black) {
         layer.shadowOffset = offset
         layer.shadowOpacity = opacity
         layer.shadowRadius = radius
         layer.shadowColor = color.cgColor
         layer.masksToBounds = false
     }
}
