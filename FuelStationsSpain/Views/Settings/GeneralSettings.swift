import SwiftUI

struct GeneralSettings: View {
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic: Bool = Defaults.hideStationsNotOpenPublic
    
    var body: some View {
        List {
            Section("Fuels") {
                NavigationLink("Select favorite fuel") {
                    FavoriteFuelPicker()
                }
            }
            Section("Map") {
                Toggle("Hide stations that aren't open to the general public", isOn: $hideStationsNotOpenPublic)
            }
        }
        .navigationTitle("General settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
