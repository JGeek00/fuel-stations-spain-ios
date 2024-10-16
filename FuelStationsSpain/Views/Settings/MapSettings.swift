

import SwiftUI

struct MapSettings: View {
    
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel = Defaults.hideStationsDontHaveFavoriteFuel
    @AppStorage(StorageKeys.closedStationsShowMethod, store: UserDefaults.shared) private var closedStationsShowMethod: Enums.ClosedStationsMode = Defaults.closedStationsShowMethod
    @AppStorage(StorageKeys.showRedClockClosedStations, store: UserDefaults.shared) private var showRedClockClosedStations = Defaults.showRedClockClosedStations
    @AppStorage(StorageKeys.mapStyle, store: UserDefaults.shared) private var mapStyle = Defaults.mapStyle
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic = Defaults.hideStationsNotOpenPublic
    
    var body: some View {
        List {
            Picker("Map style", selection: $mapStyle) {
                Text("Standard")
                    .tag(Enums.MapStyle.standard)
                Text("Hybrid")
                    .tag(Enums.MapStyle.hybrid)
                Text("Satellite")
                    .tag(Enums.MapStyle.satellite)
            }
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
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MapSettings()
}
