import Foundation

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
