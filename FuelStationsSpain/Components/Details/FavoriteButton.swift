import SwiftUI

struct StationDetailsFavoriteButton: View {
    var station: FuelStation
    var backgroundCircle: Bool
    
    init(station: FuelStation, backgroundCircle: Bool = true) {
        self.station = station
        self.backgroundCircle = backgroundCircle
    }
    
    @EnvironmentObject private var favoritesProvider: FavoritesProvider
    
    var body: some View {
        let isFavorite = favoritesProvider.isFavorite(stationId: station.id!)
        Button {
            if isFavorite == true {
                favoritesProvider.removeFavorite(stationId: station.id!)
            }
            else {
                favoritesProvider.addFavorite(station: station)
            }
        } label: {
            Image(systemName: isFavorite == true ? "star.fill" : "star")
                .padding(4)
                .fontWeight(.semibold)
                .animation(.default, value: isFavorite)
        }
        .condition { view in
            if backgroundCircle == true {
                if #available(iOS 26.0, *) {
                    view.buttonStyle(.glass)
                } else {
                    view.buttonStyle(.bordered)
                }
            }
            else {
                view
            }
        }
        .if(backgroundCircle == true) { view in
            view.clipShape(Circle())
        }
    }
}

#Preview("FavoriteButton") {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil)
    
    StationDetailsFavoriteButton(station: station)
        .environmentObject(FavoritesProvider.shared)
}
