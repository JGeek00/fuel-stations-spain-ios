import SwiftUI

struct RootView: View {
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    @AppStorage(StorageKeys.onboardingCompleted, store: UserDefaults.shared) private var onboardingCompleted: Bool = Defaults.onboardingCompleted
        
    @Environment(\.horizontalSizeClass) private var defaultHorizontalSizeClass
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var tabViewManager: TabViewManager
    @EnvironmentObject private var appUpdatesProvider: AppUpdatesProvider
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel

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
        TabView(selection: $tabViewManager.selectedTab) {
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Enums.Tabs.map)
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(Enums.Tabs.favorites)
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Enums.Tabs.search)
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Enums.Tabs.settings)
                .environment(\.horizontalSizeClass, defaultHorizontalSizeClass)
        }
        .environment(\.horizontalSizeClass, .compact)
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .fullScreenCover(isPresented: $onboardingViewModel.showOnboarding, content: {
            OnboardingView()
        })
        .onChange(of: locationManager.firstLocation, initial: true) { old, new in
            guard old == nil, let latitude = new?.coordinate.latitude, let longitude = new?.coordinate.longitude else { return }
            Task {
                await mapManager.setInitialLocation(latitude: latitude, longitude: longitude)
            }
        }
        .onAppear {
            if onboardingCompleted == false {
                onboardingViewModel.showOnboarding = true
            }
            else {
                locationManager.requestLocationAccess()
            }
            requestAppReview()
            Task {
                await appUpdatesProvider.checkUpdateAvailable()
            }
        }
        .alert("Update available", isPresented: $appUpdatesProvider.updateAvailable) {
            Button("Close", role: .cancel) {
                appUpdatesProvider.updateAvailable = false
            }
            Button("Update now") {
                openURL(URL(string: Urls.appStoreAppPage)!)
            }
        } message: {
            Text("An update of the application is available on the App Store. New versions include new features and bug fixes. Some app features may not work properly until you update the app.")
        }
    }
}
