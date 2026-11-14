import Foundation
import Testing
@testable import FuelStationsSpain

/// Respuesta del App Store decodificada de JSON mínimo.
private func appStoreInfo(version: String?) -> StatusResponse<AppStoreInfoResult> {
    guard let version else {
        return StatusResponse(successful: false, data: nil)
    }
    let json = #"{"resultCount":1,"results":[{"version":"\#(version)"}]}"#
    let data = try! JSONDecoder().decode(AppStoreInfoResult.self, from: Data(json.utf8))
    return StatusResponse(successful: true, data: data)
}

/// Versión del host app (la que usa `checkUpdateAvailable` vía Bundle.main).
private var bundleVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
}

private func bumpedMajor(_ version: String) -> String {
    var parts = version.split(separator: ".").map { Int($0) ?? 0 }
    if parts.isEmpty { parts = [0, 0, 0] }
    parts[0] += 1
    return parts.map(String.init).joined(separator: ".")
}

private func loweredMajor(_ version: String) -> String {
    var parts = version.split(separator: ".").map { Int($0) ?? 0 }
    if parts.isEmpty { parts = [0, 0, 0] }
    parts[0] = max(parts[0] - 1, 0)
    return parts.map(String.init).joined(separator: ".")
}

@Suite
@MainActor
struct AppUpdatesProviderTests {

    @Test func updateAvailableWhenStoreVersionIsHigher() async {
        let higher = bumpedMajor(bundleVersion)
        let provider = AppUpdatesProvider(fetchAppStoreInfo: { appStoreInfo(version: higher) })

        await provider.checkUpdateAvailable()

        #expect(provider.updateAvailable == true)
    }

    @Test func noUpdateWhenStoreVersionMatchesApp() async {
        let same = bundleVersion
        let provider = AppUpdatesProvider(fetchAppStoreInfo: { appStoreInfo(version: same) })

        await provider.checkUpdateAvailable()

        #expect(provider.updateAvailable == false)
    }

    @Test func noUpdateWhenStoreVersionIsLower() async {
        let lower = loweredMajor(bundleVersion)
        let provider = AppUpdatesProvider(fetchAppStoreInfo: { appStoreInfo(version: lower) })

        await provider.checkUpdateAvailable()

        #expect(provider.updateAvailable == false)
    }

    @Test func noUpdateWhenFetchReturnsNoData() async {
        let provider = AppUpdatesProvider(fetchAppStoreInfo: { appStoreInfo(version: nil) })

        await provider.checkUpdateAvailable()

        #expect(provider.updateAvailable == false)
    }
}
