import SwiftUI
import MapKit

struct FavoriteDetailsView: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var tabViewManager: TabViewManager
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    @EnvironmentObject private var toastProvider: ToastProvider
    
    @AppStorage(StorageKeys.showStationSummary, store: UserDefaults.shared) private var showStationSummary = Defaults.showStationSummary
    
    @State private var defineStationAliasOpen = false
    @State private var stationAliasTextField: String = ""
    
    @State private var navigationPath = NavigationPath()
    @State private var lookAroundScene: MKLookAroundScene? = nil
    
    var body: some View {
        let alias = favoritesProvider.favorites.first(where: { $0.id == station.id! })?.alias
        
        let formattedSchedule = getStationSchedule(station.openingHours!)
        let distanceToUserLocation: Double? = {
            if station.latitude != nil && station.longitude != nil && locationManager.lastLocation?.coordinate.latitude != nil && locationManager.lastLocation?.coordinate.longitude != nil {
                let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))
                return distance
            }
            return nil
        }()
        
        NavigationStack(path: $navigationPath) {
            GeometryReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if showStationSummary {
                            Text("Summary")
                                .fontSize(22)
                                .fontWeight(.bold)
                            StationDetailsSummary(width: proxy.size.width, station: station, schedule: formattedSchedule, distanceToLocation: distanceToUserLocation)
                                .customBackgroundWithMaterial()
                                .clipShape(RoundedRectangle(cornerRadius: 8.0))
                            
                            Divider()
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                            
                            Text("Details")
                                .fontSize(22)
                                .fontWeight(.bold)
                        }
                        Alias(alias: alias)
                        Address()
                        Locality()
                        StationDetailsScheduleItem(station: station, schedule: formattedSchedule, alwaysExpanded: showStationSummary)
                            .background(Color.listItemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        SaleType()
                        StationDetailsPricesItem(station: station)
                            .background(Color.listItemBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        
                        StationDetailsMapItem(station: station, lookAroundScene: lookAroundScene) {
                            navigationPath.append(NavigateHowToReachStation(station: station))
                        }
                        .background(Color.listItemBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        LastUpdated()
                        HStack {
                            NavigationLink {
                                HistoricPricesView(station: station, showingInSheet: false)
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
                    StationDetailsFavoriteButton(station: station, backgroundCircle: false)
                    Menu {
                        Button {
                            stationAliasTextField = alias ?? ""
                            defineStationAliasOpen = true
                        } label: {
                            Label("Set station alias", systemImage: "pencil")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                .alert("Define station alias", isPresented: $defineStationAliasOpen) {
                    TextField("Alias", text: $stationAliasTextField)
                    Button("Cancel", role: .cancel) {
                        defineStationAliasOpen = false
                    }
                    Button("Save") {
                        favoritesProvider.setFavoriteAlias(stationId: station.id!, newAlias: stationAliasTextField)
                        defineStationAliasOpen = false
                    }
                } message: {
                    Text("You can define an alias for this station. This will make it easier for you to identify it.")
                }
                .navigationDestination(for: NavigateHowToReachStation.self) { value in
                    HowToReachStation(station: value.station)
                }
                .onChange(of: station, initial: true) {
                    DispatchQueue.global(qos: .background).async {
                        Task {
                            let result = await getLookAroundScene(latitude: station.latitude!, longitude: station.longitude!)
                            DispatchQueue.main.async {
                                lookAroundScene = result
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func Alias(alias: String?) -> some View {
        if let stationAlias = alias, !stationAlias.isEmpty {
            StationDetailsListItem(
                icon: "pencil",
                iconColor: .gray,
                title: String(localized: "Station alias"),
                subtitle: stationAlias
            )
            .customBackgroundWithMaterial()
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            .animation(.default, value: alias)
        }
    }
    
    @ViewBuilder private func Address() -> some View {
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
                StationDetailsListItem(
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
    
    @ViewBuilder private func Locality() -> some View {
        if let locality = station.locality {
            StationDetailsListItem(
                icon: "building.2.fill",
                iconColor: .green,
                title: String(localized: "Locality"),
                subtitle: String(locality.capitalized)
            )
            .background(Color.listItemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
        }
    }
    
    @ViewBuilder private func SaleType() -> some View {
        if let saleType = station.saleType {
            StationDetailsListItem(
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
                StationDetailsListItem(
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

