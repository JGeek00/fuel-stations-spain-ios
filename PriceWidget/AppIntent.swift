import WidgetKit
import AppIntents
import CoreData

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "Configure the service station widget." }

    @Parameter(title: "Service station")
    var serviceStation: ServiceStation?
    
    @Parameter(title: "Fuel type")
    var selectedFuel: FuelType?
}

struct FuelType: AppEntity {
    let id: String
    let value: String
    let label: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Fuel type"
    static var defaultQuery = FuelTypeQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(label)")
    }
    
    static let fuelTypes: [FuelType] = [
        FuelType(id: Enums.FuelType.gasoilA.rawValue, value: Enums.FuelType.gasoilA.rawValue, label: String(localized: "A Gasoil")),
        FuelType(id: Enums.FuelType.gasoilB.rawValue, value: Enums.FuelType.gasoilB.rawValue, label: String(localized: "B Gasoil")),
        FuelType(id: Enums.FuelType.premiumGasoil.rawValue, value: Enums.FuelType.premiumGasoil.rawValue, label: String(localized: "Premium Gasoil")),
        FuelType(id: Enums.FuelType.biodiesel.rawValue, value: Enums.FuelType.biodiesel.rawValue, label: String(localized: "Biodiesel")),
        FuelType(id: Enums.FuelType.gasoline95E5.rawValue, value: Enums.FuelType.gasoline95E5.rawValue, label: String(localized: "Gasoline 95 E5")),
        FuelType(id: Enums.FuelType.gasoline95E10.rawValue, value: Enums.FuelType.gasoline95E10.rawValue, label: String(localized: "Gasoline 95 E10")),
        FuelType(id: Enums.FuelType.gasoline95E5Premium.rawValue, value: Enums.FuelType.gasoline95E5Premium.rawValue, label: String(localized: "Gasoline 95 E5 Premium")),
        FuelType(id: Enums.FuelType.gasoline98E5.rawValue, value: Enums.FuelType.gasoline98E5.rawValue, label: String(localized: "Gasoline 98 E5")),
        FuelType(id: Enums.FuelType.gasoline98E10.rawValue, value: Enums.FuelType.gasoline98E10.rawValue, label: String(localized: "Gasoline 95 E10")),
        FuelType(id: Enums.FuelType.bioethanol.rawValue, value: Enums.FuelType.bioethanol.rawValue, label: String(localized: "Bioethanol")),
        FuelType(id: Enums.FuelType.cng.rawValue, value: Enums.FuelType.cng.rawValue, label: String(localized: "Compressed Natural Gas")),
        FuelType(id: Enums.FuelType.lng.rawValue, value: Enums.FuelType.lng.rawValue, label: String(localized: "Liquefied Natural Gas")),
        FuelType(id: Enums.FuelType.lpg.rawValue, value: Enums.FuelType.lpg.rawValue, label: String(localized: "Liquefied petroleum gases")),
        FuelType(id: Enums.FuelType.hydrogen.rawValue, value: Enums.FuelType.hydrogen.rawValue, label: String(localized: "Hydrogen")),
    ]
}

struct FuelTypeQuery: EntityQuery {
    func entities(for identifiers: [FuelType.ID]) async throws -> [FuelType] {
        FuelType.fuelTypes.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [FuelType] {
        FuelType.fuelTypes
    }
    
    func defaultResult() async -> FuelType? {
        try? await suggestedEntities().first
    }
}

struct ServiceStation: AppEntity {
    let id: String
    let label: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Service stations"
    static var defaultQuery = ServiceStationsQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(label)")
    }
}

struct ServiceStationsQuery: EntityQuery {    
    func entities(for identifiers: [ServiceStation.ID]) async throws -> [ServiceStation] {
        if let favorites = fetchFavorites() {
            let data = favorites.map() { ServiceStation(id: $0.id!, label: generateLabel(id: $0.id!, name: $0.name!, address: $0.address!, locality: $0.locality)) }.filter { identifiers.contains($0.id) }
            return data
        }
        return []
    }
    
    func suggestedEntities() async throws -> [ServiceStation] {
        if let favorites = fetchFavorites() {
            let data = favorites.map() { ServiceStation(id: $0.id!, label: generateLabel(id: $0.id!, name: $0.name!, address: $0.address!, locality: $0.locality)) }
            return data
        }
        return []
    }
    
    func defaultResult() async -> ServiceStation? {
        try? await suggestedEntities().first
    }
}
