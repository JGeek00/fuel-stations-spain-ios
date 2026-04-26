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

func addDistancesToStations(stations: [FuelStation], lastLocation: CLLocation?) -> [FuelStation] {
    if let latitude = lastLocation?.coordinate.latitude, let longitude = lastLocation?.coordinate.longitude {
        return stations.map { item in
            var itemCloned = item
            itemCloned.distanceToUserLocation = distanceBetweenCoordinates(Coordinate(latitude: item.latitude, longitude: item.longitude), Coordinate(latitude: latitude, longitude: longitude))
            return itemCloned
        }
    }
    else {
        return stations
    }
}

func sortStations(stations: [FuelStation], sortingMethod: Enums.StationsSortingOptions) -> [FuelStation] {
    func sort(_ a: Double?, _ b: Double?) -> Bool {
        if a != nil && b != nil {
            return a! < b!
        }
        else if a == nil && b != nil {
            return false
        }
        else if a != nil && b == nil {
            return true
        }
        else {
            return true
        }
    }
    
    let sorted = stations.sorted { a, b in
        switch sortingMethod {
        case .proximity:
            return sort(a.distanceToUserLocation, b.distanceToUserLocation)
        case .fuelType(let fuel):
            let aVal: Double? = FuelStation.getObjectProperty(station: a, propertyName: "\(fuel.rawValue)Price")
            let bVal: Double? = FuelStation.getObjectProperty(station: b, propertyName: "\(fuel.rawValue)Price")
            return sort(aVal, bVal)
        }
    }
    return sorted
}

func sortingText(sortingMethod: Enums.StationsSortingOptions) -> String {
    func fuelName() -> String {
        switch sortingMethod {
        case .proximity:
            return String("")
        case .fuelType(let fuel):
            // Map FuelType raw values to localized display strings by searching fuelList
            for section in fuelList {
                if let item = section.types.first(where: { $0.type == fuel }) {
                    return item.name
                }
            }
            return fuel.rawValue
        }
    }
    if sortingMethod == .proximity {
        return String(localized: "Sorted by proximity")
    }
    else {
        return String(localized: "Sorted by \(fuelName()) price")
    }
}
