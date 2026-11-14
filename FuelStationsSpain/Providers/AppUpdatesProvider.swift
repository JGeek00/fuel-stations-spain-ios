import Foundation

@MainActor
class AppUpdatesProvider: ObservableObject {
    static let shared = AppUpdatesProvider()
    
    @Published var updateAvailable = false
    
    private let fetchAppStoreInfo: () async -> StatusResponse<AppStoreInfoResult>
    
    init(fetchAppStoreInfo: @escaping () async -> StatusResponse<AppStoreInfoResult> = FuelStationsSpain.fetchAppStoreInfo) {
        self.fetchAppStoreInfo = fetchAppStoreInfo
    }
    
    func checkUpdateAvailable() async {
        let result = await self.fetchAppStoreInfo()
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let appStoreData = result.data, let appStoreVersion = appStoreData.results?.first?.version {
            let hasUpdate = compareSoftwareVersions(appVersion: appVersion, comparisonVersion: appStoreVersion)
            self.updateAvailable = hasUpdate
        }
    }
}
