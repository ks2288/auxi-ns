//
//  Date+Helpers.swift
//  auxi-ns
//
//

import Foundation

// MARK: - Date extension

extension Date {
    
    /// Returns true if the date is the same as the current date, false otherwise
    ///
    /// - Returns: Returns true if the date is the same as the current date, false otherwise
    var isToday: Bool {
        isOnSameDay(as: Date())
    }
    
    /// Returns true iff the date given as the parameter is on the same day as self.
    func isOnSameDay(as otherDate: Date) -> Bool {
        let nowComponents = calendar.dateComponents([.day, .month, .year], from: otherDate)
        let selfComponents = calendar.dateComponents([.day, .month, .year], from: self)
        return Date.datesMatch(lhs: nowComponents, rhs: selfComponents)
    }
    
    /// Returns true if the date is the same as the yesterday's date, false otherwise
    ///
    /// - Returns: Returns true if the date is the same as the yesterday's date, false otherwise
    var isYesterday: Bool {
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            let yesterdayComponents = calendar.dateComponents([.day, .month, .year], from: yesterday)
            let selfComponents = calendar.dateComponents([.day, .month, .year], from: self)
            return Date.datesMatch(lhs: yesterdayComponents, rhs: selfComponents)
        }
        
        return false
    }
    
    /// Returns the date, of tomorrow, with the same time as the current date
    var tomorrow: Date {
        calendar.date(byAdding: .day, value: 1, to: self) ?? self.addingTimeInterval((24 * 60 * 60))
    }
    
    /// Returns the next week
    var nextWeek: Date {
        let endDayOfTheWeek = self.endOfWeek()
        return Calendar.current.date(byAdding: .day, value: 1, to: endDayOfTheWeek) ?? self
    }
    
    /// Returns the next month
    var nextMonth: Date {
        let endDayOfTheMonth = self.endOfMonth()
        return Calendar.current.date(byAdding: .day, value: 1, to: endDayOfTheMonth) ?? self
    }
    
    /// Returns the previous week
    var previousWeek: Date {
        let startDayOfTheWeek = self.startOfWeek()
        return Calendar.current.date(byAdding: .day, value: -1, to: startDayOfTheWeek) ?? self
    }
    
    /// Returns the previous month
    var previousMonth: Date {
        let startDayOfTheMonth = self.startOfMonth()
        return Calendar.current.date(byAdding: .day, value: -1, to: startDayOfTheMonth) ?? self
    }
    
    /// Returns the ellapsed time as a TimeInterval
    ///
    /// - Parameter startDate: The start date.
    /// - Returns: Returns the ellapsed time as a TimeInterval
    static func getEllapsedTime(since startDate: Date) -> TimeInterval {
        let duration = Date().timeIntervalSince(startDate)
        return duration
    }
    
    /// Converts from one TimeZone to another.
    ///
    /// - Parameters:
    ///   - to: The destination TimeZone, default: GMT - Dates in iOS are GMT/UTC by default
    ///   - from: The starting TimeZone, default: TimeZone.autoupdatingCurrent
    /// - Returns: The date adjusted to the new TimeZone
    //swiftlint:disable:next force_unwrapping - will not fail
    func convert(to: TimeZone = TimeZone(abbreviation: "GMT")!,
                 from: TimeZone = TimeZone.autoupdatingCurrent) -> Date {
        let toSeconds = to.secondsFromGMT()
        let fromSeconds = from.secondsFromGMT()
        let interval = TimeInterval(toSeconds - fromSeconds)
        return addingTimeInterval(interval)
    }
    
    /// Converts to the local TimeZone from another.
    ///
    ///   - from: The starting TimeZone, default: TimeZone(abbreviation: "GMT")
    /// - Returns: The date adjusted to the new TimeZone
    //swiftlint:disable:next force_unwrapping - will not fail
    func convertToLocal(from: TimeZone = TimeZone(abbreviation: "GMT")!) -> Date {
        convert(to: TimeZone.autoupdatingCurrent, from: from)
    }
    
    /// Converts to a UTC Date
    ///
    /// - Parameter from: The starting timezone
    /// - Returns: A date in UTC (technically GMT, since that's the TimeZone,
    ///            but UTC is the time standard being used by iOS, which uses GMT).
    func convertToUTC(from: TimeZone = TimeZone.autoupdatingCurrent) -> Date {
        //swiftlint:disable:next force_unwrapping - will not fail
        convert(to: TimeZone(abbreviation: "GMT")!, from: from)
    }
    
    /// Gets a list of DateComponents, converted
    /// The component array will begin at the current date, and end at the hour limit, or end of day.
    ///
    /// - Parameters:
    ///   - minutes: The frequency in minutes that the schedule repeats
    ///   - includeDMY: The frequency in minutes that the schedule repeats
    ///   - hourLimit: If given, doesn't end at end of day, but rather ends after the number of hours.
    /// - Returns: [DateComponents]
    func getRepeatingTimes(repeat minutes: Int,
                           includeDMY: Bool = false,
                           hourLimit: Int? = nil) -> [DateComponents] {
        var dates = [DateComponents]()
        let starting = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: self)
        
        /// Converts data to UTC and appends it to dates array
        ///
        /// - Parameter current:
        func addToResult(current: Date) {
            // This will convert the starting hour to the be the starting hour in UTC time
            // so when they're scheduled, they're scheduled in the timeZone specified, but as UTC time.
            if includeDMY {
                dates.append(calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                                     from: current))
            } else {
                dates.append(calendar.dateComponents([.hour, .minute, .second],
                                                     from: current))
            }
        }
        
        addToResult(current: self)
        
        var endDate: Date?
        if let hourLimit = hourLimit {
            endDate = calendar.date(byAdding: .hour, value: hourLimit, to: self)
        }
        
        if var nextTime = calendar.date(byAdding: .minute, value: minutes, to: self) {
            var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                                     from: nextTime)
            
            /// Checks for next date, or components, and if they exist returns true, otherwise returns false
            ///
            /// - Returns: Checks for next date, or components, and if they exist returns true, otherwise returns false
            func done() -> Bool {
                if let endDate = endDate {
                    return nextTime >= endDate
                } else {
                    return components.day == nil || components.day != starting.day
                }
            }
            
            while !done() {
                addToResult(current: nextTime)
                
                if let time = calendar.date(byAdding: .minute,
                                            value: minutes,
                                            to: nextTime) {
                    nextTime = time
                    components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                                         from: nextTime)
                } else {
                    components.day = nil
                }
            }
        }
        return dates
    }
    
    /// Gets a list of DateComponents, converted to UTC time for the given TimeZone.
    /// The component array will begin at the current date, and end at the hour limit, or end of day.
    ///
    /// - Parameters:
    ///   - minutes: The frequency in minutes that the schedule repeats
    ///   - includeDMY: The frequency in minutes that the schedule repeats
    ///   - hourLimit: If given, doesn't end at end of day, but rather ends after the number of hours.
    ///   - timeZone: The timezone for the scheduled times, default: TimeZone.autoupdatingCurrent
    /// - Returns: [DateComponents]
    func getRepeatingTimesAsUTC(repeat minutes: Int,
                                includeDMY: Bool = false,
                                hourLimit: Int? = nil,
                                timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> [DateComponents] {
        var dates = [DateComponents]()
        let starting = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year], from: self)
        
        /// Converts data to UTC and appends it to dates array
        ///
        /// - Parameter current:
        func addToResult(current: Date) {
            // This will convert the starting hour to the be the starting hour in UTC time
            // so when they're scheduled, they're scheduled in the timeZone specified, but as UTC time.
            let utcTime = current.convertToUTC(from: timeZone)
            if includeDMY {
                dates.append(calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                                     from: utcTime))
            } else {
                dates.append(calendar.dateComponents([.hour, .minute, .second],
                                                     from: utcTime))
            }
        }
        
        addToResult(current: self)
        
        var endDate: Date?
        if let hourLimit = hourLimit {
            endDate = calendar.date(byAdding: .hour, value: hourLimit, to: self)
        }
        
        if var nextTime = calendar.date(byAdding: .minute, value: minutes, to: self) {
            var components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                                     from: nextTime)
            
            /// Checks for next date, or components, and if they exist returns true, otherwise returns false
            ///
            /// - Returns: Checks for next date, or components, and if they exist returns true, otherwise returns false
            func done() -> Bool {
                if let endDate = endDate {
                    return nextTime >= endDate
                } else {
                    return components.day == nil || components.day != starting.day
                }
            }
            
            while !done() {
                addToResult(current: nextTime)
                
                if let time = calendar.date(byAdding: .minute,
                                            value: minutes,
                                            to: nextTime) {
                    nextTime = time
                    components = calendar.dateComponents([.hour, .minute, .second, .day, .month, .year],
                                                         from: nextTime)
                } else {
                    components.day = nil
                }
            }
        }
        return dates
    }
    
    /// Returns a date object set to the given time of day
    ///
    /// - Parameters:
    ///   - hour:
    ///   - minute:
    ///   - second:
    ///   - nanosecond:
    /// - Returns: Returns a date object set to the given time of day, or nil if failure
    static func timeOfDay(hour: Int,
                          minute: Int = 0,
                          second: Int = 0,
                          nanosecond: Int = 0) -> Date? {
        let validRange = 0...59
        let hourRange = 0...23
        guard hourRange.contains(hour)
                && validRange.contains(minute)
                && validRange.contains(second) else {
            return nil
        }
        var components = Calendar.autoupdatingCurrent
            .dateComponents([.day, .month, .year, .hour, .minute, .second, .nanosecond, .timeZone],
                            from: Date())
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        let timeOfDay = Calendar.autoupdatingCurrent.date(from: components)
        return timeOfDay
    }
    
    /// Returns true if the day, month and year match, false otherwise
    ///
    /// - Parameters:
    ///   - lhs: The left-hand-side date
    ///   - rhs: The right-hand-side date
    /// - Returns: Returns true if the day, month and year match, false otherwise
    static func datesMatch(lhs: DateComponents, rhs: DateComponents) -> Bool {
        if let lhsDay = lhs.day,
           let rhsDay = rhs.day,
           let lhsMonth = lhs.month,
           let rhsMonth = rhs.month,
           let lhsYear = lhs.year,
           let rhsYear = rhs.year {
            return lhsDay == rhsDay && lhsMonth == rhsMonth && lhsYear == rhsYear
        } else if let lhsHour = lhs.hour,
                  let lhsMinute = lhs.minute,
                  let lhsSecond = lhs.second,
                  let rhsHour = rhs.hour,
                  let rhsMinute = rhs.minute,
                  let rhsSecond = rhs.second {
            return lhsHour == rhsHour && lhsMinute == rhsMinute && lhsSecond == rhsSecond
        }
        return false
    }
    
    // The dates sent to and received from the Cloud API are "almost" equal-- they are off on milliseconds.
    // E.g., Actual: Optional(2019-05-09 16:35:35 +0000) Expected: Optional(2019-05-09 16:35:35 +0000), but
    // looking a little more deeply we have:
    // timeIntervalSinceReferenceDate : 579112535.747 versus timeIntervalSinceReferenceDate : 579112535.754833
    // This method compares dates on the basis of seconds, ignoring milliseconds.
    static func equalUsingSeconds(_ date1: Date?, _ date2: Date?) -> Bool {
        // If both dates are nil, consider them equal
        if date1 == nil && date2 == nil {
            return true
        }
        
        // Otherwise, both should be non-nil to possibly be equal.
        guard let date1 = date1, let date2 = date2 else {
            return false
        }
        return Int(date1.timeIntervalSinceReferenceDate) == Int(date2.timeIntervalSinceReferenceDate)
    }
    
    /// Returns the number of hours from another Date.
    /// when comparing:
    ///   self = 1970 Jan 01, 22:59:59.999 +00:00
    ///   date = 1970 Jan 02, 23:00:00.000 +00:00
    /// This will return 0 even though the hour number incremented.
    ///
    /// - Parameters:
    ///  - from date: the Date to calculate hours from
    /// - Returns: Number of hours.
    func hours(from date: Date) -> Int {
        Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    /// Returns the number of days from another Date.
    /// Useful when comparing dates with non determinant lengths (i.e. leap years):
    /// self = 1999 Feb 27, 00:00:00.000 +00:00
    /// date = 1999 Mar 01, 00:00:00.000 +00:00
    /// will return 2
    /// Where as
    /// self = 2000 Feb 27, 00:00:00.000 +00:00
    /// date = 2000 Mar 01, 00:00:00.000 +00:00
    /// will return 3
    ///
    /// - Parameters:
    ///  - from date: the Date to calculate hours from
    /// - Returns: Number of days.
    func days(from date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    /// Returns the number of months from another Date.
    ///
    /// - Parameters:
    ///  - from date: the Date to calculate hours from
    /// - Returns: Number of months.
    func months(from date: Date) -> Int {
        Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    /// Create a new date form calendar components.
    ///
    /// - Parameters:
    ///   - calendar: Calendar (default is current).
    ///   - timeZone: TimeZone (default is current).
    ///   - era: Era (default is current era).
    ///   - year: Year (default is current year).
    ///   - month: Month (default is current month).
    ///   - day: Day (default is today).
    ///   - hour: Hour (default is current hour).
    ///   - minute: Minute (default is current minute).
    ///   - second: Second (default is current second).
    ///   - nanosecond: Nanosecond (default is current nanosecond).
    init(calendar: Calendar? = Calendar.current,
         timeZone: TimeZone? = TimeZone.current,
         era: Int? = Date().era,
         year: Int? = Date().year,
         month: Int? = Date().month,
         day: Int? = Date().day,
         hour: Int? = Date().hour,
         minute: Int? = Date().minute,
         second: Int? = Date().second,
         nanosecond: Int? = Date().nanosecond) {
        
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = timeZone
        components.era = era
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.nanosecond = nanosecond
        
        self = calendar?.date(from: components) ?? Date()
    }
    
    func setTime(hour: Int,
                 min: Int,
                 sec: Int = 0,
                 calendar: Calendar = Calendar.current,
                 timeZone: TimeZone = TimeZone.current) -> Date {
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.timeZone = timeZone
        components.hour = hour
        components.minute = min
        components.second = sec
        //swiftlint:disable:next force_unwrapping - will not fail
        return calendar.date(from: components)!
    }
    
    func setTime(timeOfDay: Date,
                 calendar: Calendar = Calendar.autoupdatingCurrent,
                 timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> Date {
        let hourMinuteSecond = calendar.dateComponents([.hour, .minute, .second], from: timeOfDay)
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.timeZone = timeZone
        //swiftlint:disable force_unwrapping - will not fail
        components.hour = hourMinuteSecond.hour!
        components.minute = hourMinuteSecond.minute!
        components.second = hourMinuteSecond.second!
        return calendar.date(from: components)!
        //swiftlint:enable force_unwrapping
    }
    
    func setDate(month: Int,
                 day: Int,
                 year: Int,
                 calendar: Calendar = Calendar.autoupdatingCurrent,
                 timeZone: TimeZone = TimeZone.autoupdatingCurrent) -> Date {
        var components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second, .timeZone], from: self)
        components.month = month
        components.day = day
        components.year = year
        //swiftlint:disable:next force_unwrapping - will not fail
        return calendar.date(from: components)!
    }
    
    func setBeginOfDay(calendar: Calendar = Calendar.current, timeZone: TimeZone = TimeZone.current) -> Date {
        setTime(hour: 0, min: 0, sec: 0, calendar: calendar, timeZone: timeZone)
    }
    
    func setEndOfDay(calendar: Calendar = Calendar.current, timeZone: TimeZone = TimeZone.current) -> Date {
        setTime(hour: 23, min: 59, sec: 59, calendar: calendar, timeZone: timeZone)
    }
    
    func startOfWeek(calendar: Calendar = Calendar.current, timeZone: TimeZone = TimeZone.current) -> Date {
        //swiftlint:disable:next force_unwrapping - will not fail
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
            .setBeginOfDay(calendar: calendar, timeZone: timeZone)
    }
    
    func endOfWeek(calendar: Calendar = Calendar.current, timeZone: TimeZone = TimeZone.current) -> Date {
        //swiftlint:disable:next force_unwrapping - will not fail
        calendar.date(byAdding: .day, value: 6, to: startOfWeek(calendar: calendar, timeZone: timeZone))!
            .setEndOfDay(calendar: calendar, timeZone: timeZone)
    }
    
    func startOfMonth(calendar: Calendar = Calendar.current) -> Date {
        //swiftlint:disable:next force_unwrapping - will not fail
        calendar.date(from: calendar.dateComponents([.year, .month], from: calendar.startOfDay(for: self)))!
    }
    
    func endOfMonth(calendar: Calendar = Calendar.current) -> Date {
        //swiftlint:disable:next force_unwrapping - will not fail
        calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth(calendar: calendar))!
    }
    
    func dayNumberOfWeek(calendar: Calendar = Calendar.current) -> Int {
        //swiftlint:disable:next force_unwrapping - will not fail
        calendar.dateComponents([.weekday], from: self).weekday!
    }
    
    var calendar: Calendar {
        Calendar.autoupdatingCurrent
    }
    
    /// Time zone used by system.
    var timeZone: TimeZone {
        calendar.timeZone
    }
    
    var era: Int {
        calendar.component(.era, from: self)
    }
    
    var year: Int {
        get {
            calendar.component(.year, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone,
                        era: era, year: newValue, month: month, day: day,
                        hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    var month: Int {
        get {
            calendar.component(.month, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone,
                        era: era, year: year, month: newValue, day: day,
                        hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    var day: Int {
        get {
            calendar.component(.day, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone,
                        era: era, year: year, month: month, day: newValue,
                        hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    func day(calendar: Calendar = Calendar.current) -> Int {
        calendar.component(.day, from: self)
    }
    
    var hour: Int {
        get {
            calendar.component(.hour, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone,
                        era: era, year: year, month: month, day: day,
                        hour: newValue, minute: minute, second: second, nanosecond: nanosecond)
        }
    }
    
    var minute: Int {
        get {
            calendar.component(.minute, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone,
                        era: era, year: year, month: month, day: day,
                        hour: hour, minute: newValue, second: second, nanosecond: nanosecond)
        }
    }
    
    var second: Int {
        get {
            calendar.component(.second, from: self)
        }
        set {
            self = Date(calendar: calendar, timeZone: timeZone,
                        era: era, year: year, month: month, day: day,
                        hour: hour, minute: minute, second: newValue, nanosecond: nanosecond)
        }
    }
    
    var nanosecond: Int {
        calendar.component(.nanosecond, from: self)
    }
    
    /// Round the time to the nearest time, TimeInterval in seconds
    public func round(precision: TimeInterval) -> Date {
        rounded(precision: precision, rule: .toNearestOrAwayFromZero)
    }
    
    private func rounded(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (timeIntervalSinceReferenceDate / precision).rounded(rule) * precision
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
    
    var randomDayOfCurrentMonth: Date {
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        guard
            let days = calendar.range(of: .day, in: .month, for: self),
            let randomDay = days.randomElement()
        else {
                return self
        }
        dateComponents.setValue(randomDay, for: .day)
        return calendar.date(from: dateComponents) ?? self
    }
}
