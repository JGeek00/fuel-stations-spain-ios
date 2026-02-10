import SwiftUI
import MapKit

struct SearchStationDetails: View {
    var isSplitView: Bool

    init(isSplitView: Bool) {
        self.isSplitView = isSplitView
    }
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @AppStorage(StorageKeys.showStationSummary, store: UserDefaults.shared) private var showStationSummary = Defaults.showStationSummary
    
    @State private var navigationPath = NavigationPath()
    @State private var lookAroundScene: MKLookAroundScene? = nil
        
    var body: some View {
        if isSplitView == true {
            NavigationStack(path: $navigationPath) {
                Content()
            }
            .navigationDestination(for: NavigateHowToReachStation.self) { value in
                HowToReachStation(station: value.station)
            }
        }
        else {
            Content()
        }
    }
    
    @ViewBuilder private func Content() -> some View {
        if let station = searchViewModel.selectedStation {
            let formattedSchedule = getStationSchedule(station.openingHours!)
            let distanceToUserLocation: Double? = {
                if station.latitude != nil && station.longitude != nil && locationManager.lastLocation?.coordinate.latitude != nil && locationManager.lastLocation?.coordinate.longitude != nil {
                    let distance = distanceBetweenCoordinates(Coordinate(latitude: station.latitude!, longitude: station.longitude!), Coordinate(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude))
                    return distance
                }
                return nil
            }()
            
            GeometryReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        if showStationSummary {
                            Text("Summary")
                                .fontSize(22)
                                .fontWeight(.bold)
                            StationDetailsSummary(width: proxy.size.width, station: station, schedule: formattedSchedule, distanceToLocation: distanceToUserLocation)
                                .cardGlassBackgroundIfAvailable()
                            
                            Divider()
                                .padding(.top, 12)
                                .padding(.bottom, 8)
                            
                            Text("Details")
                                .fontSize(22)
                                .fontWeight(.bold)
                        }
                        
                        Address(station: station, distance: distanceToUserLocation)
                        
                        Locality(station: station)
                        
                        StationDetailsScheduleItem(station: station, schedule: formattedSchedule, alwaysExpanded: showStationSummary)
                            .cardGlassBackgroundIfAvailable()
                        
                        SaleType(station: station)
                        
                        StationDetailsPricesItem(station: station)
                            .cardGlassBackgroundIfAvailable()
                        
                        StationDetailsMapItem(station: station, lookAroundScene: lookAroundScene) {
                            if isSplitView == true {
                                navigationPath.append(NavigateHowToReachStation(station: station))
                            }
                            else {
                                searchViewModel.navigationPath.append(NavigateHowToReachStation(station: station))
                            }
                        }
                        .cardGlassBackgroundIfAvailable()
                        
                        LastUpdated()
                        
                        HStack {
                            NavigationLink {
                                HistoricPricesView(station: station, showingInSheet: false)
                            } label: {
                                Label("Price history", systemImage: "chart.line.uptrend.xyaxis")
                            }
                            .condition { view in
                                if #available(iOS 26.0, *) {
                                    view.buttonStyle(.glassProminent)
                                } else {
                                    view.buttonStyle(.borderedProminent)
                                }
                            }
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
        else {
            ContentUnavailableView("Select a station", systemImage: "fuelpump.fill", description: Text("Select a service station to see it's details."))
        }
    }
    
    @ViewBuilder private func Address(station: FuelStation, distance: Double?) -> some View {
        if let address = station.address {
            let distanceText: String? = {
                if let distance {
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
                .cardGlassBackgroundIfAvailable()
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder private func Locality(station: FuelStation) -> some View {
        if let locality = station.locality {
            StationDetailsListItem(
                icon: "building.2.fill",
                iconColor: .green,
                title: String(localized: "Locality"),
                subtitle: String(locality.capitalized)
            )
            .cardGlassBackgroundIfAvailable()
        }
    }
    
    @ViewBuilder private func SaleType(station: FuelStation) -> some View {
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
            .cardGlassBackgroundIfAvailable()
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
                .cardGlassBackgroundIfAvailable()
            }
        }
    }
}
