import Foundation
import Testing
@testable import FuelStationsSpain

/// Smoke tests del harness de red: valida que el stub URLProtocol + la sesión
/// configurable de `httpRequest` funcionan. La cobertura completa es de T4.
@Suite struct HTTPClientSmokeTests {
    @Test func stubbed200WithValidJSONDecodesSuccessfully() async throws {
        // Sin reset() global: Swift Testing corre suites en paralelo y borraría
        // stubs/requests de otros tests en vuelo. URL única + filtrado por URL.
        let url = Config.apiBaseUrl + "/smoke-municipalities"
        let json = try FixtureLoader.string("municipalities")
        StubURLProtocol.Registry.set(url: url, stub: StubURLProtocol.Stub(statusCode: 200, body: Data(json.utf8)))

        let original = HTTPClientSessionProvider.shared.session
        HTTPClientSessionProvider.shared.session = StubURLProtocol.session()
        defer { HTTPClientSessionProvider.shared.session = original }

        let result: StatusResponse<[Municipality]> = await httpRequest(url: url)

        #expect(result.successful)
        #expect(result.statusCode == 200)
        #expect(result.data?.count == 2)
        #expect(result.data?.first?.IDMunicipio == "28065")
        #expect(result.data?.first?.Municipio == "Madrid")
        #expect(StubURLProtocol.Registry.requests.filter { $0.url?.absoluteString == url }.count == 1)
    }
}
