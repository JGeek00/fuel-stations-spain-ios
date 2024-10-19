import SwiftUI
import Sentry

@main
struct FuelStationsSpainApp: App {
    let persistenceController = PersistenceController.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        #if RELEASE
        SentrySDK.start { options in
            options.dsn = Config.sentryDsn
            options.debug = false
            options.tracesSampleRate = 0.5
        }
        #endif
    }
    
    let locationManager = LocationManager()
    let mapManager = MapManager.shared
    let favoritesProvider = FavoritesProvider.shared
    let tabViewManager = TabViewManager.shared
    let toastProvider = ToastProvider.shared
    let iapManager = IAPManager()
    let appUpdatesProvider = AppUpdatesProvider()
    let onboardingViewModel = OnboardingViewModel()
    let favoritesListViewModel = FavoritesListViewModel()
    let searchViewModel = SearchViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locationManager)
                .environmentObject(mapManager)
                .environmentObject(favoritesProvider)
                .environmentObject(tabViewManager)
                .environmentObject(toastProvider)
                .environmentObject(iapManager)
                .environmentObject(appUpdatesProvider)
                .environmentObject(onboardingViewModel)
                .environmentObject(favoritesListViewModel)
                .environmentObject(searchViewModel)
        }
    }
}
