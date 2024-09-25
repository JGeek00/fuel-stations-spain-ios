

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
