import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

class HabitStore: ObservableObject {

    static let groupSuiteName = "group.com.ananth.habittracker"

    private let defaults: UserDefaults

    @Published var habitName: String = ""
    @Published var startDate: Date = Date()
    @Published var notificationTime: Date = HabitStore.defaultNotificationTime()
    @Published var checkIns: [String: Bool] = [:]

    var isConfigured: Bool { !habitName.isEmpty }

    init() {
        let suite = UserDefaults(suiteName: Self.groupSuiteName)
        assert(suite != nil, "App Group not configured: \(Self.groupSuiteName)")
        self.defaults = suite ?? UserDefaults.standard
        load()
    }

    private func load() {
        habitName = defaults.string(forKey: "habitName") ?? ""
        startDate = defaults.object(forKey: "startDate") as? Date ?? Date()
        notificationTime = defaults.object(forKey: "notificationTime") as? Date ?? HabitStore.defaultNotificationTime()
        checkIns = defaults.dictionary(forKey: "checkIns") as? [String: Bool] ?? [:]
    }

    func reload() {
        load()
        objectWillChange.send()
    }

    func save(habitName: String, startDate: Date, notificationTime: Date, clearHistory: Bool) {
        self.habitName = habitName
        self.startDate = startDate
        self.notificationTime = notificationTime
        if clearHistory { self.checkIns = [:] }

        defaults.set(habitName, forKey: "habitName")
        defaults.set(startDate, forKey: "startDate")
        defaults.set(notificationTime, forKey: "notificationTime")
        if clearHistory { defaults.set([:] as [String: Bool], forKey: "checkIns") }
        defaults.synchronize()

        reloadWidget()
    }

    func logCheckIn(value: Bool) {
        let key = Self.dateKey(for: Date())
        checkIns[key] = value
        defaults.set(checkIns, forKey: "checkIns")
        defaults.synchronize()
        reloadWidget()
    }

    func todayCheckIn() -> Bool? {
        checkIns[Self.dateKey(for: Date())]
    }

    func streak() -> Int {
        Self.calculateStreak(checkIns: checkIns, startDate: startDate)
    }

    // MARK: - Pure functions (used by tests and widget)

    static func calculateStreak(checkIns: [String: Bool], startDate: Date, today: Date = Date()) -> Int {
        let calendar = Calendar.current
        var date = calendar.startOfDay(for: today)
        let start = calendar.startOfDay(for: startDate)

        guard date >= start else { return 0 }

        var count = 0
        while date >= start {
            let key = dateKey(for: date)
            if let result = checkIns[key] {
                if !result { break }   // explicit miss — stop
                count += 1
            } else {
                count += 1             // absent = implicit ✓
            }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return count
    }

    static func dateKey(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.locale = Locale.current
        fmt.timeZone = TimeZone.current
        return fmt.string(from: date)
    }

    // MARK: - Private

    private func reloadWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    private static func defaultNotificationTime() -> Date {
        var c = DateComponents()
        c.hour = 21
        c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }
}
