import Foundation
import SwiftUI

struct ChartPoint: Hashable {
    var date: Date
    var value: Double
    
    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

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
    
    @Published var chartData: [ChartPoint] = []
    @Published var chartMinValue: Double = 0.0
    @Published var chartMaxValue: Double = 0.0
    @Published var chartHasData = false
    @Published var selectedChartPoint: String?
    
    func loadData() async {
        self.loading = true

        let today = Date()
        let start = Calendar.current.date(byAdding: .year, value: -1, to: today)!
        
        let result = await ApiClient.fetchServiceStationHistoric(stationId: station.id!, startDate: start, endDate: today)
        
        DispatchQueue.main.async {
            withAnimation(.default) {
                if result.successful == true {
                    self.data = result.data
                    self.error = nil

                    self.generateChartData()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.default) {
                            self.loading = false
                        }
                    }
                }
                else {
                    self.data = nil
                    self.loading = false
                    self.error = .connection
                }
            }
        }
    }
    
    func generateChartData() {
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter
        }()
        
        if let data = self.data {
            let filteredFuel: [ChartPoint] = {
                switch selectedFuel {
                case .gasoilA:
                    return data.filter() { $0.date != nil && $0.gasoil_a_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoil_a_price!) }
                case .gasoilB:
                    return data.filter() { $0.date != nil && $0.gasoil_b_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoil_b_price!) }
                case .premiumGasoil:
                    return data.filter() { $0.date != nil && $0.premium_gasoil_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.premium_gasoil_price!) }
                case .biodiesel:
                    return data.filter() { $0.date != nil && $0.biodiesel_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.biodiesel_price!) }
                case .gasoline95E10:
                    return data.filter() { $0.date != nil && $0.gasoline_95_e10_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline_95_e10_price!) }
                case .gasoline95E5:
                    return data.filter() { $0.date != nil && $0.gasoline_95_e5_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline_95_e5_price!) }
                case .gasoline95E5Premium:
                    return data.filter() { $0.date != nil && $0.gasoline_95_e5_premium_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline_95_e5_premium_price!) }
                case .gasoline98E10:
                    return data.filter() { $0.date != nil && $0.gasoline_98_e10_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline_98_e10_price!) }
                case .gasoline98E5:
                    return data.filter() { $0.date != nil && $0.gasoline_98_e5_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline_98_e5_price!) }
                case .bioethanol:
                    return data.filter() { $0.date != nil && $0.bioethanol_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.bioethanol_price!) }
                case .cng:
                    return data.filter() { $0.date != nil && $0.cng_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.cng_price!) }
                case .lng:
                    return data.filter() { $0.date != nil && $0.lng_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.lng_price!) }
                case .lpg:
                    return data.filter() { $0.date != nil && $0.lpg_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.lpg_price!) }
                case .hydrogen:
                    return data.filter() { $0.date != nil && $0.hydrogen_price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.hydrogen_price!) }
                }
            }()
            
            let dates: [Date] = {
                func convertDate(_ date: Date) -> Date {
                    var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
                    dateComponents.hour = 0
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    let zeroedDate = calendar.date(from: dateComponents)!
                    let localDate = convertToLocalTime(date: zeroedDate)
                    return localDate
                }
                
                let currentDate = Date()
                let timeZone = TimeZone.current
                var calendar = Calendar.current
                calendar.timeZone = timeZone
                
                let localCurrentDate = convertToLocalTime(date: currentDate)
                
                switch selectedTime {
                case .week1:
                    let startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate)!
                    let convertedDate = convertDate(startDate)
                    return [convertedDate, localCurrentDate]
                case .month1:
                    let startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                    let convertedDate = convertDate(startDate)
                    return [convertedDate, localCurrentDate]
                case .month3:
                    let startDate = calendar.date(byAdding: .month, value: -3, to: currentDate)!
                    let convertedDate = convertDate(startDate)
                    return [convertedDate, localCurrentDate]
                case .month6:
                    let startDate = calendar.date(byAdding: .month, value: -6, to: currentDate)!
                    let convertedDate = convertDate(startDate)
                    return [convertedDate, localCurrentDate]
                case .year1:
                    let startDate = calendar.date(byAdding: .year, value: -1, to: currentDate)!
                    let convertedDate = convertDate(startDate)
                    return [convertedDate, localCurrentDate]
                }
            }()

            let filtered = filteredFuel.filter() { $0.date >= dates.first! && $0.date <= dates.last! }
            chartData = filtered
            chartMaxValue = {
                if let max = filtered.map({ $0.value }).max() {
                    return max + 0.1
                }
                return 0.0
            }()
            chartMinValue = {
                if let max = filtered.map({ $0.value }).min() {
                    return max - 0.1
                }
                return 0.0
            }()
            withAnimation(.default) {
                chartHasData = !filtered.isEmpty && filtered.count > 2
            }
        }
    }
}
