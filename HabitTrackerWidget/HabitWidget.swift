import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct HabitEntry: TimelineEntry {
    let date: Date
    let habitName: String
    let streak: Int
    let todayCheckIn: Bool?
    let isConfigured: Bool
}

// MARK: - Provider

struct HabitTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habitName: "Avoid social media", streak: 7, todayCheckIn: nil, isConfigured: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        // Refresh at midnight (day rollover)
        let tomorrow = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let timeline = Timeline(entries: [makeEntry()], policy: .after(tomorrow))
        completion(timeline)
    }

    private func makeEntry() -> HabitEntry {
        let store = HabitStore()
        return HabitEntry(
            date: Date(),
            habitName: store.habitName,
            streak: store.streak(),
            todayCheckIn: store.todayCheckIn(),
            isConfigured: store.isConfigured
        )
    }
}

// MARK: - Widget + Bundle

@main
struct HabitTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitTrackerWidget()
    }
}

struct HabitTrackerWidget: Widget {
    let kind = "HabitTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitTimelineProvider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Track your daily habit streak.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
