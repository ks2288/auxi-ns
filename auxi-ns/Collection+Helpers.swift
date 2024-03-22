//
//  Collection+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension Collection {

    /// Convenience function to turn Collection to an Array consisting its elements
    func toArray() -> [Self.Element] {
        Array(self)
    }

    /// Convenience function to get a random element in a collection
    func random() -> Self.Element? {
        guard !isEmpty else {
            return nil
        }
        return toArray()[Int.random(in: 0..<self.count)]
    }
}
