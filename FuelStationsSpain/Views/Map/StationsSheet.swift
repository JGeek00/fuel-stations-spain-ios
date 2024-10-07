import SwiftUI
import CoreLocation

struct StationsSheet: View {
    
    @EnvironmentObject private var mapManager: MapManager
    @EnvironmentObject private var locationManager: LocationManager
    
    @AppStorage(StorageKeys.hideStationsNotOpenPublic, store: UserDefaults.shared) private var hideStationsNotOpenPublic: Bool = Defaults.hideStationsNotOpenPublic
    
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    
    // Keep the same location while the view is being presented
    @State private var location: CLLocation? = nil
    
    @State private var selectedSorting: Enums.StationsSortingOptions = .proximity
    
    var body: some View {
        NavigationStack {
            Group {
                if mapManager.loading {
                    ProgressView()
                }
                else {
                    if let data = mapManager.data?.results {
                        if !data.isEmpty {
                            Group {
                                let processedData = {
                                    let d = addDistancesToStations(stations: data, lastLocation: location)
                                    let filtered = searchText != "" ? d.filter() { $0.signage!.lowercased().contains(searchText.lowercased()) } : d
                                    let sorted = sortStations(stations: filtered, sortingMethod: selectedSorting)
                                    if hideStationsNotOpenPublic == true {
                                        return sorted.filter() { $0.saleType != .r }
                                    }
                                    else {
                                        return sorted
                                    }
                                }()
                                Group {
                                    if listHasContent == false {
                                        ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                            .transition(.opacity)
                                    }
                                    else {
                                        List {
                                            Section {
                                                ForEach(processedData, id: \.self) { item in
                                                    Button {
                                                        mapManager.showStationsSheet = false
                                                        // await to prevent opening a sheet with another one already open
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                            withAnimation(.easeOut) { 
                                                                mapManager.selectStation(station: item, centerLocation: true)
                                                            }
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
                                        .animation(.default, value: processedData)
                                        .transition(.opacity)
                                    }
                                }
                                .onChange(of: processedData) {
                                    withAnimation(.default) {
                                        if processedData.isEmpty {
                                            listHasContent = false
                                        }
                                        else {
                                            listHasContent = true
                                        }
                                    }
                                }
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
                        }
                        else {
                            ContentUnavailableView("No nearby stations", systemImage: "fuelpump.slash.fill", description: Text("There are no nearby service stations around your current position."))
                        }
                    }
                    else {
                        ContentUnavailableView("Data unavailable", systemImage: "exclamationmark.circle.fill", description: Text("Nearby stations couldn't be loaded due to an error."))
                    }
                }
            }
            .navigationTitle("Nearby service stations")
        }
        .onAppear {
            location = locationManager.lastLocation
        }
    }
}
