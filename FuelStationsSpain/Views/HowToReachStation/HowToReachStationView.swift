import SwiftUI
@preconcurrency import MapKit

struct NavigateHowToReachStation: Hashable {
    let station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
}

struct HowToReachStation: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
        
    @EnvironmentObject private var locationManager: LocationManager
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.openURL) private var openURL
    
    @AppStorage(StorageKeys.mapStyle, store: UserDefaults.shared) private var mapStyle: Enums.MapStyle = Defaults.mapStyle
    
    @State private var startingPoint: CLLocationCoordinate2D?
    @State private var destination: MKMapItem?
    @State private var route: MKRoute?
    
    @Namespace private var mapScope
    
    private func getDirections() {
        guard let startingPoint = self.startingPoint else { return }

        self.route = nil
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: startingPoint))
        request.destination = self.destination
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
    
    var body: some View {
        MapView()
            .mapScope(mapScope)
            .onAppear {
                if let latitude = locationManager.lastLocation?.coordinate.latitude, let longitude = locationManager.lastLocation?.coordinate.longitude {
                    withAnimation(.default) {
                        startingPoint = CLLocationCoordinate2D(
                            latitude: latitude,
                            longitude: longitude
                        )
                        destination = MKMapItem(placemark: MKPlacemark(coordinate: .init(latitude: station.latitude!, longitude: station.longitude!)))
                    }
                }
            }
            .onChange(of: destination) {
                getDirections()
            }
            .navigationTitle("How to get there")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let latitude = locationManager.lastLocation?.coordinate.latitude, let longitude = locationManager.lastLocation?.coordinate.longitude {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button("Open in Apple Maps") {
                                openInAppleMaps(sourceLatitude: latitude, sourceLongitude: longitude, destinationLatitude: station.latitude!, destinationLongitude: station.longitude!, stationName: station.signage!.capitalized)
                            }
                            Button("Open in Google Maps") {
                                openURL(URL(string: "https://www.google.com/maps/search/?api=1&query=\(station.latitude!)%2C\(station.longitude!)")!)
                            }
                        } label: {
                            Text("Open in...")
                        }
                    }
                }
        }
    }
    
    @ViewBuilder private func MapView() -> some View {
        if let startingPoint = startingPoint, let destination = destination {
            let mpStyle: MapStyle = {
                switch mapStyle {
                case .standard: return MapStyle.standard
                case .hybrid: return MapStyle.hybrid
                case .satellite: return MapStyle.imagery
                }
            }()
            Map(scope: mapScope) {
                Annotation(String(describing: ""), coordinate: startingPoint) {
                    Circle()
                        .fill(.blue)
                        .frameDynamicSize(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: .black.opacity(0.5), radius: 5)
                }
                Marker(station.signage!.capitalized, coordinate: destination.placemark.coordinate)
                        
                if let route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(mpStyle)
            .mapControls {
                MapScaleView()
            }
            .overlay(alignment: .topTrailing, content: {
                if let distance = route?.distance, let time = route?.expectedTravelTime {
                    let d: String = {
                        if distance >= 1000 {
                            return "\(formattedNumber(value: distance/1000)) Km"
                        }
                        else {
                            return "\(Int(distance)) m"
                        }
                    }()
                    let time: String = {
                        let (days, hours, minutes) = timeIntervalToDHM(time)
                        var text: [String] = []
                        if days > 0 {
                            text.append("\(days) d")
                        }
                        if hours > 0 {
                            text.append("\(hours) h")
                        }
                        if minutes > 0 {
                            text.append("\(minutes) min")
                        }
                        return text.joined(separator: ", ")
                    }()
                    
                    VStack(alignment: .trailing) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "point.topleft.down.to.point.bottomright.curvepath.fill")
                                Spacer()
                                    .frame(width: 8)
                                Text(verbatim: d)
                            }
                            Spacer()
                                .frame(height: 12)
                            HStack {
                                Image(systemName: "timer")
                                Spacer()
                                    .frame(width: 8)
                                Text(verbatim: time)
                            }
                        }
                        .fontSize(14)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.foreground)
                        .condition { view in
                            if #available(iOS 26.0, *) {
                                view
                                    .padding(12)
                                    .glassEffect(in: .rect(cornerRadius: 24.0))
                            } else {
                                view
                                    .padding(8)
                                    .background(Material.regular)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(color: .black.opacity(0.3), radius: 5)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 12)
                        
                        MapCompass(scope: mapScope)
                    }
                    .offset(x: -(12 * fontSizeMultiplier(for: dynamicTypeSize)), y: 12 * fontSizeMultiplier(for: dynamicTypeSize))
                }
            })
        }
        else {
            ContentUnavailableView("Location unavailable", systemImage: "location.slash.fill", description: Text("Location access is required to show the map."))
                .transition(.opacity)
        }
        
    }
}

#Preview {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    
    NavigationStack {
        HowToReachStation(station: station)
            .environmentObject(LocationManager(mockData: true))
    }
}
