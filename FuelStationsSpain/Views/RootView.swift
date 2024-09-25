import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .fontDesign(.rounded)
    }
}

#Preview {
    RootView()
}
