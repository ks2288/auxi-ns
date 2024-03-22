//
//  DateFormatter+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension DateFormatter {
    
    static let rfc3339DateTimeFormat = "yyyy-MM-dd'T'HH-mm"
    static var rfc3339DateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = rfc3339DateTimeFormat
        return dateFormatter
    }
    static let rfc3339DateTimeFormatWithSeconds = "yyyy-MM-dd'T'HH:mm:ss"
    static let rfc3339DateTimeFormatWithMillis = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    static let simpleDateTimeFormat = "yyyy/MM/dd HH:mm:ss"
    static let iso8601DateTimeFormat = "yyyy/MM/dd'T'HH:mm:ss"
    
    /// Convenience function converting an Optional<Date> to String
    /// - Parameter date: Date to be converted to String
    /// - Returns: String representation of the Date, if date is nil will return nil.
    func string(fromOptional date: Date? = nil) -> String? {
        if let date = date {
            return string(from: date)
        } else {
            return nil
        }
    }
}
