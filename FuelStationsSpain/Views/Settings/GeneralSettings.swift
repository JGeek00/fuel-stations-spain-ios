import SwiftUI

struct GeneralSettings: View {
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic = Defaults.hideStationsNotOpenPublic
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel = Defaults.hideStationsDontHaveFavoriteFuel
    @AppStorage(StorageKeys.closedStationsShowMethod, store: UserDefaults.shared) private var closedStationsShowMethod: Enums.ClosedStationsMode = Defaults.closedStationsShowMethod
    @AppStorage(StorageKeys.showRedClockClosedStations, store: UserDefaults.shared) private var showRedClockClosedStations = Defaults.showRedClockClosedStations
    @AppStorage(StorageKeys.defaultListSorting, store: UserDefaults.shared) private var defaultListSorting = Defaults.defaultListSorting
    
    var body: some View {
        List {
            Section {
                Picker("Favorite fuel", selection: $favoriteFuel) {
                    ForEach(favoriteFuels, id: \.self) { fuelGroup in
                        Section {
                            ForEach(fuelGroup.fuels, id: \.self) { fuel in
                                Text(fuel.label)
                                    .tag(fuel.fuelType)
                            }
                        } header: {
                            if let label = fuelGroup.label {
                                Text(label)
                            }
                        }
                    }
                }
            } footer: {
                Text("If you select a favorite fuel, the price will appear directly on the map on each service station marker. It will also appear directly on each favorite station and when searching stations by locality.")
            }
            Section("Map") {
                Toggle("Hide stations that aren't open to the general public", isOn: $hideStationsNotOpenPublic)
                if favoriteFuel != .none {
                    Toggle("Hide stations that don't sell the selected favorite fuel", isOn: $hideStationsDontHaveFavoriteFuel)
                }
                Picker("Closed stations", selection: $closedStationsShowMethod) {
                    Text("Show normally")
                        .lineLimit(2)
                        .tag(Enums.ClosedStationsMode.showNormally)
                    Text("Show dimmed")
                        .lineLimit(2)
                        .tag(Enums.ClosedStationsMode.showDimmed)
                    Text("Hide completely")
                        .lineLimit(2)
                        .tag(Enums.ClosedStationsMode.hideCompletely)
                }
                if closedStationsShowMethod != .hideCompletely {
                    Toggle("Show red clock on closed stations", isOn: $showRedClockClosedStations)
                }
            }
            Section("Lists") {
                DefaultSortingPicker()
            }
        }
        .navigationTitle("General settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func DefaultSortingPicker() -> some View {
        let selectedText = {
            switch defaultListSorting {
                case .proximity: return String(localized: "Proximity")
                case .aGasoil: return String(localized: "A Gasoil")
                case .bGasoil: return String(localized: "B Gasoil")
                case .premiumGasoil: return String(localized: "Premium Gasoil")
                case .biodiesel: return String(localized: "Biodiesel")
                case .gasoline95E5: return String(localized: "Gasoline 95 E5")
                case .gasoline95E10: return String(localized: "Gasoline 95 E10")
                case .gasoline95E5Premium: return String(localized: "Gasoline 95 E5 Premium")
                case .gasoline98E5: return String(localized: "Gasoline 98 E5")
                case .gasoline98E10: return String(localized: "Gasoline 98 E10")
                case .bioethanol: return String(localized: "Bioethanol")
                case .cng: return String(localized: "Compressed Natural Gas")
                case .lng: return String(localized: "Liquefied Natural Gas")
                case .lpg: return String(localized: "Liquefied petroleum gases")
                case .hydrogen: return String(localized: "Hydrogen")
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
                            MenuItem(label: String(localized: "A Gasoil"), selectedOption: $defaultListSorting, value: .aGasoil)
                            MenuItem(label: String(localized: "B Gasoil"), selectedOption: $defaultListSorting, value: .bGasoil)
                            MenuItem(label: String(localized: "Premium Gasoil"), selectedOption: $defaultListSorting, value: .premiumGasoil)
                            MenuItem(label: String(localized: "Biodiesel"), selectedOption: $defaultListSorting, value: .biodiesel)
                        }
                        Section("Gasoline") {
                            MenuItem(label: String(localized: "Gasoline 95 E5"), selectedOption: $defaultListSorting, value: .gasoline95E5)
                            MenuItem(label: String(localized: "Gasoline 95 E10"), selectedOption: $defaultListSorting, value: .gasoline95E10)
                            MenuItem(label: String(localized: "Gasoline 95 E5 Premium"), selectedOption: $defaultListSorting, value: .gasoline95E5Premium)
                            MenuItem(label: String(localized: "Gasoline 98 E5"), selectedOption: $defaultListSorting, value: .gasoline98E5)
                            MenuItem(label: String(localized: "Gasoline 98 E10"), selectedOption: $defaultListSorting, value: .gasoline98E10)
                            MenuItem(label: String(localized: "Bioethanol"), selectedOption: $defaultListSorting, value: .bioethanol)
                        }
                        Section("Gas") {
                            MenuItem(label: String(localized: "Compressed Natural Gas"), selectedOption: $defaultListSorting, value: .cng)
                            MenuItem(label: String(localized: "Liquefied Natural Gas"), selectedOption: $defaultListSorting, value: .lng)
                            MenuItem(label: String(localized: "Liquefied petroleum gases"), selectedOption: $defaultListSorting, value: .lpg)
                        }
                        Section("Others") {
                            MenuItem(label: String(localized: "Hydrogen"), selectedOption: $defaultListSorting, value: .hydrogen)
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
