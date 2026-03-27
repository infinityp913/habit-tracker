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

    // 1. No check-ins → all days from start to yesterday are implicit ✓ (today pending)
    func testAllImplicitTrue() {
        XCTAssertEqual(streak([:], start: "2026-03-20", today: "2026-03-26"), 6)
    }

    // 2. Explicit miss today resets streak to 0
    func testMissedTodayResetsStreak() {
        XCTAssertEqual(streak(["2026-03-26": false], start: "2026-03-20", today: "2026-03-26"), 0)
    }

    // 3. Miss in the middle breaks streak; days after the miss still count
    func testMissInMiddleBreaksStreak() {
        // Miss on March 23 → only March 24, 25 count = 2 (today pending, excluded)
        XCTAssertEqual(streak(["2026-03-23": false], start: "2026-03-20", today: "2026-03-26"), 2)
    }

    // 4. Explicit ✓ days mixed with implicit ✓ days all count (today pending excluded)
    func testExplicitDoneMixedWithImplicit() {
        let checkIns: [String: Bool] = ["2026-03-24": true, "2026-03-25": true]
        XCTAssertEqual(streak(checkIns, start: "2026-03-20", today: "2026-03-26"), 6)
    }

    // 5. Start date in the future → streak is 0
    func testFutureStartDateReturnsZero() {
        XCTAssertEqual(streak([:], start: "2026-04-01", today: "2026-03-26"), 0)
    }

    // 6. Clearing history (empty check-ins) restores implicit streak through yesterday
    func testClearHistoryRestoresImplicitStreak() {
        // With an explicit miss: streak = 0
        XCTAssertEqual(streak(["2026-03-26": false], start: "2026-03-20", today: "2026-03-26"), 0)
        // After clearing (empty dict): streak = 6 (today pending)
        XCTAssertEqual(streak([:], start: "2026-03-20", today: "2026-03-26"), 6)
    }

    // 7. Today pending (nil) excludes today from count
    func testTodayPendingExcludesDay() {
        XCTAssertEqual(streak(["2026-03-25": true], start: "2026-03-25", today: "2026-03-26"), 1)
    }

    // 8. Today explicitly confirmed includes today
    func testTodayConfirmedIncludesDay() {
        XCTAssertEqual(streak(["2026-03-25": true, "2026-03-26": true],
                              start: "2026-03-25", today: "2026-03-26"), 2)
    }

    // 9. Today explicitly missed returns zero (regression guard)
    func testTodayMissedReturnsZeroRegression() {
        XCTAssertEqual(streak(["2026-03-26": false], start: "2026-03-20", today: "2026-03-26"), 0)
    }

    // 10. Habit started today, not yet checked in → yesterday < startDate → streak = 0
    func testHabitStartedTodayPending() {
        XCTAssertEqual(streak([:], start: "2026-03-26", today: "2026-03-26"), 0)
    }

    // MARK: - Toggle logic

    private func toggle(_ checkIns: [String: Bool], key: String, value: Bool) -> [String: Bool] {
        HabitStore.toggledCheckIns(checkIns, key: key, value: value)
    }

    // 14. Tapping same value twice → removes key (pending)
    func testToggleConfirmedToPending() {
        let after1 = toggle([:], key: "2026-03-26", value: true)
        XCTAssertEqual(after1["2026-03-26"], true)
        let after2 = toggle(after1, key: "2026-03-26", value: true)
        XCTAssertNil(after2["2026-03-26"])
    }

    // 15. Tapping missed twice → removes key (pending)
    func testToggleMissedToPending() {
        let after1 = toggle([:], key: "2026-03-26", value: false)
        XCTAssertEqual(after1["2026-03-26"], false)
        let after2 = toggle(after1, key: "2026-03-26", value: false)
        XCTAssertNil(after2["2026-03-26"])
    }

    // 16. Tapping different value → overwrites (no toggle)
    func testSwitchMissedToConfirmed() {
        let after1 = toggle([:], key: "2026-03-26", value: false)
        let after2 = toggle(after1, key: "2026-03-26", value: true)
        XCTAssertEqual(after2["2026-03-26"], true)
    }

    // MARK: - isTodayPending

    private func pending(_ checkIns: [String: Bool], start: String, today: String) -> Bool {
        HabitStore.isTodayPending(checkIns: checkIns, startDate: date(start), today: date(today))
    }

    // 11. No entry today, startDate in the past → pending
    func testIsTodayPendingTrue() {
        XCTAssertTrue(pending([:], start: "2026-03-20", today: "2026-03-26"))
    }

    // 12. Today explicitly confirmed → not pending
    func testIsTodayPendingFalseWhenConfirmed() {
        XCTAssertFalse(pending(["2026-03-26": true], start: "2026-03-20", today: "2026-03-26"))
    }

    // 13. startDate in the future → not pending (habit hasn't started)
    func testIsTodayPendingFalseBeforeStartDate() {
        XCTAssertFalse(pending([:], start: "2026-04-01", today: "2026-03-26"))
    }
}
