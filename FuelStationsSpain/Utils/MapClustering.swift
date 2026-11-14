import CoreLocation
import Foundation

struct StationCluster: Identifiable, Hashable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let stations: [FuelStation]

    var count: Int { stations.count }
    var singleStation: FuelStation? { stations.count == 1 ? stations.first : nil }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: StationCluster, rhs: StationCluster) -> Bool { lhs.id == rhs.id }
}

func clusterStations(_ stations: [FuelStation], latitudeDelta: Double) -> [StationCluster] {
    guard !stations.isEmpty else { return [] }

    let cellSize = max(latitudeDelta / 8, 0.0005)
    var buckets: [String: [FuelStation]] = [:]
    var order: [String] = []
    for station in stations {
        let key = "\(Int(floor(station.latitude / cellSize))):\(Int(floor(station.longitude / cellSize)))"
        if buckets[key] == nil { order.append(key) }
        buckets[key, default: []].append(station)
    }

    return order.compactMap { key in
        guard let group = buckets[key], !group.isEmpty else { return nil }
        let latitude = group.reduce(0.0) { $0 + $1.latitude } / Double(group.count)
        let longitude = group.reduce(0.0) { $0 + $1.longitude } / Double(group.count)
        return StationCluster(
            id: group.count == 1 ? group[0].id : "cluster-\(key)",
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            stations: group
        )
    }
}
