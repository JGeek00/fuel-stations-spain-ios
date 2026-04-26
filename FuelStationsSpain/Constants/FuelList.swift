struct FuelListSection: Hashable {
    let name: String
    let types: [FuelListItem]
}

struct FuelListItem: Hashable {
    let name: String
    let type: Enums.FuelType
}

let fuelList = [
    FuelListSection(
        name: String(localized: "Gasoil"),
        types: [
            FuelListItem(name: String(localized: "A Gasoil"), type: .gasoilA),
            FuelListItem(name: String(localized: "B Gasoil"), type: .gasoilB),
            FuelListItem(name: String(localized: "Premium Gasoil"), type: .premiumGasoil),
            FuelListItem(name: String(localized: "Renewable Diesel"), type: .renewableDiesel),
            FuelListItem(name: String(localized: "Biodiesel"), type: .biodiesel)
        ]
    ),
    FuelListSection(
        name: String(localized: "Gasoline"),
        types: [
            FuelListItem(name: String(localized: "Gasoline 95 E5"), type: .gasoline95E5),
            FuelListItem(name: String(localized: "Gasoline 95 E10"), type: .gasoline95E10),
            FuelListItem(name: String(localized: "Gasoline 95 E25"), type: .gasoline95E25),
            FuelListItem(name: String(localized: "Gasoline 95 E85"), type: .gasoline95E85),
            FuelListItem(name: String(localized: "Gasoline 95 E5 Premium"), type: .gasoline95E5Premium),
            FuelListItem(name: String(localized: "Gasoline 98 E5"), type: .gasoline98E5),
            FuelListItem(name: String(localized: "Gasoline 98 E10"), type: .gasoline98E10),
            FuelListItem(name: String(localized: "Renewable Gasoline"), type: .renewableGasoline),
            FuelListItem(name: String(localized: "Bioethanol"), type: .bioethanol)
        ]
    ),
    FuelListSection(
        name: String(localized: "Gas"),
        types: [
            FuelListItem(name: String(localized: "Compressed Natural Gas"), type: .cng),
            FuelListItem(name: String(localized: "Liquefied Natural Gas"), type: .lng),
            FuelListItem(name: String(localized: "Liquefied Petroleum Gases"), type: .lpg),
            FuelListItem(name: String(localized: "Liquefied Biogas"), type: .liquefiedBiogas),
            FuelListItem(name: String(localized: "Compressed Biogas"), type: .compressedBiogas)
        ]
    ),
    FuelListSection(
        name: String(localized: "Others"),
        types: [
            FuelListItem(name: String(localized: "AdBlue"), type: .adBlue),
            FuelListItem(name: String(localized: "Ammonia"), type: .ammonia),
            FuelListItem(name: String(localized: "Hydrogen"), type: .hydrogen),
            FuelListItem(name: String(localized: "Methanol"), type: .methanol),
        ]
    ),
]
