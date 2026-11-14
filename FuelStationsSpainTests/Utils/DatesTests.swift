import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/Dates.swift`.
/// Nota TZ: `formatDate` parsea el offset de la propia cadena (el sufijo "Z"
/// se interpreta como UTC), así que el `Date` resultante es independiente del
/// TZ del host. `getSQLDateFormat` se valida mediante round-trip de
/// componentes construidos y leídos con el mismo `Calendar.current`.
@Suite struct DatesTests {
    @Test func formatDateParsesFixedISODateAsUTC() {
        let date = formatDate("2024-01-15T10:30:00.000Z")
        #expect(date != nil)
        #expect(date?.timeIntervalSince1970 == 1705314600) // 2024-01-15T10:30:00Z
    }

    @Test func formatDateWithExplicitOffsetParsesThatOffset() {
        // +01:00 → 09:30 UTC
        let date = formatDate("2024-01-15T10:30:00.000+01:00")
        #expect(date?.timeIntervalSince1970 == 1705311000)
    }

    @Test func formatDateReturnsNilForInvalidInput() {
        #expect(formatDate("no-es-una-fecha") == nil)
        #expect(formatDate("") == nil)
    }

    @Test func getSQLDateFormatRendersComponentsWithZeroPadding() {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 5
        components.hour = 12
        let date = Calendar.current.date(from: components)
        #expect(date != nil)
        #expect(getSQLDateFormat(date!) == "2024-03-05")
    }

    @Test func getSQLDateFormatIsStableAcrossHoursOfSameDay() {
        var components = DateComponents()
        components.year = 2025
        components.month = 11
        components.day = 9
        let morning = Calendar.current.date(from: components)
        components.hour = 23
        components.minute = 30
        let night = Calendar.current.date(from: components)
        #expect(morning != nil && night != nil)
        #expect(getSQLDateFormat(morning!) == "2025-11-09")
        #expect(getSQLDateFormat(night!) == "2025-11-09")
    }
}
