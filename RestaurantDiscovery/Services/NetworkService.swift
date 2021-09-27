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
        
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json")
        components?.queryItems = [
            URLQueryItem(name: "keyword", value: keyword),
            URLQueryItem(name: "location", value: "\(lat),\(lng)"),
            URLQueryItem(name: "radius", value: String(15000)),
            URLQueryItem(name: "type", value: "restaurant"),
            URLQueryItem(name: "key", value: GOOGLE_API_KEY),
        ]
        
        URLSession.shared.dataTask(with: components!.url!) { data, response, error in
            if let error = error {
                dispatch(.failure(.underlying(error)))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                if (200...400).contains(response.statusCode) {
                    if let data = data {
                        do {
                            let envelope = try JSONDecoder().decode(RestaurantEnvelope.self, from: data)
                            if envelope.status != "OK" {
                                dispatch(.failure(.invalidResponse))
                            } else {
                                dispatch(.success(envelope))
                            }
                            
                        } catch {
                            dispatch(.failure(.underlying(error)))
                        }
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
