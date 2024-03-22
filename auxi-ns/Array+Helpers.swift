//
//  Array+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension Array where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}
