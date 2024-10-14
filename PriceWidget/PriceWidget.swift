import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> StationWidget {
        StationWidget(date: Date(), configuration: ConfigurationAppIntent(), data: mockStation, yesterdayData: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> StationWidget {
        StationWidget(date: Date(), configuration: configuration, data: mockStation, yesterdayData: nil)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<StationWidget> {
        let nilEntry = StationWidget(date: Date(), configuration: configuration, data: nil, yesterdayData: nil)
        
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
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        let zeroedDate = calendar.date(from: dateComponents)!
        let localDate = convertToLocalTime(date: zeroedDate)

        let currentData = await ApiClient.fetchServiceStationsById(stationIds: [selectedStationId])
        let yesterdayData = await ApiClient.fetchServiceStationHistoric(stationId: selectedStationId, startDate: localDate, endDate: .now)
                
        guard let data = currentData.data?.results?.first else { return
            Timeline(entries: [nilEntry], policy: .after(nextUpdate))
        }
       
        let entry = StationWidget(date: Date(), configuration: configuration, data: data, yesterdayData: yesterdayData.data?.first)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct StationWidget: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let data: FuelStation?
    let yesterdayData: FuelStationHistoric?
}

struct PriceWidgetEntryView : View {
    var entry: Provider.Entry
    
    func getSelectedFuelValue(station: FuelStation, fuelKey: String) -> Double? {
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
    
    func getSelectedFuelYesterdayValue(station: FuelStationHistoric, fuelKey: String) -> Double? {
        let fuel = Enums.FuelType(rawValue: fuelKey)
        switch fuel {
        case .gasoilA:
            return station.gasoil_a_price
        case .gasoilB:
            return station.gasoil_b_price
        case .premiumGasoil:
            return station.premium_gasoil_price
        case .biodiesel:
            return station.biodiesel_price
        case .gasoline95E10:
            return station.gasoline_95_e10_price
        case .gasoline95E5:
            return station.gasoline_95_e5_price
        case .gasoline95E5Premium:
            return station.gasoline_95_e5_premium_price
        case .gasoline98E10:
            return station.gasoline_98_e10_price
        case .gasoline98E5:
            return station.gasoline_98_e5_price
        case .bioethanol:
            return station.bioethanol_price
        case .cng:
            return station.cng_price
        case .lng:
            return station.lng_price
        case .lpg:
            return station.lpg_price
        case .hydrogen:
            return station.hydrogen_price
        case .none:
            return nil
        }
    }

    var body: some View {
        if let data = entry.data, let selectedFuel = entry.configuration.selectedFuel {
            VStack(alignment: .leading) {
                Group {
                    Text(verbatim: data.signage!.capitalized)
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                Spacer()
                Group {
                    Text(verbatim: selectedFuel.label)
                        .font(.system(size: 14))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                        .frame(height: 6)
                    HStack(alignment: .bottom) {
                        Group {
                            if let price = getSelectedFuelValue(station: data, fuelKey: selectedFuel.value) {
                                Text(verbatim: "\(formattedNumber(value: price, digits: 3)) €")
                            }
                            else {
                                Text(verbatim: "N/A")
                            }
                        }
                        .font(.system(size: 18))
                        .fontWeight(.bold)
                        .lineLimit(1)
                    }
                    if let price = getSelectedFuelValue(station: data, fuelKey: selectedFuel.value), let yesterday = entry.yesterdayData, let yesterdayPrice = getSelectedFuelYesterdayValue(station: yesterday, fuelKey: selectedFuel.value) {
                        let difference = price - yesterdayPrice
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fontDesign(.rounded)
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
    StationWidget(date: .now, configuration: .noSelection, data: mockStation, yesterdayData: mockYesterdayData)
    StationWidget(date: .now, configuration: .aGasoil, data: mockStation, yesterdayData: mockYesterdayData)
    StationWidget(date: .now, configuration: .gasoline95E5, data: mockStation, yesterdayData: mockYesterdayData)
    StationWidget(date: .now, configuration: .gasoline95E5, data: mockStationLong, yesterdayData: mockYesterdayData)
}
