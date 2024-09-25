//
//  FuelStationsSpainApp.swift
//  FuelStationsSpain
//
//  Created by Juan Gilsanz Polo on 25/9/24.
//

import SwiftUI

@main
struct FuelStationsSpainApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
