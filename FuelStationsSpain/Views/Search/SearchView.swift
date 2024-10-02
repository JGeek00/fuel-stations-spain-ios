import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
        
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView {
                SearchMunicipalitiesList()
                    .environmentObject(SearchMunicipalitiesViewModel())
                    .navigationSplitViewColumnWidth(proxy.size.width*0.3)
            } detail: {
                SearchStationDetails()
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}
