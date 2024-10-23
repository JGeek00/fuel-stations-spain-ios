import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @AppStorage(StorageKeys.defaultListSorting, store: UserDefaults.shared) private var defaultListSorting = Defaults.defaultListSorting
        
    @State private var columnVisibility = NavigationSplitViewVisibility.all
        
    var body: some View {
        if horizontalSizeClass == .regular {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SearchMunicipalitiesList(isSplitView: true)
            } content: {
                SearchStationsList(isSplitView: true)
            } detail: {
                SearchStationDetails(isSplitView: true)
            }
            .navigationSplitViewStyle(.balanced)
            .onAppear {
                searchViewModel.location = locationManager.lastLocation
                searchViewModel.stationsSelectedSorting = defaultListSorting
            }
        }
        else {
            NavigationStack(path: $searchViewModel.navigationPath) {
                SearchMunicipalitiesList(isSplitView: false)
                    .navigationDestination(for: Municipality.self) { item in
                        SearchStationsList(isSplitView: false)
                    }
                    .navigationDestination(for: FuelStation.self) { _ in
                        SearchStationDetails(isSplitView: false)
                    }
                    .navigationDestination(for: NavigateHowToReachStation.self) { value in
                        HowToReachStation(station: value.station)
                    }
            }
            .onAppear {
                searchViewModel.location = locationManager.lastLocation
                searchViewModel.stationsSelectedSorting = defaultListSorting
            }
        }
    }
}
