import SwiftUI

struct DetailsViewSettings: View {
    
    @AppStorage(StorageKeys.showStationSummary, store: UserDefaults.shared) private var showStationSummary = Defaults.showStationSummary
    
    var body: some View {
        List {
            Section {
                Toggle("Show service station summary", isOn: $showStationSummary)
            } footer: {
                Text("Displays a summary with the favorite fuel price, if the service station is currently open, and the distance to the user location.")
            }
        }
        .navigationTitle("Details view")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailsViewSettings()
}
