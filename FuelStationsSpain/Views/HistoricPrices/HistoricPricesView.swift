import SwiftUI
import Charts

struct HistoricPricesView: View {
    var station: FuelStation
    var showingInSheet: Bool
    
    init(station: FuelStation, showingInSheet: Bool) {
        self.station = station
        _historicPricesViewModel = StateObject(wrappedValue: HistoricPricesViewModel(station: station))
        self.showingInSheet = showingInSheet
    }
    
    @StateObject private var historicPricesViewModel: HistoricPricesViewModel
    
    private func formatDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: dateString) {
            return date
        } else {
            return nil
        }
    }
    
    var body: some View {
        List {
            Filters()
            
            Section {
                if historicPricesViewModel.loading == true {
                    HStack {
                        ProgressView()
                    }
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                else if historicPricesViewModel.data != nil {
                    if !historicPricesViewModel.chartHasData {
                        ContentUnavailableView("No data available", systemImage: "fuelpump.slash.fill", description: Text("There is no data for the selected fuel."))
                            .transition(.opacity)
                    }
                    else {
                        ChartContent(chartData: historicPricesViewModel.chartData, chartMinValue: historicPricesViewModel.chartMinValue, chartMaxValue: historicPricesViewModel.chartMaxValue, selectedTime: historicPricesViewModel.selectedTime)
                            .transition(.opacity)
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
                await historicPricesViewModel.loadData()
            }
        }
        .onChange(of: historicPricesViewModel.selectedFuel) {
            historicPricesViewModel.generateChartData()
        }
        .onChange(of: historicPricesViewModel.selectedTime) {
            historicPricesViewModel.generateChartData()
        }
    }
    
    @ViewBuilder private func Filters() -> some View {
        Section {
            Picker("Fuel", selection: $historicPricesViewModel.selectedFuel) {
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
        .disabled(historicPricesViewModel.loading)
        
        Section {
            Picker("Time", selection: $historicPricesViewModel.selectedTime) {
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
        .listRowBackground(showingInSheet ? Color.sheetListBackground : Color.listBackground)
        .listRowInsets(.init())
        .disabled(historicPricesViewModel.loading)
    }
}

fileprivate struct ChartContent: View {
    var chartData: [ChartPoint]
    var chartMinValue: Double
    var chartMaxValue: Double
    var selectedTime: Enums.HistoricTime
    
    init(chartData: [ChartPoint], chartMinValue: Double, chartMaxValue: Double, selectedTime: Enums.HistoricTime) {
        self.chartData = chartData
        self.chartMinValue = chartMinValue
        self.chartMaxValue = chartMaxValue
        self.selectedTime = selectedTime
    }
    
    @AppStorage(StorageKeys.chartAnnotationMode, store: UserDefaults.shared) private var chartAnnotationMode = Defaults.chartAnnotationMode
    
    @State private var selectedIndex: Int?
    @State private var lastSelectedIndex: Int?
    @State private var showChartAnnotation = false
    
    var body: some View {
        VStack {
            Group {
                if chartAnnotationMode == .outsideChart, showChartAnnotation == true {
                    if let lastSelectedIndex, lastSelectedIndex >= 0 && lastSelectedIndex < chartData.count {
                        let markValue = chartData[lastSelectedIndex]
                        HStack {
                            Text(markValue.date, format: .dateTime.weekday().day().month().year())
                            Spacer()
                            Text(verbatim: "\(formattedNumber(value: markValue.value, digits: 3)) €")
                        }
                        .fontSize(14)
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                        .transition(.opacity)
                    }
                }
                else {
                    if let first = chartData.first?.date, let last = chartData.last?.date {
                        Group {
                            Text(first, format: .dateTime.weekday().day().month().year()) + Text(verbatim: " - ") + Text(last, format: .dateTime.weekday().day().month().year())
                        }
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .animation(.easeOut, value: chartData)
                        .transition(.opacity)
                    }
                }
            }
            .frameDynamicSize(height: 40)

            let chartArray = Array(zip(chartData.indices, chartData))
            Chart(chartArray, id: \.1) { index, item in
                LineMark(
                    x: .value(String(localized: "Date"), index),
                    y: .value(String(localized: "Price (€)"), item.value)
                )
                .interpolationMethod(.linear)
                AreaMark(
                    x: .value(String(localized: "Date"), index),
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
                .interpolationMethod(.linear)
                if let selectedIndex, selectedIndex >= 0 && selectedIndex < chartData.count {
                    let markValue = chartData[selectedIndex]
                    if chartAnnotationMode == .tooltip {
                        RuleMark(x: .value("Date", selectedIndex))
                            .lineStyle(.init(dash: [2, 2]))
                            .cornerRadius(8)
                            .offset(x: 0, y: 12)
                            .annotation(position: .automatic, overflowResolution: .init(x: .fit(to: .plot), y: .fit(to: .plot))) {
                                VStack {
                                    Text(markValue.date, format: .dateTime.weekday().day().month().year())
                                    Spacer()
                                        .frame(height: 4)
                                    Text(verbatim: "\(formattedNumber(value: markValue.value, digits: 3)) €")
                                }
                                .fontSize(14)
                                .fontWeight(.semibold)
                                .padding(8)
                                .background(Color.chartAnnotation)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                    }
                    else {
                        RuleMark(x: .value("Date", selectedIndex))
                            .lineStyle(.init(dash: [2, 2]))
                            .cornerRadius(8)
                            .offset(x: 0, y: 12)
                    }
                }
            }
            .chartXSelection(value: $selectedIndex)
            .chartYScale(domain: chartMinValue...chartMaxValue)
            .chartYAxisLabel(String(localized: "Price (€)"))
            .chartXAxis(Visibility.hidden)
            .animation(.easeOut, value: chartData)
            .frame(height: 350)
        }
        .onChange(of: selectedIndex) {
            withAnimation(.easeOut(duration: 0.2)) {
                showChartAnnotation = selectedIndex != nil
            }
            if let selectedIndex = selectedIndex {
                lastSelectedIndex = selectedIndex
            }
        }
    }
}


#Preview {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    NavigationStack {
        HistoricPricesView(station: station, showingInSheet: false)
    }
}
