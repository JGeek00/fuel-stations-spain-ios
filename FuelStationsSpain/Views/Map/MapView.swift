import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
            ContentUnavailableView("Location access required", systemImage: "location.fill", description: Text("This application requires location access to show you the nearby service stations."))
        }
        else {
            MapComponent()
        }
    }
}

fileprivate struct MapComponent: View {
    
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var locationManager: LocationManager
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic: Bool = Defaults.hideStationsNotOpenPublic
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel: Bool = Defaults.hideStationsDontHaveFavoriteFuel
    
    private func getFuelValue(_ item: FuelStation, property: Enums.FavoriteFuelType) -> Double? {
        switch property {
        case .none:
            return nil
        case .aGasoil:
            return item.gasoilAPrice
        case .bGasoil:
            return item.gasoilBPrice
        case .premiumGasoil:
            return item.premiumGasoilPrice
        case .biodiesel:
            return item.biodieselPrice
        case .gasoline95E10:
            return item.gasoline95E10Price
        case .gasoline95E5:
            return item.gasoline95E5Price
        case .gasoline95E5Premium:
            return item.gasoline95E5PremiumPrice
        case .gasoline98E10:
            return item.gasoline98E5Price
        case .gasoline98E5:
            return item.gasoline98E5Price
        case .bioethanol:
            return item.bioethanolPrice
        case .cng:
            return item.cngPrice
        case .lng:
            return item.lngPrice
        case .lpg:
            return item.lpgPrice
        case .hydrogen:
            return item.hydrogenPrice
        }
    }

    var body: some View {
        Map(position: $mapManager.position, bounds: MapCameraBounds(minimumDistance: 500, maximumDistance: 50000)) {
            if let stations = mapManager.data?.results {
                let markers = {
                    var m = stations.filter() { $0.signage != nil && $0.latitude != nil && $0.longitude != nil }
                    if hideStationsNotOpenPublic == true {
                        m = m.filter() { $0.saleType != .r }
                    }
                    if hideStationsDontHaveFavoriteFuel == true && favoriteFuel != .none {
                        m = m.filter() { item in
                            if getFuelValue(item, property: favoriteFuel) != nil {
                                return true
                            }
                            return false
                        }
                    }
                    return m
                }()
                ForEach(markers, id: \.id) { value in
                    Annotation(value.signage!, coordinate: CLLocationCoordinate2D(latitude: value.latitude!, longitude: value.longitude!)) {
                        MarkerIcon()
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.markerGradientStart, Color.markerGradientEnd]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                Task {
                                    // await to prevent opening a sheet with another one already open
                                    if mapManager.showStationSheet == true {
                                        mapManager.showStationSheet = false
                                        try await Task.sleep(for: .seconds(0.7))
                                    }
                                    mapManager.selectStation(station: value)
                                }
                            }
                    }
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd, { value in
            mapManager.onMapCameraChange(value)
        })
        .overlay(alignment: .topLeading) {
            GeometryReader(content: { geometry in
                Group {
                    Button {
                        withAnimation(.easeOut) {
                            mapManager.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
                        }
                    } label: {
                        Image(systemName: "location.fill.viewfinder")
                            .font(.system(size: 22))
                            .foregroundStyle(locationManager.lastLocation != nil ? Color.foreground : Color.gray)
                            .contentShape(Rectangle())
                    }
                    .disabled(locationManager.lastLocation == nil)
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                }
                .offset(x: geometry.size.width - 52, y: 12)
                Group {
                    Button {
                        if mapManager.showStationSheet == true {
                            mapManager.showStationSheet = false
                        }
                        mapManager.showStationsSheet.toggle()
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.foreground)
                            .contentShape(Rectangle())
                    }
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                }
                .offset(x: geometry.size.width - 52, y: 70)
                if mapManager.loading == true || mapManager.error != nil {
                    Group {
                        Button {
                            mapManager.showErrorAlert.toggle()
                        } label: {
                            Group {
                                if mapManager.loading == true {
                                    ProgressView()
                                        .font(.system(size: 24))
                                }
                                else {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.red)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .frame(width: 40, height: 40)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .disabled(mapManager.loading)
                    }
                    .offset(x: 12, y: 50)
                    .transition(.opacity)
                }
            })
        }
        .alert("Success", isPresented: $mapManager.showSuccessAlert, actions: {
            Button("Close") {
                mapManager.showSuccessAlert.toggle()
            }
        }, message: {
            Text("Data loaded successfully.")
        })
        .alert("Error", isPresented: $mapManager.showErrorAlert, actions: {
            Button("Close") {
                mapManager.showErrorAlert.toggle()
            }
            Button("Retry") {
                Task {
                    await mapManager.fetchData(latitude: mapManager.latitude, longitude: mapManager.longitude)
                }
            }
        }, message: {
            switch mapManager.error {
                case .connection:
                    Text("Cannot establish a connection with the server. Check your Internet connection.")
                case .usage:
                    Text("Usage quota exceded. Try again later.")
                default:
                    Text("Unknown error.")
            }
        })
        .sheet(isPresented: $mapManager.showStationsSheet, content: {
            StationsSheet()
        })
        .sheet(isPresented: $mapManager.showStationSheet) {
            if horizontalSizeClass == .compact {
                StationDetailsSheet()
                    .presentationBackground(Material.regular)
                    .presentationDetents([.fraction(0.5), .fraction(0.99)])
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .fraction(0.99))
                    )
            }
            else {
                StationDetailsSheet()
                    .presentationBackground(Material.regular)
            }
        }
    }
}
