import CoreLocation
import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests no-UI de `SearchViewModel`: agrupación por provincia e inicial
/// (con tildes), filtros de municipios y estaciones, ordenación por
/// proximidad/precio, reset de municipio seleccionado y el fetch de
/// municipios que dispara el `init` (el stub se instala ANTES de instanciar).
@Suite(.serialized)
@MainActor
struct SearchViewModelTests {

    private static let municipalitiesURL = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/Listados/Municipios"

    /// Estaciones para fetch/sort: REPSOL cerca (Madrid) y cara,
    /// SHELL lejos (Barcelona) y barata, para que el orden por
    /// proximidad y por precio sea distinto.
    private static let stationsBody = """
    {
      "lastUpdated": "2024-01-15T10:00:00.000+0100",
      "count": 2,
      "results": [
        {"id":"1111","postalCode":"28001","address":"Calle Alcalá 1","openingHours":"L-D: 24h",\
    "latitude":40.4166,"longitude":-3.7038,"locality":"Madrid","signage":"REPSOL",\
    "percBioEthanol":"","percMethylEster":"","municipalityId":28065,"provinceId":28,"regionId":7,\
    "gasoline95E5Price":1.559},
        {"id":"2222","postalCode":"28001","address":"Calle Alcalá 2","openingHours":"L-D: 24h",\
    "latitude":41.3874,"longitude":2.1686,"locality":"Barcelona","signage":"SHELL",\
    "percBioEthanol":"","percMethylEster":"","municipalityId":8019,"provinceId":8,"regionId":9,\
    "gasoline95E5Price":1.509}
      ]
    }
    """

    private static var stationsURL: String {
        var components = URLComponents(string: "\(Config.apiBaseUrl)/service-stations")!
        components.queryItems = [URLQueryItem(name: "municipalityId", value: "28065")]
        return components.url!.absoluteString
    }

    private func withStubSession(_ body: () async throws -> Void) async throws {
        let original = HTTPClientSessionProvider.shared.session
        HTTPClientSessionProvider.shared.session = StubURLProtocol.session()
        defer { HTTPClientSessionProvider.shared.session = original }
        try await body()
    }

    /// Registra el stub de municipios ANTES de instanciar: el `init` dispara
    /// `fetchMunicipalities` en cuanto se crea la VM.
    private func makeVM(municipalitiesBody: Data = Data("[]".utf8), municipalitiesStatus: Int = 200) -> SearchViewModel {
        StubURLProtocol.Registry.set(
            url: Self.municipalitiesURL,
            stub: StubURLProtocol.Stub(statusCode: municipalitiesStatus, body: municipalitiesBody)
        )
        return SearchViewModel()
    }

    /// Espera acotada a una condición en el actor principal.
    private func waitUntil(timeout: TimeInterval = 3, _ condition: () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        return condition()
    }

    /// VM con municipios cargados + municipio seleccionado + stub de estaciones.
    private func makeLoadedVMWithStations() async throws -> SearchViewModel {
        let vm = makeVM(municipalitiesBody: try FixtureLoader.data("viewmodels-municipalities"))
        _ = await waitUntil { vm.municipalitiesLoading == false }

        vm.selectedMunicipality = try JSONDecoder().decode(Municipality.self, from: Data("{\"IDMunicipio\":\"28065\"}".utf8))
        vm.location = CLLocation(latitude: 40.4166, longitude: -3.7038)
        StubURLProtocol.Registry.set(
            url: Self.stationsURL,
            stub: StubURLProtocol.Stub(statusCode: 200, body: Data(Self.stationsBody.utf8))
        )
        return vm
    }

    // MARK: init / fetch de municipios

    @Test func initFetchesAndGroupsMunicipalitiesByProvinceAndInitial() async throws {
        try await withStubSession {
            let vm = makeVM(municipalitiesBody: try FixtureLoader.data("viewmodels-municipalities"))

            let loaded = await waitUntil { vm.municipalitiesLoading == false }
            #expect(loaded)
            #expect(vm.municipalitiesError == false)
            #expect(vm.municipalitiesData?.count == 5)

            let byProvince = vm.municipalitiesDataByProvince
            // El orden es el del comparador `<` de String con equivalencia
            // canónica: las letras con tilde quedan después de todas las planas.
            #expect(byProvince?.map(\.sectionName) == ["A Coruña", "Jaén", "Zamora", "Ávila"])
            let avila = byProvince?.last { $0.sectionName == "Ávila" }
            #expect(avila?.sectionId == "05")
            #expect(avila?.municipalities.map(\.Municipio) == ["Ávila", "Cebreros"])

            // La inicial se calcula sin tildes: "Ávila" y "A Coruña" van a "A",
            // "Jaén" a "J", y las secciones quedan ordenadas alfabéticamente.
            let byInitial = vm.municipalitiesDataByInitial
            #expect(byInitial?.map(\.sectionName) == ["A", "C", "J", "Z"])
            #expect(byInitial?.first { $0.sectionName == "A" }?.municipalities.map(\.Municipio) == ["A Coruña", "Ávila"])
            #expect(byInitial?.first { $0.sectionName == "J" }?.municipalities.map(\.Municipio) == ["Jaén"])
        }
    }

    @Test func initSetsErrorWhenMunicipalitiesFetchFails() async throws {
        try await withStubSession {
            let vm = makeVM(municipalitiesStatus: 500)

            let loaded = await waitUntil { vm.municipalitiesLoading == false }
            #expect(loaded)
            #expect(vm.municipalitiesError == true)
            #expect(vm.municipalitiesData == nil)
            #expect(vm.municipalitiesDataByProvince == nil)
            #expect(vm.municipalitiesDataByInitial == nil)
        }
    }

    // MARK: filterMunicipalities

    @Test func filterMunicipalitiesMatchesAndClears() async throws {
        try await withStubSession {
            let vm = makeVM(municipalitiesBody: try FixtureLoader.data("viewmodels-municipalities"))
            _ = await waitUntil { vm.municipalitiesLoading == false }

            // Coincidencia insensible a mayúsculas y con tilde en el patrón.
            vm.municipalitiesSearchText = "jaé"
            vm.filterMunicipalities()
            let appeared = await waitUntil { vm.filteredMunicipalitiesData != nil }
            #expect(appeared)
            #expect(vm.filteredMunicipalitiesData?.map(\.Municipio) == ["Jaén"])

            vm.municipalitiesSearchText = "ZAM"
            vm.filterMunicipalities()
            _ = await waitUntil { vm.filteredMunicipalitiesData?.map(\.Municipio) == ["Zamora"] }
            #expect(vm.filteredMunicipalitiesData?.map(\.Municipio) == ["Zamora"])

            // Texto vacío limpia.
            vm.municipalitiesSearchText = ""
            vm.filterMunicipalities()
            #expect(vm.filteredMunicipalitiesData == nil)

            // clearSearch explícito también limpia.
            vm.municipalitiesSearchText = "jaé"
            vm.filterMunicipalities(clearSearch: true)
            #expect(vm.filteredMunicipalitiesData == nil)
        }
    }

    // MARK: fetchStations / sortSearchStations

    @Test func fetchStationsSortsByProximityAndByFuelPrice() async throws {
        try await withStubSession {
            let vm = try await makeLoadedVMWithStations()

            await vm.fetchStations()
            let loaded = await waitUntil { vm.stationsLoading == false }
            #expect(loaded)
            #expect(vm.stationsError == false)
            #expect(vm.stationsData?.results.count == 2)

            // Proximidad: REPSOL (Madrid) antes que SHELL (Barcelona).
            #expect(vm.sortedStationsList?.map(\.id) == ["1111", "2222"])
            #expect(vm.sortedStationsList?.first?.distanceToUserLocation != nil)

            // Precio gasoline95E5: SHELL (1.509) antes que REPSOL (1.559).
            vm.stationsSelectedSorting = .fuelType(.gasoline95E5)
            await vm.sortSearchStations()
            let resorted = await waitUntil { vm.sortedStationsList?.map(\.id) == ["2222", "1111"] }
            #expect(resorted)
            #expect(vm.sortedStationsList?.map(\.id) == ["2222", "1111"])
        }
    }

    @Test func fetchStationsWithoutSelectedMunicipalityDoesNothing() async throws {
        try await withStubSession {
            let vm = makeVM()
            _ = await waitUntil { vm.municipalitiesLoading == false }

            await vm.fetchStations()
            #expect(vm.stationsLoading == true)
            #expect(vm.stationsData == nil)
            #expect(vm.sortedStationsList == nil)
        }
    }

    // MARK: filterStations

    @Test func filterStationsMatchesSignageAndClears() async throws {
        try await withStubSession {
            let vm = try await makeLoadedVMWithStations()
            await vm.fetchStations()
            _ = await waitUntil { vm.stationsLoading == false }
            #expect(vm.sortedStationsList?.count == 2)

            vm.stationsSearchText = "repsol"
            vm.filterStations()
            let appeared = await waitUntil { vm.filteredStationsList != nil }
            #expect(appeared)
            #expect(vm.filteredStationsList?.map(\.id) == ["1111"])

            vm.stationsSearchText = "SHELL"
            vm.filterStations()
            _ = await waitUntil { vm.filteredStationsList?.map(\.id) == ["2222"] }
            #expect(vm.filteredStationsList?.map(\.id) == ["2222"])

            vm.filterStations(clearSearch: true)
            #expect(vm.filteredStationsList == nil)
        }
    }

    // MARK: clearSelectedMunicipality

    @Test func clearSelectedMunicipalityResetsStationsState() async throws {
        try await withStubSession {
            let vm = makeVM()
            _ = await waitUntil { vm.municipalitiesLoading == false }

            vm.selectedMunicipality = try JSONDecoder().decode(Municipality.self, from: Data("{\"IDMunicipio\":\"28065\"}".utf8))
            vm.stationsData = try JSONDecoder().decode(FuelStationsResult.self, from: try FixtureLoader.data("network-stations"))
            vm.stationsError = true
            vm.stationsLoading = false

            vm.clearSelectedMunicipality()

            #expect(vm.selectedMunicipality == nil)
            #expect(vm.stationsData == nil)
            #expect(vm.stationsLoading == true)
            #expect(vm.stationsError == false)
        }
    }
}
