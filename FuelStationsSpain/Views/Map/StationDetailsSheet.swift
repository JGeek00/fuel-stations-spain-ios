import SwiftUI

struct StationDetailsSheet: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    func formatDate(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = formatter.date(from: value) {
            return date
        }
        else {
            return nil
        }
    }
    
    var body: some View {
        if let station = mapViewModel.selectedStation {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        if let name = station.signage {
                            Text(verbatim: name.capitalized)
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .truncationMode(.tail)
                                .lineLimit(1)
                        }
                        Spacer()
                        Button {
                            mapViewModel.showStationSheet = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                mapViewModel.selectedStation = nil
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .fontWeight(.semibold)
                                .foregroundColor(.foreground.opacity(0.5))
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .clipShape(Circle())
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        if let address = station.address {
                            let distanceText: String? = {
                                if station.latitude != nil && station.longitude != nil && locationManager.lastLocation?.coordinate.latitude != nil && locationManager.lastLocation?.coordinate.longitude != nil {
                                    let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))
                                    if distance < 1 {
                                        return String(localized: "\(Int(distance*1000)) m from your current location")
                                    } else {
                                        return String(localized: "\(formattedNumber(value: distance)) Km from your current location")
                                    }
                                }
                                return nil
                            }()
                            
                            ListItem(
                                icon: "mappin",
                                iconColor: .red,
                                title: address.capitalized,
                                subtitle: distanceText
                            )
                        }
                        if let locality = station.locality {
                            ListItem(
                                icon: "building.2.fill",
                                iconColor: .green,
                                title: String(localized: "Locality"),
                                subtitle: String(locality.capitalized)
                            )
                        }
                        ScheduleItem()
                        if let saleType = station.saleType {
                            ListItem(
                                icon: "person.fill",
                                iconColor: .purple,
                                title: String(localized: "Sales to the general public")
                            ) {
                                switch saleType {
                                case .p:
                                    AnyView(
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Spacer()
                                                .frame(width: 4)
                                            Text("Yes")
                                        }
                                        .foregroundStyle(Color.green)
                                        .font(.system(size: 14))
                                        .fontWeight(.medium)
                                    )
                                case .r:
                                    AnyView(
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                            Spacer()
                                                .frame(width: 4)
                                            Text("No")
                                        }
                                        .foregroundStyle(Color.red)
                                        .font(.system(size: 14))
                                        .fontWeight(.medium)
                                    )
                                }
                            }
                        }
                        PricesItem()
                        if let update = mapViewModel.data?.lastUpdated {
                            if let date = formatDate(update) {
                                ListItem(
                                    icon: "arrow.down.circle.fill",
                                    iconColor: .brown,
                                    title: String(localized: "Latest information")
                                ) {
                                    AnyView(
                                        Text(date, format: .dateTime.weekday().day().hour().minute())
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color.gray)
                                            .fontWeight(.medium)
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        else {
            ContentUnavailableView("No station selected", systemImage: "xmark.circle", description: Text("Select a service station to see it's details."))
        }
    }
}

fileprivate struct ScheduleItem: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
        
    @State private var showFullSchedule = false
    @State private var chevronAngle: Double = 0
    
    private let daysOfWeek = ["L", "M", "X", "J", "V", "S", "D"]
    
    var body: some View {
        if let openingHours = mapViewModel.selectedStation?.openingHours {
            let schedule = parseSchedule(schedule: openingHours)
            
            let currentDate = Date()
            let calendar = Calendar.current
            let dayOfWeek = calendar.component(.weekday, from: currentDate)
            
            let todaySchedule = schedule[dayOfWeek-1]
            let todayValue: Text = {
                if let todaySchedule = todaySchedule {
                    // todaySchedule[0] = opening time, todaySchedule[1] = closing time
                    if let openingTime = todaySchedule[0], let closingTime = todaySchedule[1] {
                        let opening = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime)
                        let closing = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime)
                        
                        // If opening is 00:00 and closing is 23:59 that's converted to open 24h
                        if opening.hour == 00 && opening.minute == 00 && closing.hour == 23 && closing.minute == 59 {
                            return Text("Open 24 hours")
                                .foregroundStyle(Color.green)
                        }
                        
                        // Take the current date and apply the opening hour and minute
                        var openingCalendar = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                        openingCalendar.hour = opening.hour
                        openingCalendar.minute = opening.minute
                        
                        // Take the current date and apply the closing hour and minute
                        var closingCalendar = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                        closingCalendar.hour = closing.hour
                        closingCalendar.minute = closing.minute
                        
                        // If current date is between opening date and closing date it's currently open
                        if let openingDate = calendar.date(from: openingCalendar), let closingDate = calendar.date(from: closingCalendar) {
                            if openingDate <= currentDate && currentDate <= closingDate {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "HH:mm"
                                return Text("Open until \(dateFormatter.string(from: closingTime))")
                                    .foregroundStyle(Color.green)
                            }
                            else {
                                return Text("Currently closed")
                                    .foregroundStyle(Color.red)
                            }
                        }
                        else {
                            return Text(verbatim: "N/A")
                                .foregroundStyle(Color.gray)
                        }
                    }
                    else {
                        return Text(verbatim: "N/A")
                            .foregroundStyle(Color.gray)
                    }
                }
                else {
                    return Text(verbatim: "N/A")
                        .foregroundStyle(Color.gray)
                }
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
                            HStack {
                                todayValue
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                            }
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
                                ForEach(0..<schedule.count) { i in
                                    let item = schedule[i]
                                    if let item = item, let openingTime = item[0], let closingTime = item[1] {
                                        let opening = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime)
                                        let closing = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime)
                                        if let openingHour = opening.hour, let openingMinute = opening.minute, let closingHour = closing.hour, let closingMinute = closing.minute {
                                            Text(verbatim: "\(String(format: "%02d", openingHour)):\(String(format: "%02d", openingMinute)) - \(String(format: "%02d", closingHour)):\(String(format: "%02d", closingMinute))")
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
            .customBackgroundWithMaterial()
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
        else {
            EmptyView()
        }
    }
}

struct PricesItem: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
        
    var body: some View {
        if let station = mapViewModel.selectedStation {
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
                        Product(name: String(localized: "Gasoline 95 E10"), value: station.gasoline95E10Price)
                        Product(name: String(localized: "Gasoline 95 E5"), value: station.gasoline95E5Price)
                        Product(name: String(localized: "Gasoline 95 E5 Premium"), value: station.gasoline95E5PremiumPrice)
                        Product(name: String(localized: "Gasoline 98 E10"), value: station.gasoline98E10Price)
                        Product(name: String(localized: "Gasoline 98 E5"), value: station.gasoline98E5Price)
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
            .customBackgroundWithMaterial()
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
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

fileprivate struct ListItem: View {
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
        .customBackgroundWithMaterial()
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
    
}
