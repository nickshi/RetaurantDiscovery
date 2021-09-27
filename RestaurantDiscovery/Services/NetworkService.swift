//
//  APIClient.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/23/21.
//

import Foundation

protocol NetworkType {
    func getNearByResturants(_ lat: Double, _ lng: Double, _ keyword: String, _ completionHanlder: @escaping (Result<RestaurantEnvelope, NetworkError>) -> Void)
}

enum NetworkError: Error {
    case invalidResponse
    case underlying(Error)
}
class NetworkService: NetworkType {
    func getNearByResturants(_ lat: Double, _ lng: Double, _ keyword: String, _ completionHanlder: @escaping (Result<RestaurantEnvelope, NetworkError>) -> Void) {
        
        func dispatch(_ result: Result<RestaurantEnvelope, NetworkError>) {
            DispatchQueue.main.async {
                completionHanlder(result)
            }
        }
        
        let strURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=\(keyword)&location=\(lat)%2C\(lng)&radius=1500&type=restaurant&key=\(GOOGLE_API_KEY)"
        URLSession.shared.dataTask(with: URL(string: strURL)!) { data, response, error in
            if let error = error {
                dispatch(.failure(.underlying(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if (200...400).contains(response.statusCode) {
                    if let data = data, let envelope = try? JSONDecoder().decode(RestaurantEnvelope.self, from: data) {
                        dispatch(.success(envelope))
                    } else {
                        dispatch(.failure(.invalidResponse))
                    }
                } else {
                    dispatch(.failure(.invalidResponse))
                }
            } else {
                dispatch(.failure(.invalidResponse))
            }
        }.resume()
    }
}
