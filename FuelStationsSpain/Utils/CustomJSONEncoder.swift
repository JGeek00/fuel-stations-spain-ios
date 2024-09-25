import Foundation

class CustomJSONEncoder: JSONEncoder {
    override func encode<T>(_ value: T) throws -> Data where T : Encodable {
        let originalData = try super.encode(value)
        if var jsonString = String(data: originalData, encoding: .utf8) {
            jsonString = jsonString.replacingOccurrences(of: "\\/", with: "/")
            if let modifiedData = jsonString.data(using: .utf8) {
                return modifiedData
            }
        }
        return originalData
    }
}
