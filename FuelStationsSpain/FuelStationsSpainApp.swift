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
    
    @State private var onboardingViewModel = OnboardingViewModel()
    @State private var locationManager = LocationManager()
    @State private var favoritesProvider = FavoritesProvider.shared
    @State private var appUpdatesProvider = AppUpdatesProvider()
    @State private var tabViewManager = TabViewManager.shared
    @State private var toastProvider = ToastProvider.shared
    @State private var iapManager = IAPManager()
    @State private var mapManager = MapManager.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(locationManager)
                .environment(mapManager)
                .environment(favoritesProvider)
                .environment(tabViewManager)
                .environment(toastProvider)
                .environment(iapManager)
                .environment(appUpdatesProvider)
                .environment(onboardingViewModel)
                .environmentObject(FavoritesListViewModel())
                .environmentObject(SearchViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
