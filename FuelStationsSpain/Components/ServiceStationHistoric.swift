import SwiftUI
import Charts

struct ServiceStationHistoric: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
        _serviceStationHistoricViewModel = StateObject(wrappedValue: ServiceStationHistoricViewModel(station: station))
    }
    
    @StateObject private var serviceStationHistoricViewModel: ServiceStationHistoricViewModel
    
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
                if serviceStationHistoricViewModel.loading == true {
                    HStack {
                        ProgressView()
                    }
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                else if serviceStationHistoricViewModel.data != nil {
                    if !serviceStationHistoricViewModel.chartHasData {
                        ContentUnavailableView("No data available", systemImage: "fuelpump.slash.fill", description: Text("There is no data for the selected fuel."))
                            .transition(.opacity)
                    }
                    else {
                        ChartContent()
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
                await serviceStationHistoricViewModel.loadData()
            }
        }
        .onChange(of: serviceStationHistoricViewModel.selectedFuel) {
            serviceStationHistoricViewModel.generateChartData()
        }
        .onChange(of: serviceStationHistoricViewModel.selectedTime) {
            serviceStationHistoricViewModel.generateChartData()
        }
    }
    
    @ViewBuilder private func Filters() -> some View {
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
        .listRowInsets(.init())
        .disabled(serviceStationHistoricViewModel.loading)
    }
    
    @ViewBuilder func ChartContent() -> some View {
        VStack {
            if let first = serviceStationHistoricViewModel.chartData.first?.date, let last = serviceStationHistoricViewModel.chartData.last?.date {
                Group {
                    Text(first, format: .dateTime.weekday().day().month().year()) + Text(verbatim: " - ") + Text(last, format: .dateTime.weekday().day().month().year())
                }
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .center)
                .animation(.easeOut, value: serviceStationHistoricViewModel.chartData)
            }
            Chart {
                ForEach(serviceStationHistoricViewModel.chartData, id: \.self) { item in
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
            .chartOverlay { proxy in
                Color.clear
                    .onContinuousHover { phase in
                        switch phase {
                        case let .active(location):
                            serviceStationHistoricViewModel.selectedChartPoint = proxy.value(atX: location.x, as: String.self)
                        case .ended:
                            serviceStationHistoricViewModel.selectedChartPoint = nil
                        }
                    }
            }
            .chartYScale(domain: serviceStationHistoricViewModel.chartMinValue...serviceStationHistoricViewModel.chartMaxValue)
            .chartYAxisLabel(String(localized: "Price (€)"))
            .chartXAxis(Visibility.hidden)
            .animation(.easeOut, value: serviceStationHistoricViewModel.chartData)
            .frame(height: 350)
        }
    }
}
