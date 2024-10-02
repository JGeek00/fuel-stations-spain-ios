import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
        
    var body: some View {
        NavigationSplitView {
            MunicipalitiesList()
        } content: {
            StationsList()
        } detail: {
            
        }
    }
}
