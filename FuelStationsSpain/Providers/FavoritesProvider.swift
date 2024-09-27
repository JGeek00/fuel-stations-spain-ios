import Foundation
import CoreData

@MainActor
class FavoritesProvider: ObservableObject {
    static let shared = FavoritesProvider()
    
    @Published var favorites: [FavoriteStation] = []
    
    private let coredataContext = PersistenceController.shared.container.viewContext
    
    init() {
        _ = fetchFavorites()
    }
    
    func fetchFavorites() -> Bool {
        let fetchRequest: NSFetchRequest = FavoriteStation.fetchRequest()
        do {
            let items = try coredataContext.fetch(fetchRequest)
            self.favorites = items
            return true
        } catch {
            print("Failed to fetch items: \(error)")
            return false
        }
    }
    
    func isFavorite(stationId: String) -> Bool {
        return favorites.contains() { $0.id == stationId }
    }
    
    func addFavorite(stationId: String) -> Bool {
        let fetchRequest: NSFetchRequest = FavoriteStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", stationId as CVarArg)
        do {
            let items = try coredataContext.fetch(fetchRequest)
            if items.count == 0 {
                let newFavorite = FavoriteStation(context: coredataContext)
                newFavorite.id = stationId
                newFavorite.date = Date()
                try coredataContext.save()
                _ = self.fetchFavorites()
                return true
            }
            return false
        } catch {
            print("Failed to fetch items: \(error)")
            return false
        }
    }
    
    func removeFavorite(stationId: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteStation> = FavoriteStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", stationId as CVarArg)
        do {
            let result = try coredataContext.fetch(fetchRequest)
            if let favoriteToDelete = result.first {
                coredataContext.delete(favoriteToDelete)
                try coredataContext.save()
                _ = self.fetchFavorites()
                return true
            }
            return false
        } catch {
            print("Failed to fetch or delete: \(error)")
            return false
        }
    }
}
