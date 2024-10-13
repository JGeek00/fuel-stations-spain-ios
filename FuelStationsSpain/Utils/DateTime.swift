

import Foundation

func toLocalDate(from utcDate: Date) -> Date {
    // Get the local time zone
    let localTimeZone = TimeZone.current
    
    // Get the UTC time zone
    let utcTimeZone = TimeZone(identifier: "UTC")!

    // Get the offset between the two time zones
    let timeZoneOffset = localTimeZone.secondsFromGMT() - utcTimeZone.secondsFromGMT()
    
    // Adjust the Date object to local time by adding the offset
    return utcDate.addingTimeInterval(TimeInterval(timeZoneOffset))
}

func hoursDifference() -> Int {
    // Get the current date in UTC
    let utcDate = Date()

    // Get the local time zone
    let localTimeZone = TimeZone.current

    // Calculate the difference in seconds from UTC
    let differenceInSeconds = localTimeZone.secondsFromGMT(for: utcDate)

    // Calculate the difference in hours
    return differenceInSeconds / 3600
}

func timeIntervalToDHM(_ timeInterval: TimeInterval) -> (days: Int, hours: Int, minutes: Int) {
    // Round the total seconds to the nearest minute
    let totalMinutes = Int(round(timeInterval / 60))
    
    // Calculate days, hours, and minutes
    let days = totalMinutes / (24 * 60)
    let hours = (totalMinutes % (24 * 60)) / 60
    let minutes = totalMinutes % 60
    
    return (days, hours, minutes)
}
