import SwiftUI

@main
struct FuelStationsSpainApp: App {
    let persistenceController = PersistenceController.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
    
    init() {
        // Run migrations as early as possible so AppStorage-backed properties read the migrated values
        FavoriteFuelMigrator.migrateIfNeeded()
        SortingMigrator.migrateIfNeeded()
    }
    
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
