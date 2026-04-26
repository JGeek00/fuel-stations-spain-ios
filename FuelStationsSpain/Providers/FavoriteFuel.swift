import SwiftUI

@propertyWrapper
@MainActor
struct FavoriteFuelValue: DynamicProperty {
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var rawValue: String?

    var wrappedValue: Enums.FuelType? {
        get { rawValue.flatMap { Enums.FuelType(rawValue: $0) } }
        nonmutating set { rawValue = newValue?.rawValue }
    }

    var projectedValue: Binding<Enums.FuelType?> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }

    init() {}
}
