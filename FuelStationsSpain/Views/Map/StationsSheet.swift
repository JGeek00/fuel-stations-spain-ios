import SwiftUI
import CoreLocation

struct StationsSheet: View {
    
    @EnvironmentObject private var mapViewModel: MapViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    
    // Last location changes constantly, having a fixed location prevents unwanted reorders on the list
    @State private var location: CLLocation? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if mapViewModel.loading {
                    ProgressView()
                }
                else {
                    if let data = mapViewModel.data?.results {
                        let data = addDistancesToStations(stations: data, lastLocation: location)
                        let sortedDistance = sortStationsByDistance(data)
                        let filtered = searchText != "" ? sortedDistance.filter() { $0.signage!.lowercased().contains(searchText.lowercased()) } : sortedDistance
                        Group {
                            if listHasContent == false {
                                ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                    .transition(.opacity)
                            }
                            else {
                                List(filtered, id: \.self) { item in
                                    Button {
                                        mapViewModel.showStationsSheet.toggle()
                                        // await to prevent opening a sheet with another one already open
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                            mapViewModel.selectStation(station: item, centerLocation: true)
                                            Task {
                                                await mapViewModel.fetchData(latitude: item.latitude!, longitude: item.longitude!)
                                            }
                                        })
                                    } label: {
                                        StationListEntry(station: item)
                                    }
                                }
                                .animation(.default, value: filtered)
                                .transition(.opacity)
                            }
                        }
                        .onChange(of: filtered) {
                            withAnimation(.default) {
                                if filtered.isEmpty {
                                    listHasContent = false
                                }
                                else {
                                    listHasContent = true
                                }
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
            .searchable(text: $searchText, prompt: "Search service station by name")
        }
        .onAppear {
            location = locationManager.lastLocation
        }
    }
}
