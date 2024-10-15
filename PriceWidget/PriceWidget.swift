import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> StationWidget {
        StationWidget(date: Date(), configuration: ConfigurationAppIntent(), data: mockData)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> StationWidget {
        StationWidget(date: Date(), configuration: configuration, data: mockData)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<StationWidget> {
        let nilEntry = StationWidget(date: Date(), configuration: configuration, data: nil)
        
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
        
        let startDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
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
       
        let entry = StationWidget(date: Date(), configuration: configuration, data: data)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct StationWidget: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let data: [HistoricPrice]?
}

struct PriceWidgetEntryView : View {
    var entry: Provider.Entry
    
    func getSelectedFuelValue(station: HistoricPrice, fuelKey: String) -> Double? {
        let fuel = Enums.FuelType(rawValue: fuelKey)
        switch fuel {
        case .gasoilA:
            return station.gasoilAPrice
        case .gasoilB:
            return station.gasoilBPrice
        case .premiumGasoil:
            return station.premiumGasoilPrice
        case .biodiesel:
            return station.biodieselPrice
        case .gasoline95E10:
            return station.gasoline95E10Price
        case .gasoline95E5:
            return station.gasoline95E5Price
        case .gasoline95E5Premium:
            return station.gasoline95E5PremiumPrice
        case .gasoline98E10:
            return station.gasoline98E10Price
        case .gasoline98E5:
            return station.gasoline98E5Price
        case .bioethanol:
            return station.bioethanolPrice
        case .cng:
            return station.cngPrice
        case .lng:
            return station.lngPrice
        case .lpg:
            return station.lpgPrice
        case .hydrogen:
            return station.hydrogenPrice
        case .none:
            return nil
        }
    }
 
    var body: some View {
        if let data = entry.data, let selectedFuel = entry.configuration.selectedFuel {
            if let yesterdayData = data.first, let todayData = data.last {
                if let yesterdayPrice = getSelectedFuelValue(station: yesterdayData, fuelKey: selectedFuel.value), let todayPrice = getSelectedFuelValue(station: todayData, fuelKey: selectedFuel.value) {
                    let alias = getFavoriteAlias(favoriteId: todayData.stationId!)
                    VStack(alignment: .leading) {
                        Group {
                            if let alias = alias, !alias.isEmpty {
                                Text(verbatim: alias)
                            }
                            else {
                                Text(verbatim: todayData.stationSignage!.capitalized)
                            }
                        }
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .lineLimit(2)
                        .truncationMode(.tail)
                        Spacer()
                        Group {
                            Text(verbatim: selectedFuel.label)
                                .font(.system(size: 14))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Spacer()
                                .frame(height: 6)
                            HStack(alignment: .bottom) {
                                Text(verbatim: "\(formattedNumber(value: todayPrice, digits: 3)) €")
                                    .font(.system(size: 18))
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                            }
                            
                            let difference = todayPrice - yesterdayPrice
                            let percDifference = difference / yesterdayPrice * 100
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
                            Spacer()
                                .frame(height: 6)
                            HStack() {
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
                                    Text("compared to yesterday")
                                        .font(.system(size: 8))
                                        .foregroundStyle(Color.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontDesign(.rounded)
                }
                else {
                    VStack(alignment: .center) {
                        Text(verbatim: todayData.stationSignage!.capitalized)
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

struct PriceWidget: Widget {
    let kind: String = "PriceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            PriceWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall])
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
        intent.selectedFuel = FuelType(id: fuel.id, value: fuel.value, label: fuel.label)
        return intent
    }
    fileprivate static var gasoline95E5: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        let fuel = FuelType.fuelTypes[4]
        intent.selectedFuel = FuelType(id: fuel.id, value: fuel.value, label: fuel.label)
        return intent
    }
}

#Preview(as: .systemSmall) {
    PriceWidget()
} timeline: {
    StationWidget(date: .now, configuration: .noSelection, data: mockData)
    StationWidget(date: .now, configuration: .aGasoil, data: mockData)
    StationWidget(date: .now, configuration: .gasoline95E5, data: mockData)
}
