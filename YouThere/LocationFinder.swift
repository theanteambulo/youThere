//
//  LocationFinder.swift
//  YouThere
//
//  Created by Jake King on 20/09/2021.
//

import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        print("User's location will be stored with permission")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation =  locations.first?.coordinate
        print("Started tracking the user's location")
    }
}
