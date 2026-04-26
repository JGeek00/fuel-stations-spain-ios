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
        
        let favoriteFuelRaw = UserDefaults.shared.string(forKey: StorageKeys.favoriteFuel) ?? Defaults.favoriteFuel?.rawValue
        if let favoriteFuelRaw = favoriteFuelRaw {
            selectedFuel = Enums.FuelType(rawValue: favoriteFuelRaw) ?? .gasoilA
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
        
        let result = await ApiClient.fetchHistoricPrices(stationId: station.id, startDate: start, endDate: today)
        
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
                return data.compactMap { item -> ChartPoint? in
                    guard let dateString = item.date, let date = dateFormatter.date(from: dateString) else { return nil }
                    guard let price = item.price(for: selectedFuel) else { return nil }
                    let localDate = convertToLocalTime(date: date)
                    return ChartPoint(date: localDate, value: price)
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
