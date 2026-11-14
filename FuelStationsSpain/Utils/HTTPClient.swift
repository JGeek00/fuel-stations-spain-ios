import Foundation

/// Test seam: URLSession used by `httpRequest`. Defaults to `.shared`;
/// tests replace it with a session backed by a stub URLProtocol.
/// Sendable garantizado con el NSLock interno (@unchecked porque `_session` es var).
final class HTTPClientSessionProvider: @unchecked Sendable {
    static let shared = HTTPClientSessionProvider()

    private let lock = NSLock()
    private var _session: URLSession = .shared

    var session: URLSession {
        get { lock.withLock { _session } }
        set { lock.withLock { _session = newValue } }
    }

    private init() {}
}

func httpRequest<T: Decodable>(url: String, httpMethod: String? = "GET", body: Data? = nil, queryParameters: [URLQueryItem]? = nil) async -> StatusResponse<T> {
    let defaultErrorResponse = StatusResponse<T>(successful: false, statusCode: nil, data: nil)
    
    guard let url = URL(string: url) else { return defaultErrorResponse }
    do {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if queryParameters != nil {
            components.queryItems = queryParameters
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = httpMethod
        request.timeoutInterval = 15
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        if body != nil {
            request.httpBody = try CustomJSONEncoder().encode(body)
        }

        print("[HTTP] -> \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
        let (data, r) = try await HTTPClientSessionProvider.shared.session.data(for: request)
        guard let response = r as? HTTPURLResponse else {
            print("[HTTP] no HTTPURLResponse")
            return defaultErrorResponse
        }
        if response.statusCode < 400 {
            do {
                let formatted = try JSONDecoder().decode(T.self, from: data)
                return StatusResponse<T>(successful: true, statusCode: response.statusCode, data: formatted)
            } catch {
                print("[HTTP] decode \(request.url?.absoluteString ?? "?"): \(error)")
                return defaultErrorResponse
            }
        }
        else {
            print("[HTTP] <- \(response.statusCode) body=\(String(data: data.prefix(300), encoding: .utf8) ?? "?")")
            return StatusResponse<T>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
        }
    } catch let e {
        let nserr = e as NSError
        print("[HTTP] !! FAIL domain=\(nserr.domain) code=\(nserr.code) desc=\(e)")
        return defaultErrorResponse
    }
}
