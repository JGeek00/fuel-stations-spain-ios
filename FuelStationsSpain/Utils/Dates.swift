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
