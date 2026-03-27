import SwiftUI
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var store: HabitStore
    @State private var showingSetup = false
    @State private var notificationsDisabled = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Gear icon
                HStack {
                    Spacer()
                    Button { showingSetup = true } label: {
                        Image(systemName: "gearshape")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.45))
                    }
                }
                .padding()

                Spacer()

                // Habit name
                Text(store.habitName)
                    .font(.title3.italic())
                    .foregroundColor(.white.opacity(0.55))
                    .padding(.bottom, 6)

                // Streak number
                Text("\(store.streak())")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                Text("DAY STREAK")
                    .font(.caption)
                    .tracking(4)
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.bottom, 44)

                // Check-in buttons
                HStack(spacing: 16) {
                    checkInButton(title: "✓  Done",   value: true)
                    checkInButton(title: "✗  Missed", value: false)
                }
                .padding(.bottom, 20)

                // Reminder time
                Text("Reminder at \(formattedTime(store.notificationTime))")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.28))

                // Notifications-off warning
                if notificationsDisabled {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Notifications off — tap to open Settings.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 6)
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingSetup) {
            SetupView(isFirstLaunch: false)
                .environmentObject(store)
        }
        .task {
            await refreshNotificationStatus()
        }
    }

    @ViewBuilder
    private func checkInButton(title: String, value: Bool) -> some View {
        let isSelected = store.todayCheckIn() == value
        Button {
            withAnimation(.spring(duration: 0.2)) {
                store.logCheckIn(value: value)
            }
        } label: {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(isSelected ? Color.white : Color.white.opacity(0.11))
                .cornerRadius(12)
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }

    private func refreshNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsDisabled = settings.authorizationStatus == .denied
    }
}
