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

    @Namespace private var mapScope
    
    @State private var selectedDetent: PresentationDetent = .fraction(0.5)

    var body: some View {
        MapComponent()
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
                Button("Close", role: .cancel) {
                    mapManager.movingMapFastAlert = false
                }
                Button("Retry") {
                    Task {
                        await mapManager.fetchData(latitude: mapManager.latitude, longitude: mapManager.longitude)
                    }
                }
            }, message: {
                Text("The data provider has a system to prevent overloads. Move the map slower to load the data. Restart the app and try again.")
            })
            .alert("Connection error", isPresented: $mapManager.connectionErrorAlert, actions: {
                Button("Close", role: .cancel) {
                    mapManager.connectionErrorAlert = true
                }
                Button("Retry") {
                    Task {
                        await mapManager.fetchData(latitude: mapManager.latitude, longitude: mapManager.longitude)
                    }
                }
            }, message: {
                Text("Cannot establish a connection to the server. Check your Internet connection or try again later.")
            })
            .sheet(isPresented: $mapManager.showStationsSheet, content: {
                StationsSheet()
            })
            .if(UIDevice.current.userInterfaceIdiom == .pad) { view in
                Group {
                    GeometryReader { proxy in
                        view
                            .bottomSheet(
                                bottomSheetPosition: $mapManager.stationDetailsSheetPosition,
                                switchablePositions: [.absoluteBottom(70), .dynamicTop],
                                headerContent: {
                                    StationDetailsSheetHeader(isSideSheet: true)
                                }
                            ) {
                                StationDetailsSheetContent(width: proxy.size.width)
                                    .padding(.top)
                            }
                            .sheetWidth(.relative(0.4))
                            .enableAccountingForKeyboardHeight()
                            .enableAppleScrollBehavior()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.background))
                    }
                }
            }
            .if(UIDevice.current.userInterfaceIdiom != .pad) { view in
                view
                    .sheet(isPresented: $mapManager.showStationDetailsSheet, onDismiss: {
                        mapManager.selectedStationAnimation = nil
                        mapManager.isOpeningOrClosingSheet = true
                    }, content: {
                        GeometryReader { proxy in
                            Group {
                                if mapManager.selectedStation != nil {
                                    ScrollView {
                                        StationDetailsSheetHeader(isSideSheet: false)
                                        StationDetailsSheetContent(width: proxy.size.width)
                                    }
                                    .transition(.opacity)
                                }
                                else {
                                    ContentUnavailableView("No station selected", systemImage: "xmark.circle", description: Text("Select a service station to see it's details."))
                                        .transition(.opacity)
                                }
                            }
                            .presentationBackground {
                                // On versions prior to iOS 26 a background must always be defined
                                if #available(iOS 26.0, *) {
                                    if selectedDetent == .fraction(0.99) {
                                        Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
                                    }
                                }
                                else {
                                    Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
                                }
                            }
                            .presentationDetents([.fraction(0.5), .fraction(0.99)], selection: $selectedDetent)
                            .presentationBackgroundInteraction(
                                .enabled(upThrough: .fraction(0.99))
                            )
                            .onDisappear {
                                if mapManager.isOpeningOrClosingSheet == true {
                                    mapManager.selectedStation = nil
                                    mapManager.isOpeningOrClosingSheet = false
                                }
                            }
                        }
                    })
            }
            .mapScope(mapScope)
    }
    
    @ViewBuilder
    private func MapComponent() -> some View {
        let mpStyle: MapStyle = {
            switch mapStyle {
            case .standard: return MapStyle.standard
            case .hybrid: return MapStyle.hybrid
            case .satellite: return MapStyle.imagery
            }
        }()
        
        Map(position: $mapManager.position, bounds: MapCameraBounds(minimumDistance: 500, maximumDistance: 50000), scope: mapScope) {
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
                        MapMarkerBubble(value)
                            .environmentObject(MapManager.shared)
                    }
                }
            }
        }
        .mapStyle(mpStyle)
        .mapControls {
            MapScaleView()
        }
        .onMapCameraChange(frequency: .onEnd, { value in
            mapManager.onMapCameraChange(value)
        })
        .overlay(alignment: .topTrailing) {
            MapOverlayRightButtons(mapScope: mapScope)
        }
        .overlay(alignment: .topLeading, content: {
            MapOverlayLeftButtons()
        })
    }
}
