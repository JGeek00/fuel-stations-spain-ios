import Foundation

func fetchAppStoreInfo() async -> StatusResponse<AppStoreInfoResult> {
    let result: StatusResponse<AppStoreInfoResult> = await httpRequest(
        url: "https://itunes.apple.com/lookup",
        queryParameters: [
            URLQueryItem(name: "bundleId", value: "com.jgeek00.FuelStationsSpain"),
        ]
    )
    return result
}

class ApiClient {
    static func fetchServiceStationsByLocation(lat: Double, long: Double, distance: Int) async -> StatusResponse<FuelStationsResult> {
        let result: StatusResponse<FuelStationsResult> = await httpRequest(
            url: "\(Config.apiBaseUrl)/service-stations",
            queryParameters: [
                URLQueryItem(name: "coordinates", value: "\(lat),\(long)"),
                URLQueryItem(name: "distance", value: String(distance))
            ]
        )
        return result
    }
    
    static func fetchServiceStationsById(stationIds: [String]) async -> StatusResponse<FuelStationsResult> {
        let result: StatusResponse<FuelStationsResult> = await httpRequest(
            url: "\(Config.apiBaseUrl)/service-stations",
            queryParameters: stationIds.map({ item in
                URLQueryItem(name: "id", value: item)
            })
        )
        return result
    }
    
    static func fetchMunicipalities() async -> StatusResponse<[Municipality]> {
        let result: StatusResponse<[Municipality]> = await httpRequest(
            url: "https://sedeaplicaciones.minetur.gob.es/ServiciosRESTCarburantes/PreciosCarburantes/Listados/Municipios"
        )
        return result
    }
    
    static func fetchServiceStationsByMunicipality(municipalityId: String) async -> StatusResponse<FuelStationsResult> {
        let result: StatusResponse<FuelStationsResult> = await httpRequest(
            url: "\(Config.apiBaseUrl)/service-stations",
            queryParameters: [
                URLQueryItem(name: "municipalityId", value: municipalityId)
            ]
        )
        return result
    }
    
    static func fetchHistoricPrices(stationId: String, startDate: Date, endDate: Date, includeCurrentPrices: Bool = false) async -> StatusResponse<[HistoricPrice]> {
        let result: StatusResponse<[HistoricPrice]> = await httpRequest(
            url: "\(Config.apiBaseUrl)/historic-prices",
            queryParameters: [
                URLQueryItem(name: "id", value: stationId),
                URLQueryItem(name: "startDate", value: getSQLDateFormat(startDate)),
                URLQueryItem(name: "endDate", value: getSQLDateFormat(endDate)),
                URLQueryItem(name: "includeCurrentPrices", value: includeCurrentPrices == true ? "true" : "false"),
            ]
        )
        return result
    }
}
