import Foundation

class OpeningSchedule {
    let schedule: [Date]
    let isCurrentlyOpen: Bool
    
    init(schedule: [Date], isCurrentlyOpen: Bool) {
        self.schedule = schedule
        self.isCurrentlyOpen = isCurrentlyOpen
    }
}

func parseSchedule(schedule: String) -> [[Date?]?] {
    // Define a calendar to work with DateComponents
    _ = Calendar.current
    
    // Date formatter to convert string time (e.g., "07:00") to Date
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    
    // Define the dictionary for day abbreviations mapping to indices (e.g., "L" = 0 for Monday, etc.)
    let daysOfWeek = ["L": 0, "M": 1, "X": 2, "J": 3, "V": 4, "S": 5, "D": 6]
    
    // Initialize the result array with 7 null values (for 7 days of the week)
    var result: [[Date?]?] = Array(repeating: nil, count: 7)
    
    // Split the input string by semicolon to handle different segments
    let dayParts = schedule.split(separator: ";").map() { value in
        return value.replacing(" ", with: "")
    }

    for part in dayParts {
        // Split by colon to separate days from the time range
        guard let range = part.range(of: ":") else { continue }
        let firstPart = part[..<range.lowerBound] // "L-S"
        let secondPart = part[range.upperBound...] // " 07:00-21:00"
        
        let daysString = String(firstPart)
        let timeRange = String(secondPart.replacing("00:00", with: "23:59"))

        var times: [Date?] = []
        
        // Check if time range is "24H"
        if timeRange == "24H" {
            // Set opening time to 00:00 and closing time to 23:59
            times.append(dateFormatter.date(from: "00:00"))
            times.append(dateFormatter.date(from: "23:59"))
        } else {
            // If contains "y" it has two opening periods
            if timeRange.contains("y") {
                var periodsSplit = timeRange.split(separator: "y")
                periodsSplit = periodsSplit.map() { $0.replacing(" ", with: "") }
                periodsSplit.forEach { period in
                    // Split the time range by hyphen to get opening and closing times
                    let timeSplit = period.split(separator: "-")
                    if timeSplit.count == 2 {
                        if let open = dateFormatter.date(from: String(timeSplit[0])), let close = dateFormatter.date(from: String(timeSplit[1])) {
                            times.append(open)
                            times.append(close)
                        }
                    }
                }
            }
            else {
                // Split the time range by hyphen to get opening and closing times
                let timeSplit = timeRange.split(separator: "-")
                guard timeSplit.count == 2,
                      let open = dateFormatter.date(from: String(timeSplit[0])),
                      let close = dateFormatter.date(from: String(timeSplit[1])) else {
                    continue
                }
                times.append(open)
                times.append(close)
            }
        }
        
        // Split the days string to handle multiple day abbreviations (e.g., "L-V" or "S-D")
        let dayGroups = daysString.split(separator: "-")
        
        if dayGroups.count == 1 {  // Single day case
            if let dayIndex = daysOfWeek[String(dayGroups[0])] {
                result[dayIndex] = times
            }
        } else if dayGroups.count == 2 {  // Day range case (e.g., "L-V")
            if let startDay = daysOfWeek[String(dayGroups[0])],
               let endDay = daysOfWeek[String(dayGroups[1])] {
                for i in startDay...endDay {
                    result[i] = times
                }
            }
        }
    }

    return result
}

func getStationSchedule(_ openingHours: String) -> OpeningSchedule? {
    let schedule = parseSchedule(schedule: openingHours)
    
    let currentDate = Date()
    let calendar = Calendar.current
    let dayOfWeek = calendar.component(.weekdayOrdinal, from: currentDate)

    if let todaySchedule = schedule[dayOfWeek] {
        if todaySchedule.count == 2 {
            // todaySchedule[0] = opening time, todaySchedule[1] = closing time
            if let openingTime = todaySchedule[0], let closingTime = todaySchedule[1] {
                let opening = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime)
                let closing = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime)
                
                // If opening is 00:00 and closing is 23:59 that's converted to open 24h
                if opening.hour == 00 && opening.minute == 00 && closing.hour == 23 && closing.minute == 59 {
                    return OpeningSchedule(schedule: [], isCurrentlyOpen: true)
                }
                
                // Take the current date and apply the opening hour and minute
                var openingCalendar = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                openingCalendar.hour = opening.hour
                openingCalendar.minute = opening.minute
                
                // Take the current date and apply the closing hour and minute
                var closingCalendar = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                closingCalendar.hour = closing.hour
                closingCalendar.minute = closing.minute
                
                // If current date is between opening date and closing date it's currently open
                if let openingDate = calendar.date(from: openingCalendar), let closingDate = calendar.date(from: closingCalendar) {
                    if openingDate <= currentDate && currentDate <= closingDate {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        return OpeningSchedule(schedule: [openingDate, closingDate], isCurrentlyOpen: true)
                    }
                    else {
                        return OpeningSchedule(schedule: [openingDate, closingDate], isCurrentlyOpen: false)
                    }
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        else if todaySchedule.count == 4 {
            // todaySchedule[0] = opening time, todaySchedule[1] = closing time, todaySchedule[2] = opening time, todaySchedule[3] = closing time
            if let openingTime1 = todaySchedule[0], let closingTime1 = todaySchedule[1], let openingTime2 = todaySchedule[2], let closingTime2 = todaySchedule[3] {
                let opening1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime1)
                let closing1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime1)
                let opening2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime2)
                let closing2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime2)
                
                // Take the current date and apply the opening hour and minute
                var openingCalendar1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                openingCalendar1.hour = opening1.hour
                openingCalendar1.minute = opening1.minute
                
                // Take the current date and apply the closing hour and minute
                var closingCalendar1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                closingCalendar1.hour = closing1.hour
                closingCalendar1.minute = closing1.minute
                
                // Take the current date and apply the opening hour and minute
                var openingCalendar2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                openingCalendar2.hour = opening2.hour
                openingCalendar2.minute = opening2.minute
                
                // Take the current date and apply the closing hour and minute
                var closingCalendar2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                closingCalendar2.hour = closing2.hour
                closingCalendar2.minute = closing2.minute
                
                // If current date is between opening date and closing date it's currently open
                if let openingDate1 = calendar.date(from: openingCalendar1), let closingDate1 = calendar.date(from: closingCalendar1), let openingDate2 = calendar.date(from: openingCalendar2), let closingDate2 = calendar.date(from: closingCalendar2) {
                    if (openingDate1 <= currentDate && currentDate <= closingDate1) || (openingDate2 <= currentDate && currentDate <= closingDate2) {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "HH:mm"
                        return OpeningSchedule(schedule: [openingDate1, closingDate1, openingDate2, closingDate2], isCurrentlyOpen: true)
                    }
                    else {
                        return OpeningSchedule(schedule: [openingDate1, closingDate1, openingDate2, closingDate2], isCurrentlyOpen: false)
                    }
                }
                else {
                    return nil
                }
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    else {
        return OpeningSchedule(schedule: [], isCurrentlyOpen: false)
    }
}
