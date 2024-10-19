import SwiftUI
import MapKit
import Sentry

fileprivate let delta = 0.003

func getLookAroundScene(latitude: Double, longitude: Double) async -> MKLookAroundScene? {
    let request = MKLookAroundSceneRequest(coordinate: .init(latitude: latitude, longitude: longitude))
    do {
        let result = try await request.scene
        return result
    } catch let error {
        DispatchQueue.main.async {
            SentrySDK.capture(error: error)
        }
        return nil
    }
}

struct StationDetailsMapItem: View {
    var station: FuelStation
    var onShowHowToGetThere: () -> Void
    var showOnlyLookAround: Bool
    var lookAroundScene: MKLookAroundScene?
    
    init(station: FuelStation, showOnlyLookAround: Bool = false, lookAroundScene: MKLookAroundScene?, onShowHowToGetThere: @escaping () -> Void) {
        self.station = station
        self.onShowHowToGetThere = onShowHowToGetThere
        self.showOnlyLookAround = showOnlyLookAround
        self.lookAroundScene = lookAroundScene
    }
    
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var tabViewManager: TabViewManager
    @EnvironmentObject private var locationManager: LocationManager
    
    @Environment(\.openURL) private var openURL
    
    @State private var camera = MapCameraPosition.region(.init(center: Config.defaultCoordinates, span: .init(latitudeDelta: delta, longitudeDelta: delta)))
    @State private var mapMode = Enums.LocationPreviewMode.map
    @State private var showLookAround = false // Just for the transition
    
    var body: some View {
        VStack {
            if let signage = station.signage, let latitude = station.latitude, let longitude = station.longitude {
                if showOnlyLookAround {
                    LookAround()
                        .frame(height: 300)
                }
                else {
                    Picker("Map mode", selection: $mapMode) {
                        Text("Map view")
                            .tag(Enums.LocationPreviewMode.map)
                        Text("Look around view")
                            .tag(Enums.LocationPreviewMode.lookAround)
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    Group {
                        if showLookAround {
                            LookAround()
                        }
                        else {
                            Map(position: $camera, interactionModes: []) {
                                Marker(signage.capitalized, coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                            }
                            .mapStyle(.standard(pointsOfInterest: .excludingAll))
                            .transition(.opacity)
                        }
                    }
                    .frame(height: 300)
                    .onChange(of: mapMode) {
                        withAnimation(.default) {
                            showLookAround = mapMode == .lookAround
                        }
                    }
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Button("Show in map") {
                            mapManager.selectStation(station: station, centerLocation: true)
                            tabViewManager.selectedTab = .map
                        }
                        .frame(maxWidth: .infinity)
                        .disabled(runningOnPreview())
                        Divider()
                            .frame(width: 1)
                        Button("How to get there") {
                            onShowHowToGetThere()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                }
            }
        }
        .onChange(of: station, initial: true) {
            if let latitude = station.latitude, let longitude = station.longitude {
                camera = MapCameraPosition.region(.init(center: .init(latitude: latitude, longitude: longitude), span: .init(latitudeDelta: delta, longitudeDelta: delta)))
            }
        }
    }
    
    @ViewBuilder func LookAround() -> some View {
        if lookAroundScene != nil {
            LookAroundPreview(initialScene: lookAroundScene)
                .transition(.opacity)
        }
        else {
            ContentUnavailableView("Look around not available", systemImage: "binoculars.fill", description: Text("The look around feature is not available on this area."))
                .transition(.opacity)
        }
    }
}

#Preview("MapItem") {
    @Previewable @State var lookAroundScene: MKLookAroundScene? = nil
    
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    
    ScrollView {
        StationDetailsMapItem(station: station, lookAroundScene: lookAroundScene) {}
            .environmentObject(MapManager.shared)
            .environmentObject(LocationManager(mockData: true))
            .onAppear {
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
