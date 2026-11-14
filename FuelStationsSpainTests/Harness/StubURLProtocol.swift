import Foundation

/// URLProtocol stub que sirve respuestas enlatadas registradas por URL absoluta.
/// Se usa con una URLSession efímera (`StubURLProtocol.session()`), inyectada
/// en `httpRequest` a través de `HTTPClientSessionProvider`.
final class StubURLProtocol: URLProtocol {
    struct Stub {
        let statusCode: Int
        let body: Data
        let headers: [String: String]
        let error: Error?

        init(statusCode: Int, body: Data, headers: [String: String] = ["Content-Type": "application/json"], error: Error? = nil) {
            self.statusCode = statusCode
            self.body = body
            self.headers = headers
            self.error = error
        }
    }

    /// Registro de stubs, protegido con lock (URLProtocol se invoca en hilos arbitrarios).
    final class Registry {
        nonisolated(unsafe) private static let lock = NSLock()
        nonisolated(unsafe) private static var stubs: [String: Stub] = [:]
        nonisolated(unsafe) private static var receivedRequests: [URLRequest] = []

        static func set(url: String, stub: Stub) {
            lock.withLock { stubs[url] = stub }
        }

        static func stub(for url: String) -> Stub? {
            lock.withLock { stubs[url] }
        }

        static func record(_ request: URLRequest) {
            lock.withLock { receivedRequests.append(request) }
        }

        static var requests: [URLRequest] {
            lock.withLock { receivedRequests }
        }

        static func reset() {
            lock.withLock {
                stubs.removeAll()
                receivedRequests.removeAll()
            }
        }
    }

    /// Sesión efímera configurada con este protocolo.
    static func session() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: config)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Registry.record(request)
        let stub = request.url.flatMap { Registry.stub(for: $0.absoluteString) }
        if let error = stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let statusCode = stub?.statusCode ?? 404
        let body = stub?.body ?? Data()
        let headers = stub?.headers ?? ["Content-Type": "application/json"]
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
