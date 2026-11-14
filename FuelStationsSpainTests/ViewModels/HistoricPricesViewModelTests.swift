import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests no-UI de `HistoricPricesViewModel`: generación de datos de gráfico
/// (rangos de tiempo, min/max, chartHasData, fuel sin precios, fechas
/// inválidas), fuel por defecto leído de `UserDefaults` y `loadData` contra
/// la API stubeada. No se toca ninguna vista.
@Suite(.serialized)
@MainActor
struct HistoricPricesViewModelTests {

    /// VM con el fuel favorito neutralizado (o fijado con `favoriteFuelRaw`),
    /// para que el fuel leído en el init sea determinista.
    private func makeVM(favoriteFuelRaw: String? = nil) -> HistoricPricesViewModel {
        var vm: HistoricPricesViewModel!
        DisposableDefaults.run(keys: [StorageKeys.favoriteFuel]) {
            if let favoriteFuelRaw {
                UserDefaults.shared.set(favoriteFuelRaw, forKey: StorageKeys.favoriteFuel)
            }
            vm = HistoricPricesViewModel(station: makeFuelStation(id: "1111"))
        }
        return vm
    }

    /// `HistoricPrice` con solo los campos que interesan (el resto son opcionales).
    private func makeHistoric(date: String, gasoilA: Double? = nil, gasoline95E5: Double? = nil) throws -> HistoricPrice {
        var pairs = ["\"date\":\"\(date)\""]
        if let gasoilA { pairs.append("\"gasoilAPrice\":\(gasoilA)") }
        if let gasoline95E5 { pairs.append("\"gasoline95E5Price\":\(gasoline95E5)") }
        let json = "{" + pairs.joined(separator: ",") + "}"
        return try JSONDecoder().decode(HistoricPrice.self, from: Data(json.utf8))
    }

    private func dayString(daysAgo: Int, from today: Date = Date()) -> String {
        getSQLDateFormat(Calendar.current.date(byAdding: .day, value: -daysAgo, to: today)!)
    }

    private func monthString(monthsAgo: Int, from today: Date = Date()) -> String {
        getSQLDateFormat(Calendar.current.date(byAdding: .month, value: -monthsAgo, to: today)!)
    }

    /// Espera acotada a una condición en el actor principal.
    private func waitUntil(timeout: TimeInterval = 3, _ condition: () -> Bool) async -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() && Date() < deadline {
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        return condition()
    }

    private func withStubSession(_ body: () async throws -> Void) async throws {
        let original = HTTPClientSessionProvider.shared.session
        HTTPClientSessionProvider.shared.session = StubURLProtocol.session()
        defer { HTTPClientSessionProvider.shared.session = original }
        try await body()
    }

    /// URLs candidatas de historic-prices: la VM usa hoy ± su propio `Date()`,
    /// así que se registran stubs para las variantes de ±1 día en cada extremo.
    private func historicURLCandidates(stationId: String, from today: Date) -> [String] {
        let calendar = Calendar.current
        var candidates: [String] = []
        for startShift in [-1, 0, 1] {
            let start = calendar.date(byAdding: .year, value: -1, to: today)!
                .addingTimeInterval(Double(startShift) * 86_400)
            for endShift in [0, 1] {
                let end = today.addingTimeInterval(Double(endShift) * 86_400)
                var components = URLComponents(string: "\(Config.apiBaseUrl)/historic-prices")!
                components.queryItems = [
                    URLQueryItem(name: "id", value: stationId),
                    URLQueryItem(name: "startDate", value: getSQLDateFormat(start)),
                    URLQueryItem(name: "endDate", value: getSQLDateFormat(end)),
                    URLQueryItem(name: "includeCurrentPrices", value: "false"),
                ]
                candidates.append(components.url!.absoluteString)
            }
        }
        return candidates
    }

    // MARK: init

    @Test func initReadsFavoriteFuelFromDefaults() {
        #expect(makeVM(favoriteFuelRaw: "gasoline95E5").selectedFuel == .gasoline95E5)
    }

    @Test func initFallsBackToGasoilAWithUnknownFuelOrNoPreference() {
        #expect(makeVM(favoriteFuelRaw: "no-existe").selectedFuel == .gasoilA)
        #expect(makeVM().selectedFuel == .gasoilA)
    }

    @Test func selectedChartPointStartsNilAndIsSettable() {
        let vm = makeVM()
        #expect(vm.selectedChartPoint == nil)
        vm.selectedChartPoint = "2024-01-15"
        #expect(vm.selectedChartPoint == "2024-01-15")
    }

    // MARK: generateChartData — rangos

    @Test func generateChartDataFiltersPointsBySelectedTimeRange() throws {
        let today = Date()
        let recent = try makeHistoric(date: dayString(daysAgo: 0, from: today), gasoilA: 1.5)
        let halfMonth = try makeHistoric(date: dayString(daysAgo: 15, from: today), gasoilA: 1.1)
        let twoMonths = try makeHistoric(date: monthString(monthsAgo: 2, from: today), gasoilA: 1.2)
        let eightMonths = try makeHistoric(date: monthString(monthsAgo: 8, from: today), gasoilA: 2.0)
        let old = try makeHistoric(date: monthString(monthsAgo: 25, from: today), gasoilA: 9.9)
        let data = [recent, halfMonth, twoMonths, eightMonths, old]

        // Puntos esperados por rango: week1 solo el de hoy; month1 añade el de
        // 15 días; month3 añade el de 2 meses; year1 añade el de 8 meses; el de
        // 25 meses nunca entra.
        let expectations: [(Enums.HistoricTime, Int, Bool)] = [
            (.week1, 1, false),
            (.month1, 2, false),
            (.month3, 3, true),
            (.month6, 3, true),
            (.year1, 4, true),
        ]
        for (time, count, hasData) in expectations {
            let vm = makeVM()
            vm.data = data
            vm.selectedTime = time
            vm.generateChartData()
            #expect(vm.chartData.count == count)
            #expect(vm.chartHasData == hasData)
        }

        let vm = makeVM()
        vm.data = data
        vm.selectedTime = .year1
        vm.generateChartData()
        #expect(vm.chartData.map(\.value) == [1.5, 1.1, 1.2, 2.0])
        #expect(abs(vm.chartMaxValue - 2.1) < 0.0001)
        #expect(abs(vm.chartMinValue - 1.0) < 0.0001)
    }

    @Test func generateChartDataWithoutUsablePointsIsEmpty() throws {
        let vm = makeVM()
        vm.data = try [
            makeHistoric(date: "no-es-una-fecha", gasoilA: 1.5),           // fecha inválida
            makeHistoric(date: dayString(daysAgo: 0), gasoline95E5: 1.6),  // sin precio del fuel seleccionado
        ]
        vm.generateChartData()
        #expect(vm.chartData.isEmpty)
        #expect(vm.chartHasData == false)
        #expect(vm.chartMaxValue == 0.0)
        #expect(vm.chartMinValue == 0.0)

        // Sin datos cargados es un no-op.
        vm.data = nil
        vm.generateChartData()
        #expect(vm.chartData.isEmpty)
    }

    @Test func generateChartDataSinglePointSetsSymmetricRange() throws {
        let point = try makeHistoric(date: dayString(daysAgo: 1), gasoilA: 1.4)
        let vm = makeVM()
        vm.data = [point]
        vm.generateChartData()
        #expect(vm.chartData.count == 1)
        #expect(vm.chartHasData == false)  // 1 punto <= 2
        #expect(abs(vm.chartMaxValue - 1.5) < 0.0001)
        #expect(abs(vm.chartMinValue - 1.3) < 0.0001)
    }

    // MARK: loadData

    @Test func loadDataFillsDataAndChartOnSuccess() async throws {
        try await withStubSession {
            let today = Date()
            let json = """
            [
              {"stationId":"1111","gasoilAPrice":1.4,"date":"\(dayString(daysAgo: 2, from: today))"},
              {"stationId":"1111","gasoilAPrice":1.7,"date":"\(dayString(daysAgo: 1, from: today))"},
              {"stationId":"1111","gasoilAPrice":1.6,"date":"\(dayString(daysAgo: 0, from: today))"}
            ]
            """
            let candidates = historicURLCandidates(stationId: "1111", from: today)
            for url in candidates {
                StubURLProtocol.Registry.set(url: url, stub: StubURLProtocol.Stub(statusCode: 200, body: Data(json.utf8)))
            }

            let vm = makeVM()
            await vm.loadData()

            let finished = await waitUntil { vm.loading == false }
            #expect(finished)
            #expect(vm.error == nil)
            #expect(vm.data?.count == 3)
            #expect(vm.chartData.count == 3)
            #expect(vm.chartHasData)

            // La petición salió con el id de la estación.
            let sent = StubURLProtocol.Registry.requests.filter { candidates.contains($0.url?.absoluteString ?? "") }
            let request = try #require(sent.first)
            let url = try #require(request.url)
            let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
            let query = try #require(components.queryItems)
            #expect(query.contains(URLQueryItem(name: "id", value: "1111")))
            #expect(query.contains(URLQueryItem(name: "includeCurrentPrices", value: "false")))
        }
    }

    @Test func loadDataSetsConnectionErrorOnFailure() async throws {
        try await withStubSession {
            let candidates = historicURLCandidates(stationId: "1111", from: Date())
            for url in candidates {
                StubURLProtocol.Registry.set(url: url, stub: StubURLProtocol.Stub(statusCode: 500, body: Data("[]".utf8)))
            }

            let vm = makeVM()
            await vm.loadData()

            let finished = await waitUntil { vm.loading == false }
            #expect(finished)
            #expect(vm.data == nil)
            #expect(vm.error == .connection)
        }
    }
}
