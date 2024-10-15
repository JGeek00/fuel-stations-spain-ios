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
