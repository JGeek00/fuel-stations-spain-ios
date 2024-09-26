import Foundation

class OpeningSchedule {
    let opening: Date?
    let closing: Date?
    let isCurrentlyOpen: Bool
    
    init(opening: Date?, closing: Date?, isCurrentlyOpen: Bool) {
        self.opening = opening
        self.closing = closing
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

        var openingTime: Date? = nil
        var closingTime: Date? = nil
        
        // Check if time range is "24H"
        if timeRange == "24H" {
            // Set opening time to 00:00 and closing time to 23:59
            openingTime = dateFormatter.date(from: "00:00")
            closingTime = dateFormatter.date(from: "23:59")
        } else {
            // Split the time range by hyphen to get opening and closing times
            let times = timeRange.split(separator: "-")
            guard times.count == 2,
                  let open = dateFormatter.date(from: String(times[0])),
                  let close = dateFormatter.date(from: String(times[1])) else {
                continue
            }
            openingTime = open
            closingTime = close
        }
        
        // Split the days string to handle multiple day abbreviations (e.g., "L-V" or "S-D")
        let dayGroups = daysString.split(separator: "-")
        
        if dayGroups.count == 1 {  // Single day case
            if let dayIndex = daysOfWeek[String(dayGroups[0])] {
                result[dayIndex] = [openingTime, closingTime]
            }
        } else if dayGroups.count == 2 {  // Day range case (e.g., "L-V")
            if let startDay = daysOfWeek[String(dayGroups[0])],
               let endDay = daysOfWeek[String(dayGroups[1])] {
                for i in startDay...endDay {
                    result[i] = [openingTime, closingTime]
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
    let dayOfWeek = calendar.component(.weekday, from: currentDate)
    
    let todaySchedule = schedule[dayOfWeek-1]
    if let todaySchedule = todaySchedule {
        // todaySchedule[0] = opening time, todaySchedule[1] = closing time
        if let openingTime = todaySchedule[0], let closingTime = todaySchedule[1] {
            let opening = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime)
            let closing = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime)
            
            // If opening is 00:00 and closing is 23:59 that's converted to open 24h
            if opening.hour == 00 && opening.minute == 00 && closing.hour == 23 && closing.minute == 59 {
                return OpeningSchedule(opening: nil, closing: nil, isCurrentlyOpen: true)
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
                    return OpeningSchedule(opening: openingDate, closing: closingDate, isCurrentlyOpen: true)
                }
                else {
                    return OpeningSchedule(opening: openingDate, closing: closingDate, isCurrentlyOpen: false)
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
