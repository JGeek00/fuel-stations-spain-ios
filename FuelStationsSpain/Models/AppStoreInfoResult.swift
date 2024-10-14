import Foundation

// MARK: - AppStoreInfoResult
struct AppStoreInfoResult: Sendable, Codable {
    let resultCount: Int?
    let results: [AppStoreResult]?
}

// MARK: - AppStoreResult
struct AppStoreResult: Sendable, Codable {
    let features, supportedDevices: [String]?
    let advisories: [String]?
    let isGameCenterEnabled: Bool?
    let kind: String?
    let screenshotUrls, ipadScreenshotUrls, appletvScreenshotUrls: [String]?
    let artworkUrl60, artworkUrl512, artworkUrl100: String?
    let artistViewURL: String?
    let bundleID, primaryGenreName: String?
    let primaryGenreID, trackID: Int?
    let trackName: String?
    let releaseDate: String?
    let genreIDS: [String]?
    let isVppDeviceBasedLicensingEnabled: Bool?
    let sellerName: String?
    let currentVersionReleaseDate: String?
    let releaseNotes, version, wrapperType, currency: String?
    let description, trackCensoredName: String?
    let languageCodesISO2A: [String]?
    let fileSizeBytes, formattedPrice, contentAdvisoryRating: String?
    let userRatingCountForCurrentVersion: Int?
    let trackViewURL: String?
    let trackContentRating: String?
    let averageUserRatingForCurrentVersion, averageUserRating: Int?
    let minimumOSVersion: String?
    let artistID: Int?
    let artistName: String?
    let genres: [String]?
    let price, userRatingCount: Int?
}
