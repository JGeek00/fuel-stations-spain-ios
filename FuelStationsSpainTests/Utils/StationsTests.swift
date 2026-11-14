import Foundation
import CoreLocation
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/Stations.swift`: haversine, relleno de distancias y sorts.
/// Las aserciones usan coordenadas reales (Madrid/Barcelona) y tolerancias
/// calculadas con la misma fórmula del código; no dependen de locale ni TZ.
@Suite struct StationsTests {
    /// Madrid, Barcelona, Girona, Toledo (fixture `utils-stations.json`).
    private func loadStations() throws -> [FuelStation] {
        try JSONDecoder().decode([FuelStation].self, from: FixtureLoader.data("utils-stations"))
    }

    private func isClose(_ a: Double, _ b: Double, tolerance: Double) -> Bool {
        abs(a - b) < tolerance
    }

    @Test func haversineMadridBarcelonaIsAbout505km() {
        let madrid = Coordinate(latitude: 40.4168, longitude: -3.7038)
        let barcelona = Coordinate(latitude: 41.3874, longitude: 2.1686)
        let distance = distanceBetweenCoordinates(madrid, barcelona)
        #expect(isClose(distance, 505.1, tolerance: 5.0))
    }

    @Test func haversineSamePointIsZero() {
        let point = Coordinate(latitude: 40.4168, longitude: -3.7038)
        let distance = distanceBetweenCoordinates(point, point)
        #expect(isClose(distance, 0.0, tolerance: 0.001))
    }

    @Test func addDistancesWithNilLastLocationLeavesDistanceNil() throws {
        let stations = try loadStations()
        let result = addDistancesToStations(stations: stations, lastLocation: nil)
        #expect(result.count == stations.count)
        for station in result {
            #expect(station.distanceToUserLocation == nil)
        }
    }

    @Test func addDistancesFillsDistanceToGivenLocation() throws {
        let stations = try loadStations()
        let madrid = CLLocation(latitude: 40.4168, longitude: -3.7038)
        let result = addDistancesToStations(stations: stations, lastLocation: madrid)

        // Madrid (índice 0): distancia ~0
        #expect(result[0].distanceToUserLocation != nil)
        #expect(isClose(result[0].distanceToUserLocation!, 0.0, tolerance: 0.5))
        // Barcelona (índice 1): ~505 km, coincide con el cálculo directo
        #expect(isClose(result[1].distanceToUserLocation!, 505.1, tolerance: 5.0))
        #expect(isClose(
            result[1].distanceToUserLocation!,
            distanceBetweenCoordinates(
                Coordinate(latitude: stations[1].latitude, longitude: stations[1].longitude),
                Coordinate(latitude: madrid.coordinate.latitude, longitude: madrid.coordinate.longitude)),
            tolerance: 0.001))
        // La colección de entrada no se muta
        #expect(stations[1].distanceToUserLocation == nil)
    }

    @Test func sortStationsByProximityPutsNilLast() throws {
        var stations = try loadStations()
        stations[0].distanceToUserLocation = 0 // Madrid
        stations[1].distanceToUserLocation = 505 // Barcelona
        stations[2].distanceToUserLocation = nil // Girona
        stations[3].distanceToUserLocation = 67.5 // Toledo

        let sorted = sortStations(stations: stations, sortingMethod: .proximity)
        #expect(sorted[0].id == "1") // Madrid, distancia 0
        #expect(sorted[1].id == "4") // Toledo, 67.5 km
        #expect(Set(sorted.suffix(2).map(\.id)) == Set(["2", "3"])) // Barcelona y Girona (sin distancia) al final
    }

    @Test func sortStationsByFuelPricePutsNilLast() throws {
        let stations = try loadStations()

        // gasoline95E5: Bcn 1.50 < Madrid 1.60, Girona/Toledo sin precio
        let sorted95 = sortStations(stations: stations, sortingMethod: .fuelType(.gasoline95E5))
        #expect(sorted95[0].id == "2")
        #expect(sorted95[1].id == "1")
        #expect(Set(sorted95.suffix(2).map(\.id)) == Set(["3", "4"]))

        // gasoline98E5: Girona 1.70 < Madrid 1.80, Bcn/Toledo sin precio
        let sorted98 = sortStations(stations: stations, sortingMethod: .fuelType(.gasoline98E5))
        #expect(sorted98[0].id == "3")
        #expect(sorted98[1].id == "1")
        #expect(Set(sorted98.suffix(2).map(\.id)) == Set(["2", "4"]))
    }
}
