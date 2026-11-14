import SwiftUI
import UIKit
import Testing
@testable import FuelStationsSpain

/// Tests de `Extensions/Color.swift` — solo `Color.init(hex:)`.
/// `toHex()` queda excluido: depende de la conversión UIColor/CGColor del
/// sistema (ver reporte de exclusiones). El round-trip se verifica descomponiendo
/// los componentes RGBA del color resultante vía UIColor, no con `toHex()`.
@Suite struct ColorHexTests {
    private func rgba(_ color: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b), Double(a))
    }

    // UIColor(Color) cuantiza a Float32 (extended sRGB): comparar con épsilon,
    // no con igualdad exacta.
    private static func isClose(_ a: Double, _ b: Double) -> Bool {
        abs(a - b) < 0.001
    }

    private static let orange = (r: 1.0, g: 128.0 / 255.0, b: 0.0, a: 1.0)

    @Test func hexWithHashParses() {
        let components = rgba(Color(hex: "#FF8000"))
        #expect(Self.isClose(components.r, Self.orange.r))
        #expect(Self.isClose(components.g, Self.orange.g))
        #expect(Self.isClose(components.b, Self.orange.b))
    }

    @Test func hexWithoutHashParses() {
        let components = rgba(Color(hex: "FF8000"))
        #expect(Self.isClose(components.r, Self.orange.r))
        #expect(Self.isClose(components.g, Self.orange.g))
        #expect(Self.isClose(components.b, Self.orange.b))
    }

    @Test func hexIsCaseInsensitive() {
        let upper = rgba(Color(hex: "ff8000"))
        #expect(Self.isClose(upper.r, Self.orange.r) && Self.isClose(upper.g, Self.orange.g) && Self.isClose(upper.b, Self.orange.b))
    }

    @Test func hexTrimsWhitespace() {
        let components = rgba(Color(hex: "  #FF8000 "))
        #expect(Self.isClose(components.r, Self.orange.r))
        #expect(Self.isClose(components.g, Self.orange.g))
        #expect(Self.isClose(components.b, Self.orange.b))
    }

    @Test func invalidHexFallsBackToBlack() {
        let components = rgba(Color(hex: "xyz"))
        #expect(components.r == 0 && components.g == 0 && components.b == 0)
    }

    @Test func emptyHexFallsBackToBlack() {
        let components = rgba(Color(hex: ""))
        #expect(components.r == 0 && components.g == 0 && components.b == 0)
    }

    @Test func roundTripThroughComponentsIsStable() {
        // hex → Color → componentes RGBA → hex normalizado → Color: mismo resultado
        for hex in ["#1A2B3C", "7F8081", "000000", "FFFFFF"] {
            let first = rgba(Color(hex: hex))
            let rebuilt = String(format: "%02X%02X%02X",
                                 Int(round(first.r * 255)),
                                 Int(round(first.g * 255)),
                                 Int(round(first.b * 255)))
            let second = rgba(Color(hex: rebuilt))
            #expect(Self.isClose(first.r, second.r) && Self.isClose(first.g, second.g) && Self.isClose(first.b, second.b))
        }
    }
}
