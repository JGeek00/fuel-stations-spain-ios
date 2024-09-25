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
                .environmentObject(MapViewModel(latitude: locationManager.lastLocation?.coordinate.latitude, longitude: locationManager.lastLocation?.coordinate.longitude))
        }
    }
}

fileprivate struct MapComponent: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        Map(position: $mapViewModel.position, bounds: MapCameraBounds(minimumDistance: 500, maximumDistance: 50000)) {
            if let stations = mapViewModel.data?.results {
                let markers = stations.filter() { $0.signage != nil && $0.latitude != nil && $0.longitude != nil }
                ForEach(markers, id: \.id) { value in
                    Annotation(value.signage!, coordinate: CLLocationCoordinate2D(latitude: value.latitude!, longitude: value.longitude!)) {
                        MarkerIcon()
                            .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.markerGradientStart, Color.markerGradientEnd]), startPoint: .top, endPoint: .bottom))
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                Task {
                                    // await to prevent opening a sheet with another one already open
                                    if mapViewModel.showStationSheet == true {
                                        mapViewModel.showStationSheet = false
                                        try await Task.sleep(for: .seconds(0.1))
                                    }
                                    mapViewModel.selectStation(station: value)
                                }
                            }
                    }
                }
            }
        }
        .onChange(of: mapViewModel.position, { oldValue, newValue in
            // Only executed first time map is moved
            mapViewModel.usedMoved = true
        })
        .onMapCameraChange(frequency: .onEnd, { value in
            // Prevents multiple executions when map is loaded
            guard mapViewModel.usedMoved == true else {
                return
            }
            mapViewModel.setPosition(latitude: value.camera.centerCoordinate.latitude, longitude: value.camera.centerCoordinate.longitude)
            mapViewModel.fetchData(latitude: value.camera.centerCoordinate.latitude, longitude: value.camera.centerCoordinate.longitude)
        })
        .overlay(alignment: .topLeading) {
            GeometryReader(content: { geometry in
                Group {
                    HStack {
                        Spacer()
                            .frame(width: 58)
                        Spacer()
                        HStack {
                            Image(systemName: "location.slash.fill")
                            Spacer()
                                .frame(width: 6)
                            Text("Location unavailable")
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 14))
                        }
                        .foregroundStyle(Color.black)
                        .padding(12)
                        .background(Color.yellow.opacity(0.8))
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                        Spacer()
                        Spacer()
                            .frame(width: 58)
                    }
                }
                .offset(x: 0, y: 12)
                .opacity(locationManager.lastLocation != nil ? 0 : 1)
                .animation(.easeInOut(duration: 0.25), value: locationManager.lastLocation)
                Group {
                    Button {
                        mapViewModel.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
                    } label: {
                        Image(systemName: "location.fill.viewfinder")
                            .font(.system(size: 22))
                            .foregroundStyle(locationManager.lastLocation != nil ? Color.foreground : Color.gray)
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
                        Task {
                            // await to prevent opening a sheet with another one already open
                            if mapViewModel.showStationSheet == true {
                                mapViewModel.showStationSheet = false
                                try await Task.sleep(for: .seconds(0.1))
                            }
                            mapViewModel.showStationsSheet.toggle()
                        }
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.foreground)
                    }
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                }
                .offset(x: geometry.size.width - 52, y: 70)
                Group {
                    Button {
                        if mapViewModel.error != nil {
                            mapViewModel.showErrorAlert.toggle()
                        }
                        else if mapViewModel.error == nil && mapViewModel.loading == false {
                            mapViewModel.showSuccessAlert.toggle()
                        }
                    } label: {
                        if mapViewModel.loading == true {
                            ProgressView()
                                .font(.system(size: 24))
                        }
                        else {
                            if mapViewModel.error != nil {
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
                    .frame(width: 40, height: 40)
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.3), radius: 5)
                    .disabled(mapViewModel.loading)
                }
                .offset(x: 12, y: 12)
            })
        }
        .alert("Success", isPresented: $mapViewModel.showSuccessAlert, actions: {
            Button("Close") {
                mapViewModel.showSuccessAlert.toggle()
            }
        }, message: {
            Text("Data loaded successfully.")
        })
        .alert("Error", isPresented: $mapViewModel.showErrorAlert, actions: {
            Button("Close") {
                mapViewModel.showErrorAlert.toggle()
            }
            Button("Retry") {
                mapViewModel.fetchData(latitude: mapViewModel.latitude, longitude: mapViewModel.longitude, force: true)
            }
        }, message: {
            switch mapViewModel.error {
                case .connection:
                    Text("Cannot establish a connection with the server. Check your Internet connection.")
                case .usage:
                    Text("Usage quota exceded. Try again later.")
                default:
                    Text("Unknown error.")
            }
        })
        .sheet(isPresented: $mapViewModel.showStationsSheet, content: {
            StationsSheet()
        })
        .sheet(isPresented: $mapViewModel.showStationSheet) {
            StationDetailsSheet()
                .presentationBackground(Material.regular)
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(
                    .enabled(upThrough: .large)
                )
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: locationManager.firstLocation) {
            guard let loc = locationManager.firstLocation else { return }
            mapViewModel.updatePositionAndFetch(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        }
    }
}
