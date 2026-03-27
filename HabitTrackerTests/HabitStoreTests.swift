import XCTest
@testable import HabitTracker

final class HabitStoreTests: XCTestCase {

    // MARK: - Helpers

    private func date(_ string: String) -> Date {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale.current
        fmt.timeZone = TimeZone.current
        return fmt.date(from: string)!
    }

    private func streak(_ checkIns: [String: Bool], start: String, today: String) -> Int {
        HabitStore.calculateStreak(checkIns: checkIns, startDate: date(start), today: date(today))
    }

    // MARK: - Tests

    // 1. No check-ins → all days from start to today are implicit ✓
    func testAllImplicitTrue() {
        XCTAssertEqual(streak([:], start: "2026-03-20", today: "2026-03-26"), 7)
    }

    // 2. Explicit miss today resets streak to 0
    func testMissedTodayResetsStreak() {
        XCTAssertEqual(streak(["2026-03-26": false], start: "2026-03-20", today: "2026-03-26"), 0)
    }

    // 3. Miss in the middle breaks streak; days after the miss still count
    func testMissInMiddleBreaksStreak() {
        // Miss on March 23 → only March 24, 25, 26 count = 3
        XCTAssertEqual(streak(["2026-03-23": false], start: "2026-03-20", today: "2026-03-26"), 3)
    }

    // 4. Explicit ✓ days mixed with implicit ✓ days all count
    func testExplicitDoneMixedWithImplicit() {
        let checkIns: [String: Bool] = ["2026-03-24": true, "2026-03-25": true]
        XCTAssertEqual(streak(checkIns, start: "2026-03-20", today: "2026-03-26"), 7)
    }

    // 5. Start date in the future → streak is 0
    func testFutureStartDateReturnsZero() {
        XCTAssertEqual(streak([:], start: "2026-04-01", today: "2026-03-26"), 0)
    }

    // 6. Clearing history (empty check-ins) restores full implicit streak
    func testClearHistoryRestoresImplicitStreak() {
        // With an explicit miss: streak = 0
        XCTAssertEqual(streak(["2026-03-26": false], start: "2026-03-20", today: "2026-03-26"), 0)
        // After clearing (empty dict): streak = 7
        XCTAssertEqual(streak([:], start: "2026-03-20", today: "2026-03-26"), 7)
    }
}
