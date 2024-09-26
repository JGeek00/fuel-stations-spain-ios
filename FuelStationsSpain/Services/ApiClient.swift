import Foundation

class ApiClient {
    static func fetchServiceStationsByLocation(lat: Double, long: Double, distance: Int) async -> StatusResponse<FuelStationsResult> {
        let result: StatusResponse<FuelStationsResult> = await httpRequest(
            url: "https://fuelapi.jgeek00.com/service-stations",
            queryParameters: [
                URLQueryItem(name: "coordinates", value: "\(lat),\(long)"),
                URLQueryItem(name: "distance", value: String(distance))
            ]
        )
        return result
    }
    
    static func fetchServiceStationsById(stationIds: [String]) async -> StatusResponse<FuelStationsResult> {
        let result: StatusResponse<FuelStationsResult> = await httpRequest(
            url: "https://fuelapi.jgeek00.com/service-stations",
            queryParameters: stationIds.map({ item in
                URLQueryItem(name: "id", value: item)
            })
        )
        return result
    }
}
