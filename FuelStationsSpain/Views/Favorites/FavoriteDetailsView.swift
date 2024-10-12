import SwiftUI
import MapKit

struct FavoriteDetailsView: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    @EnvironmentObject private var toastProvider: ToastProvider
    
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
                        
                        Button {
                            UIPasteboard.general.string = address.capitalized
                            toastProvider.showToast(icon: "document.on.document.fill", title: String(localized: "Address copied to the clipboard"))
                        } label: {
                            StationDetailsComponents.ListItem(
                                icon: "mappin",
                                iconColor: .red,
                                title: address.capitalized,
                                subtitle: distanceText
                            )
                            .customBackgroundWithMaterial()
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        }
                        .buttonStyle(.plain)
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
                        .background(Color.listItemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    
                    HStack {
                        NavigationLink {
                            ServiceStationHistoric()
                                .environmentObject(ServiceStationHistoricViewModel(station: station))
                        } label: {
                            Label("Price history", systemImage: "chart.line.uptrend.xyaxis")
                        }
                        .buttonStyle(.borderedProminent)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                }
                .padding()
            }
            .navigationTitle(station.signage?.capitalized ?? String(localized: "Service station"))
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.listBackground)
            .toolbar {
                if let stationId = station.id {
                    StationDetailsComponents.FavoriteButton(stationId: stationId)
                }
            }
        }
    }
}

