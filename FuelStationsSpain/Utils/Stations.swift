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

func sortStations(stations: [FuelStation], sortingMethod: Enums.SortingOptions) -> [FuelStation] {
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
        case .aGasoil:
            return sort(a.gasoilAPrice, b.gasoilAPrice)
        case .bGasoil:
            return sort(a.gasoilBPrice, b.gasoilBPrice)
        case .premiumGasoil:
            return sort(a.premiumGasoilPrice, b.premiumGasoilPrice)
        case .biodiesel:
            return sort(a.biodieselPrice, b.biodieselPrice)
        case .gasoline95E10:
            return sort(a.gasoline95E10Price, b.gasoline95E10Price)
        case .gasoline95E5:
            return sort(a.gasoline95E5Price, b.gasoline95E5Price)
        case .gasoline95E5Premium:
            return sort(a.gasoline95E5PremiumPrice, b.gasoline95E5PremiumPrice)
        case .gasoline98E10:
            return sort(a.gasoline98E10Price, b.gasoline98E10Price)
        case .gasoline98E5:
            return sort(a.gasoline98E5Price, b.gasoline98E5Price)
        case .bioethanol:
            return sort(a.bioethanolPrice, b.bioethanolPrice)
        case .cng:
            return sort(a.cngPrice, b.cngPrice)
        case .lng:
            return sort(a.lngPrice, b.lngPrice)
        case .lpg:
            return sort(a.lpgPrice, b.lpgPrice)
        case .hydrogen:
            return sort(a.hydrogenPrice, b.hydrogenPrice)
        }
    }
    return sorted
}
