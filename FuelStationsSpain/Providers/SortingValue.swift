import SwiftUI

@propertyWrapper
@MainActor
struct SortingValue: DynamicProperty {
    @AppStorage(StorageKeys.defaultListSorting, store: UserDefaults.shared) private var rawValue: String?

    var wrappedValue: Enums.StationsSortingOptions {
        get {
            if let raw = rawValue, let v = Enums.StationsSortingOptions(rawValue: raw) {
                return v
            }
            return Defaults.defaultListSorting
        }
        nonmutating set {
            rawValue = newValue.rawValue
        }
    }

    var projectedValue: Binding<Enums.StationsSortingOptions> {
        Binding(get: { wrappedValue }, set: { wrappedValue = $0 })
    }

    init() {}
}
