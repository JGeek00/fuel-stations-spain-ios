import SwiftUI

struct StationListEntry: View {
    var station: FuelStation
    var onTap: () -> Void
    
    init(station: FuelStation, onTap: @escaping () -> Void) {
        self.station = station
        self.onTap = onTap
    }
    
    var body: some View {
        let dateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter
        }()
        
        Button {
            onTap()
        } label: {
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
                                if formattedSchedule.closing == nil && formattedSchedule.opening == nil {
                                    Text("Open 24 hours")
                                        .foregroundStyle(Color.green)
                                }
                                else if formattedSchedule.isCurrentlyOpen == true {
                                    Text("Open until \(dateFormatter.string(from: formattedSchedule.closing!))")
                                        .foregroundStyle(Color.green)
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
}
