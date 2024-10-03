import SwiftUI

fileprivate struct Province: Hashable {
    let provinceId: String
    let provinceName: String
    let municipalities: [Municipality]
}

struct SearchMunicipalitiesList: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @State private var searchText = ""
    @State private var listHasContent = true    // To make transition
    @State private var sorting: Enums.SearchSortingOptions = .groupedProvince
    
    var body: some View {
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
                    let filtered = searchText != "" ? data.filter() { $0.Municipio!.lowercased().contains(searchText.lowercased()) } : data
                    Group {
                        if listHasContent == false {
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
                                listHasContent = false
                            }
                            else {
                                listHasContent = true
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search municipality")
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
                }
                else {
                    ContentUnavailableView("Cannot load municipalities", systemImage: "exclamationmark.circle.fill", description: Text("An error occured when loading the municipalities. Try again later."))
                        .transition(.opacity)
                }
            }
        }
        .navigationTitle("Search")
    }
    
    @ViewBuilder
    private func DataList(data: [Municipality]) -> some View {
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
