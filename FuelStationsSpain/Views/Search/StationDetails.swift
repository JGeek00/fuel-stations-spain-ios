import SwiftUI

struct SearchStationDetails: View {
    
    @Environment(SearchViewModel.self) private var searchViewModel
    @Environment(LocationManager.self) private var locationManager
    @Environment(FavoritesProvider.self) private var favoritesProvider
    @Environment(FavoritesListViewModel.self) private var favoritesListViewModel
    @EnvironmentObject private var toastProvider: ToastProvider
    
    @State private var navigationPath = NavigationPath()
        
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let station = searchViewModel.selectedStation {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            Address(station: station)
                            Locality(station: station)
                            StationDetailsComponents.ScheduleItem(station: station)
                                .background(Color.listItemBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            SaleType(station: station)
                            StationDetailsComponents.PricesItem(station: station)
                                .background(Color.listItemBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            
                            StationDetailsComponents.MapView(station: station) {
                                navigationPath.append(NavigateHowToReachStation(station: station))
                            }
                            .background(Color.listItemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            LastUpdated()
                            HStack {
                                NavigationLink {
                                    ServiceStationHistoric(station: station)
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
                else {
                    ContentUnavailableView("Select a station", systemImage: "fuelpump.fill", description: Text("Select a service station to see it's details."))
                }
            }
            .navigationDestination(for: NavigateHowToReachStation.self) { value in
                HowToReachStation(station: value.station)
            }
        }
    }
    
    @ViewBuilder private func Address(station: FuelStation) -> some View {
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
    }
    
    @ViewBuilder private func Locality(station: FuelStation) -> some View {
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
    }
    
    @ViewBuilder private func SaleType(station: FuelStation) -> some View {
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
                        .fontSize(14)
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
                        .fontSize(14)
                        .fontWeight(.medium)
                    )
                }
            }
            .background(Color.listItemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
    }
    
    @ViewBuilder private func LastUpdated() -> some View {
        if let update = favoritesListViewModel.data?.lastUpdated {
            if let date = formatDate(update) {
                StationDetailsComponents.ListItem(
                    icon: "arrow.down.circle.fill",
                    iconColor: .brown,
                    title: String(localized: "Latest information")
                ) {
                    AnyView(
                        Text(date, format: .dateTime.weekday().day().hour().minute())
                            .fontSize(14)
                            .foregroundStyle(Color.gray)
                            .fontWeight(.medium)
                    )
                }
                .background(Color.listItemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8.0))
            }
        }
    }
}
