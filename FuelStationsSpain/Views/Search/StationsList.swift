import SwiftUI
import CoreLocation

struct SearchStationsList: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var location: CLLocation? = nil
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    @State private var selectedSorting: Enums.StationsSortingOptions = .proximity
    
    var body: some View {
        NavigationStack {
            if let selectedMunicipality = searchViewModel.selectedMunicipality {
                Group {
                    if searchViewModel.stationsLoading == true {
                        ProgressView()
                            .transition(.opacity)
                    }
                    else if searchViewModel.stationsError == true {
                        ContentUnavailableView("Select a municipality", systemImage: "building.columns.fill", description: Text("Select a municipality to see it's service stations."))
                    }
                    else {
                        if let data = searchViewModel.stationsData?.results {
                            let data = addDistancesToStations(stations: data, lastLocation: location)
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
                                                HStack {
                                                    if horizontalSizeClass == .regular {
                                                        Spacer()
                                                    }
                                                    Text(sortingText(sortingMethod: selectedSorting))
                                                        .fontWeight(.semibold)
                                                        .multilineTextAlignment(horizontalSizeClass == .regular ? .center : .leading)
                                                        .padding(.bottom, 12)
                                                        .padding(.leading, horizontalSizeClass == .regular ? 0 : -12)
                                                        .padding(.top, horizontalSizeClass == .regular ? 0 : -12)
                                                        .textCase(nil)
                                                        .font(.system(size: 14))
                                                    Spacer()
                                                }
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
                        else {
                            ContentUnavailableView("Select a municipality", systemImage: "building.columns.fill", description: Text("Select a municipality to see it's service stations."))
                        }
                    }
                }
                .navigationTitle(selectedMunicipality.Municipio?.capitalized ?? String(localized: "Municipality"))
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    location = locationManager.lastLocation
                }
            }
            else {
                ContentUnavailableView("Select a municipality", systemImage: "building.columns.fill", description: Text("Select a municipality to see it's service stations."))
            }
        }
        .onChange(of: searchViewModel.selectedMunicipality) {
            if searchViewModel.selectedMunicipality != nil {
                Task {
                    await searchViewModel.fetchStations()
                }
            }
        }
    }
}
