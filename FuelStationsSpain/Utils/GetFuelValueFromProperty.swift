import Foundation

func getFuelValueFromProperty(_ item: FuelStation, property: Enums.FavoriteFuelType) -> Double? {
    switch property {
    case .none:
        return nil
    case .aGasoil:
        return item.gasoilAPrice
    case .bGasoil:
        return item.gasoilBPrice
    case .premiumGasoil:
        return item.premiumGasoilPrice
    case .biodiesel:
        return item.biodieselPrice
    case .gasoline95E10:
        return item.gasoline95E10Price
    case .gasoline95E5:
        return item.gasoline95E5Price
    case .gasoline95E5Premium:
        return item.gasoline95E5PremiumPrice
    case .gasoline98E10:
        return item.gasoline98E5Price
    case .gasoline98E5:
        return item.gasoline98E5Price
    case .bioethanol:
        return item.bioethanolPrice
    case .cng:
        return item.cngPrice
    case .lng:
        return item.lngPrice
    case .lpg:
        return item.lpgPrice
    case .hydrogen:
        return item.hydrogenPrice
    }
}
