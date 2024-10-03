import SwiftUI
import AlertToast
import MapKit

struct FavoriteDetailsView: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    
    @State private var showAddedFavoritesToast = false
    @State private var showRemovedFavoritesToast = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
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
                        .background(Color.listItemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    if let locality = station.locality {
                        StationDetailsComponents.ListItem(
                            icon: "building.2.fill",
                            iconColor: .green,
                            title: String(localized: "Locality"),
                            subtitle: String(locality.capitalized)
                        )
                        .background(Color.listItemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    StationDetailsComponents.ScheduleItem(station: station)
                        .background(Color.listItemBackground)
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
                        .background(Color.listItemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    StationDetailsComponents.PricesItem(station: station)
                        .background(Color.listItemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    if let update = favoritesListViewModel.data?.lastUpdated {
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
                            .background(Color.listItemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                    }
                    StationDetailsComponents.MapView(station: station)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                }
                .padding()
            }
            .navigationTitle(station.signage?.capitalized ?? String(localized: "Service station"))
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.listBackground)
            .toolbar {
                if let stationId = station.id {
                    let isFavorite = favoritesProvider.isFavorite(stationId: stationId)
                    Button {
                        if isFavorite == true {
                            if favoritesProvider.removeFavorite(stationId: stationId) == true {
                                showAddedFavoritesToast = false
                                showRemovedFavoritesToast = true
                            }
                        }
                        else {
                            if favoritesProvider.addFavorite(stationId: stationId) == true {
                                showRemovedFavoritesToast = false
                                showAddedFavoritesToast = true
                            }
                        }                    } label: {
                        Image(systemName: isFavorite == true ? "star.fill" : "star")
                            .fontWeight(.semibold)
                            .animation(.default, value: isFavorite)
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
            }
            .toast(isPresenting: $showAddedFavoritesToast, duration: 3, tapToDismiss: true) {
                AlertToast(displayMode: .alert, type: .systemImage("star.fill", .foreground), title: String(localized: "Added to favorites"))
            }
            .toast(isPresenting: $showRemovedFavoritesToast, duration: 3, tapToDismiss: true) {
                AlertToast(displayMode: .alert, type: .systemImage("star.slash.fill", .foreground), title: String(localized: "Removed from favorites"))
            }
        }
    }
}

