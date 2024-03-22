//
//  CoreLocation+Helpers.swift
//  auxi-ns
//
//

import CoreLocation
import Foundation

extension CLPlacemark {
    /// Creates a string with multiple address components excluding postal and country code
    internal var address: String {
        ("\(self.subThoroughfare ?? "")" +
            " \(self.thoroughfare ?? "")" +
            " \(self.locality ?? "")," +
            " \(self.administrativeArea ?? "")").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension CLLocation {
    
    // default value for the horizontalAccuracy/verticalAccuracy param for CLLocation
    // when doing a reverse look up from GPS.
    // Per Apple's Doc: "The radius of uncertainty for the location, measured in meters."
    static let defaultHorizontalAccuracy: Double = 300
    static let defaultVerticalAccuracy: Double = 300
    
    /// Convenience factory method to create CLLocation from CLLocationCoordinate2D
    static func create(from coordinate: CLLocationCoordinate2D) -> CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    /// Does a reverse lookup of CLPlacemark with the CLLocation info
    /// - Parameters:
    ///     - completion: completion handler that runs with the first result (if none found nil) from the lookup
    func getFirstPlaceMark(completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(self) { placemarks, error in
            Logger.v("placemarks for country! \(placemarks ?? [])")
            completion(placemarks?.first)
        }
    }
    
    /// Convenient factory method that creates CLLocation from GPS properties
    static func create(latitude: Double,
                       longitude: Double,
                       elevation: Double,
                       horizontalAccuracy: Double = CLLocation.defaultHorizontalAccuracy,
                       verticalAccuracy: Double = CLLocation.defaultVerticalAccuracy,
                       timestamp: Date = Date()) -> CLLocation {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let altitude = CLLocationDistance(elevation)
        return CLLocation(coordinate: coordinates,
                          altitude: altitude,
                          horizontalAccuracy: 1414,
                          verticalAccuracy: 1414,
                          timestamp: timestamp)
    }
    
    /// Convenience conversion method to create GeographicalCoordinates from self
    func toGeographicalCoordinates() -> GeographicalCoordinates {
        GeographicalCoordinates(clLocation: self)
    }
}
