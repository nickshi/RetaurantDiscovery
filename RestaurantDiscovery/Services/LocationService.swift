//
//  LocationService.swift
//  RestaurantDiscovery
//
//  Created by Nick Shi on 9/24/21.
//

import Foundation
import CoreLocation

enum LocationServiceError: Error {
    case notAuthorizedToRequestLocation
}

protocol LocationService {
    typealias FetchLocationCompletion = (Location?, LocationServiceError?) -> Void
    
    func fetchLocation(completion: @escaping FetchLocationCompletion)
}

class LocationManager: NSObject, LocationService {
    
    private lazy var locationManager: CLLocationManager = {
        // Initialize Location Manager
        let locationManager = CLLocationManager()
        
        // Configure Location Manager
        locationManager.delegate = self
        
        return locationManager
    }()
    
    private var didFetchLocation: FetchLocationCompletion?
    
    
    func fetchLocation(completion: @escaping LocationService.FetchLocationCompletion) {
        self.didFetchLocation = completion
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            // Request Authorization
            locationManager.requestWhenInUseAuthorization()
            
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            // Fetch Location
            locationManager.startUpdatingLocation()
        } else {
            // Invoke Completion Handler
            didFetchLocation?(nil, .notAuthorizedToRequestLocation)
            
            // Reset Completion Handler
            didFetchLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        locationManager.stopUpdatingLocation()
        // Invoke Completion Handler
        didFetchLocation?(Location(location: location), nil)
        
        // Reset Completion Handler
        didFetchLocation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Unable to Fetch Location (\(error))")
    }
    
}

fileprivate extension Location {
    // MARK: - Initialization

    init(location: CLLocation) {
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
    }

}


