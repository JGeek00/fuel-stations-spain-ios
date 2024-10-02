import SwiftUI
import CoreLocation

struct SearchStationsList: View {
        
    @EnvironmentObject private var stationsViewModel: SearchStationsViewModel
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var location: CLLocation? = nil
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    @State private var selectedSorting: Enums.StationsSortingOptions = .proximity
    
    var body: some View {
        Group {
            if stationsViewModel.loading == true {
                ProgressView()
                    .transition(.opacity)
            }
            else if stationsViewModel.data?.results != nil {
                let data = addDistancesToStations(stations: stationsViewModel.data!.results!, lastLocation: location)
                if data.isEmpty {
                    ContentUnavailableView("No stations", systemImage: "fuelpump.slash.fill", description: Text("This municipality has no service stations."))
                        .transition(.opacity)
                }
                else {
                    let sorted = sortStations(stations: data, sortingMethod: selectedSorting)
                    let filtered = searchText != "" ? sorted.filter() { $0.signage!.lowercased().contains(searchText.lowercased()) } : sorted
                    Group {
                        if listHasContent == false {
                            ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                .transition(.opacity)
                        }
                        else {
                            List(selection: $searchViewModel.selectedStation) {
                                Section {
                                    ForEach(filtered, id: \.self) { item in
                                        StationListEntry(station: item, sortingMethod: selectedSorting)
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
                            .listStyle(.insetGrouped)
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
                    .searchable(text: $searchText, prompt: "Search service station by name")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            SortingPicker(selectedSorting: $selectedSorting)
                        }
                    }
                }
            }
        }
        .navigationTitle(stationsViewModel.selectedMunicipality.Municipio?.capitalized ?? String(localized: "Municipality"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            location = locationManager.lastLocation
        }
    }
}
