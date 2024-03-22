//
//  CaseIterable+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension CaseIterable where Self: RawRepresentable {
    /// Convenient property that gives you the array of raw values
    static var allValues: [Self.RawValue] {
        allCases.map { $0.rawValue }
    }
}

extension CaseIterable where Self: Equatable {
    
    /// Convenience function to get a random case
    static func random() -> Self? {
        allCases.random()
    }
    
    /// Convenience function to get a random case
    ///
    /// - Parameter without: cases which you don't want to be selected
    static func random(without: Self...) -> Self? {
        allCases.filter { !without.contains($0) }.random()
    }
}
