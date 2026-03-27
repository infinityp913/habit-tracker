import SwiftUI
import WidgetKit

struct WidgetView: View {
    let entry: HabitEntry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Small (read-only)

struct SmallWidgetView: View {
    let entry: HabitEntry

    var body: some View {
        VStack(spacing: 3) {
            if entry.isConfigured {
                Text(entry.habitName)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("\(entry.streak)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(entry.streak == 0 ? "start today" : "days")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            } else {
                Text("Open app\nto set up")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)
            }
        }
        .containerBackground(.black, for: .widget)
    }
}

// MARK: - Medium (interactive ✓/✗)

struct MediumWidgetView: View {
    let entry: HabitEntry

    var body: some View {
        HStack(spacing: 0) {
            // Left: streak
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.habitName)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(2)

                Text("\(entry.streak)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(entry.streak == 0 ? "start today" : "days")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right: ✓ / ✗ buttons
            if entry.isConfigured {
                VStack(spacing: 10) {
                    Button(intent: LogCheckInIntent(value: true)) {
                        ZStack {
                            Circle()
                                .fill(entry.todayCheckIn == true ? Color.white : Color.white.opacity(0.11))
                                .frame(width: 50, height: 50)
                            Text("✓")
                                .font(.title3.bold())
                                .foregroundColor(entry.todayCheckIn == true ? .black : .white)
                        }
                    }
                    .buttonStyle(.plain)

                    Button(intent: LogCheckInIntent(value: false)) {
                        ZStack {
                            Circle()
                                .fill(entry.todayCheckIn == false ? Color.white : Color.white.opacity(0.11))
                                .frame(width: 50, height: 50)
                            Text("✗")
                                .font(.title3.bold())
                                .foregroundColor(entry.todayCheckIn == false ? .black : .white)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .containerBackground(.black, for: .widget)
    }
}
