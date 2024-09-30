import SwiftUI

struct SortingPicker: View {
    var selectedSorting: Enums.SortingOptions
    var onSelect: (_ selected: Enums.SortingOptions) -> Void
    
    init(selectedSorting: Enums.SortingOptions, onSelect: @escaping (_: Enums.SortingOptions) -> Void) {
        self.selectedSorting = selectedSorting
        self.onSelect = onSelect
    }
    
    var body: some View {
        Menu {
            Section {
                MenuItem(label: String(localized: "Proximity"), selectedOption: selectedSorting, value: .proximity) { value in
                    onSelect(value)
                }
            }
            Section {
                Menu {
                    Section {
                        MenuItem(label: String(localized: "A Gasoil"), selectedOption: selectedSorting, value: .aGasoil) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "B Gasoil"), selectedOption: selectedSorting, value: .bGasoil) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Premium Gasoil"), selectedOption: selectedSorting, value: .premiumGasoil) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Biodiesel"), selectedOption: selectedSorting, value: .biodiesel) { value in
                            onSelect(value)
                        }
                    }
                    Section {
                        MenuItem(label: String(localized: "Gasoline 95 E10"), selectedOption: selectedSorting, value: .gasoline95E10) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Gasoline 95 E5"), selectedOption: selectedSorting, value: .gasoline95E5) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Gasoline 95 E5 Premium"), selectedOption: selectedSorting, value: .gasoline95E5Premium) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Gasoline 98 E10"), selectedOption: selectedSorting, value: .gasoline98E10) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Gasoline 98 E5"), selectedOption: selectedSorting, value: .gasoline98E5) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Bioethanol"), selectedOption: selectedSorting, value: .bioethanol) { value in
                            onSelect(value)
                        }
                    }
                    Section {
                        MenuItem(label: String(localized: "Compressed Natural Gas"), selectedOption: selectedSorting, value: .cng) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Liquefied Natural Gas"), selectedOption: selectedSorting, value: .lng) { value in
                            onSelect(value)
                        }
                        MenuItem(label: String(localized: "Liquefied petroleum gases"), selectedOption: selectedSorting, value: .lpg) { value in
                            onSelect(value)
                        }
                    }
                    Section {
                        MenuItem(label: String(localized: "Hydrogen"), selectedOption: selectedSorting, value: .hydrogen) { value in
                            onSelect(value)
                        }
                    }
                } label: {
                    HStack {
                        Text("Fuel price")
                        if selectedSorting != .proximity {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
    }
    
    @ViewBuilder
    func MenuItem(label: String, selectedOption: Enums.SortingOptions, value: Enums.SortingOptions, onSelect: @escaping (_ value: Enums.SortingOptions) -> Void) -> some View {
        Button {
            onSelect(value)
        } label: {
            Text(label)
            if selectedOption == value {
                Image(systemName: "checkmark")
            }
        }
    }
}
