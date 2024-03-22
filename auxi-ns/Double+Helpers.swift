//
//  Double+Helpers.swift
//  auxi-ns
//
//

import Foundation


extension Double {
    
    /// Rounds to the nearest
    /// - Parameter toNearest:
    /// - Returns:
    func round(toNearest: Double) -> Double {
        return (self / toNearest).rounded() * toNearest
    }
    
    /// Rounds to the number of decimal places
    /// - Parameter places:
    /// - Returns:
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
