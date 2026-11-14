import Foundation
import Testing
@testable import FuelStationsSpain

/// Contrato de los endpoints de `ApiClient`: para cada fetch se verifica la
/// URL exacta (host + path) y los query items exactos (nombre, valor y orden)
/// tal y como los recibe el stub, además del payload decodificado.
///
/// No se usa `Registry.reset()`: es global y en ejecución paralela borra los
/// stubs/requests de otros tests en vuelo. Cada test registra su stub en una
/// URL única y filtra `Registry.requests` por esa URL exacta.
@Suite(.serialized)
struct ApiClientEndpointTests {
    /// Registra un stub en la URL exacta que produce `httpRequest` a partir
    /// de `base` + path + query items, y devuelve esa URL absoluta.
    private func stub(base: String, path: String, query: [URLQueryItem], statusCode: Int, body: Data) -> String {
        var components = URLComponents(string: base + path)!
        if !query.isEmpty {
            components.queryItems = query
        }
        let url = components.url!.absoluteString
        StubURLProtocol.Registry.set(url: url, stub: StubURLProtocol.Stub(statusCode: statusCode, body: body))
        return url
    }

    private func requestSent(to url: String) throws -> URLComponents {
        let matching = StubURLProtocol.Registry.requests.filter { $0.url?.absoluteString == url }
        try #require(matching.count == 1)
        return URLComponents(url: try #require(matching.first?.url), resolvingAgainstBaseURL: false)!
    }

    private func withStubSession(_ body: () async throws -> Void) async throws {
        let original = HTTPClientSessionProvider.shared.session
        HTTPClientSessionProvider.shared.session = StubURLProtocol.session()
        defer { HTTPClientSessionProvider.shared.session = original }
        try await body()
    }

    @Test func fetchServiceStationsByLocationSendsCoordinatesAndDistance() async throws {
        try await withStubSession {
            let body = try FixtureLoader.data("network-stations")
            let url = stub(
                base: Config.apiBaseUrl, path: "/service-stations",
                query: [
                    URLQueryItem(name: "coordinates", value: "40.4166359,-3.7038101"),
                    URLQueryItem(name: "distance", value: "20"),
                ],
                statusCode: 200, body: body
            )

            let result = await ApiClient.fetchServiceStationsByLocation(lat: 40.4166359, long: -3.7038101, distance: 20)

            #expect(result.successful)
            #expect(result.data?.results.count == 2)

            let request = try requestSent(to: url)
            #expect(request.scheme == "https")
            #expect(request.host == "fuelapi.jgeek00.com")
            #expect(request.path == "/service-stations")
            #expect(request.queryItems == [
                URLQueryItem(name: "coordinates", value: "40.4166359,-3.7038101"),
                URLQueryItem(name: "distance", value: "20"),
            ])
        }
    }

    @Test func fetchServiceStationsByIdRepeatsIdQueryItem() async throws {
        try await withStubSession {
            let url = stub(
                base: Config.apiBaseUrl, path: "/service-stations",
                query: [
                    URLQueryItem(name: "id", value: "1111"),
                    URLQueryItem(name: "id", value: "2222"),
                    URLQueryItem(name: "id", value: "3333"),
                ],
                statusCode: 200, body: try FixtureLoader.data("network-stations")
            )

            let result = await ApiClient.fetchServiceStationsById(stationIds: ["1111", "2222", "3333"])

            #expect(result.successful)

            let request = try requestSent(to: url)
            #expect(request.path == "/service-stations")
            #expect(request.queryItems == [
                URLQueryItem(name: "id", value: "1111"),
                URLQueryItem(name: "id", value: "2222"),
                URLQueryItem(name: "id", value: "3333"),
            ])
        }
    }

    @Test func fetchMunicipalitiesSendsNoQuery() async throws {
        try await withStubSession {
            let url = "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/Listados/Municipios"
            StubURLProtocol.Registry.set(
                url: url,
                stub: StubURLProtocol.Stub(statusCode: 200, body: try FixtureLoader.data("municipalities"))
            )

            let result = await ApiClient.fetchMunicipalities()

            #expect(result.successful)
            #expect(result.data?.count == 2)
            #expect(result.data?.first?.IDMunicipio == "28065")

            let request = try requestSent(to: url)
            #expect(request.scheme == "https")
            #expect(request.host == "sedeaplicaciones.minetur.gob.es")
            #expect(request.path == "/ServiciosRESTCarburantes/PreciosCarburantes/Listados/Municipios")
            #expect(request.query == nil)
        }
    }

    @Test func fetchServiceStationsByMunicipalitySendsMunicipalityId() async throws {
        try await withStubSession {
            let url = stub(
                base: Config.apiBaseUrl, path: "/service-stations",
                query: [URLQueryItem(name: "municipalityId", value: "28065")],
                statusCode: 200, body: try FixtureLoader.data("network-stations")
            )

            let result = await ApiClient.fetchServiceStationsByMunicipality(municipalityId: "28065")

            #expect(result.successful)
            #expect(result.data?.count == 2)

            let request = try requestSent(to: url)
            #expect(request.path == "/service-stations")
            #expect(request.queryItems == [URLQueryItem(name: "municipalityId", value: "28065")])
        }
    }

    @Test func fetchHistoricPricesSendsIdDatesAndIncludeCurrentPrices() async throws {
        try await withStubSession {
            var start = DateComponents(); start.year = 2024; start.month = 1; start.day = 15; start.hour = 12
            var end = DateComponents(); end.year = 2024; end.month = 2; end.day = 20; end.hour = 12
            let startDate = try #require(Calendar.current.date(from: start))
            let endDate = try #require(Calendar.current.date(from: end))

            let body = try FixtureLoader.data("network-historic")
            let withCurrentURL = stub(
                base: Config.apiBaseUrl, path: "/historic-prices",
                query: [
                    URLQueryItem(name: "id", value: "1111"),
                    URLQueryItem(name: "startDate", value: "2024-01-15"),
                    URLQueryItem(name: "endDate", value: "2024-02-20"),
                    URLQueryItem(name: "includeCurrentPrices", value: "true"),
                ],
                statusCode: 200, body: body
            )
            let withoutCurrentURL = stub(
                base: Config.apiBaseUrl, path: "/historic-prices",
                query: [
                    URLQueryItem(name: "id", value: "1111"),
                    URLQueryItem(name: "startDate", value: "2024-01-15"),
                    URLQueryItem(name: "endDate", value: "2024-02-20"),
                    URLQueryItem(name: "includeCurrentPrices", value: "false"),
                ],
                statusCode: 200, body: body
            )

            let withCurrent = await ApiClient.fetchHistoricPrices(
                stationId: "1111", startDate: startDate, endDate: endDate, includeCurrentPrices: true
            )
            let withoutCurrent = await ApiClient.fetchHistoricPrices(
                stationId: "1111", startDate: startDate, endDate: endDate
            )

            #expect(withCurrent.successful)
            #expect(withoutCurrent.successful)
            #expect(withCurrent.data?.count == 2)
            #expect(withCurrent.data?.first?.gasoline95E5Price == 1.521)
            #expect(withCurrent.data?.first?.date == "2024-01-15")

            let first = try requestSent(to: withCurrentURL)
            let second = try requestSent(to: withoutCurrentURL)
            #expect(first.path == "/historic-prices")
            #expect(first.queryItems == [
                URLQueryItem(name: "id", value: "1111"),
                URLQueryItem(name: "startDate", value: "2024-01-15"),
                URLQueryItem(name: "endDate", value: "2024-02-20"),
                URLQueryItem(name: "includeCurrentPrices", value: "true"),
            ])
            #expect(second.queryItems == [
                URLQueryItem(name: "id", value: "1111"),
                URLQueryItem(name: "startDate", value: "2024-01-15"),
                URLQueryItem(name: "endDate", value: "2024-02-20"),
                URLQueryItem(name: "includeCurrentPrices", value: "false"),
            ])
        }
    }

    @Test func fetchAppStoreInfoSendsBundleId() async throws {
        try await withStubSession {
            let url = stub(
                base: "https://itunes.apple.com", path: "/lookup",
                query: [URLQueryItem(name: "bundleId", value: "com.jgeek00.FuelStationsSpain")],
                statusCode: 200, body: try FixtureLoader.data("network-appstore")
            )

            let result = await fetchAppStoreInfo()

            #expect(result.successful)
            let info = try #require(result.data)
            #expect(info.resultCount == 1)
            #expect(info.results?.first?.trackName == "HispaFuel - Gasolineras España")
            #expect(info.results?.first?.bundleID == "com.jgeek00.FuelStationsSpain")

            let request = try requestSent(to: url)
            #expect(request.scheme == "https")
            #expect(request.host == "itunes.apple.com")
            #expect(request.path == "/lookup")
            #expect(request.queryItems == [
                URLQueryItem(name: "bundleId", value: "com.jgeek00.FuelStationsSpain"),
            ])
        }
    }
}
