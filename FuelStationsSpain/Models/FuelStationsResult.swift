import Foundation

// MARK: - FuelStationsResult
struct FuelStationsResult: Codable, Hashable {
    let lastUpdated: String?
    let results: [FuelStation]?
}

// MARK: - FuelStation
struct FuelStation: Codable, Hashable {
    let id, postalCode, address, openingHours: String?
    let latitude, longitude: Double?
    let locality: String?
    let margin: Margin?
    let municipality, province: Int?
    let referral: Referral?
    let signage: String?
    let saleType: SaleType?
    let percBioEthanol, percMethylEster, municipalityID, provinceID: String?
    let regionID: String?
    let biodieselPrice, bioethanolPrice, cngPrice, lngPrice: Double?
    let lpgPrice: Double?
    let gasoilAPrice: Double?
    let gasoilBPrice, premiumGasoilPrice: Double?
    let gasoline95E10Price: Double?
    let gasoline95E5Price: Double?
    let gasoline95E5PremiumPrice: Double?
    let gasoline98E10Price: Double?
    let gasoline98E5Price: Double?
    let hydrogenPrice: Double?

    enum CodingKeys: String, CodingKey {
        case id, postalCode, address, openingHours, latitude, longitude, locality, margin, municipality, province, referral, signage, saleType, percBioEthanol, percMethylEster
        case municipalityID = "municipalityId"
        case provinceID = "provinceId"
        case regionID = "regionId"
        case biodieselPrice, bioethanolPrice
        case cngPrice = "CNGPrice"
        case lngPrice = "LNGPrice"
        case lpgPrice = "LPGPrice"
        case gasoilAPrice, gasoilBPrice, premiumGasoilPrice, gasoline95E10Price, gasoline95E5Price, gasoline95E5PremiumPrice, gasoline98E10Price, gasoline98E5Price, hydrogenPrice
    }
}

enum Margin: String, Codable, Hashable {
    case d = "D"
    case i = "I"
    case n = "N"
}

enum Referral: String, Codable, Hashable {
    case dm = "dm"
    case om = "OM"
}

enum SaleType: String, Codable, Hashable {
    case p = "P"
    case r = "R"
}

struct StationWithDistance: Hashable {
    let station: FuelStation
    let distance: Double?
    
    init(station: FuelStation, distance: Double?) {
        self.station = station
        self.distance = distance
    }
}
