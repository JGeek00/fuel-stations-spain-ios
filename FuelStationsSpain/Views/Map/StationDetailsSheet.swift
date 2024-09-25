import SwiftUI

struct StationDetailsSheet: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        if let station = mapViewModel.selectedStation {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    HStack {
                        if let name = station.signage {
                            Text(verbatim: name.capitalized)
                                .font(.system(size: 30))
                                .fontWeight(.semibold)
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
                        ScheduleItem()
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
                    if let closingTime = todaySchedule[1], let openingTime = todaySchedule[0] {
                        let opening = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: openingTime)
                        let closing = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: closingTime)
                        if opening.hour == 00 && opening.minute == 00 && closing.hour == 23 && closing.minute == 59 {
                            return Text("Open 24 hours")
                                .foregroundStyle(Color.green)
                        }
                        var now = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
                        now.hour = closing.hour
                        now.minute = closing.minute
                        if let closingDate = calendar.date(from: now) {
                            if currentDate < closingDate {
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
                                .frame(height: 4)
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
            .background(Color.background)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
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
                        .frame(height: 4)
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }
                if let viewSubtitle = viewSubtitle {
                    Spacer()
                        .frame(height: 4)
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
        .background(Color.background)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
    }
    
}
