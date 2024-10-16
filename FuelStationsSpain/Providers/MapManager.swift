import MapKit
import SwiftUI
import BottomSheet

@MainActor
@Observable
class MapManager {
    static let shared = MapManager()
    
    var data: FuelStationsResult? = nil
    var loading = true
    var error: Enums.ApiErrorReason? = nil
    
    var position: MapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: Config.defaultCoordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    var showSuccessAlert = false
    var showErrorAlert = false
    
    var showStationsSheet = false
    
    var showStationDetailsSheet = false
    var stationDetailsSheetPosition: BottomSheetPosition = .hidden
    var selectedStation: FuelStation? = nil
    var selectedStationAnimation: FuelStation? = nil   // Used just for the map marker animation
    @ObservationIgnored var isOpeningOrClosingSheet = false
        
    @ObservationIgnored private var previousLoadCoordinates: Coordinate? = nil
    @ObservationIgnored private var firstLoadCompleted = false
    
    var movingMapFastAlert = false
    var connectionErrorAlert = false
    
    @ObservationIgnored var latitude = 0.0
    @ObservationIgnored var longitude = 0.0
    
    init() {}
    
    func setInitialLocation(latitude: Double?, longitude: Double?) async {
        if latitude != nil && longitude != nil {
            self.latitude = latitude!
            self.longitude = longitude!
            self.position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                    span: MKCoordinateSpan(latitudeDelta: Config.mapDefaultZoom, longitudeDelta: Config.mapDefaultZoom)
                )
            )
            await fetchData(latitude: latitude!, longitude: longitude!)
            self.firstLoadCompleted = true
        }
        else {
            self.latitude = Config.defaultCoordinates.latitude
            self.longitude = Config.defaultCoordinates.longitude
            await fetchData(latitude: Config.defaultCoordinates.latitude, longitude: Config.defaultCoordinates.longitude)
            self.firstLoadCompleted = true
        }
    }
    
    func onMapCameraChange(_ value: MapCameraUpdateContext) {
        self.latitude = value.camera.centerCoordinate.latitude
        self.longitude = value.camera.centerCoordinate.longitude

        if !(self.firstLoadCompleted == true && (previousLoadCoordinates == nil || (previousLoadCoordinates != nil && distanceBetweenCoordinates(Coordinate(latitude: latitude, longitude: longitude), previousLoadCoordinates!) > Config.defaultFetchDistance))) {
            return
        }
        
        Task {
            await self.fetchData(latitude: value.camera.centerCoordinate.latitude, longitude: value.camera.centerCoordinate.longitude)
        }
    }
    
    func fetchData(latitude: Double, longitude: Double) async {
        withAnimation(.default) {
            self.loading = true
        }
        
        let result = await ApiClient.fetchServiceStationsByLocation(lat: latitude, long: longitude, distance: (Config.defaultFetchDistance*0.75).truncate())
        
        if result.successful == true {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = FuelStationsResult.filterStations(result.data!)
                    self.loading = false
                    self.error = nil
                }
            }
        }
        else {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    if result.statusCode == 429 {
                        self.error = .usage
                        self.movingMapFastAlert = true
                    }
                    else {
                        self.error = .connection
                        self.connectionErrorAlert = true
                    }
                    self.loading = false
                }
            }
        }
        
        self.previousLoadCoordinates = Coordinate(latitude: latitude, longitude: longitude)
    }
    
    func centerToLocation(latitude: Double, longitude: Double) {
        self.position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: Config.mapDefaultZoom, longitudeDelta: Config.mapDefaultZoom)
            )
        )
    }
    
    func selectStation(station: FuelStation, centerLocation: Bool = false) {
        if isOpeningOrClosingSheet == true { return }
                
        self.isOpeningOrClosingSheet = true
        
        withAnimation(.default) {
            self.selectedStation = station
        }
        self.selectedStationAnimation = station
        self.showStationDetailsSheet = true
        self.stationDetailsSheetPosition = .dynamicTop
        if centerLocation == true {
            centerToLocation(latitude: station.latitude!, longitude: station.longitude!)
        }
        
        self.isOpeningOrClosingSheet = false
    }
}
