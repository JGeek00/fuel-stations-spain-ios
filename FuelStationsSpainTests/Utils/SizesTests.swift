import SwiftUI
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/Sizes.swift`: multiplicador de tamaño por DynamicTypeSize.
@Suite struct SizesTests {
    @Test func fontSizeMultiplierMatchesTable() {
        let table: [(DynamicTypeSize, CGFloat)] = [
            (.xSmall, 0.8),
            (.small, 0.9),
            (.medium, 0.95),
            (.large, 1.0),
            (.xLarge, 1.05),
            (.xxLarge, 1.1),
            (.xxxLarge, 1.15),
            (.accessibility1, 1.2),
            (.accessibility2, 1.3),
            (.accessibility3, 1.4),
            (.accessibility4, 1.5),
            (.accessibility5, 1.6),
        ]
        for (size, expected) in table {
            #expect(fontSizeMultiplier(for: size) == expected, "\(size) debe multiplicar ×\(expected)")
        }
    }

    @Test func baseLargeIsIdentity() {
        #expect(fontSizeMultiplier(for: .large) == 1.0)
    }
}
