//
//  Bool+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension Bool {
    func toUInt8() -> UInt8 {
        return UInt8(self ? 0x01 : 0x00)
    }
}

extension Array where Iterator.Element == Bool {

    /// Converts a boolean array to Data, with given size.
    ///
    /// - Parameter sizeInBytes: The size of the resulting Data structure.
    /// - Returns: Data containing the boolean flags
    func toData() -> Data {
        guard !self.isEmpty else {
            return Data()
        }
        var data = Data(repeating: 0, count: self.count / 8 + (self.count % 8 == 0 ? 0: 1))

        for index in 0 ..< self.count {
            let byteIndex = index / 8 // index 0-7 for byte 0, index 8-15 for byte 1, etc
            let shiftAmount = UInt8(index % 8) // index 0 = true -> 0b0000 0001
            let item = self[index]
            let flag = UInt8(item ? 1 : 0)
            data[byteIndex] |= flag << shiftAmount
        }
        Logger.v("Converted boolean array to binary: \(data.asHex)")
        return data
    }
}
