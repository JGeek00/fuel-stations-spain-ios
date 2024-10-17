import Foundation

@MainActor
class AppUpdatesProvider: ObservableObject {
    static let shared = AppUpdatesProvider()
    
    @Published var updateAvailable = false
    
    init() {}
    
    func checkUpdateAvailable() async {
        let result = await fetchAppStoreInfo()
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let appStoreData = result.data, let appStoreVersion = appStoreData.results?.first?.version {
            let hasUpdate = compareSoftwareVersions(appVersion: appVersion, comparisonVersion: appStoreVersion)
            self.updateAvailable = hasUpdate
        }
    }
}
