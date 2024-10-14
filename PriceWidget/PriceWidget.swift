import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> StationWidget {
        StationWidget(date: Date(), configuration: ConfigurationAppIntent(), data: mockStation)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> StationWidget {
        StationWidget(date: Date(), configuration: configuration, data: mockStation)
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

        let fetchedData = await ApiClient.fetchServiceStationsById(stationIds: [selectedStationId])
        guard let data = fetchedData.data?.results?.first else { return
            Timeline(entries: [nilEntry], policy: .after(nextUpdate))
        }
       
        let entry = StationWidget(date: Date(), configuration: configuration, data: data)
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct StationWidget: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let data: FuelStation?
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
            return station.premiumGasoilPrice
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
            VStack(alignment: .leading) {
                Group {
                    Text(verbatim: data.signage!.capitalized)
                        .fontWeight(.semibold)
                        .font(.system(size: 18))
                        .lineLimit(2)
                        .truncationMode(.tail)
                    Spacer()
                        .frame(height: 4)
                    Text(verbatim: data.address!.capitalized)
                        .foregroundStyle(Color.gray)
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .truncationMode(.tail)
                }
                Spacer()
                Group {
                    Text(verbatim: selectedFuel.label)
                        .font(.system(size: 16))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                        .frame(height: 4)
                    Group {
                        if let price = getSelectedFuelValue(station: data, fuelKey: selectedFuel.value) {
                            Text(verbatim: "\(formattedNumber(value: price, digits: 3)) €")
                        }
                        else {
                            Text(verbatim: "N/A")
                        }
                    }
                    .font(.system(size: 20))
                    .fontWeight(.bold)
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
    StationWidget(date: .now, configuration: .noSelection, data: mockStation)
    StationWidget(date: .now, configuration: .aGasoil, data: mockStation)
    StationWidget(date: .now, configuration: .gasoline95E5, data: mockStation)
}
