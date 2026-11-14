import SwiftUI
import CoreLocation

@MainActor
class FavoritesListViewModel: ObservableObject {
    @Published var data: FuelStationsResult? = nil
    @Published var loading = true
    @Published var error: Enums.ApiErrorReason? = nil
    
    @Published var selectedStation: FuelStation? = nil
    @Published var searchText = ""
    @Published var listHasContent = true    // To make transition
    
    // Keep the same location when the view is being presented
    @Published var location: CLLocation? = nil

    /// Seam de test: proveedor de favoritos inyectable. Por defecto es el
    /// singleton compartido, el mismo comportamiento de antes de la inyección.
    private let favoritesProvider: FavoritesProvider

    init(favoritesProvider: FavoritesProvider = FavoritesProvider.shared) {
        self.favoritesProvider = favoritesProvider
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        let favorites = favoritesProvider.favorites.map() { $0.id! } as [String]
        if favorites.isEmpty { return }

        self.loading = true
    
        let result = await ApiClient.fetchServiceStationsById(stationIds: favorites)
        if let data = result.data {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = data
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
