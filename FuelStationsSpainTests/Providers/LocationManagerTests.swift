import CoreLocation
import Testing
@testable import FuelStationsSpain

private let madrid = Config.defaultCoordinates

@Suite
@MainActor
struct LocationManagerTests {

    @Test func mockDataInitUsesMadridAndAuthorizedWhenInUse() {
        let manager = LocationManager(mockData: true)

        #expect(manager.authorizationStatus == .authorizedWhenInUse)
        #expect(manager.firstLocation?.coordinate.latitude == madrid.latitude)
        #expect(manager.firstLocation?.coordinate.longitude == madrid.longitude)
        #expect(manager.lastLocation?.coordinate.latitude == madrid.latitude)
        #expect(manager.lastLocation?.coordinate.longitude == madrid.longitude)
    }

    @Test func normalInitStartsEmpty() {
        let manager = LocationManager()

        #expect(manager.authorizationStatus == nil)
        #expect(manager.firstLocation == nil)
        #expect(manager.lastLocation == nil)
    }

    @Test func didChangeAuthorizationUpdatesStatus() {
        let manager = LocationManager()

        manager.locationManager(CLLocationManager(), didChangeAuthorization: .denied)
        #expect(manager.authorizationStatus == .denied)

        manager.locationManager(CLLocationManager(), didChangeAuthorization: .authorizedAlways)
        #expect(manager.authorizationStatus == .authorizedAlways)
    }

    @Test func didUpdateLocationsSetsFirstAndLast() {
        let manager = LocationManager()
        let first = CLLocation(latitude: 41.0, longitude: -4.0)
        let last = CLLocation(latitude: 42.0, longitude: -5.0)

        manager.locationManager(CLLocationManager(), didUpdateLocations: [first, last])

        // La primera localización es la última de la primera tanda recibida.
        #expect(manager.firstLocation?.coordinate.latitude == 42.0)
        #expect(manager.lastLocation?.coordinate.latitude == 42.0)

        // Llamadas posteriores no cambian firstLocation, solo lastLocation.
        let newer = CLLocation(latitude: 43.0, longitude: -6.0)
        manager.locationManager(CLLocationManager(), didUpdateLocations: [newer])
        #expect(manager.firstLocation?.coordinate.latitude == 42.0)
        #expect(manager.lastLocation?.coordinate.latitude == 43.0)
    }

    @Test func didUpdateLocationsWithEmptyArrayDoesNothing() {
        let manager = LocationManager(mockData: true)

        manager.locationManager(CLLocationManager(), didUpdateLocations: [])

        #expect(manager.firstLocation?.coordinate.latitude == madrid.latitude)
        #expect(manager.lastLocation?.coordinate.latitude == madrid.latitude)
    }
}

@Suite
@MainActor
struct TabViewManagerTests {

    @Test func defaultTabIsMap() {
        let manager = TabViewManager()
        #expect(manager.selectedTab == .map)
    }
}
