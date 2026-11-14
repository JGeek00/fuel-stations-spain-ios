import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests no-UI de `FavoritesListViewModel`: fetch de las estaciones favoritas
/// contra la API stubeada usando un `FavoritesProvider` en memoria (seam
/// inyectado), con los casos de éxito, error de conexión (500) y límite de uso
/// (429), y el retorno temprano cuando no hay favoritos.
@Suite(.serialized)
@MainActor
struct FavoritesListViewModelTests {

    private func makeProvider() -> FavoritesProvider {
        FavoritesProvider(context: makeInMemoryPersistence().container.viewContext)
    }

    private func withStubSession(_ body: () async throws -> Void) async throws {
        let original = HTTPClientSessionProvider.shared.session
        HTTPClientSessionProvider.shared.session = StubURLProtocol.session()
        defer { HTTPClientSessionProvider.shared.session = original }
        try await body()
    }

    /// Espera acotada a una condición en el actor principal.
    private func waitUntil(timeout: TimeInterval = 3, _ condition: () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        return condition()
    }

    private func serviceStationsURL(ids: [String]) -> String {
        var components = URLComponents(string: "\(Config.apiBaseUrl)/service-stations")!
        components.queryItems = ids.map { URLQueryItem(name: "id", value: $0) }
        return components.url!.absoluteString
    }

    // MARK: fetch

    @Test func fetchDataWithoutFavoritesReturnsEarly() async throws {
        try await withStubSession {
            let vm = FavoritesListViewModel(favoritesProvider: makeProvider())

            // El fetch retorna sin pedir nada: loading se queda en su valor inicial.
            try await Task.sleep(nanoseconds: 300_000_000)
            #expect(vm.loading == true)
            #expect(vm.data == nil)
            #expect(vm.error == nil)

            // Ningún id propio llegó a la red.
            var idsSent: [String?] = []
            for request in StubURLProtocol.Registry.requests {
                guard let url = request.url,
                      let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { continue }
                for item in components.queryItems ?? [] where item.name == "id" {
                    idsSent.append(item.value)
                }
            }
            #expect(!idsSent.contains("99990001"))
        }
    }

    @Test func fetchDataFetchesFavoriteStations() async throws {
        try await withStubSession {
            let provider = makeProvider()
            provider.addFavorite(station: makeFuelStation(id: "1111"))
            provider.addFavorite(station: makeFuelStation(id: "2222"))

            StubURLProtocol.Registry.set(
                url: serviceStationsURL(ids: ["1111", "2222"]),
                stub: StubURLProtocol.Stub(statusCode: 200, body: try FixtureLoader.data("network-stations"))
            )

            let vm = FavoritesListViewModel(favoritesProvider: provider)

            let loaded = await waitUntil { vm.loading == false }
            #expect(loaded)
            #expect(vm.error == nil)
            #expect(vm.data?.results.map(\.id) == ["1111", "2222"])
        }
    }

    @Test func fetchDataSetsConnectionErrorOnServerFailure() async throws {
        try await withStubSession {
            let provider = makeProvider()
            provider.addFavorite(station: makeFuelStation(id: "88880001"))

            StubURLProtocol.Registry.set(
                url: serviceStationsURL(ids: ["88880001"]),
                stub: StubURLProtocol.Stub(statusCode: 500, body: Data("[]".utf8))
            )

            let vm = FavoritesListViewModel(favoritesProvider: provider)

            let finished = await waitUntil { vm.loading == false }
            #expect(finished)
            #expect(vm.data == nil)
            #expect(vm.error == .connection)
        }
    }

    @Test func fetchDataSetsUsageErrorOnRateLimit() async throws {
        try await withStubSession {
            let provider = makeProvider()
            provider.addFavorite(station: makeFuelStation(id: "88880002"))

            StubURLProtocol.Registry.set(
                url: serviceStationsURL(ids: ["88880002"]),
                stub: StubURLProtocol.Stub(statusCode: 429, body: Data("[]".utf8))
            )

            let vm = FavoritesListViewModel(favoritesProvider: provider)

            let finished = await waitUntil { vm.loading == false }
            #expect(finished)
            #expect(vm.data == nil)
            #expect(vm.error == .usage)
        }
    }
}
