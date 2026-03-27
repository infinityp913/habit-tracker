# HabitTracker

A minimal iPhone habit tracker with a home screen widget. Track one habit. See your streak. That's it.

## Features

- Home screen widget (small: streak count, medium: interactive ✓/✗ buttons)
- Daily notification at a time you choose with inline ✓/✗ actions
- Set a past start date to preserve an existing streak
- Missed days reset the streak to 0 — no exceptions

## Requirements

- iPhone with iOS 17+
- Mac with Xcode 15+
- Apple ID (free — no paid developer account required)

## Installation

```bash
git clone https://github.com/yourname/habit-tracker.git
cd habit-tracker
brew install xcodegen
xcodegen generate
open HabitTracker.xcodeproj
```

In Xcode:

1. Select the **HabitTracker** target → Signing & Capabilities → set your Team to your Apple ID
2. Repeat for the **HabitTrackerWidget** target
3. Plug in your iPhone, enable Developer Mode if prompted
4. Press **⌘R**

After install, long-press the home screen → **+** → search **HabitTracker** to add the widget.

## Re-signing (every 6 days)

Free Apple ID certificates expire after **7 days**. When the cert expires the app stops launching.

**Set a recurring calendar reminder for every 6 days.**

To re-sign:

1. Plug iPhone into Mac via USB
2. Open `HabitTracker.xcodeproj` in Xcode
3. Press **⌘R**

Takes about 30 seconds. Your streak data is untouched.

## Project Structure

```
HabitTracker/
├── HabitTrackerApp.swift       # App entry point
├── ContentView.swift           # Today view: streak + ✓/✗ buttons
├── SetupView.swift             # First-launch and edit screen
├── HabitStore.swift            # Data model (shared with widget via App Group)
└── NotificationManager.swift   # Daily notification scheduling + delegate

HabitTrackerWidget/
├── HabitWidget.swift           # TimelineProvider + WidgetBundle
├── WidgetView.swift            # Small and medium widget views
└── LogCheckInIntent.swift      # AppIntent for interactive ✓/✗ buttons

HabitTrackerTests/
└── HabitStoreTests.swift       # Streak calculation unit tests
```

## Data

All data is stored in App Group UserDefaults (`group.com.ananth.habittracker`) shared between the app and widget. There is no cloud sync — a device wipe or app deletion will permanently erase your streak history.

## License

MIT
