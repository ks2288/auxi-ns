//
//  String+Date.swift
//  auxi-ns
//
//

import Foundation

/// Extension for converting String to Date and other supplementary functions to do so.
extension String {
    
    /// Convenience function to convert a string representation of a DateTime to a Date in the time zone of the device.
    func asLocalDate(format: String) -> Date? {
        return asDate(format: format,
                      locale: Locale.current,
                      timeZone: TimeZone.current)
    }
    
    /// Convenience function to convert a string representation of a DateTime to a Date in GMT
    func asGMTDate(format: String) -> Date? {
        // should never happen but just in case...
        guard let timeZone = TimeZone(secondsFromGMT: 0) else {
            Logger.w("Could not create TimeZone with 0 seconds from GMT.")
            return nil
        }
        return asDate(format: format,
                      locale: Locale(identifier: "en_US_POSIX"),
                      timeZone: timeZone)
    }
    
    /// Convenience function to convert a string representation of a DateTime to Date
    /// Note: The date will be altered if the timezone of the input string is not the same as specified. If you don't
    /// want it to change use asDate(format: String) instead.
    /// - Parameters:
    ///   - format: date time format of the string
    ///   - locale: locale for the date formatter. checkout: https://developer.apple.com/library/archive/qa/qa1480/_index.html
    ///   - timeZone: time zone for the date formatter
    func asDate(format: String, locale: Locale, timeZone: TimeZone) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        return dateFormatter.date(from: self)
    }
    
    /// Convenience function to convert a string representation of a DateTime to Date
    /// - Parameters:
    ///   - format: date time format of the string
    func asDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    /// Converts the date time string coming from ElliotLog
    func dateFromElliotLogTimestamp() -> Date? {
        return asGMTDate(format: DateFormatter.rfc3339DateTimeFormat)
    }
    
    /// Converts the date time string assuming it is in ISO8601 DateTime Format
    func dateFromISOTimestamp() -> Date? {
        return asGMTDate(format: DateFormatter.iso8601DateTimeFormat)
    }
    
    /// Converts the date string assuming it follows the following format:
    /// "MMMM d, yyyy" (i.e. November 1, 1990)
    func elliotDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.date(from: self)
    }
}

/// Extension for converting Date to String and other supplementary functions to do so.
extension Date {
    
    /// Creates a string representing the date & time with specified Format.
    /// Defaults to:
    /// "MMMM dd, yyyy hh:mm:ss a" (i.e. November 1, 1990 08:15:00 pm)
    func datetimeString(_ format: String = "MMMM dd, yyyy hh:mm:ss a",
                        timeZone: TimeZone = TimeZone.current,
                        locale: Locale = Locale.current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Creates a string representing the date & time with specified style.
    func datetimeString(dateStyle: DateFormatter.Style,
                        timeStyle: DateFormatter.Style,
                        timeZone: TimeZone = TimeZone.current,
                        locale: Locale = Locale.current) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        let localizedDate = formatter.string(from: self as Date)
        return localizedDate
    }
    
    /// Creates a string representing the date portion only with the format:
    /// "MMMM dd, yyyy" (i.e. November 1, 1990)
    func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: self)
    }
    
    /// Creates a string representing the time portion only with the format specified.
    /// Defaults to: h:mm a (e.g., 9:00 am)
    func timeString(_ format: String = "h:mm a", locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    /// Creates a string representing the time portion only with the style specified.
    func timeString(_ style: DateFormatter.Style, locale: Locale = Locale.current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.timeStyle = style
        return dateFormatter.string(from: self)
    }
    
    /// Creates a string representing the time interval from the specified date in the format:
    /// hh:mm:ss
    func formattedTimeIntervalSince(date: Date) -> String {
        timeIntervalSince(date).formatted(allowedUnits: [.hour, .minute, .second],
                                          zeroFormattingBehavior: .pad,
                                          defaultString: "--:--:--")
    }
    
    /// Creates a string representing the date time in GMT with RFC3339 format including seconds.
    func configTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormatter.rfc3339DateTimeFormatWithSeconds
        formatter.timeZone = TimeZone(identifier: "GMT")
        return formatter.string(from: self)
    }
    
    //Returns the month name as string, example February
    func monthAsString(_ format: String = "LLLL") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate(format)
        return dateFormatter.string(from: self)
    }
    
    //Returns the day name as string, example Monday
    func dayAsString(_ format: String = "EEEE") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
