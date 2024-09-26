import SwiftUI

struct StationListEntry: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
    
    var body: some View {
        let dateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
        
        HStack {
            VStack(alignment: .leading) {
                if let signage = station.signage {
                    Text(signage.capitalized)
                        .font(.system(size: 18))
                        .fontWeight(.semibold)
                }
                Spacer()
                    .frame(height: 4)
                if let address = station.address {
                    Text(address.capitalized)
                        .font(.system(size: 14))
                }
                Spacer()
                    .frame(height: 4)
                if let schedule = station.openingHours {
                    let formattedSchedule = getStationSchedule(schedule)
                    if let formattedSchedule = formattedSchedule {
                        Group {
                            if formattedSchedule.schedule.isEmpty {
                                Text("Open 24 hours")
                                    .foregroundStyle(Color.green)
                            }
                            else if formattedSchedule.isCurrentlyOpen == true {
                                if formattedSchedule.schedule.count == 2 {
                                    Text("Open until \(dateFormatter.string(from: formattedSchedule.schedule[1]))")
                                        .foregroundStyle(Color.green)
                                }
                                else if formattedSchedule.schedule.count == 4 {
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
                            }
                            else if formattedSchedule.isCurrentlyOpen == false {
                                Text("Currently closed")
                                    .foregroundStyle(Color.red)
                            }
                            else {
                                EmptyView()
                            }
                        }
                        .font(.system(size: 14))
                        .fontWeight(.medium)
                    }
                    else {
                        EmptyView()
                    }
                }
            }
            if let distance = station.distanceToUserLocation {
                Spacer()
                Group {
                    if distance < 1 {
                        Text("\(Int(distance*1000)) m")
                    } else {
                        Text("\(formattedNumber(value: distance)) Km")
                    }
                }
                .font(.system(size: 16))
                .fontWeight(.semibold)
            }
        }
        .foregroundStyle(Color.foreground)
    }
}
