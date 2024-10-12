import Foundation

// MARK: - FuelStationHistoric
struct FuelStationHistoric: Sendable, Codable, Hashable {
    let station_id: String?
    let biodiesel_price: Double?
    let bioethanol_price: Double?
    let cng_price: Double?
    let lng_price: Double?
    let lpg_price: Double?
    let gasoil_a_price: Double?
    let gasoil_b_price: Double?
    let premium_gasoil_price: Double?
    let gasoline_95_e10_price: Double?
    let gasoline_95_e5_price: Double?
    let gasoline_95_e5_premium_price: Double?
    let gasoline_98_e10_price: Double?
    let gasoline_98_e5_price: Double?
    let hydrogen_price: Double?
    let date: String?
}
