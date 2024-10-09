import SwiftUI

struct GeneralSettings: View {
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic = Defaults.hideStationsNotOpenPublic
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel = Defaults.hideStationsDontHaveFavoriteFuel
    @AppStorage(StorageKeys.closedStationsShowMethod, store: UserDefaults.shared) private var closedStationsShowMethod: Enums.ClosedStationsMode = Defaults.closedStationsShowMethod
    @AppStorage(StorageKeys.showRedClockClosedStations, store: UserDefaults.shared) private var showRedClockClosedStations = Defaults.showRedClockClosedStations
    
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
        }
        .navigationTitle("General settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
