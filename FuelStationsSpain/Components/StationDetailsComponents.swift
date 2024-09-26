import SwiftUI

class StationDetailsComponents {
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
                                        if formattedSchedule.schedule.isEmpty {
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
        
        @EnvironmentObject private var mapViewModel: MapViewModel
            
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

}
