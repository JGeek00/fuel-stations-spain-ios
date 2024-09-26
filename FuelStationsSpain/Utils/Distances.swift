import Foundation
import CoreLocation

struct Coordinate {
    let latitude: Double
    let longitude: Double
}

func distanceBetweenCoordinates(_ coordinate1: Coordinate, _ coordinate2: Coordinate) -> Double {
    let earthRadius = 6371.0 // Earth's radius in kilometers
    
    let lat1 = coordinate1.latitude * Double.pi / 180.0
    let lon1 = coordinate1.longitude * Double.pi / 180.0
    let lat2 = coordinate2.latitude * Double.pi / 180.0
    let lon2 = coordinate2.longitude * Double.pi / 180.0
    
    let dLat = lat2 - lat1
    let dLon = lon2 - lon1
    
    let a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1) * cos(lat2) *
            sin(dLon / 2) * sin(dLon / 2)
    let c = 2 * atan2(sqrt(a), sqrt(1 - a))
    
    let distance = earthRadius * c
    
    return distance
}

func sortStationsByDistance(data: [FuelStation], lastLocation: CLLocation?) -> [StationWithDistance] {
    let dataWithDistances: [StationWithDistance] = data.map() { item in
        if item.latitude != nil && item.longitude != nil && lastLocation?.coordinate.latitude != nil && lastLocation?.coordinate.longitude != nil {
            let distance = distanceBetweenCoordinates(Coordinate(latitude: item.latitude!, longitude: item.longitude!), Coordinate(latitude: lastLocation!.coordinate.latitude, longitude: lastLocation!.coordinate.longitude))
            return StationWithDistance(station: item, distance: distance)
        }
        else {
            return StationWithDistance(station: item, distance: nil)
        }
    }.sorted { a, b in
        if a.distance != nil && b.distance != nil {
            return a.distance! < b.distance!
        }
        else if a.distance == nil && b.distance != nil {
            return true
        }
        else if a.distance != nil && b.distance == nil {
            return false
        }
        else {
            return false
        }
    }
    return dataWithDistances
}

func addDistancesToStations(stations: [FuelStation], lastLocation: CLLocation?) -> [FuelStation] {
    if let latitude = lastLocation?.coordinate.latitude, let longitude = lastLocation?.coordinate.longitude {
        return stations.map { item in
            if let stationLatitude = item.latitude, let stationLongitude = item.longitude {
                var itemCloned = item
                itemCloned.distanceToUserLocation = distanceBetweenCoordinates(Coordinate(latitude: stationLatitude, longitude: stationLongitude), Coordinate(latitude: latitude, longitude: longitude))
                return itemCloned
            }
            else {
                return item
            }
        }
    }
    else {
        return stations
    }
}

func sortStationsByDistance(_ stations: [FuelStation]) -> [FuelStation] {
    let sorted = stations.sorted { a, b in
        if a.distanceToUserLocation != nil && b.distanceToUserLocation != nil {
            return a.distanceToUserLocation! < b.distanceToUserLocation!
        }
        else if a.distanceToUserLocation == nil && b.distanceToUserLocation != nil {
            return true
        }
        else if a.distanceToUserLocation != nil && b.distanceToUserLocation == nil {
            return false
        }
        else {
            return false
        }
    }
    return sorted
}
