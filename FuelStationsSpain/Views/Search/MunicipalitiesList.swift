import SwiftUI

struct SearchListSection: Hashable {
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
                if searchViewModel.municipalitiesData != nil {
                    DataList()
                        .searchable(text: $searchViewModel.municipalitiesSearchText, isPresented: $searchViewModel.municipalitiesSearchPresented, prompt: "Search municipality")
                        .onSubmit(of: .search) {
                            searchViewModel.filterMunicipalities()
                        }
                        .onChange(of: searchViewModel.municipalitiesSearchPresented, { oldValue, newValue in
                            if oldValue == true && newValue == false {
                                searchViewModel.filterMunicipalities(clearSearch: true)
                            }
                        })
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
    private func DataList() -> some View {
        if let filtered = searchViewModel.filteredMunicipalitiesData {
            if !filtered.isEmpty {
                List(filtered, id: \.self, selection: $searchViewModel.selectedMunicipality) { item in
                    Text(item.Municipio!)
                }
                .transition(.opacity)
            }
            else {
                ContentUnavailableView("No results", systemImage: "magnifyingglass", description: Text("Change the inputted search term."))
                    .transition(.opacity)
            }
        }
        else {
            switch searchViewModel.municipalitiesSorting {
            case .groupedProvince:
                List(searchViewModel.municipalitiesDataByProvince!, id: \.self, selection: $searchViewModel.selectedMunicipality) { item in
                    Section(item.sectionName) {
                        ForEach(item.municipalities, id: \.self) { item in
                            Text(item.Municipio!)
                        }
                    }
                }
                .animation(.default, value: searchViewModel.municipalitiesDataByProvince!)
                .transition(.opacity)
            case .alphabetical:
                if showSectionIndexList {
                    ScrollViewReader { proxy in
                        List(searchViewModel.municipalitiesDataByInitial!, id: \.sectionId, selection: $searchViewModel.selectedMunicipality) { section in
                            // Simulates a section header. Not using Section because it causes "List failed to visit cell content, returning an empty cell" error
                            Text(section.sectionName.uppercased())
                                .listRowBackground(Color.listBackground)
                                .listRowSeparator(.hidden)
                                .fontSize(14)
                                .foregroundStyle(Color.gray)
                                .padding(.top, section == searchViewModel.municipalitiesDataByInitial!.first ? 12 : 24)
                                .disabled(true)
                            ForEach(section.municipalities, id: \.self) { item in
                                Text(item.Municipio!)
                                    .listRowSeparator(item == section.municipalities.last ? .hidden : .visible)
                            }
                            .id(section.sectionId)
                        }
                        .overlay(content: {
                            if !searchViewModel.municipalitiesSearchPresented {
                                SectionIndexTitles(proxy: proxy, titles: searchViewModel.municipalitiesDataByInitial!.map() { $0.sectionName })
                                    .transition(.opacity)
                            }
                        })
                        .animation(.default, value: searchViewModel.municipalitiesDataByInitial!)
                        .transition(.opacity)
                    }
                }
                else {
                    List(searchViewModel.municipalitiesDataByInitial!, id: \.sectionId, selection: $searchViewModel.selectedMunicipality) { section in
                        Section(section.sectionName.uppercased()) {
                            ForEach(section.municipalities, id: \.self) { item in
                                Text(item.Municipio!)
                            }
                        }
                    }
                    .animation(.default, value: searchViewModel.municipalitiesDataByInitial!)
                    .transition(.opacity)
                }
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
