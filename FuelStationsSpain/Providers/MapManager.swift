import MapKit
import SwiftUI
import BottomSheet

@MainActor
class MapManager: ObservableObject {
    static let shared = MapManager()
    
    @Published var data: FuelStationsResult? = nil
    @Published var loading = true
    @Published var error: Enums.ApiErrorReason? = nil
    
    @Published var position: MapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: Config.defaultCoordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
    
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    @Published var showStationsSheet = false
    
    @Published var showStationDetailsSheet = false
    @Published var stationDetailsSheetPosition: BottomSheetPosition = .hidden
    @Published var selectedStation: FuelStation? = nil
    @Published var selectedStationAnimation: FuelStation? = nil   // Used just for the map marker animation
    var isOpeningOrClosingSheet = false
        
    private var previousLoadCoordinates: Coordinate? = nil
    private var firstLoadCompleted = false
    
    @Published var movingMapFastAlert = false
    @Published var connectionErrorAlert = false
    
    var latitude = 0.0
    var longitude = 0.0
    
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
