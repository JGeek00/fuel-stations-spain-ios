import Foundation
import CoreData

@MainActor
class FavoritesProvider: ObservableObject {
    static let shared = FavoritesProvider()
    
    @Published var favorites: [FavoriteStation] = []
    
    private let coredataContext = PersistenceController.shared.container.viewContext
    
    init() {
        fetchFavorites()
    }
    
    func fetchFavorites() {
        let fetchRequest: NSFetchRequest = FavoriteStation.fetchRequest()
        do {
            let items = try coredataContext.fetch(fetchRequest)
            self.favorites = items
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func isFavorite(stationId: String) -> Bool {
        return favorites.contains() { $0.id == stationId }
    }
    
    func addFavorite(stationId: String) {
        let fetchRequest: NSFetchRequest = FavoriteStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", stationId as CVarArg)
        do {
            let items = try coredataContext.fetch(fetchRequest)
            if items.count == 0 {
                let newFavorite = FavoriteStation(context: coredataContext)
                newFavorite.id = stationId
                newFavorite.date = Date()
                try coredataContext.save()
                self.fetchFavorites()
            }
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func removeFavorite(stationId: String) {
        let fetchRequest: NSFetchRequest<FavoriteStation> = FavoriteStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", stationId as CVarArg)
        do {
            let result = try coredataContext.fetch(fetchRequest)
            if let personToDelete = result.first {
                coredataContext.delete(personToDelete)
                try coredataContext.save()
                self.fetchFavorites()
            } else {
                print("No person found with this ID")
            }
        } catch {
            print("Failed to fetch or delete person: \(error)")
        }
    }
}
