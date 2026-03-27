# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Setup

This project uses [xcodegen](https://github.com/yonaskolb/XcodeGen) — the `.xcodeproj` is not committed. Regenerate it after any `project.yml` changes:

```bash
xcodegen generate
```

Or run the full setup from scratch:

```bash
./setup.sh
```

## Build & Test Commands

```bash
# Build main app
xcodebuild -scheme HabitTracker -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 16'

# Run all tests
xcodebuild test -scheme HabitTracker -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test method
xcodebuild test -scheme HabitTracker -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:HabitTrackerTests/HabitStoreTests/testMethodName
```

## Architecture

Three targets: `HabitTracker` (app), `HabitTrackerWidget` (WidgetKit extension), `HabitTrackerTests`.

### Data Sharing via App Group

Both the app and widget read/write the same `UserDefaults` suite:

```swift
UserDefaults(suiteName: "group.com.ananth.habittracker")
```

Both targets declare the `group.com.ananth.habittracker` App Group entitlement. This is the **only** persistence layer — no CloudKit, CoreData, or files.

**Do NOT use `@AppStorage` for any shared data.** `@AppStorage` reads from the standard (non-App Group) container and the widget will always see stale data.

### HabitStore — Single Source of Truth

`HabitStore.swift` is compiled into **both** the app and widget targets (see `project.yml` sources). It is an `ObservableObject` injected as `@EnvironmentObject` from `HabitTrackerApp.swift`. It calls `WidgetCenter.shared.reloadAllTimelines()` after every mutation.

**Check-in data model:**
- Stored as `[String: Bool]` keyed by `"yyyy-MM-dd"` in the device's **local timezone** (never UTC)
- Missing keys = implicit ✓ (user trusts their past)
- Explicit `false` = missed day, breaks the streak immediately
- `clearHistory()` deletes the entire `checkIns` dict (all days become implicit ✓ again from `startDate`); it does NOT reset `startDate`

**Streak calculation** is a pure static function (`HabitStore.calculateStreak`) — this is the only logic with unit tests.

### Two Separate Check-In Code Paths

These run in different OS processes and must NOT be merged:

1. **Widget button tap** → `LogCheckInIntent` (AppIntent, widget process) → writes App Group UserDefaults → calls `reloadAllTimelines()`
2. **Notification action tap** → iOS brings app to foreground → `UNUserNotificationCenterDelegate.userNotificationCenter(_:didReceive:)` → calls `HabitStore.logCheckIn(value:)` directly → calls `reloadAllTimelines()`

### Widget

- **Small**: read-only streak display
- **Medium**: interactive ✓/✗ via `LogCheckInIntent` (requires iOS 17+)
- Timeline refreshes at midnight; `reloadAllTimelines()` triggers an immediate refresh after any check-in

### Notifications

`NotificationManager` (singleton) schedules a daily `UNCalendarNotificationTrigger`. Action buttons use `.foreground` (not background) — background execution is unreliable on iOS; a brief app flash is better than a silently dropped check-in.

When `notificationTime` changes, always call `removePendingNotificationRequests(withIdentifiers:)` before scheduling the new request.

## Key Design Constraints

- **Single habit only** — intentional product decision, not a limitation
- **Widget-first** — the app is for setup and review; the widget is the primary interface
- **No grace period** — missed days reset streak to 0 immediately (v1 philosophy)
- **No data backup** — App Group UserDefaults only; device wipe loses all history (accepted for personal use)

## Design Doc

The full spec and architectural decisions live at:
`~/.gstack/projects/habit-tracker/ananth-unknown-design-20260326-145313.md`
