import SwiftUI
import CoreLocation

struct FavoritesView: View {

    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var width = 0.0
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                Group {
                    if favoritesProvider.favorites.isEmpty {
                        ContentUnavailableView("No favorite stations", systemImage: "list.bullet", description: Text("Mark some service stations as favorites to see them here."))
                    }
                    else {
                        if favoritesListViewModel.loading == true {
                            ProgressView()
                                .transition(.opacity)
                        }
                        else if favoritesListViewModel.error != nil {
                            ContentUnavailableView("Cannot load stations", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the list of service stations. Try again later."))
                                .transition(.opacity)
                        }
                        else {
                            Content()
                                .transition(.opacity)
                        }
                    }
                }
                .navigationTitle("Favorites")
                .navigationSplitViewColumnWidth(min: width*0.3, ideal: width*0.4, max: width*0.5)
            } detail: {
                if let selectedStation = favoritesListViewModel.selectedStation {
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
                favoritesListViewModel.location = locationManager.lastLocation
            }
            .onChange(of: proxy.size.width) {
                width = proxy.size.width
            }
        }
    }
    
    @ViewBuilder private func Content() -> some View {
        if let data = favoritesListViewModel.data?.results {
            if data.isEmpty {
                ContentUnavailableView("No stations", systemImage: "fuelpump.slash.fill", description: Text("This municipality has no service stations."))
                    .transition(.opacity)
            }
            else {
                let dataWithDistance = addDistancesToStations(stations: data, lastLocation: favoritesListViewModel.location)
                let sorted = sortStations(stations: dataWithDistance, sortingMethod: favoritesListViewModel.selectedSorting)
                let filtered = favoritesListViewModel.searchText != "" ? sorted.filter() { $0.signage!.lowercased().contains(favoritesListViewModel.searchText.lowercased()) } : sorted
                Group {
                    if favoritesListViewModel.listHasContent == false {
                        ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                            .transition(.opacity)
                    }
                    else {
                        List(selection: $favoritesListViewModel.selectedStation) {
                            Section {
                                ForEach(filtered, id: \.self) { item in
                                    StationListEntry(station: item, sortingMethod: favoritesListViewModel.selectedSorting, hideFavoriteSymbol: true)
                                }
                            } header: {
                                HStack {
                                    if horizontalSizeClass == .regular {
                                        Spacer()
                                    }
                                    Text(sortingText(sortingMethod: favoritesListViewModel.selectedSorting))
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
                            favoritesListViewModel.listHasContent = false
                        }
                        else {
                            favoritesListViewModel.listHasContent = true
                        }
                    }
                }
                .searchable(text: $favoritesListViewModel.searchText, prompt: "Search service station by name")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        SortingPicker(selectedSorting: $favoritesListViewModel.selectedSorting)
                    }
                }
            }
        }
        else {
            ContentUnavailableView("Cannot load favorites", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the favorites information. Try again later."))
        }
    }
}
