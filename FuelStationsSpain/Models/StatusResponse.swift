import Foundation

struct StatusResponse<T: Sendable>: Sendable {
    let successful: Bool
    let statusCode: Int?
    let data: T?
    let rawBody: String?
    
    init(successful: Bool, statusCode: Int? = nil, data: T? = nil, rawBody: String? = nil) {
        self.successful = successful
        self.statusCode = statusCode
        self.data = data
        self.rawBody = rawBody
    }
}
