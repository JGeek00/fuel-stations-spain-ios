import SwiftUI

struct ListsSettings: View {
    
    @AppStorage(StorageKeys.defaultListSorting, store: UserDefaults.shared) private var defaultListSorting = Defaults.defaultListSorting
    
    var body: some View {
        List {
            let selectedText = {
                switch defaultListSorting {
                    case .proximity: return String(localized: "Proximity")
                    case .aGasoil: return String(localized: "A Gasoil")
                    case .bGasoil: return String(localized: "B Gasoil")
                    case .premiumGasoil: return String(localized: "Premium Gasoil")
                    case .biodiesel: return String(localized: "Biodiesel")
                    case .gasoline95E5: return String(localized: "Gasoline 95 E5")
                    case .gasoline95E10: return String(localized: "Gasoline 95 E10")
                    case .gasoline95E5Premium: return String(localized: "Gasoline 95 E5 Premium")
                    case .gasoline98E5: return String(localized: "Gasoline 98 E5")
                    case .gasoline98E10: return String(localized: "Gasoline 98 E10")
                    case .bioethanol: return String(localized: "Bioethanol")
                    case .cng: return String(localized: "Compressed Natural Gas")
                    case .lng: return String(localized: "Liquefied Natural Gas")
                    case .lpg: return String(localized: "Liquefied petroleum gases")
                    case .hydrogen: return String(localized: "Hydrogen")
                }
            }()
            
            HStack {
                Text("Default sorting")
                Spacer()
                Menu {
                    Section {
                        MenuItem(label: String(localized: "Proximity"), selectedOption: $defaultListSorting, value: .proximity)
                    }
                    Section {
                        Menu {
                            Section("Gasoil") {
                                MenuItem(label: String(localized: "A Gasoil"), selectedOption: $defaultListSorting, value: .aGasoil)
                                MenuItem(label: String(localized: "B Gasoil"), selectedOption: $defaultListSorting, value: .bGasoil)
                                MenuItem(label: String(localized: "Premium Gasoil"), selectedOption: $defaultListSorting, value: .premiumGasoil)
                                MenuItem(label: String(localized: "Biodiesel"), selectedOption: $defaultListSorting, value: .biodiesel)
                            }
                            Section("Gasoline") {
                                MenuItem(label: String(localized: "Gasoline 95 E5"), selectedOption: $defaultListSorting, value: .gasoline95E5)
                                MenuItem(label: String(localized: "Gasoline 95 E10"), selectedOption: $defaultListSorting, value: .gasoline95E10)
                                MenuItem(label: String(localized: "Gasoline 95 E5 Premium"), selectedOption: $defaultListSorting, value: .gasoline95E5Premium)
                                MenuItem(label: String(localized: "Gasoline 98 E5"), selectedOption: $defaultListSorting, value: .gasoline98E5)
                                MenuItem(label: String(localized: "Gasoline 98 E10"), selectedOption: $defaultListSorting, value: .gasoline98E10)
                                MenuItem(label: String(localized: "Bioethanol"), selectedOption: $defaultListSorting, value: .bioethanol)
                            }
                            Section("Gas") {
                                MenuItem(label: String(localized: "Compressed Natural Gas"), selectedOption: $defaultListSorting, value: .cng)
                                MenuItem(label: String(localized: "Liquefied Natural Gas"), selectedOption: $defaultListSorting, value: .lng)
                                MenuItem(label: String(localized: "Liquefied petroleum gases"), selectedOption: $defaultListSorting, value: .lpg)
                            }
                            Section("Others") {
                                MenuItem(label: String(localized: "Hydrogen"), selectedOption: $defaultListSorting, value: .hydrogen)
                            }
                        } label: {
                            if defaultListSorting != .proximity {
                                Label("Fuel price", systemImage: "checkmark")
                            }
                            else {
                                Text("Fuel price")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedText)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundStyle(Color.listItemValue)
                }
            }
        }
        .navigationTitle("Lists")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ListsSettings()
}
