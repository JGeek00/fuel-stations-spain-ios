import CoreLocation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var municipalitiesData: [Municipality]? = nil
    @Published var municipalitiesDataByProvince: [SearchListSection]? = nil
    @Published var municipalitiesDataByInitial: [SearchListSection]? = nil
    @Published var filteredMunicipalitiesData: [Municipality]? = nil
    @Published var municipalitiesError: Bool = false
    @Published var municipalitiesLoading: Bool = true
    
    @Published var municipalitiesSearchText = ""
    @Published var municipalitiesSearchPresented = false
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
    
    private func groupByProvince(_ data: [Municipality]) -> [SearchListSection] {
        var grouped = [String: [Municipality]]()
           
        for municipality in data {
            if grouped[municipality.IDProvincia!] != nil {
                grouped[municipality.IDProvincia!]?.append(municipality)
            } else {
                grouped[municipality.IDProvincia!] = [municipality]
            }
        }
           
        var sections: [SearchListSection] = []
           
        for (provinceId, munList) in grouped {
            let provinceName = munList.first?.Provincia! ?? ""
            
            let provinceData = SearchListSection(
                sectionId: provinceId,
                sectionName: provinceName,
                municipalities: munList
            )
            
            sections.append(provinceData)
        }
        
        return sections.sorted { a, b in
            a.sectionName < b.sectionName
        }
    }
    
    private func groupByInitial(_ data: [Municipality]) -> [SearchListSection] {
        func removeAccents(from text: String) -> String {
            return text.folding(options: .diacriticInsensitive, locale: .current)
                    .replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
        }
        
        var grouped = [String: [Municipality]]()
           
        for municipality in data {
            if let mun = municipality.Municipio?.first {
                let noAccent = removeAccents(from: String(mun))
                if grouped[noAccent] != nil {
                    grouped[noAccent]?.append(municipality)
                } else {
                    grouped[noAccent] = [municipality]
                }
            }
        }
           
        var sections: [SearchListSection] = []
           
        for (id, munList) in grouped {
            let provinceData = SearchListSection(
                sectionId: id,
                sectionName: id,
                municipalities: munList
            )
            
            sections.append(provinceData)
        }
        
        return sections.sorted { a, b in
            a.sectionName < b.sectionName
        }
    }
    
    func filterMunicipalities(clearSearch: Bool = false) {
        if municipalitiesSearchText == "" || clearSearch == true {
            withAnimation(.default) {
                self.filteredMunicipalitiesData = nil
            }
            return
        }
        
        let searchText = municipalitiesSearchText
        if let data = municipalitiesData {
            DispatchQueue.global(qos: .background).async {
                let filtered = data.filter({ $0.Municipio?.lowercased().contains(searchText.lowercased()) ?? false })
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.filteredMunicipalitiesData = filtered
                    }
                }
            }
        }
        else {
            withAnimation(.default) {
                self.filteredMunicipalitiesData = nil
            }
        }
    }
    
    func fetchMunicipalities() async {
        self.municipalitiesLoading = true
        
        let result = await ApiClient.fetchMunicipalities()
        if result.successful == true {
            let provinces = self.groupByProvince(result.data!)
            let initial = self.groupByInitial(result.data!)
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.municipalitiesData = result.data!
                    self.municipalitiesDataByProvince = provinces
                    self.municipalitiesDataByInitial = initial
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
                        self.stationsData = FuelStationsResult.filterStations(result.data!)
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
