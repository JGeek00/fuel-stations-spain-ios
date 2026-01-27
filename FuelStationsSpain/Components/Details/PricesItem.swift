import SwiftUI

struct StationDetailsPricesItem: View {
    var station: FuelStation
    
    init(station: FuelStation) {
        self.station = station
    }
                
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "eurosign.circle.fill")
                .foregroundStyle(Color.white)
                .frameDynamicSize(width: 28, height: 28)
                .background(.orange)
                .cornerRadius(6)
            Spacer()
                .frame(width: 12)
            VStack(alignment: .leading) {
                Text("Prices")
                    .fontSize(16)
                    .fontWeight(.semibold)
                Spacer()
                    .frame(height: 8)
                VStack(alignment: .leading, spacing: 6) {
                    Product(name: String(localized: "A Gasoil"), value: station.gasoilAPrice)
                    Product(name: String(localized: "B Gasoil"), value: station.gasoilBPrice)
                    Product(name: String(localized: "Premium Gasoil"), value: station.premiumGasoilPrice)
                    Product(name: String(localized: "Biodiesel"), value: station.biodieselPrice)
                    Product(name: String(localized: "Gasoline 95 E5"), value: station.gasoline95E5Price)
                    Product(name: String(localized: "Gasoline 95 E5 Premium"), value: station.gasoline95E5PremiumPrice)
                    Product(name: String(localized: "Gasoline 95 E10"), value: station.gasoline95E10Price)
                    Product(name: String(localized: "Gasoline 98 E5"), value: station.gasoline98E5Price)
                    Product(name: String(localized: "Gasoline 98 E10"), value: station.gasoline98E10Price)
                    Product(name: String(localized: "Bioethanol"), value: station.bioethanolPrice)
                    Product(name: String(localized: "Compressed Natural Gas"), value: station.cngPrice)
                    Product(name: String(localized: "Liquefied Natural Gas"), value: station.lngPrice)
                    Product(name: String(localized: "Liquefied petroleum gases"), value: station.lpgPrice)
                    Product(name: String(localized: "Hydrogen"), value: station.hydrogenPrice)
                    Product(name: String("AdBlue"), value: station.adbluePrice)
                }
                Spacer()
                    .frame(height: 8)
                Text("There may be a small difference between the price shown here and the actual price, because of the time that elapses between a station changing the price and that price being updated on the server.")
                    .fontSize(12)
                    .foregroundStyle(Color.gray)
                    .fontWeight(.semibold)
            }
            Spacer()
        }
        .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    func Product(name: String, value: Double?) -> some View {
        if let value {
            HStack {
                Text(name)
                Spacer()
                Text("\(formattedNumber(value: value, digits: 3)) €")
            }
            .fontSize(14)
        }
        else {
            EmptyView()
        }
    }
}

#Preview("PricesItem") {
    let station = FuelStation(id: "5272", postalCode: "02328", address: "AVENIDA PRINCIPE, 2328", openingHours: "L-D: 08:00-16:00", latitude: 38.900944, longitude: -1.994028, locality: "SANTA ANA", margin: .d, municipality: nil, province: nil, referral: .om, signage: "REPSOL", saleType: .p, percBioEthanol: "0.0", percMethylEster: "0.0", municipalityID: 54, provinceID: 2, regionID: 7, biodieselPrice: nil, bioethanolPrice: nil, cngPrice: nil, lngPrice: nil, lpgPrice: nil, gasoilAPrice: 1.459, gasoilBPrice: 1.16, premiumGasoilPrice: 1.509, gasoline95E10Price: nil, gasoline95E5Price: 1.499, gasoline95E5PremiumPrice: nil, gasoline98E10Price: nil, gasoline98E5Price: 1.609, hydrogenPrice: nil, adbluePrice: nil)
    
    ScrollView {
        StationDetailsPricesItem(station: station)
    }
}
