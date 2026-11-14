import Foundation
import Testing
@testable import FuelStationsSpain

/// Contrato de `httpRequest`: códigos de estado, decodificación y errores,
/// con la sesión inyectada a través de `HTTPClientSessionProvider`.
/// `.serialized`: la sesión compartida es estado global y los tests de red
/// no deben solaparse entre sí.
///
/// No se usa `Registry.reset()`: es global y en ejecución paralela borra los
/// stubs/requests de otros tests en vuelo. Cada test usa URLs únicas y filtra
/// `Registry.requests` por su propia URL.
@Suite(.serialized)
struct HTTPClientContractTests {
    private func installStubSession() {
        HTTPClientSessionProvider.shared.session = StubURLProtocol.session()
    }
    private func restoreSession() {
        HTTPClientSessionProvider.shared.session = .shared
    }

    private func requests(for url: String) -> [URLRequest] {
        StubURLProtocol.Registry.requests.filter { $0.url?.absoluteString == url }
    }

    @Test func success200DecodesPayload() async throws {
        installStubSession()
        defer { restoreSession() }

        let url = Config.apiBaseUrl + "/network-stations"
        StubURLProtocol.Registry.set(
            url: url,
            stub: StubURLProtocol.Stub(statusCode: 200, body: try FixtureLoader.data("network-stations"))
        )

        let result: StatusResponse<FuelStationsResult> = await httpRequest(url: url)

        #expect(result.successful)
        #expect(result.statusCode == 200)
        #expect(result.rawBody == nil)
        let data = try #require(result.data)
        #expect(data.count == 2)
        #expect(data.results.first?.id == "1111")
        #expect(data.results.first?.gasoline95E5Price == 1.559)
        #expect(data.results.first?.municipalityID == 28065)
        #expect(data.results.last?.id == "2222")
        #expect(requests(for: url).count == 1)
    }

    @Test func httpErrorStatusCodeReturnsRawBodyWithoutData() async throws {
        installStubSession()
        defer { restoreSession() }

        for status in [404, 500] {
            let url = Config.apiBaseUrl + "/network-error-\(status)"
            StubURLProtocol.Registry.set(
                url: url,
                stub: StubURLProtocol.Stub(statusCode: status, body: Data("{\"error\":\"nope\"}".utf8))
            )

            let result: StatusResponse<FuelStationsResult> = await httpRequest(url: url)

            #expect(!result.successful)
            #expect(result.statusCode == status)
            #expect(result.rawBody == "{\"error\":\"nope\"}")
            #expect(result.data == nil)
            #expect(requests(for: url).count == 1)
        }
    }

    @Test func brokenDecodeReturnsFailureWithoutStatusCode() async throws {
        installStubSession()
        defer { restoreSession() }

        let url = Config.apiBaseUrl + "/network-broken-decode"
        StubURLProtocol.Registry.set(
            url: url,
            stub: StubURLProtocol.Stub(statusCode: 200, body: Data("this is not json".utf8))
        )

        let result: StatusResponse<FuelStationsResult> = await httpRequest(url: url)

        #expect(!result.successful)
        #expect(result.statusCode == nil)
        #expect(result.data == nil)
        #expect(result.rawBody == nil)
        #expect(requests(for: url).count == 1)
    }

    @Test func networkErrorPropagatesAsFailure() async throws {
        installStubSession()
        defer { restoreSession() }

        let url = Config.apiBaseUrl + "/network-transport-error"
        StubURLProtocol.Registry.set(
            url: url,
            stub: StubURLProtocol.Stub(statusCode: 200, body: Data(), error: URLError(.timedOut))
        )

        let result: StatusResponse<FuelStationsResult> = await httpRequest(url: url)

        #expect(!result.successful)
        #expect(result.statusCode == nil)
        #expect(result.data == nil)
        #expect(result.rawBody == nil)
        #expect(requests(for: url).count == 1)
    }

    @Test func invalidUrlReturnsDefaultFailure() async throws {
        installStubSession()
        defer { restoreSession() }

        let result: StatusResponse<FuelStationsResult> = await httpRequest(url: "ht tp://invalid url")

        #expect(!result.successful)
        #expect(result.statusCode == nil)
        #expect(result.data == nil)
        #expect(result.rawBody == nil)
    }
}
