import SwiftUI

struct GeneralSettings: View {
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic: Bool = Defaults.hideStationsNotOpenPublic
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel: Bool = Defaults.hideStationsDontHaveFavoriteFuel
    
    var body: some View {
        List {
            Section {
                Picker("Favorite fuel", selection: $favoriteFuel) {
                    Section {
                        Text("None")
                            .tag(Enums.FavoriteFuelType.none)
                    }
                    Section("Gasoil") {
                        Text("A Gasoil")
                            .tag(Enums.FavoriteFuelType.aGasoil)
                        Text("Premium Gasoil")
                            .tag(Enums.FavoriteFuelType.premiumGasoil)
                        Text("B Gasoil")
                            .tag(Enums.FavoriteFuelType.bGasoil)
                        Text("Biodiesel")
                            .tag(Enums.FavoriteFuelType.biodiesel)
                    }
                    Section("Gasoline") {
                        Text("Gasoline 95 E5")
                            .tag(Enums.FavoriteFuelType.gasoline95E5)
                        Text("Gasoline 95 E5 Premium")
                            .tag(Enums.FavoriteFuelType.gasoline95E5Premium)
                        Text("Gasoline 95 E10")
                            .tag(Enums.FavoriteFuelType.gasoline95E10)
                        Text("Gasoline 98 E5")
                            .tag(Enums.FavoriteFuelType.gasoline98E5)
                        Text("Gasoline 98 E10")
                            .tag(Enums.FavoriteFuelType.gasoline98E10)
                        Text("Bioethanol")
                            .tag(Enums.FavoriteFuelType.bioethanol)
                    }
                    Section("Gas") {
                        Text("Compressed Natural Gas")
                            .tag(Enums.FavoriteFuelType.cng)
                        Text("Liquefied Natural Gas")
                            .tag(Enums.FavoriteFuelType.lng)
                        Text("Liquefied petroleum gases")
                            .tag(Enums.FavoriteFuelType.lpg)
                    }
                    Section("Others") {
                        Text("Hydrogen")
                            .tag(Enums.FavoriteFuelType.hydrogen)
                    }
                }
            } footer: {
                Text("If you select a favorite fuel, the price will appear directly on the map on each service station marker. It will also appear directly on each favorite station and when searching stations by locality.")
            }
            Section("Map") {
                Toggle("Hide stations that aren't open to the general public", isOn: $hideStationsNotOpenPublic)
                Toggle("Hide stations that don't sell the selected favorite fuel", isOn: $hideStationsDontHaveFavoriteFuel)
            }
        }
        .navigationTitle("General settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
