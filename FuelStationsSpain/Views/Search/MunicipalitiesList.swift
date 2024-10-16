import SwiftUI

fileprivate struct Province: Hashable {
    let provinceId: String
    let provinceName: String
    let municipalities: [Municipality]
}

struct SearchMunicipalitiesList: View {
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    var body: some View {
        @Bindable var searchViewModel = searchViewModel
        
        Group {
            if searchViewModel.municipalitiesLoading == true {
                ProgressView()
                    .transition(.opacity)
            }
            else if searchViewModel.municipalitiesError == true {
                ContentUnavailableView("Cannot load municipalities", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the municipalities. Try again later."))
                    .transition(.opacity)
            }
            else {
                if let data = searchViewModel.municipalitiesData {
                    let filtered = searchViewModel.municipalitiesSearchText != "" ? data.filter() { $0.Municipio!.lowercased().contains(searchViewModel.municipalitiesSearchText.lowercased()) } : data
                    Group {
                        if searchViewModel.municipalitiesListHasContent == false {
                            ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                                .transition(.opacity)
                        }
                        else {
                            DataList(data: filtered)
                        }
                    }
                    .onChange(of: filtered) {
                        withAnimation(.default) {
                            if filtered.isEmpty {
                                searchViewModel.municipalitiesListHasContent = false
                            }
                            else {
                                searchViewModel.municipalitiesListHasContent = true
                            }
                        }
                    }
                    .searchable(text: $searchViewModel.municipalitiesSearchText, prompt: "Search municipality")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button {
                                    withAnimation(.default) {
                                        searchViewModel.municipalitiesSorting = .groupedProvince
                                    }
                                } label: {
                                    if searchViewModel.municipalitiesSorting == .groupedProvince {
                                        Label("Grouped by province", systemImage: "checkmark")
                                    }
                                    else {
                                        Text("Grouped by province")
                                    }
                                }
                                Button {
                                    withAnimation(.default) {
                                        searchViewModel.municipalitiesSorting = .alphabetical
                                    }
                                } label: {
                                    if searchViewModel.municipalitiesSorting == .alphabetical {
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
                }
                else {
                    ContentUnavailableView("Cannot load municipalities", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the municipalities. Try again later."))
                        .transition(.opacity)
                }
            }
        }
        .navigationTitle("Search")
        .onChange(of: searchViewModel.selectedMunicipality) {
            if searchViewModel.selectedMunicipality != nil {
                searchViewModel.stationsLoading = true
                Task {
                    await searchViewModel.fetchStations()
                }
            }
        }
    }
    
    @ViewBuilder
    private func DataList(data: [Municipality]) -> some View {
        @Bindable var searchViewModel = searchViewModel
        
        switch searchViewModel.municipalitiesSorting {
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
                    
                    let provinceData = Province(
                        provinceId: provinceId,
                        provinceName: provinceName,
                        municipalities: munList
                    )
                    
                    provinces.append(provinceData)
                }
                
                return provinces.sorted { a, b in
                    a.provinceName < b.provinceName
                }
            }()
            
            List(groupedByProvince, id: \.self, selection: $searchViewModel.selectedMunicipality) { item in
                Section(item.provinceName) {
                    ForEach(item.municipalities, id: \.self) { item in
                        Text(item.Municipio!)
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
            
            List(sorted, id: \.self, selection: $searchViewModel.selectedMunicipality) { item in
                Text(item.Municipio!)
            }
            .animation(.default, value: data)
            .transition(.opacity)
        }
    }
}
