//
//  TimeInterval+Helpers.swift
//  auxi-ns
//
//

import Foundation

extension TimeInterval {
    /// constructor that creates a TimeInterval with the specified values
    /// - Parameters:
    ///   - days: Double the number of days this time interval should represent
    ///   - hours: Double? the number of hours this time interval should represent
    ///   - minutes: Date, the number of minutes this time interval should represent
    /// Note: This just simply converts days to hours and then hours for days + hours specified to minutes
    ///    and adds it up with the minutes value provided.
    /// So it can support values like TimeInterval(days: 1, hours: 22, minutes: 120) which basically would be 2 days
    init(days: Double, hours: Double? = nil, minutes: Double? = nil) {
        var totalHours: Double = days * 24
        if let hours = hours {
            totalHours += hours * 60
        }
        self.init(hours: totalHours, minutes: minutes)
    }
    
    /// constructor that creates a TimeInterval with the specified values
    /// - Parameters:
    ///   - hours: Double the number of hours this time interval should represent
    ///   - minutes: Date?, the number of minutes this time interval should represent
    /// Note: This just simply converts hours to minutes and adds it up with the minutes value provided.
    /// So it can support values like TimeInterval(hours: 6, minutes: 120) which basically would be 8 hours.
    init(hours: Double, minutes: Double? = nil) {
        var totalMinutes: Double = hours * 60
        if let minutes = minutes {
            totalMinutes += minutes
        }
        self.init(minutes: totalMinutes)
    }
    
    /// constructor that creates a TimeInterval with the specified values
    /// - Parameters:
    ///   - minutes: Date, the number of minutes this time interval should represent
    init(minutes: Double) {
        self.init(minutes * 60)
    }
}

/// Extension for formatting TimeIntervals
extension TimeInterval {
    /// Convenience function to create a string representing the time interval
    /// - Parameters:
    ///   - allowedUnits:
    ///   - zeroFormattingBehavior:
    ///   - defaultString:
    /// - Returns: a string representing the time interval
    func formatted(allowedUnits: NSCalendar.Unit = [.hour, .minute, .second],
                   zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = .pad,
                   defaultString: String = "--:--:--") -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = allowedUnits
        formatter.zeroFormattingBehavior = zeroFormattingBehavior
        return formatter.string(from: self) ?? defaultString
    }
}
