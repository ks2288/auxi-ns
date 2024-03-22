//
//  RawRepresentable+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension RawRepresentable where Self.RawValue: BinaryInteger, Self: CustomStringConvertible {
    var longDescription: String {
        "\(description)(0x\(self.rawValue.asHex))"
    }
}
