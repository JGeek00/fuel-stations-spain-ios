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
                            let dataWithDistances = sortStationsByDistance(data: favoritesListViewModel.data!.results!, lastLocation: locationManager.lastLocation)
                            List(dataWithDistances, id: \.self) { item in
                                Button {
                                    
                                } label: {
                                    VStack(alignment: .leading) {
                                        if let signage = item.station.signage {
                                            Text(signage.capitalized)
                                                .font(.system(size: 18))
                                                .fontWeight(.semibold)
                                        }
                                        Spacer()
                                            .frame(height: 4)
                                        if let distance = item.distance {
                                            if distance < 1 {
                                                Text("\(Int(distance*1000)) m from your current location")
                                                    .font(.system(size: 14))
                                            } else {
                                                Text("\(formattedNumber(value: distance)) Km from your current location")
                                                    .font(.system(size: 14))
                                            }
                                        }
                                    }
                                    .foregroundStyle(Color.foreground)
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
