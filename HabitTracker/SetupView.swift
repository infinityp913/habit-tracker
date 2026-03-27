import SwiftUI

struct SetupView: View {
    @EnvironmentObject var store: HabitStore
    @Environment(\.dismiss) private var dismiss

    let isFirstLaunch: Bool

    @State private var habitName = ""
    @State private var startDate = Date()
    @State private var notificationTime: Date = {
        var c = DateComponents(); c.hour = 21; c.minute = 0
        return Calendar.current.date(from: c) ?? Date()
    }()
    @State private var showingClearAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    Text(isFirstLaunch ? "Set up your habit" : "Edit habit")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 48)

                    fieldGroup(label: "HABIT") {
                        TextField("e.g. avoid social media", text: $habitName)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }

                    fieldGroup(label: "START DATE") {
                        DatePicker("", selection: $startDate, in: ...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }

                    fieldGroup(label: "REMINDER TIME") {
                        DatePicker("", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }

                    let trimmed = habitName.trimmingCharacters(in: .whitespaces)
                    Button(action: handleSave) {
                        Text(isFirstLaunch ? "Start tracking" : "Save changes")
                            .font(.headline)
                            .foregroundColor(trimmed.isEmpty ? .gray : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(trimmed.isEmpty ? Color.white.opacity(0.2) : Color.white)
                            .cornerRadius(14)
                    }
                    .disabled(trimmed.isEmpty)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Clear check-in history?", isPresented: $showingClearAlert) {
            Button("Clear and Save", role: .destructive) { commitSave(clearHistory: true) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Changing the habit name or start date will clear your check-in history.")
        }
        .onAppear {
            if !isFirstLaunch {
                habitName = store.habitName
                startDate = store.startDate
                notificationTime = store.notificationTime
            }
        }
    }

    @ViewBuilder
    private func fieldGroup<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption)
                .tracking(2)
                .foregroundColor(.white.opacity(0.38))
            HStack {
                content()
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.07))
            .cornerRadius(10)
        }
    }

    private func handleSave() {
        let trimmed = habitName.trimmingCharacters(in: .whitespaces)
        let nameChanged = trimmed != store.habitName
        let dateChanged = !Calendar.current.isDate(startDate, inSameDayAs: store.startDate)

        if !isFirstLaunch && (nameChanged || dateChanged) && !store.checkIns.isEmpty {
            showingClearAlert = true
        } else {
            commitSave(clearHistory: !isFirstLaunch && (nameChanged || dateChanged))
        }
    }

    private func commitSave(clearHistory: Bool) {
        let trimmed = habitName.trimmingCharacters(in: .whitespaces)
        store.save(habitName: trimmed, startDate: startDate, notificationTime: notificationTime, clearHistory: clearHistory)

        Task {
            let granted = await NotificationManager.requestPermission()
            if granted {
                NotificationManager.scheduleNotification(habitName: trimmed, time: notificationTime)
            }
        }

        if !isFirstLaunch {
            dismiss()
        }
    }
}
