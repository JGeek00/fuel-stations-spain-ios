import SwiftUI

fileprivate struct ListSection: Hashable {
    let sectionId: String
    let sectionName: String
    let municipalities: [Municipality]
}

struct SearchMunicipalitiesList: View {
    
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @AppStorage(StorageKeys.showSectionIndexList, store: UserDefaults.shared) private var showSectionIndexList = Defaults.showSectionIndexList
    
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
                    .searchable(text: $searchViewModel.municipalitiesSearchText, isPresented: $searchViewModel.municipalitiesSearchPresented, prompt: "Search municipality")
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
        switch searchViewModel.municipalitiesSorting {
        case .groupedProvince:
            let grouped: [ListSection] = {
                var grouped = [String: [Municipality]]()
                   
                for municipality in data {
                    if grouped[municipality.IDProvincia!] != nil {
                        grouped[municipality.IDProvincia!]?.append(municipality)
                    } else {
                        grouped[municipality.IDProvincia!] = [municipality]
                    }
                }
                   
                var sections: [ListSection] = []
                   
                for (provinceId, munList) in grouped {
                    let provinceName = munList.first?.Provincia! ?? ""
                    
                    let provinceData = ListSection(
                        sectionId: provinceId,
                        sectionName: provinceName,
                        municipalities: munList
                    )
                    
                    sections.append(provinceData)
                }
                
                return sections.sorted { a, b in
                    a.sectionName < b.sectionName
                }
            }()
            
            List(grouped, id: \.self, selection: $searchViewModel.selectedMunicipality) { item in
                Section(item.sectionName) {
                    ForEach(item.municipalities, id: \.self) { item in
                        Text(item.Municipio!)
                    }
                }
            }
            .animation(.default, value: data)
            .transition(.opacity)
        case .alphabetical:
            let grouped: [ListSection] = {
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
                   
                var sections: [ListSection] = []
                   
                for (id, munList) in grouped {
                    let provinceData = ListSection(
                        sectionId: id,
                        sectionName: id,
                        municipalities: munList
                    )
                    
                    sections.append(provinceData)
                }
                
                return sections.sorted { a, b in
                    a.sectionName < b.sectionName
                }
            }()
            
            if showSectionIndexList {
                ScrollViewReader { proxy in
                    List(grouped, id: \.sectionId, selection: $searchViewModel.selectedMunicipality) { section in
                        // Simulates a section header. Not using Section because it causes "List failed to visit cell content, returning an empty cell" error
                        Text(section.sectionName.uppercased())
                            .listRowBackground(Color.listBackground)
                            .listRowSeparator(.hidden)
                            .fontSize(14)
                            .foregroundStyle(Color.gray)
                            .padding(.top, section == grouped.first ? 12 : 24)
                            .disabled(true)
                        ForEach(section.municipalities, id: \.self) { item in
                            Text(item.Municipio!)
                                .listRowSeparator(item == section.municipalities.last ? .hidden : .visible)
                        }
                        .id(section.sectionId)
                    }
                    .overlay(content: {
                        if !searchViewModel.municipalitiesSearchPresented {
                            SectionIndexTitles(proxy: proxy, titles: grouped.map() { $0.sectionName })
                                .transition(.opacity)
                        }
                    })
                    .animation(.default, value: data)
                    .transition(.opacity)
                }
            }
            else {
                List(grouped, id: \.sectionId, selection: $searchViewModel.selectedMunicipality) { section in
                    Section(section.sectionName.uppercased()) {
                        ForEach(section.municipalities, id: \.self) { item in
                            Text(item.Municipio!)
                        }
                    }
                }
                .animation(.default, value: data)
                .transition(.opacity)
            }
        }
    }
}

fileprivate struct SectionIndexTitles: View {
    let proxy: ScrollViewProxy
    let titles: [String]
    @GestureState private var dragLocation: CGPoint = .zero

    var body: some View {
        VStack {
            ForEach(titles, id: \.self) { title in
                Text(title)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                    .fontSize(12)
                    .background(
                        GeometryReader { geometry in
                            if geometry.frame(in: .global).contains(dragLocation) {
                                DispatchQueue.main.async {
                                    proxy.scrollTo(title, anchor: .center)
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            }
                            return Rectangle().fill(Color.clear)
                        }
                    )
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .global)
                .updating($dragLocation) { value, state, _ in
                    state = value.location
                }
        )
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 4)
    }
}
