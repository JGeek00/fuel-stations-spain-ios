import SwiftUI
import CoreLocation

struct FavoritesView: View {

    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedStation: FuelStation? = nil
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    
    // Keep the same location when the view is being presented
    @State private var location: CLLocation? = nil
    
    @State private var selectedSorting: Enums.StationsSortingOptions = .proximity
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var width = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
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
                                        List(selection: $selectedStation) {
                                            Section {
                                                ForEach(filtered, id: \.self) { item in
                                                    StationListEntry(station: item, sortingMethod: selectedSorting, hideFavoriteSymbol: true)
                                                }
                                            } header: {
                                                Text(sortingText(sortingMethod: selectedSorting))
                                                    .fontWeight(.semibold)
                                                    .padding(.bottom, 12)
                                                    .padding(.leading, horizontalSizeClass == .regular ? 0 : -12)
                                                    .padding(.top, horizontalSizeClass == .regular ? 0 : -12)
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
                        else {
                            ContentUnavailableView("Cannot load favorites", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the favorites information. Try again later."))
                                .transition(.opacity)
                        }
                    }
                }
                .navigationTitle("Favorites")
                .navigationSplitViewColumnWidth(min: width*0.3, ideal: width*0.4, max: width*0.5)
            } detail: {
                if let selectedStation = selectedStation {
                    FavoriteDetailsView(station: selectedStation)
                }
                else {
                    ContentUnavailableView("Select a station", systemImage: "fuelpump.fill", description: Text("Select a service station to see it's details."))
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
            .onChange(of: proxy.size.width) {
                width = proxy.size.width
            }
        }
    }
}
