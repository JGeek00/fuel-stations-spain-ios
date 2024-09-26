import SwiftUI

struct RootView: View {
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var mapViewModel: MapViewModel

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
        .onChange(of: locationManager.firstLocation, initial: true) {
            guard let latitude = locationManager.firstLocation?.coordinate.latitude, let longitude = locationManager.firstLocation?.coordinate.longitude else { return }
            Task {
                await mapViewModel.setInitialLocation(latitude: latitude, longitude: longitude)
            }
        }
    }
}
