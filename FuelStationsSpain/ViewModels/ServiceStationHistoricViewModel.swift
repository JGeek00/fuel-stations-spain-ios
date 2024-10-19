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
class HistoricPricesViewModel: ObservableObject {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
        
        let favoriteFuel = UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) ?? Defaults.favoriteFuel.rawValue
        if favoriteFuel != Enums.FavoriteFuelType.none.rawValue {
            selectedFuel = Enums.FuelType(rawValue: favoriteFuel) ?? .gasoilA
        }
    }
    
    @Published var data: [HistoricPrice]? = nil
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
        
        let result = await ApiClient.fetchHistoricPrices(stationId: station.id!, startDate: start, endDate: today)
        
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
                    return data.filter() { $0.date != nil && $0.gasoilAPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoilAPrice!) }
                case .gasoilB:
                    return data.filter() { $0.date != nil && $0.gasoilBPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoilBPrice!) }
                case .premiumGasoil:
                    return data.filter() { $0.date != nil && $0.premiumGasoilPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.premiumGasoilPrice!) }
                case .biodiesel:
                    return data.filter() { $0.date != nil && $0.biodieselPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.biodieselPrice!) }
                case .gasoline95E10:
                    return data.filter() { $0.date != nil && $0.gasoline95E10Price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline95E10Price!) }
                case .gasoline95E5:
                    return data.filter() { $0.date != nil && $0.gasoline95E5Price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline95E5Price!) }
                case .gasoline95E5Premium:
                    return data.filter() { $0.date != nil && $0.gasoline95E5PremiumPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline95E5PremiumPrice!) }
                case .gasoline98E10:
                    return data.filter() { $0.date != nil && $0.gasoline98E10Price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline98E10Price!) }
                case .gasoline98E5:
                    return data.filter() { $0.date != nil && $0.gasoline98E5Price != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.gasoline98E5Price!) }
                case .bioethanol:
                    return data.filter() { $0.date != nil && $0.bioethanolPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.bioethanolPrice!) }
                case .cng:
                    return data.filter() { $0.date != nil && $0.cngPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.cngPrice!) }
                case .lng:
                    return data.filter() { $0.date != nil && $0.lngPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.lngPrice!) }
                case .lpg:
                    return data.filter() { $0.date != nil && $0.lpgPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.lpgPrice!) }
                case .hydrogen:
                    return data.filter() { $0.date != nil && $0.hydrogenPrice != nil }.map() { ChartPoint(date: convertToLocalTime(date: dateFormatter.date(from: $0.date!)!), value: $0.hydrogenPrice!) }
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
