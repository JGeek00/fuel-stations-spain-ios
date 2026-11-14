import Foundation
import Testing
@testable import FuelStationsSpain

/// Tests de `Utils/Schedule.swift` — solo `parseSchedule`.
/// Nota TZ: las comparaciones de horas usan un `DateFormatter("HH:mm")` creado
/// con los mismos defaults (locale/TZ del proceso) que usa `parseSchedule`, así
/// que la igualdad de `Date` es independiente del host.
@Suite struct ScheduleTests {
    private func time(_ hhmm: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: hhmm)
    }

    @Test func dayRangeFillsConsecutiveDaysAndLeavesRestNil() {
        let result = parseSchedule(schedule: "L-V:07:00-21:00")
        for index in 0...4 {
            #expect(result[index]?.count == 2)
            #expect(result[index]?[0] == time("07:00"))
            #expect(result[index]?[1] == time("21:00"))
        }
        #expect(result[5] == nil)
        #expect(result[6] == nil)
    }

    @Test func singleDayFillsOnlyThatDay() {
        let result = parseSchedule(schedule: "X:09:00-14:00")
        #expect(result[2]?.count == 2)
        #expect(result[2]?[0] == time("09:00"))
        #expect(result[2]?[1] == time("14:00"))
        #expect(result[0] == nil && result[1] == nil && result[3] == nil)
    }

    @Test func twentyFourHoursMapsToMidnightAndElevenFiftyNine() {
        let result = parseSchedule(schedule: "S-D:24H")
        #expect(result[5]?.count == 2)
        #expect(result[5]?[0] == time("00:00"))
        #expect(result[5]?[1] == time("23:59"))
        #expect(result[6]?[0] == time("00:00"))
        #expect(result[6]?[1] == time("23:59"))
    }

    @Test func doublePeriodProducesFourEntries() {
        let result = parseSchedule(schedule: "L:07:00-14:00y16:00-21:00")
        let times = result[0]
        #expect(times?.count == 4)
        #expect(times?[0] == time("07:00"))
        #expect(times?[1] == time("14:00"))
        #expect(times?[2] == time("16:00"))
        #expect(times?[3] == time("21:00"))
    }

    @Test func midnightRangeIsReplacedWithTwentyThreeFiftyNine() {
        // "00:00-00:00" → se reemplaza cada "00:00" por "23:59"
        let result = parseSchedule(schedule: "L:00:00-00:00")
        #expect(result[0]?.count == 2)
        #expect(result[0]?[0] == time("23:59"))
        #expect(result[0]?[1] == time("23:59"))
    }

    @Test func invalidTimesLeaveDayNil() {
        // La hora no parsea → el guard hace `continue` y el día queda en nil
        let result = parseSchedule(schedule: "L:aa-bb")
        #expect(result[0] == nil)
    }

    @Test func partWithoutColonIsSkipped() {
        let result = parseSchedule(schedule: "L-V:07:00-21:00;basura")
        #expect(result[0]?[0] == time("07:00"))
        #expect(result[6] == nil)
    }

    @Test func invalidDayAbbreviationLeavesDayNil() {
        let result = parseSchedule(schedule: "Z:07:00-21:00")
        for index in 0...6 {
            #expect(result[index] == nil)
        }
    }

    @Test func emptyScheduleYieldsAllNil() {
        let result = parseSchedule(schedule: "")
        for index in 0...6 {
            #expect(result[index] == nil)
        }
    }

    @Test func alwaysReturnsSevenSlots() {
        #expect(parseSchedule(schedule: "M:10:00-20:00").count == 7)
    }
}
