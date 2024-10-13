import Foundation

func formatDate(_ value: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let date = formatter.date(from: value) {
        return date
    }
    else {
        return nil
    }
}

func getSQLDateFormat(_ date: Date) -> String {
    let calendar = Calendar.current

    let day = calendar.component(.day, from: date)
    let month = calendar.component(.month, from: date)
    let year = calendar.component(.year, from: date)
    
    return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
}

func convertToLocalTime(date: Date) -> Date {
    let timeZone = TimeZone.current
    let secondsFromGMT = timeZone.secondsFromGMT(for: date)
    return date.addingTimeInterval(TimeInterval(secondsFromGMT))
}
