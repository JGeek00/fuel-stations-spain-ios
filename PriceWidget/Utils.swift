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

func generateLabel(_ station: FuelStation) -> String {
    if let alias = getFavoriteAlias(favoriteId: station.id!), !alias.isEmpty {
        return alias
    }
    else {
        if let locality = station.locality {
            return "\(station.signage!.capitalized): \(station.address!.capitalized) (\(locality.capitalized))"
        }
        else {
            return "\(station.signage!.capitalized): \(station.address!.capitalized)"
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

func getStations() async -> [FuelStation] {
    let favorites = fetchFavorites()
    if let favorites = favorites, favorites.isEmpty { return [] }
    guard let favorites = favorites else { return [] }
    let result = await ApiClient.fetchServiceStationsById(stationIds: favorites.map() { $0.id! })
    if let data = result.data?.results {
        return data
    }
    else {
        return []
    }
}
