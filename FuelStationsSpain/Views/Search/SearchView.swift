import SwiftUI

fileprivate struct Province: Hashable {
    let provinceId: String
    let provinceName: String
    let municipalities: [MunicipalityInfo]
}

fileprivate struct MunicipalityInfo: Hashable {
    let idMunicipio: String
    let name: String
}

struct SearchView: View {
    
    @EnvironmentObject private var municipalitiesProvider: MunicipalitiesProvider
        
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    @State private var selectedMunicipality: Municipality? = nil
    @State private var sorting: Enums.SearchSortingOptions = .groupedProvince
    
    var body: some View {
        NavigationSplitView {
            MunicipalitiesList()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                withAnimation(.default) {
                                    sorting = .groupedProvince
                                }
                            } label: {
                                if sorting == .groupedProvince {
                                    Label("Grouped by province", systemImage: "checkmark")
                                }
                                else {
                                    Text("Grouped by province")
                                }
                            }
                            Button {
                                withAnimation(.default) {
                                    sorting = .alphabetical
                                }
                            } label: {
                                if sorting == .alphabetical {
                                    Label("Alphabetically by municipality", systemImage: "checkmark")
                                }
                                else {
                                    Text("Alphabetically by municipality")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                    }
                }
        } content: {
            
        } detail: {
            
        }
    }
    
    @ViewBuilder
    private func MunicipalitiesList() -> some View {
        Group {
            if municipalitiesProvider.loading == true {
                ProgressView()
                    .transition(.opacity)
            }
            else if municipalitiesProvider.data != nil {
                let filtered = searchText != "" ? municipalitiesProvider.data!.filter() { $0.Municipio!.lowercased().contains(searchText.lowercased()) } : municipalitiesProvider.data!
                Group {
                    if listHasContent == false {
                        ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                            .transition(.opacity)
                    }
                    else {
                        MunicipalitiesList(data: filtered)
                    }
                }
                .onChange(of: filtered) {
                    withAnimation(.default) {
                        if filtered.isEmpty {
                            listHasContent = false
                        }
                        else {
                            listHasContent = true
                        }
                    }
                }
            }
            else {
                ContentUnavailableView("Cannot load municipalities", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the municipalities. Try again later."))
                    .transition(.opacity)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Search municipality")
    }
    
    @ViewBuilder
    private func MunicipalitiesList(data: [Municipality]) -> some View {
        switch sorting {
        case .groupedProvince:
            let groupedByProvince: [Province] = {
                var groupedMunicipalities = [String: [Municipality]]()
                   
                for municipality in data {
                    if groupedMunicipalities[municipality.IDProvincia!] != nil {
                        groupedMunicipalities[municipality.IDProvincia!]?.append(municipality)
                    } else {
                        groupedMunicipalities[municipality.IDProvincia!] = [municipality]
                    }
                }
                   
                var provinces: [Province] = []
                   
                for (provinceId, munList) in groupedMunicipalities {
                    let provinceName = munList.first?.Provincia! ?? ""
                    
                    let municipalityInfoList: [MunicipalityInfo] = munList.map {
                        MunicipalityInfo(idMunicipio: $0.IDMunicipio!, name: $0.Municipio!)
                    }
                    
                    let provinceData = Province(
                        provinceId: provinceId,
                        provinceName: provinceName,
                        municipalities: municipalityInfoList
                    )
                    
                    provinces.append(provinceData)
                }
                
                return provinces.sorted { a, b in
                    a.provinceName < b.provinceName
                }
            }()
            
            List(groupedByProvince, id: \.self, selection: $selectedMunicipality) { item in
                Section(item.provinceName) {
                    ForEach(item.municipalities, id: \.self) { item in
                        Text(item.name)
                    }
                }
            }
            .animation(.default, value: data)
            .transition(.opacity)
        case .alphabetical:
            let sorted = {
                return data.sorted { a, b in
                    return a.Municipio! < b.Municipio!
                }
            }()
            
            List(sorted, id: \.self, selection: $selectedMunicipality) { item in
                Text(item.Municipio!)
            }
            .animation(.default, value: data)
            .transition(.opacity)
        }
    }
}
