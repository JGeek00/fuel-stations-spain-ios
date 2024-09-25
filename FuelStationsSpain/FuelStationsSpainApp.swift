import SwiftUI

@main
struct FuelStationsSpainApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(LocationManager())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
