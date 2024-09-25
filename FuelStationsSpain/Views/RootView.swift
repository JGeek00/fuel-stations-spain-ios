import SwiftUI

struct RootView: View {
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system

    func getColorScheme(theme: Enums.Theme) -> ColorScheme? {
        switch theme {
            case .system:
                return nil
            case .light:
                return ColorScheme.light
            case .dark:
                return ColorScheme.dark
        }
    }
    
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
        .preferredColorScheme(getColorScheme(theme: theme))
    }
}
