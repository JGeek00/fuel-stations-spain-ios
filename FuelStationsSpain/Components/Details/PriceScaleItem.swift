import SwiftUI

fileprivate struct PriceScaleItem: Sendable {
    let fuel: Enums.FuelType
    let avgPercentage: Double
    
    init(fuel: Enums.FuelType, avgPercentage: Double) {
        self.fuel = fuel
        self.avgPercentage = avgPercentage
    }
}
struct StationDetailsPriceScale: View {
    var station: FuelStation
    var alwaysExpanded: Bool
    
    init(station: FuelStation, alwaysExpanded: Bool = false) {
        self.station = station
        self.alwaysExpanded = alwaysExpanded
        if alwaysExpanded {
            _expandedContent = State(wrappedValue: true)
        }
    }
    
    @EnvironmentObject private var mapManager: MapManager
    
    @State private var expandedContent = false
    @State private var chevronAngle: Double = 0
    @State private var howIsCalculatedSheet = false
    @State private var priceScaleItems: [PriceScaleItem]? = nil
    
    private func calculateScale() {
        @Sendable func calculateAvgPercentage(nearbyStations: [FuelStation], station: FuelStation, fuel: Enums.FuelType) -> PriceScaleItem? {
            if let fuelPrice: Double = FuelStation.getObjectProperty(station: station, propertyName: "\(fuel.rawValue)Price") {
                let prices = nearbyStations.map { station in
                    let value: Double? = FuelStation.getObjectProperty(station: station, propertyName: "\(fuel.rawValue)Price")
                    return value
                }.filter() { $0 != nil } as! [Double]
                let percentage: Double? = {
                    if prices.count <= 1 {
                        return nil
                    }
                    
                    let maxPrice = prices.max()
                    let minPrice = prices.min()
                    if let maxPrice = maxPrice, let minPrice = minPrice {
                        let percentage = ((fuelPrice - minPrice) / (maxPrice - minPrice)) * 100
                        return percentage
                    }
                    return nil
                }()
                if let percentage = percentage {
                    return PriceScaleItem(fuel: fuel, avgPercentage: percentage)
                }
                return nil
            }
            return nil
        }
        
        if let nearbyStations = mapManager.data?.results {
            DispatchQueue.global(qos: .background).async {
                var items: [PriceScaleItem] = []
                if let aGasoil = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoilA) {
                    items.append(aGasoil)
                }
                if let bGasoil = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoilB) {
                    items.append(bGasoil)
                }
                if let premiumGasoil = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoilA) {
                    items.append(premiumGasoil)
                }
                if let biodiesel = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .biodiesel) {
                    items.append(biodiesel)
                }
                if let gasoline95E5 = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoline95E5) {
                    items.append(gasoline95E5)
                }
                if let gasoline95E10 = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoline95E10) {
                    items.append(gasoline95E10)
                }
                if let gasoline95E5Premium = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoline95E5Premium) {
                    items.append(gasoline95E5Premium)
                }
                if let gasoline98E5 = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoline98E5) {
                    items.append(gasoline98E5)
                }
                if let gasoline98E10 = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .gasoline98E10) {
                    items.append(gasoline98E10)
                }
                if let bioethanol = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .bioethanol) {
                    items.append(bioethanol)
                }
                if let cng = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .cng) {
                    items.append(cng)
                }
                if let lng = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .lng) {
                    items.append(lng)
                }
                if let lpg = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .lpg) {
                    items.append(lpg)
                }
                if let hydrogen = calculateAvgPercentage(nearbyStations: nearbyStations, station: station, fuel: .hydrogen) {
                    items.append(hydrogen)
                }
                DispatchQueue.main.async {
                    priceScaleItems = items
                }
            }
        }
    }
    
    var body: some View {
        if let nearbyStations = mapManager.data?.results, nearbyStations.count > 1 {
            Group {
                if let aGasoilPrice = station.gasoilAPrice, let gasoline95Price = station.gasoline95E5Price {
                    if alwaysExpanded {
                        ExpandableContent(nearbyStations: nearbyStations, aGasoilPrice: aGasoilPrice, gasoline95Price: gasoline95Price)
                            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                            .padding()
                    }
                    else {
                        Button {
                            withAnimation(.default) {
                                expandedContent.toggle()
                                chevronAngle = chevronAngle.isZero ? 180 : 0
                            }
                        } label: {
                            ExpandableContent(nearbyStations: nearbyStations, aGasoilPrice: aGasoilPrice, gasoline95Price: gasoline95Price)
                        }
                        .buttonStyle(.plain)
                        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                        .padding()
                    }
                }
                else {
                    VStack(alignment: .leading) {
                        HStack {
                            VStack {
                                Image(systemName: "gauge.with.needle.fill")
                                    .foregroundStyle(Color.white)
                                    .frameDynamicSize(width: 28, height: 28)
                                    .background(.green)
                                    .cornerRadius(6)
                                Spacer()
                            }
                            Spacer()
                                .frame(width: 12)
                            VStack(alignment: .leading) {
                                Text("Price range")
                                    .fontSize(16)
                                    .fontWeight(.semibold)
                                Spacer()
                                    .frame(height: 8)
                                VStack(alignment: .leading, spacing: 6) {
                                    FuelPriceRange(fuelName: String(localized: "A Gasoil"), fuel: .gasoilA)
                                    FuelPriceRange(fuelName: String(localized: "B Gasoil"), fuel: .gasoilB)
                                    FuelPriceRange(fuelName: String(localized: "Premium Gasoil"), fuel: .premiumGasoil)
                                    FuelPriceRange(fuelName: String(localized: "Biodiesel"), fuel: .biodiesel)
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5"), fuel: .gasoline95E5)
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5 Premium"), fuel: .gasoline95E10)
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 95 E10"), fuel: .gasoline95E5Premium)
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 98 E5"), fuel: .gasoline98E5)
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 98 E10"), fuel: .gasoline98E10)
                                    FuelPriceRange(fuelName: String(localized: "Bioethanol"), fuel: .bioethanol)
                                    FuelPriceRange(fuelName: String(localized: "Compressed Natural Gas"), fuel: .cng)
                                    FuelPriceRange(fuelName: String(localized: "Liquefied Natural Gas"), fuel: .lng)
                                    FuelPriceRange(fuelName: String(localized: "Liquefied petroleum gases"), fuel: .lpg)
                                    FuelPriceRange(fuelName: String(localized: "Hydrogen"), fuel: .hydrogen)
                                }
                                Spacer()
                                    .frame(height: 12)
                                Button("How is it calculated?") {
                                    howIsCalculatedSheet = true
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                    .padding()
                }
            }
            .sheet(isPresented: $howIsCalculatedSheet) {
                HowIsCalculatedSheet()
            }
            .onAppear {
                calculateScale()
            }
            .onChange(of: station) {
                priceScaleItems = nil
                calculateScale()
            }
        }
    }
    
    @ViewBuilder
    func ExpandableContent(nearbyStations: [FuelStation], aGasoilPrice: Double, gasoline95Price: Double) -> some View {
        let avgPercentage: Double? = {
            let stations: [FuelStation] = nearbyStations.filter() { $0.gasoilAPrice != nil && $0.gasoline95E5Price != nil }
            let aGasoilPrices: [Double] = stations.map() { $0.gasoilAPrice! }
            let gasoline95Prices: [Double] = stations.map() { $0.gasoline95E5Price! }
            
            let minAGasoil = aGasoilPrices.min()
            let maxAGasoil = aGasoilPrices.max()
            let minGasoline95 = gasoline95Prices.min()
            let maxGasoline95 = gasoline95Prices.max()
            if let minAGasoil = minAGasoil, let maxAGasoil = maxAGasoil, let minGasoline95 = minGasoline95, let maxGasoline95 = maxGasoline95 {
                let gasoilPercentage = ((aGasoilPrice - minAGasoil) / (maxAGasoil - minAGasoil)) * 100
                let gasoline95Percentage = ((gasoline95Price - minGasoline95) / (maxGasoline95 - minGasoline95)) * 100
                return (gasoilPercentage + gasoline95Percentage) / 2
            }
            return nil
        }()
        
        if let avgPercentage = avgPercentage {
            let color: Color = {
                if avgPercentage < 35.0 {
                    return Color.green
                }
                else if avgPercentage < 65.0 {
                    return Color.orange
                }
                else {
                    return Color.red
                }
            }()
            
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "gauge.with.needle.fill")
                        .foregroundStyle(Color.white)
                        .frameDynamicSize(width: 28, height: 28)
                        .background(.green)
                        .cornerRadius(6)
                    Spacer()
                        .frame(width: 12)
                    Text("Price range")
                        .fontSize(16)
                        .fontWeight(.semibold)
                }
                HStack {
                    if !alwaysExpanded {
                        Spacer()
                            .frame(width: 18)
                        Spacer()
                    }
                    VStack {
                        Gauge(
                            value: "\(Int(avgPercentage.rounded()))%",
                            percentage: avgPercentage.rounded(),
                            color: color,
                            size: 60
                        )
                        Spacer()
                            .frame(height: 4)
                        Group {
                            if avgPercentage.rounded() == 0 {
                                Text("This service station is, in general terms, ") + Text("the cheapest ").foregroundStyle(Color.green) + Text("service station in the area.")
                            }
                            else if avgPercentage.rounded() == 100 {
                                Text("This service station is, in general terms, ") + Text("the most expensive ").foregroundStyle(Color.red) + Text("service station in the area.")
                            }
                            else {
                                Text("This service station is, in general terms, ") + Text("a \(Int(avgPercentage.rounded()))% more expensive ").foregroundStyle(color) + Text("than the cheapest service station in the area.")
                            }
                        }
                        .fontSize(14)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    if !alwaysExpanded {
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color.blue)
                            .fontSize(18)
                            .fontWeight(.medium)
                            .rotationEffect(.degrees(chevronAngle))
                            .animation(.default, value: chevronAngle)
                            .disabled(priceScaleItems == nil)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                if expandedContent == true {
                    Spacer()
                        .frame(height: 12)
                    if priceScaleItems == nil {
                        Group {
                            ProgressView()
                                .padding()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    else {
                        VStack(alignment: .leading, spacing: 6) {
                            FuelPriceRange(fuelName: String(localized: "A Gasoil"), fuel: .gasoilA)
                            FuelPriceRange(fuelName: String(localized: "B Gasoil"), fuel: .gasoilB)
                            FuelPriceRange(fuelName: String(localized: "Premium Gasoil"), fuel: .premiumGasoil)
                            FuelPriceRange(fuelName: String(localized: "Biodiesel"), fuel: .biodiesel)
                            FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5"), fuel: .gasoline95E5)
                            FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5 Premium"), fuel: .gasoline95E10)
                            FuelPriceRange(fuelName: String(localized: "Gasoline 95 E10"), fuel: .gasoline95E5Premium)
                            FuelPriceRange(fuelName: String(localized: "Gasoline 98 E5"), fuel: .gasoline98E5)
                            FuelPriceRange(fuelName: String(localized: "Gasoline 98 E10"), fuel: .gasoline98E10)
                            FuelPriceRange(fuelName: String(localized: "Bioethanol"), fuel: .bioethanol)
                            FuelPriceRange(fuelName: String(localized: "Compressed Natural Gas"), fuel: .cng)
                            FuelPriceRange(fuelName: String(localized: "Liquefied Natural Gas"), fuel: .lng)
                            FuelPriceRange(fuelName: String(localized: "Liquefied petroleum gases"), fuel: .lpg)
                            FuelPriceRange(fuelName: String(localized: "Hydrogen"), fuel: .hydrogen)
                        }
                    }
                    Spacer()
                        .frame(height: 12)
                    Button("How is it calculated?") {
                        howIsCalculatedSheet = true
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .contentShape(Rectangle())
        }
    }
    
    @ViewBuilder
    func FuelPriceRange(fuelName: String, fuel: Enums.FuelType) -> some View {
        if let scaleItems = priceScaleItems, let thisItem = scaleItems.first(where: { $0.fuel == fuel }) {
            let color: Color = {
                if thisItem.avgPercentage < 35.0 {
                    return Color.green
                }
                else if thisItem.avgPercentage < 65.0 {
                    return Color.orange
                }
                else {
                    return Color.red
                }
            }()
            
            HStack {
                Text(fuelName)
                Spacer()
                Text(verbatim: "\(Int(thisItem.avgPercentage.rounded()))%")
                    .fontWeight(.medium)
                    .foregroundStyle(color)
            }
            .fontSize(14)
        }
    }
    
    @ViewBuilder
    func HowIsCalculatedSheet() -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Gauge(
                        value: "30%",
                        percentage: 30,
                        color: .green,
                        size: 60
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                        .frame(height: 12)
                    Text("For the general calculation")
                        .fontWeight(.semibold)
                        .fontSize(20)
                        .padding(.bottom, 4)
                    Text("This calculation is only available if the service station supplies at least Gasoil A and Gasoline 95 E5.\nIn this case, all nearby service stations that also supply Gasoil A and Gasoline 95 E5 will be taken.\nThen, for each of these two fuels, the minimum and maximum price is taken from among all the selected service stations, and with these two values a range is established.\nThen, the price of that fuel at the service station being analyzed is taken, and the point within the range is calculated, and thus the percentage is obtained.")
                    Spacer()
                        .frame(height: 24)
                    Text("For the individual calculations")
                        .fontWeight(.semibold)
                        .fontSize(20)
                        .padding(.bottom, 4)
                    Text("In this case, the price of this fuel at all nearby service stations that supply it will be taken.\nThen, the minimum price and the maximum price will be taken and a range will be elaborated with them.\nThen, it is calculated where in the range is the price of the service station being analyzed.")
                }
                .padding()
            }
            .navigationTitle("Price scale calculation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        howIsCalculatedSheet = false
                        mapManager.selectedStationAnimation = nil
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
            }
        }
    }
}
