import SwiftUI

struct StationDetailsSheet: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
        
    private func formatDate(_ value: String) -> Date? {
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
                        if let stationId = station.id {
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
                            
                            StationDetailsComponents.ListItem(
                                icon: "mappin",
                                iconColor: .red,
                                title: address.capitalized,
                                subtitle: distanceText
                            )
                            .customBackgroundWithMaterial()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                        if let locality = station.locality {
                            StationDetailsComponents.ListItem(
                                icon: "building.2.fill",
                                iconColor: .green,
                                title: String(localized: "Locality"),
                                subtitle: String(locality.capitalized)
                            )
                            .customBackgroundWithMaterial()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                        StationDetailsComponents.ScheduleItem(station: station)
                            .customBackgroundWithMaterial()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        if let saleType = station.saleType {
                            StationDetailsComponents.ListItem(
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
                            .customBackgroundWithMaterial()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                        StationDetailsComponents.PricesItem(station: station)
                            .customBackgroundWithMaterial()
                        if let update = mapViewModel.data?.lastUpdated {
                            if let date = formatDate(update) {
                                StationDetailsComponents.ListItem(
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
                                .customBackgroundWithMaterial()
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
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
