import SwiftUI

struct SearchView: View {
    
    @Environment(LocationManager.self) private var locationManager
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @AppStorage(StorageKeys.defaultListSorting, store: UserDefaults.shared) private var defaultListSorting = Defaults.defaultListSorting
        
    @State private var columnVisibility = NavigationSplitViewVisibility.all
        
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SearchMunicipalitiesList()
        } content: {
            SearchStationsList()
        } detail: {
            SearchStationDetails()
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            searchViewModel.location = locationManager.lastLocation
            searchViewModel.stationsSelectedSorting = defaultListSorting
        }
    }
}
