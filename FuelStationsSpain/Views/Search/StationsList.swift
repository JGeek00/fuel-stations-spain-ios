import SwiftUI
import CoreLocation

struct SearchStationsList: View {
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var searchViewModel: SearchViewModel
        
    var body: some View {        
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
                            .onChange(of: searchViewModel.stationsSelectedSorting) {
                                searchViewModel.sortSearchStations()
                            }
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
        if let data = searchViewModel.sortedStationsList {
            if data.isEmpty {
                ContentUnavailableView("No stations", systemImage: "fuelpump.slash.fill", description: Text("This municipality has no service stations."))
                    .transition(.opacity)
            }
            else {
                Group {
                    if let filtered = searchViewModel.filteredStationsList {
                        if !filtered.isEmpty {
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
                        else {
                            ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                .transition(.opacity)
                        }
                    }
                    else {
                        List(selection: $searchViewModel.selectedStation) {
                            Section {
                                ForEach(data, id: \.self) { item in
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
                        .animation(.default, value: data)
                        .transition(.opacity)
                        .listStyle(.insetGrouped)
                    }
                }
                .searchable(text: $searchViewModel.stationsSearchText, isPresented: $searchViewModel.stationsSearchPresented, prompt: "Search service station by name")
                .onSubmit(of: .search) {
                    searchViewModel.filterStations()
                }
                .onChange(of: searchViewModel.stationsSearchPresented, { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        searchViewModel.filterStations(clearSearch: true)
                    }
                })
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
