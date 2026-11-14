import CoreData
import Testing
@testable import FuelStationsSpain

/// `.serialized`: cada test crea un contenedor Core Data en memoria; en
/// paralelo con otras suites que hacen lo mismo, Core Data puede fallar
/// esporádicamente al abrir la store ("model configuration incompatible").
@Suite(.serialized)
@MainActor
struct FavoritesProviderTests {

    private func makeProvider() -> (FavoritesProvider, NSManagedObjectContext) {
        let persistence = makeInMemoryPersistence()
        let context = persistence.container.viewContext
        return (FavoritesProvider(context: context), context)
    }

    // MARK: init / fetchFavorites

    @Test func initLoadsPreexistingFavoritesFromInjectedContext() throws {
        let persistence = makeInMemoryPersistence()
        let context = persistence.container.viewContext
        let station = FavoriteStation(context: context)
        station.id = "1111"
        station.name = "Preexistente"
        station.address = "Calle Falsa 123"
        station.date = Date()
        try context.save()

        let provider = FavoritesProvider(context: context)

        #expect(provider.favorites.count == 1)
        #expect(provider.favorites.first?.id == "1111")
    }

    @Test func fetchFavoritesReloadsFromStore() throws {
        let (provider, context) = makeProvider()
        provider.addFavorite(station: makeFuelStation(id: "2222"))
        #expect(provider.favorites.count == 1)

        // Borrado directo en el store, fuera del provider.
        let request = FavoriteStation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "2222")
        for item in try context.fetch(request) {
            context.delete(item)
        }
        try context.save()

        let fetched = provider.fetchFavorites()
        #expect(fetched == true)
        #expect(provider.favorites.isEmpty)
    }

    // MARK: addFavorite

    @Test func addFavoriteInsertsAndMarksAsFavorite() {
        let (provider, _) = makeProvider()

        provider.addFavorite(station: makeFuelStation(id: "3333"))

        #expect(provider.isFavorite(stationId: "3333"))
        #expect(provider.favorites.count == 1)
        let added = provider.favorites.first
        #expect(added?.name == "REPSOL")
        #expect(added?.address == "Calle Falsa 123")
        #expect(added?.locality == "Madrid")
        #expect(added?.date != nil)
    }

    @Test func addFavoriteIsIdempotent() {
        let (provider, _) = makeProvider()

        provider.addFavorite(station: makeFuelStation(id: "4444"))
        provider.addFavorite(station: makeFuelStation(id: "4444"))

        #expect(provider.favorites.count == 1)
    }

    // MARK: removeFavorite

    @Test func removeFavoriteDeletesIt() {
        let (provider, _) = makeProvider()
        provider.addFavorite(station: makeFuelStation(id: "5555"))

        provider.removeFavorite(stationId: "5555")

        #expect(!provider.isFavorite(stationId: "5555"))
        #expect(provider.favorites.isEmpty)
    }

    @Test func removeFavoriteUnknownIdLeavesStoreUnchanged() {
        let (provider, _) = makeProvider()
        provider.addFavorite(station: makeFuelStation(id: "6666"))

        provider.removeFavorite(stationId: "desconocido")

        #expect(provider.isFavorite(stationId: "6666"))
        #expect(provider.favorites.count == 1)
    }

    // MARK: setFavoriteAlias

    @Test func setFavoriteAliasUpdatesAlias() {
        let (provider, _) = makeProvider()
        provider.addFavorite(station: makeFuelStation(id: "7777"))

        provider.setFavoriteAlias(stationId: "7777", newAlias: "La de casa")

        #expect(provider.favorites.first?.alias == "La de casa")
    }

    @Test func setFavoriteAliasUnknownIdLeavesStoreUnchanged() {
        let (provider, _) = makeProvider()
        provider.addFavorite(station: makeFuelStation(id: "8888"))

        provider.setFavoriteAlias(stationId: "desconocido", newAlias: "x")

        #expect(provider.favorites.first?.alias == nil)
    }

    // MARK: isFavorite

    @Test func isFavoriteReturnsFalseForUnknownId() {
        let (provider, _) = makeProvider()

        #expect(!provider.isFavorite(stationId: "inexistente"))
    }
}
