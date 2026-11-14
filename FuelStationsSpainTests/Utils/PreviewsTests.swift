import Foundation
import Testing
@testable import FuelStationsSpain

/// Test de `Utils/Previews.swift`: en un run de `xcodebuild test` la variable
/// de entorno de previews no está definida, así que `runningOnPreview()` es false.
@Suite struct PreviewsTests {
    @Test func runningOnPreviewIsFalseInTestEnvironment() {
        // Salvaguarda: si la variable estuviera definida, el test explica por qué falla
        #expect(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == nil)
        #expect(runningOnPreview() == false)
    }
}
