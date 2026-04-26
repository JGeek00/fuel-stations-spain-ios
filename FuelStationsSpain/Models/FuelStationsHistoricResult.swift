import Foundation

// MARK: - HistoricPrice
struct HistoricPrice: Sendable, Codable {
    let stationId: String?
    let stationSignage: String?
    let biodieselPrice: Double?
    let bioethanolPrice: Double?
    let cngPrice: Double?
    let lngPrice: Double?
    let lpgPrice: Double?
    let gasoilAPrice: Double?
    let gasoilBPrice: Double?
    let premiumGasoilPrice: Double?
    let gasoline95E10Price: Double?
    let gasoline95E5Price: Double?
    let gasoline95E5PremiumPrice: Double?
    let gasoline98E10Price: Double?
    let gasoline98E5Price: Double?
    let hydrogenPrice: Double?
    let date: String?
}

extension HistoricPrice {
    /// Returns the price for a given fuel by matching the property name dynamically.
    /// It looks for a property named "<fuel.rawValue>Price" and returns it if present.
    func price(for fuel: Enums.FuelType) -> Double? {
        let propertyName = "\(fuel.rawValue)Price"
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == propertyName {
                return child.value as? Double
            }
        }
        return nil
    }
}
