import SwiftUI

struct StationDetailsSummary: View {
    var width: Double
    var station: FuelStation
    var schedule: OpeningSchedule?
    var distanceToLocation: Double?
    
    init(width: Double, station: FuelStation, schedule: OpeningSchedule?, distanceToLocation: Double?) {
        self.width = width
        self.station = station
        self.schedule = schedule
        self.distanceToLocation = distanceToLocation
    }
    
    @EnvironmentObject private var locationManager: LocationManager
    
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel = Defaults.favoriteFuel
    
    var body: some View {
        let favoriteFuel = runningOnPreview() ? Enums.FavoriteFuelType.gasoline95E5 : self.favoriteFuel
        let fuel = favoriteFuels.map() { $0.fuels }.flatMap() { $0 }.first() { $0.fuelType == favoriteFuel }
        if width >= 300 {
            HStack {
                Spacer()
                if favoriteFuel != .none, let fuel = fuel, let fuelPrice: Double = FuelStation.getObjectProperty(station: station, propertyName: "\(favoriteFuel.rawValue)Price") {
                    VStack(alignment: .center) {
                        Text(fuel.label)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(Color.gray)
                        Spacer()
                            .frame(height: 4)
                        Text(verbatim: "\(formattedNumber(value: fuelPrice, digits: 3)) €")
                    }
                    Spacer()
                    Divider()
                        .frame(width: 1, height: 30)
                        .padding(.horizontal, 12)
                    Spacer()
                }
                if let formattedSchedule = schedule {
                    VStack(alignment: .center) {
                        Text("Schedule")
                            .foregroundStyle(Color.gray)
                        Spacer()
                            .frame(height: 4)
                        if formattedSchedule.isCurrentlyOpen {
                            Text("Open")
                                .foregroundStyle(Color.green)
                        }
                        else {
                            Text("Closed")
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                if let distance = distanceToLocation {
                    let distanceText: String = {
                        if distance < 1 {
                            return String("\(Int(distance*1000)) m")
                        } else {
                            return String("\(formattedNumber(value: distance)) Km")
                        }
                    }()
                    Spacer()
                    Divider()
                        .frame(width: 1, height: 30)
                        .padding(.horizontal, 12)
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Distance")
                            .foregroundStyle(Color.gray)
                        Spacer()
                            .frame(height: 4)
                        Text(verbatim: distanceText)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .fontWeight(.semibold)
            .padding(.vertical)
            .fontSize(14)
        }
        else {
            VStack {
                if favoriteFuel != .none, let fuel = fuel, let fuelPrice: Double = FuelStation.getObjectProperty(station: station, propertyName: "\(favoriteFuel.rawValue)Price") {
                    HStack(alignment: .center) {
                        Text(fuel.label)
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Text(verbatim: "\(formattedNumber(value: fuelPrice, digits: 3)) €")
                    }
                    Divider()
                        .padding(.vertical, 6)
                }
                if let formattedSchedule = schedule {
                    HStack(alignment: .center) {
                        Text("Schedule")
                            .foregroundStyle(Color.gray)
                        Spacer()
                        if formattedSchedule.isCurrentlyOpen {
                            Text("Open")
                                .foregroundStyle(Color.green)
                        }
                        else {
                            Text("Closed")
                                .foregroundStyle(Color.red)
                        }
                    }
                }
                if let distance = distanceToLocation {
                    let distanceText: String = {
                        if distance < 1 {
                            return String("\(Int(distance*1000)) m")
                        } else {
                            return String("\(formattedNumber(value: distance)) Km")
                        }
                    }()
                    Divider()
                        .frame(height: 1)
                        .padding(.vertical, 6)
                    HStack(alignment: .center) {
                        Text("Distance")
                            .foregroundStyle(Color.gray)
                        Spacer()
                        Text(verbatim: distanceText)
                    }
                }
            }
            .lineLimit(1)
            .truncationMode(.tail)
            .fontWeight(.semibold)
            .padding()
            .fontSize(14)
        }
    }
}

#Preview("Big") {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    
    let locationManager = LocationManager(mockData: true)
    
    let formattedSchedule = getStationSchedule(station.openingHours!)
    let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))

    
    StationDetailsSummary(width: 500, station: station, schedule: formattedSchedule, distanceToLocation: distance)
        .environmentObject(locationManager)
}

#Preview("Small") {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    
    let locationManager = LocationManager(mockData: true)
    
    let formattedSchedule = getStationSchedule(station.openingHours!)
    let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))

    
    StationDetailsSummary(width: 250, station: station, schedule: formattedSchedule, distanceToLocation: distance)
        .environmentObject(locationManager)
        .frame(width: 250)
}
