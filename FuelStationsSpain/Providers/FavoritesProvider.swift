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
                _ = self.fetchFavorites()
                ToastProvider.shared.showToast(icon: "star.fill", title: String(localized: "Added to favorites"))
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
            if let favoriteToDelete = result.first {
                coredataContext.delete(favoriteToDelete)
                try coredataContext.save()
                _ = self.fetchFavorites()
                ToastProvider.shared.showToast(icon: "star.slash.fill", title: String(localized: "Removed from favorites"))
            }
        } catch {
            print("Failed to fetch or delete: \(error)")
        }
    }
    
    func setFavoriteAlias(stationId: String, newAlias: String) {
        let fetchRequest: NSFetchRequest<FavoriteStation> = FavoriteStation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", stationId as CVarArg)
        do {
            let result = try coredataContext.fetch(fetchRequest)
            if let favorite = result.first {
                favorite.alias = newAlias
                try coredataContext.save()
                _ = self.fetchFavorites()
                ToastProvider.shared.showToast(icon: "pencil", title: String(localized: "Station alias updated"))
            }
        } catch {
            print("Failed to fetch or delete: \(error)")
        }
    }
}
