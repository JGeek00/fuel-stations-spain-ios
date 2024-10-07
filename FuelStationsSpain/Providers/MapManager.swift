import Foundation
import Combine
import MapKit
import SwiftUI

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
    
    @Published var selectedStation: FuelStation? = nil
    @Published var selectedStationAnimation: FuelStation? = nil  // Only affects the animation, just to improve it
    @Published var showStationSheet = false
    private var isOpeningOrClosingStationSheet = false
        
    private var previousLoadCoordinates: Coordinate? = nil
    private var firstLoadCompleted = false
    
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
                    self.data = result.data!
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
                    }
                    else {
                        self.error = .connection
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
        self.selectedStationAnimation = station
        self.selectedStation = station
        if centerLocation == true {
            centerToLocation(latitude: station.latitude!, longitude: station.longitude!)
        }
        self.showStationSheet = true
    }
    
    func selectStationWithDelay(station: FuelStation, centerLocation: Bool = false) {
        if isOpeningOrClosingStationSheet == true { return }
        
        self.isOpeningOrClosingStationSheet = true
        
        Task {
            self.selectedStationAnimation = nil
            
            // await to prevent opening a sheet with another one already open
            if self.showStationSheet == true {
                self.showStationSheet = false
                try await Task.sleep(for: .seconds(0.7))
            }
            
            self.selectedStation = station
            self.selectedStationAnimation = station
            
            if centerLocation == true {
                centerToLocation(latitude: station.latitude!, longitude: station.longitude!)
            }
            
            self.showStationSheet = true
            self.isOpeningOrClosingStationSheet = false
        }
    }
    
    func unselectStation() {
        if isOpeningOrClosingStationSheet == true { return }
        
        self.isOpeningOrClosingStationSheet = true
        
        self.showStationSheet = false
        self.selectedStationAnimation = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedStation = nil
            
            self.isOpeningOrClosingStationSheet = false
        }
    }
}
