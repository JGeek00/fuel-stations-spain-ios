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
                                        try await Task.sleep(for: .seconds(0.6))
                                    }
                                    mapViewModel.selectStation(station: value)
                                }
                            }
                    }
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd, { value in
            mapViewModel.onMapCameraChange(value)
        })
        .overlay(alignment: .topLeading) {
            GeometryReader(content: { geometry in
                Group {
                    Button {
                        mapViewModel.centerToLocation(latitude: locationManager.lastLocation!.coordinate.latitude, longitude: locationManager.lastLocation!.coordinate.longitude)
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
                        if mapViewModel.showStationSheet == true {
                            mapViewModel.showStationSheet = false
                        }
                        mapViewModel.showStationsSheet.toggle()
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
                        if mapViewModel.error != nil {
                            mapViewModel.showErrorAlert.toggle()
                        }
                        else if mapViewModel.error == nil && mapViewModel.loading == false {
                            mapViewModel.showSuccessAlert.toggle()
                        }
                    } label: {
                        Group {
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
                        .contentShape(Rectangle())
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
                Task {
                    await mapViewModel.fetchData(latitude: mapViewModel.latitude, longitude: mapViewModel.longitude)
                }
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
    }
}
