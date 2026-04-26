import SwiftUI

struct ListsSettings: View {
    
    @SortingValue private var defaultListSorting: Enums.StationsSortingOptions
    @AppStorage(StorageKeys.showSectionIndexList, store: UserDefaults.shared) private var showSectionIndexList = Defaults.showSectionIndexList
    
    var body: some View {
        List {
            Section {
                DefaultSortingPicker()
            }
            Section {
                Toggle("Show section index list", isOn: $showSectionIndexList)
            } footer: {
                Text("Shows a list of letters at the right of the municipalities list on the search tab that you can use to scroll the list quickly to a specific letter.")
            }
        }
        .navigationTitle("Lists")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder func DefaultSortingPicker() -> some View {
        let selectedText: String = {
            switch defaultListSorting {
            case .proximity:
                return String(localized: "Proximity")
            case .fuelType(let fuel):
                for section in fuelList {
                    if let item = section.types.first(where: { $0.type == fuel }) {
                        return item.name
                    }
                }
                return fuel.rawValue
            }
        }()
        
        HStack {
            Text("Default sorting")
            Spacer()
            Menu {
                Section {
                    MenuItem(label: String(localized: "Proximity"), selectedOption: $defaultListSorting, value: .proximity)
                }
                Section {
                    Menu {
                        Section("Gasoil") {
                            MenuItem(label: String(localized: "A Gasoil"), selectedOption: $defaultListSorting, value: .fuelType(.gasoilA))
                            MenuItem(label: String(localized: "B Gasoil"), selectedOption: $defaultListSorting, value: .fuelType(.gasoilB))
                            MenuItem(label: String(localized: "Premium Gasoil"), selectedOption: $defaultListSorting, value: .fuelType(.premiumGasoil))
                            MenuItem(label: String(localized: "Biodiesel"), selectedOption: $defaultListSorting, value: .fuelType(.biodiesel))
                        }
                        Section("Gasoline") {
                            MenuItem(label: String(localized: "Gasoline 95 E5"), selectedOption: $defaultListSorting, value: .fuelType(.gasoline95E5))
                            MenuItem(label: String(localized: "Gasoline 95 E10"), selectedOption: $defaultListSorting, value: .fuelType(.gasoline95E10))
                            MenuItem(label: String(localized: "Gasoline 95 E5 Premium"), selectedOption: $defaultListSorting, value: .fuelType(.gasoline95E5Premium))
                            MenuItem(label: String(localized: "Gasoline 98 E5"), selectedOption: $defaultListSorting, value: .fuelType(.gasoline98E5))
                            MenuItem(label: String(localized: "Gasoline 98 E10"), selectedOption: $defaultListSorting, value: .fuelType(.gasoline98E10))
                            MenuItem(label: String(localized: "Bioethanol"), selectedOption: $defaultListSorting, value: .fuelType(.bioethanol))
                        }
                        Section("Gas") {
                            MenuItem(label: String(localized: "Compressed Natural Gas"), selectedOption: $defaultListSorting, value: .fuelType(.cng))
                            MenuItem(label: String(localized: "Liquefied Natural Gas"), selectedOption: $defaultListSorting, value: .fuelType(.lng))
                            MenuItem(label: String(localized: "Liquefied petroleum gases"), selectedOption: $defaultListSorting, value: .fuelType(.lpg))
                        }
                        Section("Others") {
                            MenuItem(label: String(localized: "Hydrogen"), selectedOption: $defaultListSorting, value: .fuelType(.hydrogen))
                        }
                    } label: {
                        if defaultListSorting != .proximity {
                            Label("Fuel price", systemImage: "checkmark")
                        }
                        else {
                            Text("Fuel price")
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedText)
                    Image(systemName: "chevron.up.chevron.down")
                }
                .foregroundStyle(Color.listItemValue)
            }
        }
    }
}

#Preview {
    ListsSettings()
}
