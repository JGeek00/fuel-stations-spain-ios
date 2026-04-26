import Foundation

@MainActor
enum SortingMigrator {
    static func migrateIfNeeded() {
        let defaults = UserDefaults.shared
        let key = StorageKeys.defaultListSorting
        guard let stored = defaults.string(forKey: key) else { return }
        let value = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        // If already new format or proximity, nothing to do
        if value == "proximity" || value.hasPrefix("fuelType:") { return }

        // Mapping from old sorting case names (possibly used as raw strings) to new FuelType raw values
        let mapping: [String: String] = [
            "agasoil": "gasoilA",
            "bgasoil": "gasoilB",
            "premiumgasoil": "premiumGasoil",
            "biodiesel": "biodiesel",
            "gasoline95e5": "gasoline95E5",
            "gasoline95e10": "gasoline95E10",
            "gasoline95e5premium": "gasoline95E5Premium",
            "gasoline98e5": "gasoline98E5",
            "gasoline98e10": "gasoline98E10",
            "bioethanol": "bioethanol",
            "cng": "cng",
            "lng": "lng",
            "lpg": "lpg",
            "hydrogen": "hydrogen",
            "adblue": "adBlue"
        ]

        let lower = value.lowercased()
        if let mapped = mapping[lower] {
            defaults.set("fuelType:\(mapped)", forKey: key)
            return
        }

        // Try to match case-insensitive to any FuelType rawValue
        if let match = Enums.FuelType.allCases.first(where: { $0.rawValue.lowercased() == lower }) {
            defaults.set("fuelType:\(match.rawValue)", forKey: key)
            return
        }

        // If no mapping found, remove the key to let default apply
        defaults.removeObject(forKey: key)
    }
}
