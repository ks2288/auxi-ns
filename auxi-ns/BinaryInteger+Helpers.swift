//
//  BinaryInteger+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension BinaryInteger {
    var asHex: String {
        String(self, radix: 16, uppercase: true)
    }
    
    var firstDigit: Self {
        return nthDigit(1)
    }
    
    var secondDigit: Self {
        return nthDigit(2)
    }
    
    var thirdDigit: Self {
        return nthDigit(3)
    }
    
    var fourthDigit: Self {
        return nthDigit(4)
    }
    
    func nthDigit(_ digitAt: Self) -> Self {
        guard digitAt > 0 else {
            return 0
        }
        guard digitAt > 1 else {
            return self % 10
        }
        guard let multiplier = Int("1".padding(toLength: Int(digitAt), withPad: "0", startingAt: 0)) else {
            return self
        }
        // TODO: get the substring to clean up logic here
        let result = String(self / Self(multiplier))
        let firstDigitString = String(result[result.index(result.startIndex, offsetBy: result.count - 1)])
        let firstDigit = (firstDigitString as NSString).intValue
        return Self(firstDigit)
    }
    
    func setDigit(at: Self, to digit: Self) -> Self {
        guard at > 0 else {
            return self
        }
        guard let multiplier = Int("1".padding(toLength: Int(at), withPad: "0", startingAt: 0)) else {
            return self
        }
        return self + (Self(multiplier) * digit)
    }
}
