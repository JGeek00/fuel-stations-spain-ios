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
    @Published var usedMoved = false
    
    @Published var showSuccessAlert = false
    @Published var showErrorAlert = false
    
    @Published var showStationsSheet = false
    
    @Published var selectedStation: FuelStation? = nil
    @Published var showStationSheet = false
        
    private var previousLoadCoordinates: Coordinate? = nil
    
    var latitude = 0.0
    var longitude = 0.0
    
    init(latitude: Double?, longitude: Double?) {
        if latitude != nil && longitude != nil {
            self.latitude = latitude!
            self.longitude = longitude!
            self.position = MapCameraPosition.region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!),
                    span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom)
                )
            )
            fetchData(latitude: latitude!, longitude: longitude!, force: true)
        }
        else {
            self.latitude = Config.defaultCoordinates.latitude
            self.longitude = Config.defaultCoordinates.longitude
            fetchData(latitude: Config.defaultCoordinates.latitude, longitude: Config.defaultCoordinates.longitude, force: true)
        }
    }
    
    func updatePositionAndFetch(latitude: Double, longitude: Double) {
        guard let previousLoadCoordinates = previousLoadCoordinates else { return }
        if distanceBetweenCoordinates(Coordinate(latitude: latitude, longitude: longitude), previousLoadCoordinates) <= Config.minimumRefetchDistance {
            return
        }
        
        self.latitude = latitude
        self.longitude = longitude
        self.position = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: defaultZoom, longitudeDelta: defaultZoom)
            )
        )
        fetchData(latitude: latitude, longitude: longitude, force: true)
    }
    
    func setPosition(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func fetchData(latitude: Double, longitude: Double, force: Bool = false) {
        // To prevent triggering a lot of queries
        if !(force == true || (previousLoadCoordinates == nil || (previousLoadCoordinates != nil && distanceBetweenCoordinates(Coordinate(latitude: latitude, longitude: longitude), previousLoadCoordinates!) > Config.minimumRefetchDistance))) {
            return
        }

        Task {
            DispatchQueue.main.async {
                self.loading = true
            }
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
