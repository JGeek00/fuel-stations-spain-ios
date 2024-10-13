import SwiftUI

struct StationListEntry: View {
    var station: FuelStation
    var sortingMethod: Enums.StationsSortingOptions
    var hideFavoriteSymbol: Bool
    
    init(station: FuelStation, sortingMethod: Enums.StationsSortingOptions) {
        self.station = station
        self.sortingMethod = sortingMethod
        self.hideFavoriteSymbol = false
    }
    
    init(station: FuelStation, sortingMethod: Enums.StationsSortingOptions, hideFavoriteSymbol: Bool) {
        self.station = station
        self.sortingMethod = sortingMethod
        self.hideFavoriteSymbol = hideFavoriteSymbol
    }
    
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    
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
        
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        if let stationId = station.id, favoritesProvider.isFavorite(stationId: stationId) && !hideFavoriteSymbol {
                            Group {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(Color.accentColor)
                                    .fontSize(12)
                                Spacer()
                                    .frame(width: 4)
                            }
                            .transition(.opacity)
                        }
                        if let signage = station.signage {
                            Text(signage.capitalized)
                                .fontSize(18)
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                        .frame(height: 4)
                    if let address = station.address {
                        Text(address.capitalized)
                            .fontSize(14)
                    }
                    if sortingMethod != .proximity {
                        if let distance = station.distanceToUserLocation {
                            Spacer()
                                .frame(height: 4)
                            if distance < 1 {
                                Text("\(Int(distance*1000)) m from your location")
                                    .fontSize(14)
                            } else {
                                Text("\(formattedNumber(value: distance)) Km from your location")
                                    .fontSize(14)
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
                            .fontSize(14)
                            .fontWeight(.medium)
                        }
                        else {
                            EmptyView()
                        }
                    }
                    if sortingMethod == .proximity && favoriteFuel != .none, let value: Double = FuelStation.getObjectProperty(station: station, propertyName: favoriteFuel.rawValue), let fuelName = getFuelNameString(fuel: favoriteFuel) {
                        Spacer()
                            .frame(height: 4)
                        Text(verbatim: "\(fuelName): \(formattedNumber(value: value, digits: 3)) €")
                            .fontSize(14)
                            .transition(.opacity)
                    }
                }
                if let value = getValue() {
                    Spacer()
                    Text(value)
                        .fontSize(16)
                        .fontWeight(.semibold)
                }
                else {
                    Spacer()
                    Text(verbatim: "N/A")
                        .fontSize(16)
                        .fontWeight(.semibold)
                }
            }
            if station.saleType == .r {
                Spacer()
                    .frame(height: 6)
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Spacer()
                        .frame(width: 6)
                    Text("This station does not sell to the general public")
                }
                .foregroundStyle(Color.red)
                .fontSize(14)
                .fontWeight(.medium)
            }
        }
        .foregroundStyle(Color.foreground)
        .contextMenu {
            if let stationId = station.id {
                Button {
                    withAnimation(.default) {
                        if favoritesProvider.isFavorite(stationId: stationId) {
                            favoritesProvider.removeFavorite(stationId: stationId)
                        }
                        else {
                            favoritesProvider.addFavorite(stationId: stationId)
                        }
                    }
                } label: {
                    if favoritesProvider.isFavorite(stationId: stationId) {
                        Label("Remove from favorites", systemImage: "star.slash.fill")
                    }
                    else {
                        Label("Add to favorites", systemImage: "star.fill")
                    }
                }
            }
        }
    }
}

#Preview {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    List {
        StationListEntry(station: station, sortingMethod: .aGasoil)
    }
    .environmentObject(FavoritesProvider.shared)
}
