import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var width = 0.0
        
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SearchMunicipalitiesList()
                    .environmentObject(SearchMunicipalitiesViewModel())
                    .navigationSplitViewColumnWidth(min: width*0.3, ideal: width*0.4, max: width*0.5)
            } detail: {
                SearchStationDetails()
            }
            .navigationSplitViewStyle(.balanced)
            .onChange(of: proxy.size.width) {
                width = proxy.size.width
            }
        }
    }
}
