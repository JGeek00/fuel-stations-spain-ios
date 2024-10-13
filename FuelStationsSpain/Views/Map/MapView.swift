import SwiftUI
import MapKit
import BottomSheet

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
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic: Bool = Defaults.hideStationsNotOpenPublic
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    @AppStorage(StorageKeys.hideStationsDontHaveFavoriteFuel, store: UserDefaults.shared) private var hideStationsDontHaveFavoriteFuel: Bool = Defaults.hideStationsDontHaveFavoriteFuel
    @AppStorage(StorageKeys.mapStyle, store: UserDefaults.shared) private var mapStyle: Enums.MapStyle = Defaults.mapStyle

    var body: some View {
        let mpStyle: MapStyle = {
            switch mapStyle {
            case .standard: return MapStyle.standard
            case .hybrid: return MapStyle.hybrid
            case .satellite: return MapStyle.imagery
            }
        }()
        Map(position: $mapManager.position, bounds: MapCameraBounds(minimumDistance: 500, maximumDistance: 50000)) {
            if let stations = mapManager.data?.results {
                let markers = {
                    var m = stations.filter() { $0.signage != nil && $0.latitude != nil && $0.longitude != nil }
                    if hideStationsNotOpenPublic == true {
                        m = m.filter() { $0.saleType != .r }
                    }
                    if hideStationsDontHaveFavoriteFuel == true && favoriteFuel != .none {
                        m = m.filter() { item in
                            let price: Double? = FuelStation.getObjectProperty(station: item, propertyName: "\(favoriteFuel.rawValue)Price")
                            if price != nil {
                                return true
                            }
                            return false
                        }
                    }
                    return m
                }()
                ForEach(markers, id: \.id) { value in
                    Annotation(value.signage!, coordinate: CLLocationCoordinate2D(latitude: value.latitude!, longitude: value.longitude!)) {
                        MapMarkerItem(value)
                            .environmentObject(MapManager.shared)
                    }
                }
            }
        }
        .mapStyle(mpStyle)
        .onMapCameraChange(frequency: .onEnd, { value in
            mapManager.onMapCameraChange(value)
        })
        .overlay(alignment: .topLeading) {
            MapOverlay()
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
        .alert("You are moving the map too fast", isPresented: $mapManager.movingMapFastAlert, actions: {
            Button("Close") {
                mapManager.movingMapFastAlert = false
            }
        }, message: {
            Text("The data provider has a system to prevent overloads. Move the map slower to load the data. Restart the app and try again.")
        })
        .alert("Connection error", isPresented: $mapManager.connectionErrorAlert, actions: {
            Button("Close") {
                mapManager.connectionErrorAlert = true
            }
        }, message: {
            Text("Cannot establish a connection to the server. Check your Internet connection or try again later.")
        })
        .sheet(isPresented: $mapManager.showStationsSheet, content: {
            StationsSheet()
        })
        .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
            Group {
                view
                    .bottomSheet(
                        bottomSheetPosition: $mapManager.stationDetailsSheetPosition,
                        switchablePositions: [.absoluteBottom(70), .dynamicTop],
                        headerContent: {
                            StationDetailsSheetHeader(isSideSheet: true)
                        }
                    ) {
                        StationDetailsSheetContent()
                            .padding(.top)
                    }
                    .sheetWidth(.relative(0.4))
                    .enableAccountingForKeyboardHeight()
                    .enableAppleScrollBehavior()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.background))
            }
        }
        .if(UIDevice.current.userInterfaceIdiom != .pad) { view in
            view
                .sheet(isPresented: $mapManager.showStationDetailsSheet, onDismiss: {
                    mapManager.selectedStationAnimation = nil
                    mapManager.isOpeningOrClosingSheet = true
                }, content: {
                    Group {
                        if mapManager.selectedStation != nil {
                            ScrollView {
                                StationDetailsSheetHeader(isSideSheet: false)
                                StationDetailsSheetContent()
                            }
                            .transition(.opacity)
                        }
                        else {
                            ContentUnavailableView("No station selected", systemImage: "xmark.circle", description: Text("Select a service station to see it's details."))
                                .transition(.opacity)
                        }
                    }
                    .presentationBackground(Material.regular)
                    .presentationDetents([.fraction(0.5), .fraction(0.99)])
                    .presentationBackgroundInteraction(
                        .enabled(upThrough: .fraction(0.99))
                    )
                    .onDisappear {
                        mapManager.selectedStation = nil
                        mapManager.isOpeningOrClosingSheet = false
                    }
                })
        }
    }
    
    @ViewBuilder
    private func MapOverlay() -> some View {
        GeometryReader(content: { geometry in
            Group {
                Button {
                    withAnimation(.easeOut) {
                        mapManager.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
                    }
                } label: {
                    Image(systemName: "location.fill.viewfinder")
                        .fontSize(22)
                        .foregroundStyle(locationManager.lastLocation != nil ? Color.foreground : Color.gray)
                        .contentShape(Rectangle())
                }
                .disabled(locationManager.lastLocation == nil)
                .frameDynamicSize(width: 40, height: 40)
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 5)
            }
            .offset(x: geometry.size.width - (52 * fontSizeMultiplier(for: dynamicTypeSize)), y: 12 * fontSizeMultiplier(for: dynamicTypeSize))
            Group {
                Button {
                    mapManager.showStationDetailsSheet = false
                    mapManager.stationDetailsSheetPosition = .hidden
                    mapManager.selectedStationAnimation = nil
                    mapManager.selectedStation = nil
                    mapManager.showStationsSheet = true
                } label: {
                    Image(systemName: "list.bullet")
                        .fontSize(22)
                        .foregroundStyle(Color.foreground)
                        .contentShape(Rectangle())
                }
                .frameDynamicSize(width: 40, height: 40)
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.3), radius: 5)
            }
            .offset(x: geometry.size.width - (52 * fontSizeMultiplier(for: dynamicTypeSize)), y: 70 * fontSizeMultiplier(for: dynamicTypeSize))
            if mapManager.loading == true || mapManager.error != nil {
                Group {
                    Button {
                        mapManager.showErrorAlert.toggle()
                    } label: {
                        Group {
                            if mapManager.loading == true {
                                ProgressView()
                                    .fontSize(24)
                            }
                            else {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .fontSize(22)
                                    .foregroundStyle(Color.red)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .frameDynamicSize(width: 40, height: 40)
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                    .disabled(mapManager.loading)
                }
                .offset(x: 12 * fontSizeMultiplier(for: dynamicTypeSize), y: 50 * fontSizeMultiplier(for: dynamicTypeSize))
                .transition(.opacity)
            }
        })
    }
}

fileprivate struct MapMarkerItem: View {
    var value: FuelStation
    
    init(_ value: FuelStation) {
        self.value = value
    }
    
    @EnvironmentObject private var mapManager: MapManager
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @AppStorage(StorageKeys.closedStationsShowMethod, store: UserDefaults.shared) private var closedStationsShowMethod: Enums.ClosedStationsMode = Defaults.closedStationsShowMethod
    @AppStorage(StorageKeys.showRedClockClosedStations, store: UserDefaults.shared) private var showRedClockClosedStations = Defaults.showRedClockClosedStations
    @AppStorage(StorageKeys.favoriteFuel, store: UserDefaults.shared) private var favoriteFuel: Enums.FavoriteFuelType = Defaults.favoriteFuel
    
    @State private var formattedSchedule: OpeningSchedule?
    
    var body: some View {
        let fuelPrice: Double? = FuelStation.getObjectProperty(station: value, propertyName: "\(favoriteFuel.rawValue)Price")
        Group {
            if !(formattedSchedule?.isCurrentlyOpen == false && closedStationsShowMethod == .hideCompletely) {
                if favoriteFuel != .none, let fuelPrice = fuelPrice {
                    PriceMarker()
                        .foregroundStyle(Color.background)
                        .frameDynamicSize(width: 60, height: 34)
                        .overlay(alignment: .center) {
                            Text(verbatim: "\(formattedNumber(value: fuelPrice, digits: 3))€")
                                .fontSize(14)
                                .fontWeight(.semibold)
                                .padding(.bottom, 30*0.2)
                        }
                        .overlay(PriceMarker().stroke(Color.gray, lineWidth: 0.5))
                        .overlay(alignment: .topTrailing, content: {
                            if formattedSchedule?.isCurrentlyOpen == false && showRedClockClosedStations == true {
                                RedClock()
                            }
                        })
                        .opacity(formattedSchedule?.isCurrentlyOpen == false && closedStationsShowMethod == .showDimmed ? 0.5 : 1)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        .scaleEffect(value.id == mapManager.selectedStationAnimation?.id ? 1.5 : 1, anchor: .bottom)
                        .animation(.bouncy(extraBounce: 0.2), value: mapManager.selectedStationAnimation?.id)
                        .onTapGesture {
                            mapManager.selectStation(station: value)
                        }
                }
                else {
                    NormalMarker()
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.markerGradientStart, Color.markerGradientEnd]), startPoint: .top, endPoint: .bottom))
                        .frameDynamicSize(width: 30, height: 30)
                        .overlay(alignment: .topTrailing, content: {
                            if formattedSchedule?.isCurrentlyOpen == false && showRedClockClosedStations == true {
                                RedClock()
                            }
                        })
                        .opacity(formattedSchedule?.isCurrentlyOpen == false && closedStationsShowMethod == .showDimmed ? 0.5 : 1)
                        .scaleEffect(value.id == mapManager.selectedStationAnimation?.id ? 1.5 : 1, anchor: .bottom)
                        .animation(.bouncy(extraBounce: 0.2), value: mapManager.selectedStationAnimation?.id)
                        .onTapGesture {
                            mapManager.selectStation(station: value)
                        }
                }
            }
        }
        .onAppear {
            formattedSchedule = value.openingHours != nil ? getStationSchedule(value.openingHours!) : nil
        }
    }
    
    @ViewBuilder
    private func RedClock() -> some View {
        Circle()
            .offset(x: 6 * fontSizeMultiplier(for: dynamicTypeSize), y: -6 * fontSizeMultiplier(for: dynamicTypeSize))
            .frameDynamicSize(width: 15, height: 15)
            .foregroundStyle(Color.background)
            .overlay(alignment: .center) {
                Image(systemName: "clock.fill")
                    .offset(x: 6 * fontSizeMultiplier(for: dynamicTypeSize), y: -6 * fontSizeMultiplier(for: dynamicTypeSize))
                    .foregroundStyle(Color.red)
                    .fontSize(14)
            }
    }
    
}
