import SwiftUI

fileprivate class FuelColors {
    let fuelType: Enums.FuelTypes
    let color: Color
    
    init(fuelType: Enums.FuelTypes, color: Color) {
        self.fuelType = fuelType
        self.color = color
    }
}

@MainActor
fileprivate let defaultColors: [FuelColors] = [
    FuelColors(fuelType: .aGasoil, color: Color(hex: "#000000")),
    FuelColors(fuelType: .bGasoil, color: Color(hex: "#b30400")),
    FuelColors(fuelType: .premiumGasoil, color: Color(hex: "#000000")),
    FuelColors(fuelType: .biodiesel, color: Color(hex: "#000000")),
    FuelColors(fuelType: .gasoline95E5, color: Color(hex: "#008a56")),
    FuelColors(fuelType: .gasoline95E10, color: Color(hex: "#008a56")),
    FuelColors(fuelType: .gasoline95E5Premium, color: Color(hex: "#008a56")),
    FuelColors(fuelType: .gasoline98E5, color: Color(hex: "#80b91f")),
    FuelColors(fuelType: .gasoline98E10, color: Color(hex: "#80b91f")),
    FuelColors(fuelType: .bioethanol, color: Color(hex: "#008a56")),
    FuelColors(fuelType: .cng, color: Color(hex: "#ff8400")),
    FuelColors(fuelType: .lng, color: Color(hex: "#ff8400")),
    FuelColors(fuelType: .lpg, color: Color(hex: "#ff8400")),
    FuelColors(fuelType: .hydrogen, color: Color(hex: "#007ab7")),
]

struct FavoriteFuelPicker: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Text("Select up to \(Config.maxFavoriteFuels) favorite fuels")
                        .multilineTextAlignment(.center)
                        .fontWeight(.semibold)
                        .padding(.bottom, -12)
                        .textCase(nil)
                        .font(.system(size: 16))
                    Spacer()
                }
                .padding(.bottom, 24)
                ListItem(name: String(localized: "A Gasoil"), fuelType: .aGasoil)
                ListItem(name: String(localized: "B Gasoil"), fuelType: .bGasoil)
                ListItem(name: String(localized: "Premium Gasoil"), fuelType: .premiumGasoil)
                ListItem(name: String(localized: "Biodiesel"), fuelType: .biodiesel)
                ListItem(name: String(localized: "Gasoline 95 E5"), fuelType: .gasoline95E5)
                ListItem(name: String(localized: "Gasoline 95 E5 Premium"), fuelType: .gasoline95E5Premium)
                ListItem(name: String(localized: "Gasoline 95 E10"), fuelType: .gasoline95E10)
                ListItem(name: String(localized: "Gasoline 98 E5"), fuelType: .gasoline98E5)
                ListItem(name: String(localized: "Gasoline 98 E10"), fuelType: .gasoline98E10)
                ListItem(name: String(localized: "Bioethanol"), fuelType: .bioethanol)
                ListItem(name: String(localized: "Compressed Natural Gas"), fuelType: .cng)
                ListItem(name: String(localized: "Liquefied Natural Gas"), fuelType: .lng)
                ListItem(name: String(localized: "Liquefied petroleum gases"), fuelType: .lpg)
                ListItem(name: String(localized: "Hydrogen"), fuelType: .hydrogen)
            }
            .padding(12)
        }
        .navigationTitle("Favorite fuel")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.listBackground)
    }
}

fileprivate struct ListItem: View {
    var name: String
    var fuelType: Enums.FuelTypes
    
    @State var color: Color
    
    init(name: String, fuelType: Enums.FuelTypes) {
        self.name = name
        self.fuelType = fuelType
        self.color = .accentColor
    }
    
    @EnvironmentObject private var favoriteFuelProvider: FavoriteFuelProvider
    
    var body: some View {
        let selected = !favoriteFuelProvider.favoriteFuel.filter({ $0.fuelKey == fuelType.rawValue }).isEmpty
        let disabled = favoriteFuelProvider.favoriteFuel.count >= Config.maxFavoriteFuels && favoriteFuelProvider.favoriteFuel.filter({ $0.fuelKey == fuelType.rawValue }).isEmpty
        
        Button {
            withAnimation(.default) {
                favoriteFuelProvider.updateFavorites(item: fuelType, color: color)
            }
        } label: {
            HStack {
                ColorPicker(selection: $color) {
                    EmptyView()
                }
                .padding(.leading, -8)
                .frame(width: 30)
                Spacer()
                    .frame(width: 12)
                Text(name)
                Spacer()
                if selected == true {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .contentShape(Rectangle())
        }
        .disabled(disabled)
        .padding()
        .background(Color.listItemBackground)
        .clipShape(.rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue, lineWidth: 2)
                .opacity(selected == true ? 1 : 0)
        )
        .animation(.easeOut, value: selected)
        .buttonStyle(.plain)
        .foregroundStyle(disabled ? Color.gray : Color.foreground)
        .transition(.opacity)
        .onAppear {
            if let colorCode = favoriteFuelProvider.favoriteFuel.first(where: { $0.fuelKey == fuelType.rawValue })?.colorCode {
                self.color = Color(hex: colorCode)
            }
            else {
                self.color = defaultColors.first(where: { $0.fuelType == fuelType })?.color ?? Color.accentColor
            }
        }
        .onChange(of: color, initial: false) {
            favoriteFuelProvider.updateColor(item: fuelType, color: color)
        }
    }
}
