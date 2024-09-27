import SwiftUI

struct RootView: View {
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
        
    @Environment(\.horizontalSizeClass) private var defaultHorizontalSizeClass

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
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
                .environmentObject(MapViewModel())
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .environmentObject(FavoritesListViewModel())
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
        }
        .environment(\.horizontalSizeClass, .compact)
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
    }
}
