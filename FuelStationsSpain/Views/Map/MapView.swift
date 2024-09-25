import SwiftUI
import MapKit

struct MapView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        Group {
            if locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted {
                ContentUnavailableView("Location access required", systemImage: "location.fill", description: Text("This application requires location access to show you the nearby service stations."))
            }
            else {
                MapComponent()
                    .environmentObject(MapViewModel(latitude: locationManager.lastLocation?.coordinate.latitude, longitude: locationManager.lastLocation?.coordinate.longitude))
            }
        }
        .transition(.opacity)
    }
}

fileprivate struct MapComponent: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    
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
    }
}
