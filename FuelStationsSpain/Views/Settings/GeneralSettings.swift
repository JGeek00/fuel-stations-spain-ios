import SwiftUI

struct GeneralSettings: View {
    
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel = Defaults.favoriteFuel
        
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
            Section {
                NavigationLink("Map") {
                    MapSettings()
                }
            }
            Section {
                NavigationLink("Lists") {
                    ListsSettings()
                }
            }
            Section {
                NavigationLink("Charts") {
                    ChartsSettings()
                }
            }
            Section {
                NavigationLink("Details view") {
                    DetailsViewSettings()
                }
            }
        }
        .navigationTitle("General settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
