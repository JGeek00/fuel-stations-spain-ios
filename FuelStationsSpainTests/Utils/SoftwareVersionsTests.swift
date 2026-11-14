import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/SoftwareVersions.swift` — solo entradas válidas con 3 componentes.
/// Hallazgo NO testado (fuera de alcance): con <3 componentes la función
/// indexa fuera de rango y crashea (`comparisonVersionComponents[1]`). Se reporta
/// al orquestador sin test ni fix.
@Suite struct SoftwareVersionsTests {
    @Test func equalVersionsReturnFalse() {
        #expect(compareSoftwareVersions(appVersion: "1.2.3", comparisonVersion: "1.2.3") == false)
    }

    @Test func higherMajorReturnsTrue() {
        #expect(compareSoftwareVersions(appVersion: "1.2.3", comparisonVersion: "2.0.0") == true)
    }

    @Test func sameMajorHigherMinorReturnsTrue() {
        #expect(compareSoftwareVersions(appVersion: "1.2.3", comparisonVersion: "1.3.0") == true)
    }

    @Test func sameMajorMinorHigherPatchReturnsTrue() {
        #expect(compareSoftwareVersions(appVersion: "1.2.3", comparisonVersion: "1.2.4") == true)
    }

    @Test func lowerMajorReturnsFalse() {
        #expect(compareSoftwareVersions(appVersion: "2.0.0", comparisonVersion: "1.9.9") == false)
    }

    @Test func lowerMinorReturnsFalse() {
        #expect(compareSoftwareVersions(appVersion: "1.9.9", comparisonVersion: "1.8.0") == false)
    }

    @Test func lowerPatchReturnsFalse() {
        #expect(compareSoftwareVersions(appVersion: "1.2.3", comparisonVersion: "1.2.2") == false)
    }

    @Test func nonNumericComponentMapsToZero() {
        // "a" → 0 vía `Int($0) ?? 0`; sigue sin crashear porque hay 3 componentes
        #expect(compareSoftwareVersions(appVersion: "1.0.a", comparisonVersion: "1.0.1") == true)
        #expect(compareSoftwareVersions(appVersion: "1.0.1", comparisonVersion: "1.0.a") == false)
    }
}
