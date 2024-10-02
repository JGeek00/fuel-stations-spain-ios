import Foundation

@MainActor
class MunicipalitiesProvider: ObservableObject {
    static let shared = MunicipalitiesProvider()
    
    @Published var data: [Municipality]? = nil
    @Published var error: Bool = false
    @Published var loading: Bool = true
    
    init() {
        Task {
            await fetchData()
        }
    }
    
    func fetchData() async {
        self.loading = true
        
        let result = await ApiClient.fetchMunicipalities()
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data!
                self.loading = false
                self.error = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.data = nil
                self.loading = false
                self.error = true
            }
        }
    }
}
