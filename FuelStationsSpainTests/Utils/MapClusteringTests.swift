import CoreLocation
import Foundation
import Testing
@testable import FuelStationsSpain

@Suite struct MapClusteringTests {
    private func makeStation(id: String, lat: Double, lon: Double) -> FuelStation {
        let json = """
        {"id":"\(id)","postalCode":"28001","address":"Calle Falsa 123","openingHours":"L-D: 24h",\
        "latitude":\(lat),"longitude":\(lon),"locality":"Madrid","signage":"REPSOL",\
        "percBioEthanol":"","percMethylEster":"","municipalityId":1,"provinceId":1,"regionId":1}
        """
        return try! JSONDecoder().decode(FuelStation.self, from: Data(json.utf8))
    }

    @Test func emptyInputReturnsEmptyClusters() {
        #expect(clusterStations([], latitudeDelta: 0.3).isEmpty)
    }

    @Test func farApartStationsStaySingleWhenZoomedOut() {
        let stations = [
            makeStation(id: "mad", lat: 40.4168, lon: -3.7038),
            makeStation(id: "bcn", lat: 41.3874, lon: 2.1691)
        ]
        let clusters = clusterStations(stations, latitudeDelta: 0.3)
        #expect(clusters.count == 2)
        #expect(clusters.allSatisfy { $0.count == 1 })
    }

    @Test func nearbyStationsClusterWhenZoomedOut() {
        let stations = [
            makeStation(id: "a", lat: 40.4168, lon: -3.7038),
            makeStation(id: "b", lat: 40.4177, lon: -3.7029),
            makeStation(id: "c", lat: 40.4159, lon: -3.7047)
        ]
        let clusters = clusterStations(stations, latitudeDelta: 0.3)
        #expect(clusters.count == 1)
        #expect(clusters.first?.count == 3)
        let centroid = clusters.first!.coordinate
        #expect(abs(centroid.latitude - (40.4168 + 40.4177 + 40.4159) / 3) < 0.000001)
        #expect(abs(centroid.longitude - (-3.7038 + -3.7029 + -3.7047) / 3) < 0.000001)
    }

    @Test func sameStationsSplitWhenZoomedIn() {
        let stations = [
            makeStation(id: "a", lat: 40.4168, lon: -3.7038),
            makeStation(id: "b", lat: 40.4188, lon: -3.7018),
            makeStation(id: "c", lat: 40.4148, lon: -3.7058)
        ]
        let clusters = clusterStations(stations, latitudeDelta: 0.005)
        #expect(clusters.count == 3)
        #expect(clusters.allSatisfy { $0.count == 1 })
    }

    @Test func singleStationClusterKeepsStationIdAndCoordinate() {
        let station = makeStation(id: "solo", lat: 40.4168, lon: -3.7038)
        let clusters = clusterStations([station], latitudeDelta: 0.3)
        #expect(clusters.count == 1)
        #expect(clusters.first?.id == "solo")
        #expect(clusters.first?.singleStation == station)
        #expect(clusters.first?.coordinate.latitude == 40.4168)
        #expect(clusters.first?.coordinate.longitude == -3.7038)
    }
}
