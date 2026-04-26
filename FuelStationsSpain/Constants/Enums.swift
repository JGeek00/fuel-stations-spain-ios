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
    
    public enum StationsSortingOptions: RawRepresentable, Equatable, Hashable {
        case proximity
        case fuelType(FuelType)

        public var rawValue: String {
            switch self {
            case .proximity:
                return "proximity"
            case .fuelType(let fuel):
                return "fuelType:\(fuel.rawValue)"
            }
        }

        public init?(rawValue: String) {
            if rawValue == "proximity" {
                self = .proximity
                return
            }

            let prefix = "fuelType:"
            if rawValue.hasPrefix(prefix) {
                let value = String(rawValue.dropFirst(prefix.count))
                if let f = FuelType(rawValue: value) {
                    self = .fuelType(f)
                    return
                }
            }

            return nil

        }
    }
    
    public enum FuelType: String, Hashable, CaseIterable {
        case adBlue
        case ammonia
        case biodiesel
        case bioethanol
        case compressedBiogas
        case liquefiedBiogas
        case renewableDiesel
        case cng
        case lng
        case lpg
        case gasoilA
        case gasoilB
        case premiumGasoil
        case gasoline95E5
        case gasoline95E10
        case gasoline95E25
        case gasoline95E85
        case gasoline95E5Premium
        case gasoline98E5
        case gasoline98E10
        case renewableGasoline
        case hydrogen
        case methanol
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
    
    public enum ChartAnnotationMode: String {
        case outsideChart
        case tooltip
    }
    
    public enum LocationPreviewMode: String {
        case map
        case lookAround
    }
}
