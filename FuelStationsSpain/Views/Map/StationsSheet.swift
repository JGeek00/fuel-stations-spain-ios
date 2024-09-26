import SwiftUI



struct StationsSheet: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            Group {
                if mapViewModel.loading {
                    ProgressView()
                }
                else {
                    if let data = mapViewModel.data?.results {
                        let data = addDistancesToStations(stations: mapViewModel.data!.results!, lastLocation: locationManager.lastLocation)
                        let sortedDistance = sortStationsByDistance(data)
                        List(sortedDistance, id: \.self) { item in
                            StationListEntry(station: item) {
                                mapViewModel.showStationsSheet.toggle()
                                // await to prevent opening a sheet with another one already open
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                    mapViewModel.selectStation(station: item, centerLocation: true)
                                    Task {
                                        await mapViewModel.fetchData(latitude: item.latitude!, longitude: item.longitude!)
                                    }
                                })
                            }
                        }
                    }
                    else {
                        ContentUnavailableView("Data unavailable", systemImage: "exclamationmark.circle.fill", description: Text("Nearby stations couldn't be loaded due to an error."))
                    }
                }
            }
            .navigationTitle("Nearby service stations")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        mapViewModel.showStationsSheet.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
            }
        }
    }
}
