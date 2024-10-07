import SwiftUI

struct GeneralSettings: View {
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic: Bool = Defaults.hideStationsNotOpenPublic
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel: Bool = Defaults.hideStationsDontHaveFavoriteFuel
    
    var body: some View {
        List {
            Section {
                Picker("Favorite fuel", selection: $favoriteFuel) {
                    ForEach(favoriteFuels, id: \.self) { fuelGroup in
                        Section(fuelGroup.label) {
                            ForEach(fuelGroup.fuels, id: \.self) { fuel in
                                Text(fuel.label)
                                    .tag(fuel.fuelType)
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
            }
        }
        .navigationTitle("General settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
