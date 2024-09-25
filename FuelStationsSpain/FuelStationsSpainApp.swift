import SwiftUI
import Sentry

@main
struct FuelStationsSpainApp: App {
    let persistenceController = PersistenceController.shared
    
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
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
