import SwiftUI
import CoreLocation

struct StationsSheet: View {
    
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    
    // Keep the same location while the view is being presented
    @State private var location: CLLocation? = nil
    
    @State private var selectedSorting: Enums.SortingOptions = .proximity
    
    var body: some View {
        NavigationStack {
            Group {
                if mapManager.loading {
                    ProgressView()
                }
                else {
                    if let data = mapManager.data?.results {
                        let data = addDistancesToStations(stations: data, lastLocation: location)
                        let sorted = sortStations(stations: data, sortingMethod: selectedSorting)
                        let filtered = searchText != "" ? sorted.filter() { $0.signage!.lowercased().contains(searchText.lowercased()) } : sorted
                        Group {
                            if listHasContent == false {
                                ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                    .transition(.opacity)
                            }
                            else {
                                List {
                                    Section {
                                        ForEach(filtered, id: \.self) { item in
                                            Button {
                                                mapManager.showStationsSheet.toggle()
                                                // await to prevent opening a sheet with another one already open
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                    mapManager.selectStation(station: item, centerLocation: true)
                                                    Task {
                                                        await mapManager.fetchData(latitude: item.latitude!, longitude: item.longitude!)
                                                    }
                                                })
                                            } label: {
                                                StationListEntry(station: item, sortingMethod: selectedSorting)
                                            }
                                        }
                                    } header: {
                                        Text(sortingText(sortingMethod: selectedSorting))
                                            .fontWeight(.semibold)
                                            .padding(.bottom, 12)
                                            .padding(.leading, -12)
                                            .padding(.top, -12)
                                            .textCase(nil)
                                            .font(.system(size: 14))
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
                        mapManager.showStationsSheet.toggle()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SortingPicker(selectedSorting: $selectedSorting)
                }
            }
            .searchable(text: $searchText, prompt: "Search service station by name")
        }
        .onAppear {
            location = locationManager.lastLocation
        }
    }
}
