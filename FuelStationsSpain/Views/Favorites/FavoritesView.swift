import SwiftUI
import CoreLocation

struct FavoritesView: View {
    
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    @EnvironmentObject private var favoritesListViewModel: FavoritesListViewModel
    @EnvironmentObject private var locationManager: LocationManager
    
    var body: some View {
        NavigationSplitView {
            Group {
                if favoritesProvider.favorites.isEmpty {
                    ContentUnavailableView("No favorite stations", systemImage: "list.bullet", description: Text("Mark some service stations as favorites to see them here."))                }
                else {
                    if favoritesListViewModel.loading {
                        ProgressView()
                            .transition(.opacity)
                    }
                    else if favoritesListViewModel.data != nil {
                        if favoritesListViewModel.data!.results!.isEmpty {
                            ContentUnavailableView("No favorite stations", systemImage: "list.bullet", description: Text("Mark some service stations as favorites to see them here."))
                        }
                        else {
                            let data = addDistancesToStations(stations: favoritesListViewModel.data!.results!, lastLocation: locationManager.lastLocation)
                            let sortedDistance = sortStationsByDistance(data)
                            List(sortedDistance, id: \.self) { item in
                                StationListEntry(station: item) {
                                    
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                    else {
                        ContentUnavailableView("Cannot load favorites", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the favorites information. Try again later."))
                            .transition(.opacity)
                    }
                }
            }
            .navigationTitle("Favorites")
        } detail: {
            VStack {
                
            }
        }
        .onAppear {
            Task {
                await favoritesListViewModel.fetchData()
            }
        }
    }
}
