import Foundation

struct FavoriteFuel: Sendable, Hashable {
    let label: String
    let fuelType: Enums.FavoriteFuelType
    
    init(label: String, fuelType: Enums.FavoriteFuelType) {
        self.label = label
        self.fuelType = fuelType
    }
}

struct FuelSection: Sendable, Hashable {
    let label: String?
    let fuels: [FavoriteFuel]
    
    init(label: String?, fuels: [FavoriteFuel]) {
        self.label = label
        self.fuels = fuels
    }
}

let favoriteFuels: [FuelSection] = [
    FuelSection(
        label: nil,
        fuels: [
            FavoriteFuel(label: String(localized: "None"), fuelType: .none),
        ]
    ),
    FuelSection(
        label: String(localized: "Gasoil"),
        fuels: [
            FavoriteFuel(label: String(localized: "A Gasoil"), fuelType: .gasoilA),
            FavoriteFuel(label: String(localized: "B Gasoil"), fuelType: .gasoilB),
            FavoriteFuel(label: String(localized: "Premium Gasoil"), fuelType: .premiumGasoil),
            FavoriteFuel(label: String(localized: "Biodiesel"), fuelType: .biodiesel),
        ]
    ),
    FuelSection(
        label: String(localized: "Gasoline"),
        fuels: [
            FavoriteFuel(label: String(localized: "Gasoline 95 E5"), fuelType: .gasoline95E5),
            FavoriteFuel(label: String(localized: "Gasoline 95 E10"), fuelType: .gasoline95E10),
            FavoriteFuel(label: String(localized: "Gasoline 95 E5 Premium"), fuelType: .gasoline95E5Premium),
            FavoriteFuel(label: String(localized: "Gasoline 98 E5"), fuelType: .gasoline98E5),
            FavoriteFuel(label: String(localized: "Gasoline 95 E10"), fuelType: .gasoline98E10),
            FavoriteFuel(label: String(localized: "Bioethanol"), fuelType: .bioethanol),
        ]
    ),
    FuelSection(
        label: String(localized: "Gas"),
        fuels: [
            FavoriteFuel(label: String(localized: "Compressed Natural Gas"), fuelType: .cng),
            FavoriteFuel(label: String(localized: "Liquefied Natural Gas"), fuelType: .lng),
            FavoriteFuel(label: String(localized: "Liquefied petroleum gases"), fuelType: .lpg),
        ]
    ),
    FuelSection(
        label: String(localized: "Others"),
        fuels: [
            FavoriteFuel(label: String(localized: "Hydrogen"), fuelType: .hydrogen)
        ]
    )
]

func getFuelNameString(fuel: Enums.FavoriteFuelType) -> String? {
    for fuelGroup in favoriteFuels {
        for f in fuelGroup.fuels {
            if f.fuelType == fuel {
                return f.label
            }
        }
    }
    return nil
}
