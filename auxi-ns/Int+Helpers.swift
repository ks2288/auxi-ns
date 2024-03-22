//
//  Int+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension Int {
    
    /// Convenience function to get a random Int
    /// Main use case is with TimeInterval which is a Double
    static func random(in range: Range<Double>) -> Int {
        Int(Double.random(in: range))
    }
    
    /// Convenience function to get a random Int
    /// Main use case is with TimeInterval which is a Double
    static func random(in range: ClosedRange<Double>) -> Int {
        Int(Double.random(in: range))
    }
}
