import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/CustomJSONEncoder.swift`: el encoder no escapa "/" como "\\/".
@Suite struct CustomJSONEncoderTests {
    private struct Payload: Codable {
        let path: String
        let nested: [String]
    }

    private static let payload = Payload(path: "a/b", nested: ["x/y", "z"])

    @Test func plainJSONEncoderEscapesSlashAsPrecondition() throws {
        let data = try JSONEncoder().encode(Self.payload)
        let string = String(decoding: data, as: UTF8.self)
        // Precondición del comportamiento que el encoder custom corrige:
        // JSONEncoder estándar escapa "/" como "\/".
        #expect(string.contains("\\/"))
    }

    @Test func customJSONEncoderDoesNotEscapeSlash() throws {
        let data = try CustomJSONEncoder().encode(Self.payload)
        let string = String(decoding: data, as: UTF8.self)
        #expect(!string.contains("\\/"))
        #expect(string.contains("a/b"))
        #expect(string.contains("x/y"))
    }

    @Test func customJSONEncoderOutputIsStillDecodable() throws {
        let data = try CustomJSONEncoder().encode(Self.payload)
        let decoded = try JSONDecoder().decode(Payload.self, from: data)
        #expect(decoded.path == "a/b")
        #expect(decoded.nested == ["x/y", "z"])
    }
}
