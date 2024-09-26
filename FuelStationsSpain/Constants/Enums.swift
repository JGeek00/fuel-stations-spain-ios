import Foundation

class Enums {
    public enum Theme: String {
        case system
        case light
        case dark
        
        init?(stringValue: String) {
            switch stringValue.lowercased() {
                case "system":
                    self = .system
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    return nil
            }
        }
    }
    
    public enum ApiErrorReason: String {
        case connection
        case usage
        case notFound
    }
}