import Foundation
import Testing
@testable import FuelStationsSpain

@Suite
@MainActor
struct SortingValueTests {

    @Test func invalidRawFallsBackToDefault() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("orden-invalido", forKey: StorageKeys.defaultListSorting)

            let wrapper = SortingValue()

            #expect(wrapper.wrappedValue == Defaults.defaultListSorting)
        }
    }

    @Test func nilRawFallsBackToDefault() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            let wrapper = SortingValue()

            #expect(wrapper.wrappedValue == Defaults.defaultListSorting)
        }
    }

    @Test func validProximityRawIsUsed() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("proximity", forKey: StorageKeys.defaultListSorting)

            let wrapper = SortingValue()

            #expect(wrapper.wrappedValue == .proximity)
        }
    }

    @Test func validFuelTypeRawIsUsed() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            UserDefaults.shared.set("fuelType:gasoilA", forKey: StorageKeys.defaultListSorting)

            let wrapper = SortingValue()

            #expect(wrapper.wrappedValue == .fuelType(.gasoilA))
        }
    }

    @Test func setterWritesRawValue() {
        DisposableDefaults.run(keys: [StorageKeys.defaultListSorting]) {
            let wrapper = SortingValue()

            wrapper.wrappedValue = .fuelType(.bioethanol)

            #expect(UserDefaults.shared.string(forKey: StorageKeys.defaultListSorting) == "fuelType:bioethanol")
        }
    }
}

@Suite
@MainActor
struct FavoriteFuelValueTests {

    @Test func invalidRawFallsBackToNil() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("combustible-invalido", forKey: StorageKeys.favoriteFuel)

            let wrapper = FavoriteFuelValue()

            #expect(wrapper.wrappedValue == nil)
        }
    }

    @Test func nilRawIsNil() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            let wrapper = FavoriteFuelValue()

            #expect(wrapper.wrappedValue == nil)
        }
    }

    @Test func validRawIsUsed() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("gasoilA", forKey: StorageKeys.favoriteFuel)

            let wrapper = FavoriteFuelValue()

            #expect(wrapper.wrappedValue == .gasoilA)
        }
    }

    @Test func setterWritesRawValue() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            let wrapper = FavoriteFuelValue()

            wrapper.wrappedValue = .gasoline95E5

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == "gasoline95E5")
        }
    }

    @Test func setterWithNilRemovesValue() {
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            UserDefaults.shared.set("gasoilA", forKey: StorageKeys.favoriteFuel)
            let wrapper = FavoriteFuelValue()

            wrapper.wrappedValue = nil

            #expect(UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) == nil)
        }
    }
}
