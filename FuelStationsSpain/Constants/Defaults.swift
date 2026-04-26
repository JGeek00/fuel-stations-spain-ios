import Foundation

class Defaults {
    static let onboardingCompleted = false
    static let hideStationsNotOpenPublic = false
    static let favoriteFuel: Enums.FuelType? = nil     // nil means no favorite fuel selected
    static let hideStationsDontHaveFavoriteFuel = false
    static let closedStationsShowMethod = Enums.ClosedStationsMode.showDimmed
    static let showRedClockClosedStations = true
    static let defaultListSorting = Enums.StationsSortingOptions.proximity
    static let mapStyle = Enums.MapStyle.standard
    static let chartAnnotationMode = Enums.ChartAnnotationMode.outsideChart
    static let showSectionIndexList = true
    static let showStationSummary = true
}
