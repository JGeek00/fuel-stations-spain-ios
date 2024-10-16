import SwiftUI

@MainActor
@Observable
class FavoritesListViewModel {
    var data: FuelStationsResult? = nil
    var loading = true
    var error: Enums.ApiErrorReason? = nil
    
    init() {}
    
    func fetchData() async {
        let favorites = FavoritesProvider.shared.favorites.map() { $0.id! } as [String]
        if favorites.isEmpty { return }

        self.loading = true
    
        let result = await ApiClient.fetchServiceStationsById(stationIds: favorites)
        if result.successful == true {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = result.data!
                    self.loading = false
                    self.error = nil
                }
            }
        }
        else {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    if result.statusCode == 429 {
                        self.error = .usage
                    }
                    else {
                        self.error = .connection
                    }
                    self.loading = false
                }
            }
        }
    }
}
