import SwiftUI

@main
struct HabitTrackerApp: App {
    @StateObject private var store = HabitStore()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        NotificationManager.shared.setupDelegate()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if store.isConfigured {
                    ContentView()
                } else {
                    SetupView(isFirstLaunch: true)
                }
            }
            .environmentObject(store)
        }
        .onChange(of: scenePhase) { _, phase in
            // Re-sync store after notification action opens the app
            if phase == .active {
                store.reload()
            }
        }
    }
}
