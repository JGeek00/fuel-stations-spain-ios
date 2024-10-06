import Foundation
import CoreData
import SwiftUI

@MainActor
class FavoriteFuelProvider: ObservableObject {
    static let shared = FavoriteFuelProvider()
    
    @Published var favoriteFuel: [FavoriteFuel] = []
    
    init() {
        loadData()
    }
    
    private let coredataContext = PersistenceController.shared.container.viewContext
    
    private func loadData() {
        let fetchRequest: NSFetchRequest = FavoriteFuel.fetchRequest()
        do {
            let items = try coredataContext.fetch(fetchRequest)
            self.favoriteFuel = items
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    private func addItem(key: String, colorCode: String) {
        let fetchRequest: NSFetchRequest = FavoriteFuel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fuelKey == %@", key as CVarArg)
        do {
            let items = try coredataContext.fetch(fetchRequest)
            if items.count == 0 {
                let newItem = FavoriteFuel(context: coredataContext)
                newItem.fuelKey = key
                newItem.colorCode = colorCode
                try coredataContext.save()
                loadData()
            }
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    private func removeItem(key: String) {
        let fetchRequest: NSFetchRequest<FavoriteFuel> = FavoriteFuel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fuelKey == %@", key as CVarArg)
        do {
            let result = try coredataContext.fetch(fetchRequest)
            if let itemToDelete = result.first {
                coredataContext.delete(itemToDelete)
                try coredataContext.save()
                loadData()
            }
        } catch {
            print("Failed to fetch or delete: \(error)")
        }
    }
    
    func updateColor(item: Enums.FuelTypes, color: Color) {
        let fetchRequest: NSFetchRequest<FavoriteFuel> = FavoriteFuel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fuelKey == %@", item.rawValue)
        do {
            let results = try coredataContext.fetch(fetchRequest)
            if let newObject = results.first {
                newObject.colorCode = color.toHex()!
                try coredataContext.save()
            }
        } catch {
            print("Failed to fetch the object: \(error)")
        }
    }
    
    
    func updateFavorites(item: Enums.FuelTypes, color: Color) {
        if favoriteFuel.filter({ $0.fuelKey == item.rawValue }).isEmpty {
            addItem(key: item.rawValue, colorCode: color.toHex()!)
        }
        else {
            removeItem(key: item.rawValue)
        }
    }
}
