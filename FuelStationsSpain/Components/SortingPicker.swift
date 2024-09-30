import SwiftUI

struct SortingPicker: View {
    @Binding var selectedSorting: Enums.SortingOptions
    
    var body: some View {
        Menu {
            Section {
                MenuItem(label: String(localized: "Proximity"), selectedOption: $selectedSorting, value: .proximity)
            }
            Section {
                Menu {
                    Section("Gasoil") {
                        MenuItem(label: String(localized: "A Gasoil"), selectedOption: $selectedSorting, value: .aGasoil)
                        MenuItem(label: String(localized: "B Gasoil"), selectedOption: $selectedSorting, value: .bGasoil)
                        MenuItem(label: String(localized: "Premium Gasoil"), selectedOption: $selectedSorting, value: .premiumGasoil)
                        MenuItem(label: String(localized: "Biodiesel"), selectedOption: $selectedSorting, value: .biodiesel)
                    }
                    Section("Gasoline") {
                        MenuItem(label: String("Gasoline 95 E10"), selectedOption: $selectedSorting, value: .gasoline95E10)
                        MenuItem(label: String(localized: "Gasoline 95 E5"), selectedOption: $selectedSorting, value: .gasoline95E5)
                        MenuItem(label: String(localized: "Gasoline 95 E5 Premium"), selectedOption: $selectedSorting, value: .gasoline95E5Premium)
                        MenuItem(label: String(localized: "Gasoline 98 E10"), selectedOption: $selectedSorting, value: .gasoline98E10)
                        MenuItem(label: String(localized: "Gasoline 98 E5"), selectedOption: $selectedSorting, value: .gasoline98E5)
                        MenuItem(label: String(localized: "Bioethanol"), selectedOption: $selectedSorting, value: .bioethanol)
                    }
                    Section("Gas") {
                        MenuItem(label: String(localized: "Compressed Natural Gas"), selectedOption: $selectedSorting, value: .cng)
                        MenuItem(label: String(localized: "Liquefied Natural Gas"), selectedOption: $selectedSorting, value: .lng)
                        MenuItem(label: String(localized: "Liquefied petroleum gases"), selectedOption: $selectedSorting, value: .lpg)
                    }
                    Section("Others") {
                        MenuItem(label: String(localized: "Hydrogen"), selectedOption: $selectedSorting, value: .hydrogen)
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

fileprivate struct MenuItem: View {
    var label: String
    @Binding var selectedOption: Enums.SortingOptions
    var value: Enums.SortingOptions
    
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
