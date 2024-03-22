//
//  CocoaExtensions.swift
//  auxi-ns
//
//

import AVKit
import SwiftUI

extension Int {
    static func extractNumbers(from string: String) -> [Int] {
        let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
        return stringArray.compactMap { Int($0) }
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else {
            return nil
        }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func rotation() -> Angle {
        switch self.imageOrientation {
        case .right:
            print("oriented to the right")
            return .degrees(90)
        case .up:
            print("oriented to the up")
            return .degrees(0)
        case .left:
            print("oriented to the left")
            return .degrees(-90)
        case .down:
            print("oriented to the down")
            return .degrees(180)
        default:
            return .degrees(0)
        }
    }
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        // swiftlint:disable:next force_unwrapping - will not fail
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width / 2,
                             y: -self.size.height / 2,
                             width: self.size.width,
                             height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func aspectRatio() -> CGFloat {
        let imageAspectRatio: CGFloat = self.size.width / self.size.height
        return imageAspectRatio
    }
}

extension String {
    
    /// Create `Data` from hexadecimal string representation
    ///
    /// This creates a `Data` object from hex string. Note, if the string has any spaces or non-hex characters
    /// (e.g. starts with '<' and with a '>'), those are ignored and only hex characters are processed.
    ///
    /// - returns: Data represented by this hexadecimal string.
    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        // swiftlint:disable:next force_try - will not fail
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            // swiftlint:disable force_unwrapping - will not fail
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            // swiftlint:enable force_unwrapping
            data.append(num)
        }
        
        guard !data.isEmpty else {
            return nil
        }
        return data
    }
    
    /// Convenience function to convert a String to Data
    func data(encoding: String.Encoding = .utf8) throws -> Data {
        guard let data = self.data(using: encoding, allowLossyConversion: true) else {
            throw NSError(domain: "dev.specter.parseError", code: 1001, userInfo: nil) as Error
        }
        return data
    }
    
    /// Creates a UIImage from the data for it encoded as a Base64 string
    func base64ToImage() -> UIImage? {
        if let imageData = Data(base64Encoded: self,
                                options: Data.Base64DecodingOptions.ignoreUnknownCharacters) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    static func emojiFlag(for countryCode: String) -> String! {
        func isLowercaseASCIIScalar(_ scalar: Unicode.Scalar) -> Bool {
            return scalar.value >= 0x61 && scalar.value <= 0x7A
        }
        func regionalIndicatorSymbol(for scalar: Unicode.Scalar) -> Unicode.Scalar {
            precondition(isLowercaseASCIIScalar(scalar))
            // 0x1F1E6 marks the start of the Regional Indicator Symbol range and corresponds to 'A'
            // 0x61 marks the start of the lowercase ASCII alphabet: 'a'
            // swiftlint:disable force_unwrapping - will not fail
            return Unicode.Scalar(scalar.value + (0x1F1E6 - 0x61))!
        }
        let lowercasedCode = countryCode.lowercased()
        guard lowercasedCode.count == 2 else {
            return nil
        }
        guard lowercasedCode.unicodeScalars.allSatisfy({ scalar in isLowercaseASCIIScalar(scalar) }) else {
            return nil
        }
        let indicatorSymbols = lowercasedCode.unicodeScalars.map({ regionalIndicatorSymbol(for: $0) })
        return String(indicatorSymbols.map({ Character($0) }))
    }
    
    /// Extension vars for quicker predicate building within managed Realms
    var uuidQuery: String { return "uuid = \(self)" }
    var rtcIdQuery: String { return "rtcId = \(self)"}
}

extension View {
    func deviceScreenWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    func deviceScreenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func hapticFeedback() {
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.impactOccurred()
    }
    
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

extension UIDevice {
    static var deviceType: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else {
                return identifier
            }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
