import CoreLocation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var municipalitiesData: [Municipality]? = nil
    @Published var municipalitiesError: Bool = false
    @Published var municipalitiesLoading: Bool = true
    
    @Published var municipalitiesSearchText = ""
    @Published var municipalitiesListHasContent = true    // To make transition
    @Published var municipalitiesSorting: Enums.SearchSortingOptions = .groupedProvince
    
    @Published var selectedMunicipality: Municipality? = nil
    
    @Published var stationsData: FuelStationsResult? = nil
    @Published var stationsError: Bool = false
    @Published var stationsLoading: Bool = true
    
    @Published var stationsSearchText = ""
    @Published var stationsListHasContent = true    // To make transition
    @Published var stationsSelectedSorting: Enums.StationsSortingOptions = .proximity
    
    @Published var selectedStation: FuelStation? = nil
    
    @Published var location: CLLocation? = nil
    
    init() {
        Task {
            await fetchMunicipalities()
        }
    }
    
    func fetchMunicipalities() async {
        self.municipalitiesLoading = true
        
        let result = await ApiClient.fetchMunicipalities()
        if result.successful == true {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.municipalitiesData = result.data!
                    self.municipalitiesLoading = false
                    self.municipalitiesError = false
                }
            }
        }
        else {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.municipalitiesData = nil
                    self.municipalitiesLoading = false
                    self.municipalitiesError = true
                }
            }
        }
    }
    
    func fetchStations() async {
        if let municipalityId = selectedMunicipality?.IDMunicipio {
            self.stationsLoading = true
            
            let result = await ApiClient.fetchServiceStationsByMunicipality(municipalityId: municipalityId)
            if result.successful == true {
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.stationsData = result.data!
                        self.stationsLoading = false
                        self.stationsError = false
                    }
                }
            }
            else {
                withAnimation(.default) {
                    self.stationsData = nil
                    self.stationsLoading = false
                    self.stationsError = true
                }
            }
        }
    }
    
    func clearSelectedMunicipality() {
        self.selectedMunicipality = nil
        self.stationsData = nil
        self.stationsLoading = true
        self.stationsError = false
    }
}
