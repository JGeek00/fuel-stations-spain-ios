import SwiftUI

@MainActor
@Observable
class AppUpdatesProvider {
    static let shared = AppUpdatesProvider()
    
    var updateAvailable = false
    
    init() {}
    
    func checkUpdateAvailable() async {
        let result = await fetchAppStoreInfo()
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let appStoreData = result.data, let appStoreVersion = appStoreData.results?.first?.version {
            let hasUpdate = compareSoftwareVersions(appVersion: appVersion, comparisonVersion: appStoreVersion)
            self.updateAvailable = hasUpdate
        }
    }
}
