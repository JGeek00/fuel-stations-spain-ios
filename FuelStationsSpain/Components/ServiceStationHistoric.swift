import SwiftUI
import Charts

fileprivate struct ChartPoint: Hashable {
    var date: String
    var value: Double
    
    init(date: String, value: Double) {
        self.date = date
        self.value = value
    }
}

struct ServiceStationHistoric: View {
    
    @EnvironmentObject private var serviceStationHistoricViewModel: ServiceStationHistoricViewModel
    
    private func getSelectedFuelData(data: [FuelStationHistoric], selectedFuel: Enums.FuelType) -> [ChartPoint] {
        switch selectedFuel {
        case .gasoilA:
            return data.filter() { $0.date != nil && $0.gasoil_a_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoil_a_price!) }
        case .gasoilB:
            return data.filter() { $0.date != nil && $0.gasoil_b_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoil_b_price!) }
        case .premiumGasoil:
            return data.filter() { $0.date != nil && $0.premium_gasoil_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.premium_gasoil_price!) }
        case .biodiesel:
            return data.filter() { $0.date != nil && $0.biodiesel_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.biodiesel_price!) }
        case .gasoline95E10:
            return data.filter() { $0.date != nil && $0.gasoline_95_e10_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoline_95_e10_price!) }
        case .gasoline95E5:
            return data.filter() { $0.date != nil && $0.gasoline_95_e5_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoline_95_e5_price!) }
        case .gasoline95E5Premium:
            return data.filter() { $0.date != nil && $0.gasoline_95_e5_premium_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoline_95_e5_premium_price!) }
        case .gasoline98E10:
            return data.filter() { $0.date != nil && $0.gasoline_98_e10_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoline_98_e10_price!) }
        case .gasoline98E5:
            return data.filter() { $0.date != nil && $0.gasoline_98_e5_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.gasoline_98_e5_price!) }
        case .bioethanol:
            return data.filter() { $0.date != nil && $0.bioethanol_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.bioethanol_price!) }
        case .cng:
            return data.filter() { $0.date != nil && $0.cng_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.cng_price!) }
        case .lng:
            return data.filter() { $0.date != nil && $0.lng_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.lng_price!) }
        case .lpg:
            return data.filter() { $0.date != nil && $0.lpg_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.lpg_price!) }
        case .hydrogen:
            return data.filter() { $0.date != nil && $0.hydrogen_price != nil }.map() { ChartPoint(date: $0.date!, value: $0.hydrogen_price!) }
        }
    }
    
    private func formatDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return nil
        }
    }
    
    @State private var chartData: [ChartPoint] = []
    @State private var chartMinValue: Double = 0.0
    @State private var chartMaxValue: Double = 0.0
    
    var body: some View {
        List {
            Section {
                Picker("Fuel", selection: $serviceStationHistoricViewModel.selectedFuel) {
                    Section("Gasoil") {
                        Text("A Gasoil")
                            .tag(Enums.FuelType.gasoilA)
                        Text("B Gasoil")
                            .tag(Enums.FuelType.gasoilB)
                        Text("Premium Gasoil")
                            .tag(Enums.FuelType.premiumGasoil)
                        Text("Biodiesel")
                            .tag(Enums.FuelType.biodiesel)
                    }
                    Section("Gasoline") {
                        Text("Gasoline 95 E5")
                            .tag(Enums.FuelType.gasoline95E5)
                        Text("Gasoline 95 E10")
                            .tag(Enums.FuelType.gasoline95E10)
                        Text("Gasoline 95 E5 Premium")
                            .tag(Enums.FuelType.gasoline95E5Premium)
                        Text("Gasoline 98 E5")
                            .tag(Enums.FuelType.gasoline98E5)
                        Text("Gasoline 98 E10")
                            .tag(Enums.FuelType.gasoline98E10)
                        Text("Bioethanol")
                            .tag(Enums.FuelType.bioethanol)
                    }
                    Section("Gas") {
                        Text("Compressed Natural Gas")
                            .tag(Enums.FuelType.cng)
                        Text("Liquefied Natural Gas")
                            .tag(Enums.FuelType.lng)
                        Text("Liquefied petroleum gases")
                            .tag(Enums.FuelType.lpg)
                    }
                    Section("Others") {
                        Text("Hydrogen")
                            .tag(Enums.FuelType.hydrogen)
                    }
                }
            }
            .disabled(serviceStationHistoricViewModel.loading)
            
            Section {
                Picker("Time", selection: $serviceStationHistoricViewModel.selectedTime) {
                    Text("1 week")
                        .tag(Enums.HistoricTime.week1)
                    Text("1 month")
                        .tag(Enums.HistoricTime.month1)
                    Text("3 months")
                        .tag(Enums.HistoricTime.month3)
                    Text("6 months")
                        .tag(Enums.HistoricTime.month6)
                    Text("1 year")
                        .tag(Enums.HistoricTime.year1)
                }
                .pickerStyle(.segmented)
            }
            .listRowBackground(Color.listBackground)
            .padding(.horizontal, -20)
            .disabled(serviceStationHistoricViewModel.loading)
            
            Section {
                if serviceStationHistoricViewModel.loading == true {
                    HStack {
                        ProgressView()
                    }
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                else if serviceStationHistoricViewModel.data != nil {
                    if chartData.isEmpty || chartData.count < 3 {
                        ContentUnavailableView("No data available", systemImage: "fuelpump.slash.fill", description: Text("There is no data for the selected fuel."))
                            .transition(.opacity)
                    }
                    else {
                        VStack {
                            Group {
                                let dateFormatter: DateFormatter = {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd"
                                    return dateFormatter
                                }()
                                if let startDate = dateFormatter.date(from: chartData[0].date), let endDate = dateFormatter.date(from: chartData[chartData.count-1].date) {
                                    Text(startDate, format: .dateTime.weekday().day().month().year()) + Text(verbatim: " - ") + Text(endDate, format: .dateTime.weekday().day().month().year())
                                }
                            }
                            .fontWeight(.semibold)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            Chart {
                                ForEach(chartData, id: \.self) { item in
                                    LineMark(
                                        x: .value(String(localized: "Date"), item.date),
                                        y: .value(String(localized: "Price (€)"), item.value)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    AreaMark(
                                        x: .value(String(localized: "Date"), item.date),
                                        y: .value(String(localized: "Price (€)"), item.value)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .blue.opacity(0.5),
                                                .blue.opacity(0.2),
                                                .blue.opacity(0.05)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                }
                            }
                            .chartYScale(domain: chartMinValue...chartMaxValue)
                            .chartYAxisLabel(String(localized: "Price (€)"))
                            .chartXAxis(Visibility.hidden)
                            .frame(height: 350)
                            .transition(.opacity)
                        }
                    }
                }
                else {
                    ContentUnavailableView("Cannot load price history", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the price history. Try again later."))
                        .transition(.opacity)
                }
            }
        }
        .navigationTitle("Price history")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await serviceStationHistoricViewModel.loadData()
            }
        }
        .onChange(of: serviceStationHistoricViewModel.selectedTime, initial: false) {
            Task {
                await serviceStationHistoricViewModel.loadData()
            }
        }
        .onChange(of: serviceStationHistoricViewModel.data, initial: true) {
            if let data = serviceStationHistoricViewModel.data {
                let values = getSelectedFuelData(data: data, selectedFuel: serviceStationHistoricViewModel.selectedFuel)
                chartData = values
                chartMaxValue = {
                    if let max = values.map({ $0.value }).max() {
                        return max + 0.1
                    }
                    return 0.0
                }()
                chartMinValue = {
                    if let max = values.map({ $0.value }).min() {
                        return max - 0.1
                    }
                    return 0.0
                }()
            }
        }
        .onChange(of: serviceStationHistoricViewModel.selectedFuel, initial: true) {
            if let data = serviceStationHistoricViewModel.data {
                let values = getSelectedFuelData(data: data, selectedFuel: serviceStationHistoricViewModel.selectedFuel)
                chartData = values
                chartMaxValue = {
                    if let max = values.map({ $0.value }).max() {
                        return max + 0.1
                    }
                    return 0.0
                }()
                chartMinValue = {
                    if let max = values.map({ $0.value }).min() {
                        return max - 0.1
                    }
                    return 0.0
                }()
            }
        }
    }
}
