import Foundation
import Testing
@testable import FuelStationsSpain

/// Cobertura de decode/encode de Models/ con JSON de inventario propio.
/// Nunca toca la red real. Especificaciones: T2 de tests-non-ui-coverage.md.
@Suite struct ModelsTests {

    // MARK: - FuelStationsResult

    @Test func fuelStationsResultDecodesCodingKeysAndFullStation() throws {
        let result = try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations"))

        #expect(result.lastUpdated == "2026-02-14T08:00:00Z")
        #expect(result.count == 2)
        #expect(result.results.count == 2)

        let full = try #require(result.results.first)
        #expect(full.id == "12345")
        #expect(full.postalCode == "28001")
        #expect(full.address == "Calle Alcalá 1")
        #expect(full.openingHours == "L-D: 24H")
        #expect(full.latitude == 40.4168)
        #expect(full.longitude == -3.7038)
        #expect(full.locality == "Madrid")
        #expect(full.municipality == "Madrid")
        #expect(full.province == "Madrid")
        #expect(full.signage == "Repsol")
        #expect(full.percBioEthanol == "0.0")
        #expect(full.percMethylEster == "0.0")
        // Claves camelCase del API: municipalityId / provinceId / regionId
        #expect(full.municipalityID == 28065)
        #expect(full.provinceID == 28)
        #expect(full.regionID == 7)
        #expect(full.adbluePrice == 0.739)
        #expect(full.gasoline95E5Price == 1.559)
        // `distanceToUserLocation` no viene en el JSON del API
        #expect(full.distanceToUserLocation == nil)
    }

    @Test func fuelStationsResultOptionalFieldsAbsentDecodeAsNil() throws {
        let result = try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations"))
        let minimal = try #require(result.results.last)

        #expect(minimal.margin == nil)
        #expect(minimal.referral == nil)
        #expect(minimal.saleType == nil)
        #expect(minimal.municipality == nil)
        #expect(minimal.province == nil)
        #expect(minimal.adbluePrice == nil)
        #expect(minimal.gasoline95E5Price == nil)
        #expect(minimal.distanceToUserLocation == nil)
    }

    @Test func fuelStationEnumValuesDecode() throws {
        let result = try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations"))
        let full = try #require(result.results.first)

        #expect(full.margin == .d)
        #expect(full.referral == .om)
        #expect(full.saleType == .p)
    }

    @Test func fuelStationInvalidEnumValueThrows() {
        let json = #"{"id":"1","postalCode":"28001","address":"x","openingHours":"24H","latitude":40.0,"longitude":-3.0,"locality":"Madrid","signage":"Repsol","percBioEthanol":"0.0","percMethylEster":"0.0","municipalityId":1,"provinceId":28,"regionId":7,"margin":"X"}"#

        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(FuelStation.self, from: Data(json.utf8))
        }
    }

    @Test func fuelStationMalformedJSONThrows() {
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations-malformed"))
        }
    }

    // MARK: - Round-trip encode/decode

    @Test func fuelStationRoundTripEncodeDecode() throws {
        var station = try #require(
            try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations")).results.first
        )
        // `distanceToUserLocation` es campo runtime: el CodingKeys custom lo excluye,
        // así que Codable no lo serializa (no se envía ni se rehidrata del API).
        station.distanceToUserLocation = 12.34
        let encoded = try JSONEncoder().encode(station)
        #expect(!String(decoding: encoded, as: UTF8.self).contains("distanceToUserLocation"))

        let decoded = try JSONDecoder().decode(FuelStation.self, from: encoded)
        station.distanceToUserLocation = nil
        #expect(decoded == station)
        #expect(decoded.distanceToUserLocation == nil)
    }

    @Test func historicPriceRoundTripEncodeDecode() throws {
        let original = try #require(
            try JSONDecoder().decode([HistoricPrice].self, from: FixtureLoader.data("historic-prices")).first
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(HistoricPrice.self, from: encoded)

        // HistoricPrice no es Equatable: comparamos campo a campo
        #expect(decoded.stationId == original.stationId)
        #expect(decoded.stationSignage == original.stationSignage)
        #expect(decoded.gasoline95E5Price == original.gasoline95E5Price)
        #expect(decoded.gasoilAPrice == original.gasoilAPrice)
        #expect(decoded.date == original.date)
    }

    // MARK: - Municipality

    @Test func municipalityDecodesUppercaseKeys() throws {
        let municipalities = try JSONDecoder().decode([Municipality].self, from: FixtureLoader.data("municipalities"))
        let madrid = try #require(municipalities.first)

        #expect(municipalities.count == 2)
        #expect(madrid.IDMunicipio == "28065")
        #expect(madrid.IDProvincia == "28")
        #expect(madrid.IDCCAA == "07")
        #expect(madrid.Municipio == "Madrid")
        #expect(madrid.Provincia == "Madrid")
        #expect(madrid.CCAA == "Comunidad de Madrid")
    }

    // MARK: - HistoricPrice + price(for:)

    @Test func historicPriceDecodesFixture() throws {
        let prices = try JSONDecoder().decode([HistoricPrice].self, from: FixtureLoader.data("historic-prices"))

        #expect(prices.count == 2)
        let first = try #require(prices.first)
        #expect(first.stationId == "12345")
        #expect(first.stationSignage == "Repsol")
        #expect(first.date == "2026-02-14")
        #expect(first.gasoline95E5Price == 1.559)
        #expect(first.gasoilAPrice == 1.489)
    }

    @Test func historicPriceForFuelReturnsValueWhenPresent() throws {
        let price = try #require(
            try JSONDecoder().decode([HistoricPrice].self, from: FixtureLoader.data("historic-prices")).first
        )
        #expect(price.price(for: .gasoline95E5) == 1.559)
        #expect(price.price(for: .gasoilA) == 1.489)
    }

    @Test func historicPriceForFuelReturnsNilWhenPriceIsNullOrAbsent() throws {
        let prices = try JSONDecoder().decode([HistoricPrice].self, from: FixtureLoader.data("historic-prices"))

        // Precio explícito a null en el JSON
        let withNulls = try #require(prices.last)
        #expect(withNulls.biodieselPrice == nil)
        #expect(withNulls.price(for: .biodiesel) == nil)
        #expect(withNulls.gasoline95E5Price == nil)
        #expect(withNulls.price(for: .gasoline95E5) == nil)

        // Campo que HistoricPrice ni siquiera declara (rawValue -> "adBluePrice")
        let first = try #require(prices.first)
        #expect(first.price(for: .adBlue) == nil)
        #expect(first.price(for: .methanol) == nil)
    }

    // MARK: - AppStoreInfoResult

    @Test func appStoreInfoResultDecodes() throws {
        let info = try JSONDecoder().decode(AppStoreInfoResult.self, from: FixtureLoader.data("app-store-info"))
        let app = try #require(info.results?.first)

        #expect(info.resultCount == 1)
        #expect(app.trackID == 1540000000)
        #expect(app.trackName == "Gasolineras España")
        #expect(app.bundleID == "com.gentle.fuelstations")
        #expect(app.version == "3.2.1")
        #expect(app.primaryGenreID == 6005)
        #expect(app.genreIDS == ["6005"])
        #expect(app.minimumOSVersion == "17.0")
        #expect(app.artistID == 987654)
        #expect(app.formattedPrice == "Gratis")
        #expect(app.userRatingCount == 340)
    }

    // MARK: - StatusResponse

    @Test func statusResponseHoldsGenericData() {
        let ok = StatusResponse(successful: true, statusCode: 200, data: ["a"], rawBody: "[\"a\"]")
        #expect(ok.successful)
        #expect(ok.statusCode == 200)
        #expect(ok.data == ["a"])
        #expect(ok.rawBody == "[\"a\"]")

        let failure = StatusResponse<[String]>(successful: false)
        #expect(!failure.successful)
        #expect(failure.statusCode == nil)
        #expect(failure.data == nil)
        #expect(failure.rawBody == nil)
    }

    // MARK: - getObjectProperty

    @Test func getObjectPropertyReturnsDoubleForPriceField() throws {
        let station = try #require(
            try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations")).results.first
        )
        #expect(FuelStation.getObjectProperty(station: station, propertyName: "gasoline95E5Price") == 1.559)
        #expect(FuelStation.getObjectProperty(station: station, propertyName: "adbluePrice") == 0.739)
    }

    @Test func getObjectPropertyReturnsNilForUnknownOrNonDoubleField() throws {
        let station = try #require(
            try JSONDecoder().decode(FuelStationsResult.self, from: FixtureLoader.data("fuel-stations")).results.first
        )
        // Campo inexistente
        #expect(FuelStation.getObjectProperty(station: station, propertyName: "nonexistentPrice") == nil)
        // Campo existente pero no Double
        #expect(FuelStation.getObjectProperty(station: station, propertyName: "id") == nil)
    }
}
