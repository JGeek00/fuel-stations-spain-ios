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
    
    public enum StationsSortingOptions: String {
        case proximity
        case aGasoil
        case bGasoil
        case premiumGasoil
        case biodiesel
        case gasoline95E10
        case gasoline95E5
        case gasoline95E5Premium
        case gasoline98E10
        case gasoline98E5
        case bioethanol
        case cng
        case lng
        case lpg
        case hydrogen
    }
    
    public enum SearchSortingOptions: String {
        case groupedProvince
        case alphabetical
    }
}
