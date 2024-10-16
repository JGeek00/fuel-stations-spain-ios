import Foundation
import CoreData

func getFavoriteAlias(favoriteId: String) -> String? {
    let coredataContext = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest = FavoriteStation.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", favoriteId as CVarArg)
    do {
        let items = try coredataContext.fetch(fetchRequest)
        if let favorite = items.first {
            return favorite.alias
        }
        return nil
    } catch {
        print("Failed to fetch items: \(error)")
        return nil
    }
}

func generateLabel(id: String, name: String, address: String, locality: String?) -> String {
    if let alias = getFavoriteAlias(favoriteId: id), !alias.isEmpty {
        return alias
    }
    else {
        if let locality = locality {
            return "\(name.capitalized): \(address.capitalized) (\(locality.capitalized))"
        }
        else {
            return "\(name.capitalized): \(address.capitalized)"
        }
    }
}

func fetchFavorites() -> [FavoriteStation]? {
    let coredataContext = PersistenceController.shared.container.viewContext
    let fetchRequest: NSFetchRequest = FavoriteStation.fetchRequest()
    do {
        let items = try coredataContext.fetch(fetchRequest)
        return items
    } catch {
        print("Failed to fetch items: \(error)")
        return nil
    }
}
