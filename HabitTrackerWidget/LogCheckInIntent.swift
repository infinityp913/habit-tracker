import AppIntents
import WidgetKit

struct LogCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Check-In"
    static var description = IntentDescription("Mark today's habit as done or missed.")

    @Parameter(title: "Done")
    var value: Bool

    init() {}

    init(value: Bool) {
        self.value = value
    }

    func perform() async throws -> some IntentResult {
        HabitStore().logCheckIn(value: value)
        return .result()
    }
}
