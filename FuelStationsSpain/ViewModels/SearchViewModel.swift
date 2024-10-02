import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var selectedStation: FuelStation?
}

@MainActor
class SearchMunicipalitiesViewModel: ObservableObject {
    @Published var data: [Municipality]? = nil
    @Published var error: Bool = false
    @Published var loading: Bool = true
    
    @Published var selectedStation: FuelStation? = nil
    
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
                withAnimation(.default) {
                    self.data = result.data!
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = nil
                    self.loading = false
                    self.error = true
                }
            }
        }
    }
}

@MainActor
class SearchStationsViewModel: ObservableObject {
    var selectedMunicipality: Municipality
    
    init(selectedMunicipality: Municipality) {
        self.selectedMunicipality = selectedMunicipality
        
        Task {
            await fetchData()
        }
    }
    
    @Published var data: FuelStationsResult? = nil
    @Published var error: Bool = false
    @Published var loading: Bool = true
    
    func fetchData() async {
        self.loading = true
        
        let result = await ApiClient.fetchServiceStationsByMunicipality(municipalityId: selectedMunicipality.IDMunicipio!)
        if result.successful == true {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = result.data!
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            withAnimation(.default) {
                self.data = nil
                self.loading = false
                self.error = true
            }
        }
    }
}
