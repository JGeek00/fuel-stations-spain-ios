import CoreLocation
import SwiftUI

@MainActor
@Observable
class SearchViewModel {
    var municipalitiesData: [Municipality]? = nil
    var municipalitiesError: Bool = false
    var municipalitiesLoading: Bool = true
    
    var municipalitiesSearchText = ""
    var municipalitiesListHasContent = true    // To make transition
    var municipalitiesSorting: Enums.SearchSortingOptions = .groupedProvince
    
    var selectedMunicipality: Municipality? = nil
    
    var stationsData: FuelStationsResult? = nil
    var stationsError: Bool = false
    var stationsLoading: Bool = true
    
    var stationsSearchText = ""
    var stationsListHasContent = true    // To make transition
    var stationsSelectedSorting: Enums.StationsSortingOptions = .proximity
    
    var selectedStation: FuelStation? = nil
    
    var location: CLLocation? = nil
    
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
