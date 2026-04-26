import Foundation

@MainActor
enum FavoriteFuelMigrator {
    static func migrateIfNeeded() {
        let defaults = UserDefaults.shared
        let key = StorageKeys.favoriteFuel
        guard let stored = defaults.string(forKey: key) else { return }
        let value = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        // If user previously selected explicit "none", remove the key so it becomes nil
        if value.lowercased() == "none" {
            defaults.removeObject(forKey: key)
            return
        }
        // If it's already a valid new raw value, nothing to do
        if Enums.FuelType(rawValue: value) != nil {
            return
        }
        // Try case-insensitive match to any of the new enum raw values
        if let match = Enums.FuelType.allCases.first(where: { $0.rawValue.lowercased() == value.lowercased() }) {
            defaults.set(match.rawValue, forKey: key)
            return
        }
        // Some older versions may have used alternate keys (e.g. "aGasoil" instead of "gasoilA").
        let aliasMapping: [String: String] = [
            "agasoil": "gasoilA",
            "bgasoil": "gasoilB",
            "adblue": "adBlue",
            // add other aliases here if needed in the future
        ]
        if let mapped = aliasMapping[value.lowercased()] {
            defaults.set(mapped, forKey: key)
            return
        }
        // If we cannot map, remove the key to avoid keeping an invalid value
        defaults.removeObject(forKey: key)
    }
}
