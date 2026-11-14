import Foundation
@testable import FuelStationsSpain

/// Controlador Core Data en memoria para tests, reutilizando
/// `PersistenceController.init(inMemory:)`.
func makeInMemoryPersistence() -> PersistenceController {
    PersistenceController(inMemory: true)
}
