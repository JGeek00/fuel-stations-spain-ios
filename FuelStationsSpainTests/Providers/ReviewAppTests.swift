import Foundation
import Testing
@testable import FuelStationsSpain

private let oneDay: TimeInterval = 24 * 60 * 60

@Suite
struct ReviewAppTests {

    @Test func noRequestBeforeOneDay() {
        let now: TimeInterval = 100 * oneDay
        #expect(!shouldRequestReview(now: now, firstLaunchDate: now - oneDay + 60, hasRequestedReview: false))
    }

    @Test func requestExactlyAtOneDayBoundary() {
        let now: TimeInterval = 100 * oneDay
        #expect(shouldRequestReview(now: now, firstLaunchDate: now - oneDay, hasRequestedReview: false))
    }

    @Test func requestAfterOneDay() {
        let now: TimeInterval = 100 * oneDay
        #expect(shouldRequestReview(now: now, firstLaunchDate: now - 10 * oneDay, hasRequestedReview: false))
    }

    @Test func noRequestIfAlreadyRequested() {
        let now: TimeInterval = 100 * oneDay
        #expect(!shouldRequestReview(now: now, firstLaunchDate: now - 10 * oneDay, hasRequestedReview: true))
    }

    @Test func noRequestWhenFirstLaunchIsInFuture() {
        // Primer lanzamiento registrado "a futuro": intervalo negativo, no pide review.
        let now: TimeInterval = 100 * oneDay
        #expect(!shouldRequestReview(now: now, firstLaunchDate: now + oneDay, hasRequestedReview: false))
    }
}
