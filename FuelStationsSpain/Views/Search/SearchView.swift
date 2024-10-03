import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
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
    }
}
