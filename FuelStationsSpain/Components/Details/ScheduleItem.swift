import SwiftUI

struct StationDetailsScheduleItem: View {
    var station: FuelStation
    var schedule: OpeningSchedule?
    var alwaysExpanded: Bool
    
    init(station: FuelStation, schedule: OpeningSchedule?, alwaysExpanded: Bool = false) {
        self.station = station
        self.schedule = schedule
        self.alwaysExpanded = alwaysExpanded
        if alwaysExpanded == true {
            _showFullSchedule = State(wrappedValue: true)
        }
    }
    
    @EnvironmentObject private var locationManager: LocationManager
        
    @State private var showFullSchedule = false
    @State private var chevronAngle: Double = 0
    
    private let daysOfWeek = ["L", "M", "X", "J", "V", "S", "D"]
    
    var body: some View {
        if let openingHours = station.openingHours {
            if alwaysExpanded {
                Content(openingHours: openingHours)
                    .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                    .padding()
            }
            else {
                Button {
                    withAnimation(.default) {
                        showFullSchedule.toggle()
                        chevronAngle = chevronAngle.isZero ? 180 : 0
                    }
                } label: {
                    Content(openingHours: openingHours)
                }
                .buttonStyle(.plain)
                .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
                .padding()
            }
        }
        else {
            EmptyView()
        }
    }
    
    @ViewBuilder func Content(openingHours: String) -> some View {
        let dateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
        
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color.white)
                    .frameDynamicSize(width: 28, height: 28)
                    .background(.blue)
                    .cornerRadius(6)
                Spacer()
                    .frame(width: 12)
                VStack(alignment: .leading) {
                    Text("Opening hours")
                        .fontSize(16)
                        .fontWeight(.semibold)
                    Spacer()
                        .frame(height: 8)
                    Group {
                        if let formattedSchedule = schedule {
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
                    .fontSize(14)
                    .fontWeight(.medium)
                }
                if !alwaysExpanded {
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.blue)
                        .fontSize(18)
                        .fontWeight(.medium)
                        .rotationEffect(.degrees(chevronAngle))
                        .animation(.default, value: chevronAngle)
                }
            }
            if let schedule = schedule?.parsedSchedule, showFullSchedule == true {
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
                .fontSize(14)
                .transition(.opacity)
                .padding(.leading, 40)
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("ScheduleItem") {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    
    let formattedSchedule = getStationSchedule(station.openingHours!)
    
    ScrollView {
        StationDetailsScheduleItem(station: station, schedule: formattedSchedule)
            .environmentObject(LocationManager(mockData: true))
    }
}
