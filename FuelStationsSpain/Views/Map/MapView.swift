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

    var body: some View {
        Map(position: $mapManager.position, bounds: MapCameraBounds(minimumDistance: 500, maximumDistance: 50000)) {
            if let stations = mapManager.data?.results {
                let markers = {
                    let m = stations.filter() { $0.signage != nil && $0.latitude != nil && $0.longitude != nil }
                    if hideStationsNotOpenPublic == true {
                        return m.filter() { $0.saleType != .r }
                    }
                    else {
                        return m
                    }
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
                        mapManager.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
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
                Group {
                    Button {
                        if mapManager.error != nil {
                            mapManager.showErrorAlert.toggle()
                        }
                        else if mapManager.error == nil && mapManager.loading == false {
                            mapManager.showSuccessAlert.toggle()
                        }
                    } label: {
                        Group {
                            if mapManager.loading == true {
                                ProgressView()
                                    .font(.system(size: 24))
                            }
                            else {
                                if mapManager.error != nil {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.red)
                                }
                                else {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.green)
                                }
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
                .offset(x: 12, y: 12)
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
