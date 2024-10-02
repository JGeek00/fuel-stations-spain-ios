import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
        
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SearchMunicipalitiesList()
                    .environmentObject(SearchMunicipalitiesViewModel())
                    .navigationSplitViewColumnWidth(min: proxy.size.width*0.3, ideal: proxy.size.width*0.4, max: proxy.size.width*0.5)
            } detail: {
                SearchStationDetails()
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}
