import SwiftUI

struct StationListEntry: View {
    var station: FuelStation
    var sortingMethod: Enums.SortingOptions
    
    init(station: FuelStation, sortingMethod: Enums.SortingOptions) {
        self.station = station
        self.sortingMethod = sortingMethod
    }
    
    private func getValue() -> String? {
        func format(_ value: Double?) -> String? {
            if let value = value {
                return String("\(formattedNumber(value: value, digits: 3)) €")
            }
            else {
                return nil
            }
        }
        
        switch sortingMethod {
        case .proximity:
            if let distance = station.distanceToUserLocation {
                if distance < 1 {
                    return String("\(Int(distance*1000)) m")
                } else {
                    return String("\(formattedNumber(value: distance)) Km")
                }
            }
        case .aGasoil:
            return format(station.gasoilAPrice)
        case .bGasoil:
            return format(station.gasoilBPrice)
        case .premiumGasoil:
            return format(station.premiumGasoilPrice)
        case .biodiesel:
            return format(station.biodieselPrice)
        case .gasoline95E10:
            return format(station.gasoline95E10Price)
        case .gasoline95E5:
            return format(station.gasoline95E5Price)
        case .gasoline95E5Premium:
            return format(station.gasoline95E5PremiumPrice)
        case .gasoline98E10:
            return format(station.gasoline98E10Price)
        case .gasoline98E5:
            return format(station.gasoline98E5Price)
        case .bioethanol:
            return format(station.bioethanolPrice)
        case .cng:
            return format(station.cngPrice)
        case .lng:
            return format(station.lngPrice)
        case .lpg:
            return format(station.lpgPrice)
        case .hydrogen:
            return format(station.hydrogenPrice)
        }
        return nil
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
                if sortingMethod != .proximity {
                    if let distance = station.distanceToUserLocation {
                        Spacer()
                            .frame(height: 4)
                        if distance < 1 {
                            Text("\(Int(distance*1000)) m from your location")
                                .font(.system(size: 14))
                        } else {
                            Text("\(formattedNumber(value: distance)) Km from your location")
                                .font(.system(size: 14))
                        }
                    }
                }
                Spacer()
                    .frame(height: 4)
                if let schedule = station.openingHours {
                    let formattedSchedule = getStationSchedule(schedule)
                    if let formattedSchedule = formattedSchedule {
                        Group {
                            if formattedSchedule.schedule.isEmpty && formattedSchedule.isCurrentlyOpen == true {
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
            if let value = getValue() {
                Spacer()
                Text(value)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
            }
            else {
                Spacer()
                Text(verbatim: "N/A")
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
            }
        }
        .foregroundStyle(Color.foreground)
    }
}
