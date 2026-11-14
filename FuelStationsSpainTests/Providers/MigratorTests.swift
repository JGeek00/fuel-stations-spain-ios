import Foundation
import Testing
@testable import FuelStationsSpain

@Suite
@MainActor
struct FavoriteFuelMigratorTests {

    @Test func noStoredValueLeavesKeyAbsent() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            FavoriteFuelMigrator.migrateIfNeeded()
            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == nil)
        }
    }

    @Test func explicitNoneRemovesKey() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("none", forKey: StorageKeys.favoriteFuel)

            FavoriteFuelMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == nil)
        }
    }

    @Test func validRawValueIsKeptUntouched() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("gasoilA", forKey: StorageKeys.favoriteFuel)

            FavoriteFuelMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == "gasoilA")
        }
    }

    @Test func caseInsensitiveMatchIsNormalized() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("GASOILA", forKey: StorageKeys.favoriteFuel)

            FavoriteFuelMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == "gasoilA")
        }
    }

    @Test func legacyAliasIsMappedToNewRawValue() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("aGasoil", forKey: StorageKeys.favoriteFuel)

            FavoriteFuelMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == "gasoilA")
        }
    }

    @Test func unmappableValueIsRemoved() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("combustible-inexistente", forKey: StorageKeys.favoriteFuel)

            FavoriteFuelMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == nil)
        }
    }
}

@Suite
@MainActor
struct SortingMigratorTests {

    @Test func noStoredValueLeavesKeyAbsent() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            SortingMigrator.migrateIfNeeded()
            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == nil)
        }
    }

    @Test func proximityIsKeptUntouched() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("proximity", forKey: StorageKeys.defaultListSorting)

            SortingMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == "proximity")
        }
    }

    @Test func fuelTypePrefixIsKeptUntouched() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("fuelType:gasoilA", forKey: StorageKeys.defaultListSorting)

            SortingMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == "fuelType:gasoilA")
        }
    }

    @Test func legacyCaseNameIsMappedToFuelType() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("agasoil", forKey: StorageKeys.defaultListSorting)

            SortingMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == "fuelType:gasoilA")
        }
    }

    @Test func caseInsensitiveRawValueIsNormalizedToFuelType() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("PREMIUMGASOIL", forKey: StorageKeys.defaultListSorting)

            SortingMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == "fuelType:premiumGasoil")
        }
    }

    @Test func unmappableValueIsRemoved() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("orden-inexistente", forKey: StorageKeys.defaultListSorting)

            SortingMigrator.migrateIfNeeded()

            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == nil)
        }
    }
}
