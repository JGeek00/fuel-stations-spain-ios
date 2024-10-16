import SwiftUI
import CoreLocation

struct SearchStationsList: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Environment(SearchViewModel.self) private var searchViewModel
    @Environment(LocationManager.self) private var locationManager
        
    var body: some View {
        @Bindable var searchViewModel = searchViewModel
        
        NavigationStack {
            if let selectedMunicipality = searchViewModel.selectedMunicipality {
                Group {
                    if searchViewModel.stationsLoading == true {
                        ProgressView()
                            .transition(.opacity)
                    }
                    else if searchViewModel.stationsError == true {
                        ContentUnavailableView("Cannot load stations", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the list of service stations. Try again later."))
                            .transition(.opacity)
                    }
                    else {
                        Content()
                            .transition(.opacity)
                    }
                }
                .navigationTitle(selectedMunicipality.Municipio?.capitalized ?? String(localized: "Municipality"))
                .navigationBarTitleDisplayMode(.inline)
            }
            else {
                ContentUnavailableView("Select a municipality", systemImage: "building.columns.fill", description: Text("Select a municipality to see it's service stations."))
            }
        }
    }
    
    @ViewBuilder private func Content() -> some View {
        @Bindable var searchViewModel = searchViewModel
        
        if let data = searchViewModel.stationsData?.results {
            if data.isEmpty {
                ContentUnavailableView("No stations", systemImage: "fuelpump.slash.fill", description: Text("This municipality has no service stations."))
                    .transition(.opacity)
            }
            else {
                let dataWithDistance = addDistancesToStations(stations: data, lastLocation: searchViewModel.location)
                let sorted = sortStations(stations: dataWithDistance, sortingMethod: searchViewModel.stationsSelectedSorting)
                let filtered = searchViewModel.stationsSearchText != "" ? sorted.filter() { $0.signage!.lowercased().contains(searchViewModel.stationsSearchText.lowercased()) } : sorted
                Group {
                    if searchViewModel.stationsListHasContent == false {
                        ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                            .transition(.opacity)
                    }
                    else {
                        List(selection: $searchViewModel.selectedStation) {
                            Section {
                                ForEach(filtered, id: \.self) { item in
                                    StationListEntry(station: item, sortingMethod: searchViewModel.stationsSelectedSorting)
                                }
                            } header: {
                                HStack {
                                    if horizontalSizeClass == .regular {
                                        Spacer()
                                    }
                                    Text(sortingText(sortingMethod: searchViewModel.stationsSelectedSorting))
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(horizontalSizeClass == .regular ? .center : .leading)
                                        .padding(.bottom, 12)
                                        .padding(.leading, horizontalSizeClass == .regular ? 0 : -12)
                                        .padding(.top, horizontalSizeClass == .regular ? 0 : -12)
                                        .textCase(nil)
                                        .fontSize(14)
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
                            searchViewModel.stationsListHasContent = false
                        }
                        else {
                            searchViewModel.stationsListHasContent = true
                        }
                    }
                }
                .searchable(text: $searchViewModel.stationsSearchText, prompt: "Search service station by name")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        SortingPicker(selectedSorting: $searchViewModel.stationsSelectedSorting)
                    }
                }
            }
        }
        else {
            ContentUnavailableView("Cannot load stations", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the list of service stations. Try again later."))
        }
    }
}
