import SwiftUI
import CoreLocation

struct FavoritesView: View {

    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    @State private var selectedStation: FuelStation? = nil
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    
    // Last location changes constantly, having a fixed location prevents unwanted reorders on the list
    @State private var location: CLLocation? = nil
    
    @State private var selectedSorting: Enums.SortingOptions = .proximity
    
    var body: some View {
        NavigationSplitView {
            Group {
                if favoritesProvider.favorites.isEmpty {
                    ContentUnavailableView("No favorite stations", systemImage: "list.bullet", description: Text("Mark some service stations as favorites to see them here."))                }
                else {
                    if favoritesListViewModel.loading == true {
                        ProgressView()
                            .transition(.opacity)
                    }
                    else if favoritesListViewModel.data != nil {
                        if favoritesListViewModel.data!.results!.isEmpty {
                            ContentUnavailableView("No favorite stations", systemImage: "list.bullet", description: Text("Mark some service stations as favorites to see them here."))
                        }
                        else {
                            let data = addDistancesToStations(stations: favoritesListViewModel.data!.results!, lastLocation: location)
                            let sorted = sortStations(stations: data, sortingMethod: selectedSorting)
                            let filtered = searchText != "" ? sorted.filter() { $0.signage!.lowercased().contains(searchText.lowercased()) } : sorted
                            Group {
                                if listHasContent == false {
                                    ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                        .transition(.opacity)
                                }
                                else {
                                    List(filtered, id: \.self, selection: $selectedStation) { item in
                                        StationListEntry(station: item, sortingMethod: selectedSorting)
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
                    }
                    else {
                        ContentUnavailableView("Cannot load favorites", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the favorites information. Try again later."))
                            .transition(.opacity)
                    }
                }
            }
            .navigationTitle("Favorites")
            .searchable(text: $searchText, prompt: "Search service station by name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SortingPicker(selectedSorting: selectedSorting) { value in
                        selectedSorting = value
                    }
                }
            }
        } detail: {
            if let selectedStation = selectedStation {
                FavoriteDetailsView(station: selectedStation)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: favoritesProvider.favorites, initial: true) {
            Task {
                await favoritesListViewModel.fetchData()
            }
        }
        .onAppear {
            location = locationManager.lastLocation
        }
    }
}
