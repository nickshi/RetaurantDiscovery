//
//  Restaurant.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/21/21.
//

import Foundation

struct RestaurantEnvelope: Decodable {
    var results: [Restaurant] = []
    var status: String = ""
    
    enum CodingKeys: String, CodingKey {
        case candidates
        case results
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let status = try container.decodeIfPresent(String.self, forKey: .status) {
            self.status = status
        }
        
        if let results = try container.decodeIfPresent([Restaurant].self, forKey: .results) {
            self.results = results
        }
        
        if let results = try container.decodeIfPresent([Restaurant].self, forKey: .candidates) {
            self.results = results
        }
    }
}

struct Location: Decodable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}

struct Photo: Decodable {
    var height: Int
    var width: Int
    var photoReference: String
    
    enum CodingKeys: String, CodingKey {
        case height
        case width
        case photoReference = "photo_reference"
    }
    
    
    var photoURL: String {
        return "https://maps.googleapis.com/maps/api/place/photo?photoreference=\(photoReference)&sensor=false&maxheight=\(height)&maxwidth=\(width)&key=AIzaSyDQSd210wKX_7cz9MELkxhaEOUhFP0AkSk"
    }
}

struct Restaurant: Decodable {
    var name: String = "" 
    var rating: Double = 0
    var location: Location
    var photos: [Photo] = []
    var priceLevel: Int = 0
    var userRatingsTotal: Int = 0
    enum CodingKeys: String, CodingKey {
        case name
        case rating
        case photos
        case priceLevel = "price_level"
        case location
        case geometry
        case userRatingsTotal = "user_ratings_total"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        if let rating = try container.decodeIfPresent(Double.self, forKey: .rating) {
            self.rating = rating
        }
        if let priceLevel = try container.decodeIfPresent(Int.self, forKey: .priceLevel) {
            self.priceLevel = priceLevel
        }
        
        if let userRatingsTotal = try container.decodeIfPresent(Int.self, forKey: .userRatingsTotal) {
            self.userRatingsTotal = userRatingsTotal
        }
        
        if let photos = try container.decodeIfPresent([Photo].self, forKey: .photos) {
            self.photos = photos
        }
        
        let geometry = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .geometry)
        self.location = try geometry.decode(Location.self, forKey: .location)
    }
    
    var photoURL: String? {
        return self.photos.first?.photoURL
    }
}
