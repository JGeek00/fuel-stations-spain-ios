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
    
    public enum Tabs: String {
        case map
        case favorites
        case search
        case settings
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
    
    public enum FavoriteFuelType: String {
        case none
        case gasoilA
        case gasoilB
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
    
    public enum ClosedStationsMode: String {
        case showNormally
        case showDimmed
        case hideCompletely
    }
    
    public enum MapStyle: String {
        case standard
        case hybrid
        case satellite
    }
    
    public enum HistoricTime: String {
        case week1
        case month1
        case month3
        case month6
        case year1
    }
    
    public enum FuelType: String {
        case gasoilA
        case gasoilB
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
    
    public enum ChartAnnotationMode: String {
        case outsideChart
        case tooltip
    }
}
