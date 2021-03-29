//
//  LocationManager.swift
//  WeatherWidget
//
//  Created by Lanex-Mark on 3/27/21.
//

import Foundation
import CoreLocation
import Combine
import WidgetKit

struct LocationData: Codable {
    var city: String
    var area: String
    var country: String
    
    var locationString: String {
        return "\(city),\(country)"
    }
}

extension LocationData: Equatable {
    static func ==(lhs: LocationData, rhs: LocationData) -> Bool {
        return lhs.city == rhs.city && lhs.area == rhs.area && lhs.country == rhs.country
    }
}

extension LocationData {
    static let `default` = LocationData(city: "Makati City", area: "BGC", country: "Philippines")
}

@available(iOS 14.0, *)
class LocationManager: NSObject, ObservableObject {
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        //self.locationManager.pausesLocationUpdatesAutomatically = true
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var locationData = LocationData.default {
        willSet {
            //print(locationData)
            
            // only update Widget when locationdata has changed, otherwise dont.
            // to refrain from unnecessary weather requests from widget, since widget is already requesting every minute for weather
            if locationData.area != newValue.area || locationData.city != newValue.city || locationData.country != newValue.country {
                do {
                    let data = try JSONEncoder().encode(locationData)
                    UserDefaults.group?.setValue(data, forKey: UserDefaults.Keys.locationID)
                    WidgetCenter.shared.reloadAllTimelines()
                } catch {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
            objectWillChange.send()
        }
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func getLocationData() -> LocationData {
        self.locationData
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    private let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
}

@available(iOS 14.0, *)
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationStatus = status
        if status == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
            manager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
//            manager.stopUpdatingLocation()
//            manager.stopMonitoringSignificantLocationChanges()
            manager.requestWhenInUseAuthorization()
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.lastLocation = location
        geoCoder.reverseGeocodeLocation(self.lastLocation ?? location) { (placemarks, error) in
            if let places = placemarks {
                places.forEach { place in
                    if let city = place.locality, let subCity = place.subLocality, let country = place.country {
                        self.locationData = LocationData(city: city, area: subCity, country: country)
                    }
                }
            }
        }
    }
}
