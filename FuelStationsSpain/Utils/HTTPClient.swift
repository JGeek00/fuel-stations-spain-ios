import Foundation

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
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if body != nil {
            request.httpBody = try CustomJSONEncoder().encode(body)
        }
        
        let (data, r) = try await URLSession.shared.data(for: request)
        guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
        if response.statusCode < 400 {
            let formatted = try JSONDecoder().decode(T.self, from: data)
            return StatusResponse<T>(successful: true, statusCode: response.statusCode, data: formatted)
        }
        else {
            return StatusResponse<T>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
        }
    } catch {
        return defaultErrorResponse
    }
}
