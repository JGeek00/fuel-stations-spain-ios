import SwiftUI
import MapKit

class StationDetailsComponents {
    struct FavoriteButton: View {
        var stationId: String
        
        init(stationId: String) {
            self.stationId = stationId
        }
        
        @EnvironmentObject private var favoritesProvider: FavoritesProvider
        
        var body: some View {
            let isFavorite = favoritesProvider.isFavorite(stationId: stationId)
            Button {
                if isFavorite == true {
                    favoritesProvider.removeFavorite(stationId: stationId)
                }
                else {
                    favoritesProvider.addFavorite(stationId: stationId)
                }
            } label: {
                Image(systemName: isFavorite == true ? "star.fill" : "star")
                    .fontWeight(.semibold)
                    .animation(.default, value: isFavorite)
            }
            .buttonStyle(BorderedButtonStyle())
            .clipShape(Circle())
        }
    }
    
    struct ScheduleItem: View {
        var station: FuelStation
        
        init(station: FuelStation) {
            self.station = station
        }
        
        @EnvironmentObject private var locationManager: LocationManager
            
        @State private var showFullSchedule = false
        @State private var chevronAngle: Double = 0
        
        private let daysOfWeek = ["L", "M", "X", "J", "V", "S", "D"]
        
        var body: some View {
            if let openingHours = station.openingHours {
                let schedule = parseSchedule(schedule: openingHours)
                let formattedSchedule = getStationSchedule(openingHours)
                
                let dateFormatter = {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    return dateFormatter
                }()
                
                Button {
                    withAnimation(.default) {
                        showFullSchedule.toggle()
                        chevronAngle = chevronAngle.isZero ? 180 : 0
                    }
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundStyle(Color.white)
                                .frame(width: 28, height: 28)
                                .background(.blue)
                                .cornerRadius(6)
                            Spacer()
                                .frame(width: 12)
                            VStack(alignment: .leading) {
                                Text("Opening hours")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                Spacer()
                                    .frame(height: 8)
                                Group {
                                    if let formattedSchedule = formattedSchedule {
                                        if formattedSchedule.schedule.isEmpty && formattedSchedule.isCurrentlyOpen == true {
                                            Text("Open 24 hours")
                                                .foregroundStyle(Color.green)
                                        }
                                        else if formattedSchedule.isCurrentlyOpen == true {
                                            let now = Date()
                                            if now < formattedSchedule.schedule[1] {
                                                Text("Open until \(dateFormatter.string(from: formattedSchedule.schedule[1]))")
                                                    .foregroundStyle(Color.green)
                                            }
                                            else {
                                                Text("Open until \(dateFormatter.string(from: formattedSchedule.schedule[3]))")
                                                    .foregroundStyle(Color.green)
                                            }
                                        }
                                        else if formattedSchedule.isCurrentlyOpen == false {
                                            Text("Currently closed")
                                                .foregroundStyle(Color.red)
                                        }
                                        else {
                                            Text("Unknown")
                                                .foregroundStyle(Color.gray)
                                        }
                                    }
                                    else {
                                        Text("Unknown")
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .font(.system(size: 14))
                                .fontWeight(.medium)
                            }
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(Color.blue)
                                .font(.system(size: 18))
                                .fontWeight(.medium)
                                .rotationEffect(.degrees(chevronAngle))
                                .animation(.default, value: chevronAngle)
                            
                        }
                        if showFullSchedule == true {
                            Spacer()
                                .frame(height: 12)
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(daysOfWeek.indices) { i in
                                        Text(verbatim: "\(daysOfWeek[i]):")
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    let calendar = Calendar.current
                                    ForEach(0..<schedule.count) { i in
                                        let item = schedule[i]
                                        if let item = item {
                                            if item.count == 2 {
                                                if let openingTime = item[0], let closingTime = item[1] {
                                                    let opening = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime)
                                                    let closing = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime)
                                                    if let openingHour = opening.hour, let openingMinute = opening.minute, let closingHour = closing.hour, let closingMinute = closing.minute {
                                                        Text(verbatim: "\(String(format: "%02d", openingHour)):\(String(format: "%02d", openingMinute)) - \(String(format: "%02d", closingHour)):\(String(format: "%02d", closingMinute))")
                                                    }
                                                }
                                            }
                                            else if item.count == 4 {
                                                if let openingTime1 = item[0], let closingTime1 = item[1], let openingTime2 = item[2], let closingTime2 = item[3] {
                                                    let opening1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime1)
                                                    let closing1 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime1)
                                                    let opening2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime2)
                                                    let closing2 = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime2)
                                                    if let openingHour1 = opening1.hour, let openingMinute1 = opening1.minute, let closingHour1 = closing1.hour, let closingMinute1 = closing1.minute, let openingHour2 = opening2.hour, let openingMinute2 = opening2.minute, let closingHour2 = closing2.hour, let closingMinute2 = closing2.minute {
                                                        Text("\(String(format: "%02d", openingHour1)):\(String(format: "%02d", openingMinute1)) - \(String(format: "%02d", closingHour1)):\(String(format: "%02d", closingMinute1)) and \(String(format: "%02d", openingHour2)):\(String(format: "%02d", openingMinute2)) - \(String(format: "%02d", closingHour2)):\(String(format: "%02d", closingMinute2))")
                                                    }
                                                }
                                            }
                                        }
                                        else {
                                            Text("Closed")
                                        }
                                    }
                                }
                            }
                            .font(.system(size: 14))
                            .transition(.opacity)
                            .padding(.leading, 40)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                .padding()
            }
            else {
                EmptyView()
            }
        }
    }

    struct PricesItem: View {
        var station: FuelStation
        
        init(station: FuelStation) {
            self.station = station
        }
        
        @EnvironmentObject private var mapManager: MapManager
            
        var body: some View {
            HStack(alignment: .top) {
                Image(systemName: "eurosign.circle.fill")
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(.orange)
                    .cornerRadius(6)
                Spacer()
                    .frame(width: 12)
                VStack(alignment: .leading) {
                    Text("Prices")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 8)
                    VStack(alignment: .leading, spacing: 6) {
                        Product(name: String(localized: "A Gasoil"), value: station.gasoilAPrice)
                        Product(name: String(localized: "B Gasoil"), value: station.gasoilBPrice)
                        Product(name: String(localized: "Premium Gasoil"), value: station.premiumGasoilPrice)
                        Product(name: String(localized: "Biodiesel"), value: station.biodieselPrice)
                        Product(name: String(localized: "Gasoline 95 E5"), value: station.gasoline95E5Price)
                        Product(name: String(localized: "Gasoline 95 E5 Premium"), value: station.gasoline95E5PremiumPrice)
                        Product(name: String(localized: "Gasoline 95 E10"), value: station.gasoline95E10Price)
                        Product(name: String(localized: "Gasoline 98 E5"), value: station.gasoline98E5Price)
                        Product(name: String(localized: "Gasoline 98 E10"), value: station.gasoline98E10Price)
                        Product(name: String(localized: "Bioethanol"), value: station.bioethanolPrice)
                        Product(name: String(localized: "Compressed Natural Gas"), value: station.cngPrice)
                        Product(name: String(localized: "Liquefied Natural Gas"), value: station.lngPrice)
                        Product(name: String(localized: "Liquefied petroleum gases"), value: station.lpgPrice)
                        Product(name: String(localized: "Hydrogen"), value: station.hydrogenPrice)
                    }
                }
                Spacer()
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
            .padding()
        }
        
        @ViewBuilder
        func Product(name: String, value: Double?) -> some View {
            if let value {
                HStack {
                    Text(name)
                    Spacer()
                    Text("\(formattedNumber(value: value, digits: 3)) €")
                }
                .font(.system(size: 14))
            }
            else {
                EmptyView()
            }
        }
    }

    struct ListItem: View {
        var icon: String
        var iconColor: Color
        var title: String
        var subtitle: String?
        @ViewBuilder let viewSubtitle: (() -> AnyView)?
        
        init(icon: String, iconColor: Color, title: String, subtitle: String? = nil) {
            self.icon = icon
            self.iconColor = iconColor
            self.title = title
            self.subtitle = subtitle
            self.viewSubtitle = nil
        }
        
        init(icon: String, iconColor: Color, title: String, viewSubtitle: (() -> AnyView)? = nil) {
            self.icon = icon
            self.iconColor = iconColor
            self.title = title
            self.viewSubtitle = viewSubtitle
            self.subtitle = nil
        }
        
        var body: some View {
            return HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .cornerRadius(6)
                Spacer()
                    .frame(width: 12)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    if let subtitle = subtitle {
                        Spacer()
                            .frame(height: 8)
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                            .fontWeight(.medium)
                    }
                    if let viewSubtitle = viewSubtitle {
                        Spacer()
                            .frame(height: 8)
                        viewSubtitle()
                    }
                    else {
                        EmptyView()
                    }
                }
                Spacer()
            }
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
            .padding()
        }
    }
    
    struct PriceScale: View {
        var station: FuelStation
        
        init(station: FuelStation) {
            self.station = station
        }
        
        @EnvironmentObject private var mapManager: MapManager
        
        @State private var expandedContent = false
        @State private var chevronAngle: Double = 0
        
        var body: some View {
            if let nearbyStations = mapManager.data?.results, nearbyStations.count > 1 {
                if let aGasoilPrice = station.gasoilAPrice, let gasoline95Price = station.gasoline95E5Price {
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
                        
                        Button {
                            withAnimation(.default) {
                                expandedContent.toggle()
                                chevronAngle = chevronAngle.isZero ? 180 : 0
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack {
                                        Image(systemName: "gauge.with.needle.fill")
                                            .foregroundStyle(Color.white)
                                            .frame(width: 28, height: 28)
                                            .background(.green)
                                            .cornerRadius(6)
                                        Spacer()
                                    }
                                    Spacer()
                                        .frame(width: 12)
                                    VStack(alignment: .leading) {
                                        Text("Price range")
                                            .font(.system(size: 16))
                                            .fontWeight(.semibold)
                                        Spacer()
                                            .frame(height: 8)
                                        
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
                                            .font(.system(size: 14))
                                            .fontWeight(.medium)
                                            .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(Color.blue)
                                        .font(.system(size: 18))
                                        .fontWeight(.medium)
                                        .rotationEffect(.degrees(chevronAngle))
                                        .animation(.default, value: chevronAngle)
                                    
                                }
                                if expandedContent == true {
                                    Spacer()
                                        .frame(height: 12)
                                    VStack(alignment: .leading, spacing: 6) {
                                        FuelPriceRange(fuelName: String(localized: "A Gasoil"), fuelParameter: "gasoilAPrice")
                                        FuelPriceRange(fuelName: String(localized: "B Gasoil"), fuelParameter: "gasoilBPrice")
                                        FuelPriceRange(fuelName: String(localized: "Premium Gasoil"), fuelParameter: "premiumGasoilPrice")
                                        FuelPriceRange(fuelName: String(localized: "Biodiesel"), fuelParameter: "biodieselPrice")
                                        FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5"), fuelParameter: "gasoline95E5Price")
                                        FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5 Premium"), fuelParameter: "gasoline95E5PremiumPrice")
                                        FuelPriceRange(fuelName: String(localized: "Gasoline 95 E10"), fuelParameter: "gasoline95E10Price")
                                        FuelPriceRange(fuelName: String(localized: "Gasoline 98 E5"), fuelParameter: "gasoline98E5Price")
                                        FuelPriceRange(fuelName: String(localized: "Gasoline 98 E10"), fuelParameter: "gasoline98E10Price")
                                        FuelPriceRange(fuelName: String(localized: "Bioethanol"), fuelParameter: "bioethanolPrice")
                                        FuelPriceRange(fuelName: String(localized: "Compressed Natural Gas"), fuelParameter: "cngPrice")
                                        FuelPriceRange(fuelName: String(localized: "Liquefied Natural Gas"), fuelParameter: "lngPrice")
                                        FuelPriceRange(fuelName: String(localized: "Liquefied petroleum gases"), fuelParameter: "lpgPrice")
                                        FuelPriceRange(fuelName: String(localized: "Hydrogen"), fuelParameter: "hydrogenPrice")
                                    }
                                }
                            }
                            .contentShape(Rectangle())
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
                                    .frame(width: 28, height: 28)
                                    .background(.green)
                                    .cornerRadius(6)
                                Spacer()
                            }
                            Spacer()
                                .frame(width: 12)
                            VStack(alignment: .leading) {
                                Text("Price range")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                Spacer()
                                    .frame(height: 8)
                                VStack(alignment: .leading, spacing: 6) {
                                    FuelPriceRange(fuelName: String(localized: "A Gasoil"), fuelParameter: "gasoilAPrice")
                                    FuelPriceRange(fuelName: String(localized: "B Gasoil"), fuelParameter: "gasoilBPrice")
                                    FuelPriceRange(fuelName: String(localized: "Premium Gasoil"), fuelParameter: "premiumGasoilPrice")
                                    FuelPriceRange(fuelName: String(localized: "Biodiesel"), fuelParameter: "biodieselPrice")
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5"), fuelParameter: "gasoline95E5Price")
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 95 E5 Premium"), fuelParameter: "gasoline95E5PremiumPrice")
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 95 E10"), fuelParameter: "gasoline95E10Price")
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 98 E5"), fuelParameter: "gasoline98E5Price")
                                    FuelPriceRange(fuelName: String(localized: "Gasoline 98 E10"), fuelParameter: "gasoline98E10Price")
                                    FuelPriceRange(fuelName: String(localized: "Bioethanol"), fuelParameter: "bioethanolPrice")
                                    FuelPriceRange(fuelName: String(localized: "Compressed Natural Gas"), fuelParameter: "cngPrice")
                                    FuelPriceRange(fuelName: String(localized: "Liquefied Natural Gas"), fuelParameter: "lngPrice")
                                    FuelPriceRange(fuelName: String(localized: "Liquefied petroleum gases"), fuelParameter: "lpgPrice")
                                    FuelPriceRange(fuelName: String(localized: "Hydrogen"), fuelParameter: "hydrogenPrice")
                                }
                            }
                        }
                    }
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                    .padding()
                }
            }
        }
        
        @ViewBuilder
        func FuelPriceRange(fuelName: String, fuelParameter: String) -> some View {
            if let nearbyStations = mapManager.data?.results, let fuelPrice: Double = FuelStation.getObjectProperty(station: station, propertyName: fuelParameter) {
                let prices = nearbyStations.map { station in
                    let value: Double? = FuelStation.getObjectProperty(station: station, propertyName: fuelParameter)
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
                    let color: Color = {
                        if percentage < 35.0 {
                            return Color.green
                        }
                        else if percentage < 65.0 {
                            return Color.orange
                        }
                        else {
                            return Color.red
                        }
                    }()
                    
                    HStack {
                        Text(fuelName)
                        Spacer()
                        Text(verbatim: "\(Int(percentage.rounded()))%")
                            .fontWeight(.medium)
                            .foregroundStyle(color)
                    }
                    .font(.system(size: 14))
                }
                else {
                    HStack {
                        Text(fuelName)
                        Spacer()
                        Text(verbatim: "N/A")
                            .fontWeight(.medium)
                    }
                    .font(.system(size: 14))
                }
            }
        }
    }
    
    static fileprivate let delta = 0.003
    struct MapView: View {
        var station: FuelStation
        
        init(station: FuelStation) {
            self.station = station
        }
        
        @EnvironmentObject private var mapManager: MapManager
        @EnvironmentObject private var tabViewManager: TabViewManager
        @EnvironmentObject private var locationManager: LocationManager
        
        @State private var camera = MapCameraPosition.region(.init(center: Config.defaultCoordinates, span: .init(latitudeDelta: delta, longitudeDelta: delta)))
        
        var body: some View {
            VStack {
                if let signage = station.signage, let latitude = station.latitude, let longitude = station.longitude {
                    Map(position: $camera, interactionModes: []) {
                        Marker(signage.capitalized, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    }
                    .mapStyle(.standard(pointsOfInterest: .excludingAll))
                    .frame(height: 300)
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Button("Show in map") {
                            mapManager.selectStation(station: station, centerLocation: true)
                            tabViewManager.selectedTab = .map
                        }
                        .frame(maxWidth: .infinity)
                        if let lastLocation = locationManager.lastLocation {
                            Divider()
                                .frame(width: 1)
                            Button("How to get there") {
                                openInMapsApp(sourceLatitude: lastLocation.coordinate.latitude, sourceLongitude: lastLocation.coordinate.longitude, destinationLatitude: latitude, destinationLongitude: longitude, stationName: signage.capitalized)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }
            }
            .onChange(of: station, initial: true) {
                if let latitude = station.latitude, let longitude = station.longitude {
                    camera = MapCameraPosition.region(.init(center: .init(latitude: latitude, longitude: longitude), span: .init(latitudeDelta: delta, longitudeDelta: delta)))
                }
            }
        }
    }
}
