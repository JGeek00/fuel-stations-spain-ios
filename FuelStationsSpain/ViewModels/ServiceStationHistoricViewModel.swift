import Foundation
import SwiftUI

@MainActor
class ServiceStationHistoricViewModel: ObservableObject {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
        
        let favoriteFuel = UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) ?? Defaults.favoriteFuel.rawValue
        if favoriteFuel != Enums.FavoriteFuelType.none.rawValue {
            selectedFuel = Enums.FuelType(rawValue: favoriteFuel) ?? .gasoilA
        }
    }
    
    @Published var data: [FuelStationHistoric]? = nil
    @Published var loading = true
    @Published var error: Enums.ApiErrorReason? = nil
    
    @Published var selectedFuel: Enums.FuelType = .gasoilA
    @Published var selectedTime: Enums.HistoricTime = .week1
    
    func loadData() async {
        self.loading = true
        
        let dates: [Date] = {
            let today = Date()
            switch selectedTime {
            case .week1:
                let start = Calendar.current.date(byAdding: .day, value: -7, to: today)!
                return [start, today]
            case .month1:
                let start = Calendar.current.date(byAdding: .month, value: -1, to: today)!
                return [start, today]
            case .month3:
                let start = Calendar.current.date(byAdding: .month, value: -3, to: today)!
                return [start, today]
            case .month6:
                let start = Calendar.current.date(byAdding: .month, value: -6, to: today)!
                return [start, today]
            case .year1:
                let start = Calendar.current.date(byAdding: .year, value: -1, to: today)!
                return [start, today]
            }
        }()
        
        let result = await ApiClient.fetchServiceStationHistoric(stationId: station.id!, startDate: dates[0], endDate: dates[1])
        
        DispatchQueue.main.async {
            withAnimation(.default) {
                if result.successful == true {
                    self.data = result.data
                    self.loading = false
                    self.error = nil
                }
                else {
                    self.data = nil
                    self.loading = false
                    self.error = .connection
                }
            }
        }
    }
}
