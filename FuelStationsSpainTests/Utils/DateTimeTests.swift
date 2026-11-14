import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/DateTime.swift` — `timeIntervalToDHM` es una función pura
/// sobre segundos; no depende de TZ ni locale.
@Suite struct DateTimeTests {
    @Test func zeroIntervalIsZeroDHM() {
        let result = timeIntervalToDHM(0)
        #expect(result == (days: 0, hours: 0, minutes: 0))
    }

    @Test func ninetyMinutesIsOneHourThirty() {
        let result = timeIntervalToDHM(90 * 60)
        #expect(result == (days: 0, hours: 1, minutes: 30))
    }

    @Test func twentyFiveHoursNinetySecondsRoundsToNearestMinute() {
        // 25h 90s → 1501.5 min → redondeo a 1502 → 1 día 1h 2m
        let result = timeIntervalToDHM(25 * 3600 + 90)
        #expect(result == (days: 1, hours: 1, minutes: 2))
    }

    @Test func subMinuteIntervalsRoundUp() {
        // 5.5 min → 6 min (redondeo al minuto más cercano)
        let result = timeIntervalToDHM(5.5 * 60)
        #expect(result == (days: 0, hours: 0, minutes: 6))
    }

    @Test func multipleDaysHoursMinutesSplitCorrectly() {
        // 3 días 2h 5m = 4345 min
        let result = timeIntervalToDHM(Double(3 * 1440 + 125) * 60)
        #expect(result == (days: 3, hours: 2, minutes: 5))
    }
}
