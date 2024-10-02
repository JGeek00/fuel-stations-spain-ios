import SwiftUI

struct RootView: View {
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
        
    @Environment(\.horizontalSizeClass) private var defaultHorizontalSizeClass
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var mapManager: MapManager

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
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
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
        .onChange(of: locationManager.firstLocation, initial: true) {
            guard let latitude = locationManager.firstLocation?.coordinate.latitude, let longitude = locationManager.firstLocation?.coordinate.longitude else { return }
            Task {
                await mapManager.setInitialLocation(latitude: latitude, longitude: longitude)
            }
        }
    }
}
