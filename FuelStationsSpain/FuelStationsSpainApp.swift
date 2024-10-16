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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(LocationManager())
                .environmentObject(MapManager.shared)
                .environmentObject(FavoritesProvider.shared)
                .environmentObject(TabViewManager.shared)
                .environmentObject(ToastProvider.shared)
                .environmentObject(IAPManager())
                .environmentObject(AppUpdatesProvider())
                .environmentObject(OnboardingViewModel())
                .environmentObject(FavoritesListViewModel())
                .environmentObject(SearchViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
