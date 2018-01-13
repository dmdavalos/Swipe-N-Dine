//
//  Location.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 1/11/18.
//  Copyright © 2018 Daniel Davalos. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationDelegate {
    func didReceiveLocation(lat: Double, lon: Double)
    func didReceiveError(error: Error)
    func locationNotAuthorized()
}

class Location: NSObject, CLLocationManagerDelegate {
    public var delegate: LocationDelegate?
    
    private var latitude: Double?
    private var longitude: Double?
    private var locationManager: CLLocationManager?
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestWhenInUseAuthorization()
    }
    
    func getLocation() {
        locationManager?.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location: \(String(describing: locations.last!.coordinate.latitude)), \(String(describing: locations.last!.coordinate.longitude))")
        delegate?.didReceiveLocation(lat: locations.last!.coordinate.latitude, lon: locations.last!.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager?.requestLocation()
        }
        else if status == .denied {
            delegate?.locationNotAuthorized()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location! \(error.localizedDescription)")
        delegate?.didReceiveError(error: error)
    }
}
