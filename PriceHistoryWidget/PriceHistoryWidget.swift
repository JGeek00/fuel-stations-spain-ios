import WidgetKit
import Charts
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PriceHistoryWidgetEntry {
        PriceHistoryWidgetEntry(date: Date(), configuration: ConfigurationAppIntent(), data: mockData)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> PriceHistoryWidgetEntry {
        PriceHistoryWidgetEntry(date: Date(), configuration: configuration, data: mockData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<PriceHistoryWidgetEntry> {
        let nilEntry = PriceHistoryWidgetEntry(date: Date(), configuration: configuration, data: nil)
        
        let nextUpdate = Calendar.current.date(
            byAdding: DateComponents(minute: 30),
            to: Date()
        )!
        
        guard let selectedStationId = configuration.serviceStation?.id else { return
            Timeline(entries: [nilEntry], policy: .after(nextUpdate))
        }
        
        let currentDate = convertToLocalTime(date: Date())
       
        var calendar = Calendar.current
        let timeZone = TimeZone.current
        calendar.timeZone = timeZone
        
        let startDate = calendar.date(byAdding: .day, value: -7, to: currentDate)!
        var startDateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        startDateComponents.hour = 0
        startDateComponents.minute = 0
        startDateComponents.second = 0
        let zeroedStartDate = calendar.date(from: startDateComponents)!
        let startDateLocal = convertToLocalTime(date: zeroedStartDate)
        
        let nowLocal = convertToLocalTime(date: .now)

        let result = await ApiClient.fetchHistoricPrices(stationId: selectedStationId, startDate: startDateLocal, endDate: nowLocal, includeCurrentPrices: true)
                
        guard let data = result.data else { return
            Timeline(entries: [nilEntry], policy: .after(nextUpdate))
        }
       
        let entry = PriceHistoryWidgetEntry(date: Date(), configuration: configuration, data: data)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct PriceHistoryWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let data: [HistoricPrice]?
}


struct PriceHistoryWidgetEntryView : View {
    var entry: Provider.Entry
    
    func getSelectedFuelValues(station: [HistoricPrice], fuelKey: String) -> [Double]? {
        let fuel = Enums.FuelType(rawValue: fuelKey)
        switch fuel {
        case .gasoilA:
            return (station.map() { $0.gasoilAPrice }.filter({ $0 != nil })) as? [Double]
        case .gasoilB:
            return (station.map() { $0.gasoilBPrice }.filter({ $0 != nil })) as? [Double]
        case .premiumGasoil:
            return (station.map() { $0.premiumGasoilPrice }.filter({ $0 != nil })) as? [Double]
        case .biodiesel:
            return (station.map() { $0.biodieselPrice }.filter({ $0 != nil })) as? [Double]
        case .gasoline95E10:
            return (station.map() { $0.gasoline95E10Price }.filter({ $0 != nil })) as? [Double]
        case .gasoline95E5:
            return (station.map() { $0.gasoline95E5Price }.filter({ $0 != nil })) as? [Double]
        case .gasoline95E5Premium:
            return (station.map() { $0.gasoline95E5PremiumPrice }.filter({ $0 != nil })) as? [Double]
        case .gasoline98E10:
            return (station.map() { $0.gasoline98E10Price }.filter({ $0 != nil })) as? [Double]
        case .gasoline98E5:
            return (station.map() { $0.gasoline98E5Price }.filter({ $0 != nil })) as? [Double]
        case .bioethanol:
            return (station.map() { $0.bioethanolPrice }.filter({ $0 != nil })) as? [Double]
        case .cng:
            return (station.map() { $0.cngPrice }.filter({ $0 != nil })) as? [Double]
        case .lng:
            return (station.map() { $0.lngPrice }.filter({ $0 != nil })) as? [Double]
        case .lpg:
            return (station.map() { $0.lpgPrice }.filter({ $0 != nil })) as? [Double]
        case .hydrogen:
            return (station.map() { $0.hydrogenPrice }.filter({ $0 != nil })) as? [Double]
        case .none:
            return nil
        }
    }
 
    var body: some View {
        if entry.configuration.serviceStation != nil, let selectedFuel = entry.configuration.selectedFuel {
            if let data = entry.data, let lastData = data.last {
                if let values = getSelectedFuelValues(station: data, fuelKey: selectedFuel.value), let todayPrice = values.last, let firstPrice = values.first, let minValue = values.min(), let maxValue = values.max()  {
                    let alias = getFavoriteAlias(favoriteId: lastData.stationId!)
                    let difference = todayPrice - firstPrice
                    let percDifference = difference / firstPrice * 100
                    let color: Color = {
                        if difference == 0 {
                            return Color.gray
                        }
                        else if difference > 0 {
                            return Color.red
                        }
                        else {
                            return Color.green
                        }
                    }()
                    let triangle = {
                        if difference == 0 {
                            return "equal"
                        }
                        else if difference > 0 {
                            return "arrowtriangle.up.fill"
                        }
                        else {
                            return "arrowtriangle.down.fill"
                        }
                    }()
                    
                    GeometryReader { proxy in
                        VStack(alignment: .leading) {
                            HStack {
                                Group {
                                    if let alias = alias, !alias.isEmpty {
                                        Text(verbatim: alias)
                                    }
                                    else {
                                        Text(verbatim: lastData.stationSignage!.capitalized)
                                    }
                                }
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                                .lineLimit(2)
                                .truncationMode(.tail)
                                
                                Spacer()
                                
                                Group {
                                    Image(systemName: triangle)
                                        .font(.system(size: 14))
                                        .foregroundStyle(color)
                                    Spacer()
                                        .frame(width: 8)
                                    VStack(alignment: .leading) {
                                        HStack {
                                            Text(verbatim: "\(formattedNumber(value: difference, digits: 3)) €")
                                            Spacer()
                                                .frame(width: 4)
                                            Text(verbatim: "(\(formattedNumber(value: percDifference, digits: 1)) %)")
                                        }
                                        .font(.system(size: 10))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(color)
                                        Spacer()
                                            .frame(height: 2)
                                        Text("compared to last week")
                                            .font(.system(size: 8))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                            }
                            
                            Spacer()
                                .frame(height: 12)
                            
                            HStack(alignment: .bottom) {
                                VStack(alignment: .leading) {
                                    Text(verbatim: selectedFuel.label)
                                        .font(.system(size: 14))
                                        .lineLimit(2)
                                        .truncationMode(.tail)
                                    Spacer()
                                        .frame(height: 6)
                                    HStack(alignment: .bottom) {
                                        Text(verbatim: "\(formattedNumber(value: todayPrice, digits: 3)) €")
                                            .font(.system(size: 18))
                                            .fontWeight(.bold)
                                            .lineLimit(1)
                                    }
                                }
                                .frame(maxWidth: proxy.size.width * 0.3, alignment: .leading)
                                
                                Spacer()
                                    .frame(width: 12)

                                let chartArray = Array(zip(values.indices, values))
                                let visible = (maxValue + 0.05) - (minValue - 0.05)
                                Chart(chartArray, id: \.1) { index, item in
                                    LineMark(
                                        x: .value(String(localized: "Date"), index),
                                        y: .value(String(localized: "Price (€)"), item)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    AreaMark(
                                        x: .value(String(localized: "Date"), index),
                                        y: .value(String(localized: "Price (€)"), item)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                .blue.opacity(0.5),
                                                .blue.opacity(0),
                                            ],
                                            startPoint: .init(x: 0, y: 0),
                                            endPoint: .init(x: 0, y: ((maxValue + 0.05) - (minValue - 0.05))/2)
                                        )
                                    )
                                    .interpolationMethod(.catmullRom)
                                }
                                .chartYScale(domain: (minValue - 0.05)...(maxValue + 0.05))
                                .chartXAxis(Visibility.hidden)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fontDesign(.rounded)
                    }
                }
                else {
                    VStack(alignment: .center) {
                        Text(verbatim: lastData.stationSignage!.capitalized)
                            .fontWeight(.semibold)
                            .font(.system(size: 18))
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Image(systemName: "fuelpump.slash.fill")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        Spacer()
                            .frame(height: 8)
                        Text("There is no price information for the fuel \(selectedFuel.label).")
                            .font(.system(size: 12))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            else {
                VStack(alignment: .center) {
                    Spacer()
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 8)
                    Text("An error occured when loading the data for the widget.")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
        }
        else {
            VStack {
                Text("Press and hold the widget, and tap on edit to choose the necessary parameters.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                    .fontWeight(.medium)
                Spacer()
                    .frame(height: 8)
                Text("You must have at least one service station on favorites to use this widget.")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 10))
                    .foregroundStyle(Color.gray)
            }
        }
    }
}

struct PriceHistoryWidget: Widget {
    let kind: String = "PriceHistoryWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PriceHistoryWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var noSelection: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        return intent
    }
    fileprivate static var aGasoil: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        let fuel = FuelType.fuelTypes.first!
        intent.serviceStation = ServiceStation(id: "1", label: "FUEL STATION")
        intent.selectedFuel = FuelType(id: fuel.id, value: fuel.value, label: fuel.label)
        return intent
    }
    fileprivate static var gasoline95E5: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        let fuel = FuelType.fuelTypes[4]
        intent.serviceStation = ServiceStation(id: "1", label: "FUEL STATION")
        intent.selectedFuel = FuelType(id: fuel.id, value: fuel.value, label: fuel.label)
        return intent
    }
    fileprivate static var premiumGasoil: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        let fuel = FuelType.fuelTypes[2]
        intent.serviceStation = ServiceStation(id: "1", label: "FUEL STATION")
        intent.selectedFuel = FuelType(id: fuel.id, value: fuel.value, label: fuel.label)
        return intent
    }
}

#Preview(as: .systemMedium) {
    PriceHistoryWidget()
} timeline: {
    PriceHistoryWidgetEntry(date: .now, configuration: .noSelection, data: mockData)
    PriceHistoryWidgetEntry(date: .now, configuration: .aGasoil, data: mockData)
    PriceHistoryWidgetEntry(date: .now, configuration: .gasoline95E5, data: mockData)
    PriceHistoryWidgetEntry(date: .now, configuration: .premiumGasoil, data: mockData)
}
