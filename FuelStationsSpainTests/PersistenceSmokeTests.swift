import CoreData
import Testing
@testable import FuelStationsSpain

/// Smoke test del harness Core Data en memoria. La cobertura completa
/// (CRUD, migraciones) es de T5.
@Suite struct PersistenceSmokeTests {
    @Test func inMemoryStoreSavesAndFetchesFavoriteStation() throws {
        let persistence = makeInMemoryPersistence()
        let context = persistence.container.viewContext

        let favorite = FavoriteStation(context: context)
        favorite.id = "1234"
        favorite.name = "Estación de prueba"
        favorite.address = "Calle Falsa 123"
        favorite.date = Date()
        try context.save()

        let request = FavoriteStation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "1234")
        let fetched = try context.fetch(request)

        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Estación de prueba")

        // Un store en memoria no debe compartir estado con otro controlador.
        let other = makeInMemoryPersistence()
        let otherCount = try other.container.viewContext.count(for: FavoriteStation.fetchRequest())
        #expect(otherCount == 0)
    }
}
