import SwiftUI

struct SortingPicker: View {
    @Binding var selectedSorting: Enums.StationsSortingOptions
    
    var body: some View {
        Menu {
            Section {
                MenuItem(label: String(localized: "Proximity"), selectedOption: $selectedSorting, value: .proximity)
            }
            Section {
                Menu {
                    ForEach(fuelList, id: \.self) { section in
                        Section(section.name) {
                            ForEach(section.types, id: \.self) { type in
                                MenuItem(label: type.name, selectedOption: $selectedSorting, value: .fuelType(type.type))
                            }
                        }
                    }
                } label: {
                    if selectedSorting != .proximity {
                        Label("Fuel price", systemImage: "checkmark")
                    }
                    else {
                        Text("Fuel price")
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }
}

struct MenuItem: View {
    var label: String
    @Binding var selectedOption: Enums.StationsSortingOptions
    var value: Enums.StationsSortingOptions
    
    var body: some View {
        Button {
            selectedOption = value
        } label: {
            if selectedOption == value {
                Label(label, systemImage: "checkmark")
            }
            else {
                Text(label)
            }
        }
    }
}

#Preview {
    @Previewable @State var selected: Enums.StationsSortingOptions = .proximity
    NavigationStack {
        VStack {}
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SortingPicker(selectedSorting: $selected)
                }
            }
    }
}
