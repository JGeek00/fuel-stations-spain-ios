import Foundation
import Combine
import MapKit
import SwiftUI

let defaultZoom = 0.03

@MainActor
class MapViewModel: ObservableObject {
    @Published var data: FuelStationsResult? = nil
    @Published var loading = true
    @Published var error: Enums.ApiErrorReason? = nil
    
    @Published var position: MapCameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: Config.defaultCoordinates,
            span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom)
        )
    )
    
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    @Published var showStationsSheet = false
    
    @Published var selectedStation: FuelStation? = nil
    @Published var showStationSheet = false
        
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
                    span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom)
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

        if !(self.firstLoadCompleted == true && (previousLoadCoordinates == nil || (previousLoadCoordinates != nil && distanceBetweenCoordinates(Coordinate(latitude: latitude, longitude: longitude), previousLoadCoordinates!) > Config.minimumRefetchDistance))) {
            return
        }
        
        Task {
            await self.fetchData(latitude: value.camera.centerCoordinate.latitude, longitude: value.camera.centerCoordinate.longitude)
        }
    }
    
    func fetchData(latitude: Double, longitude: Double) async {
        self.loading = true
        
        let result = await ApiClient.fetchServiceStationsByLocation(lat: latitude, long: longitude, distance: 30)
        
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data!
                self.loading = false
                self.error = nil
            }
        }
        else {
            DispatchQueue.main.async {
                if result.statusCode == 429 {
                    self.error = .usage
                }
                else {
                    self.error = .connection
                }
                self.loading = false
            }
        }
        
        self.previousLoadCoordinates = Coordinate(latitude: latitude, longitude: longitude)
    }
    
    func centerToLocation(latitude: Double, longitude: Double) {
        self.position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom)
            )
        )
    }
    
    func selectStation(station: FuelStation, centerLocation: Bool = false) {
        self.selectedStation = station
        if centerLocation == true {
            centerToLocation(latitude: station.latitude!, longitude: station.longitude!)
        }
        self.showStationSheet.toggle()
    }
}
