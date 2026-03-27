# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0.0] - 2026-03-27

### Added
- Pending streak indicator: streak now shows only locked-in days (excludes today until confirmed). `○ today?` appears in app and medium widget; `○` icon in small widget. Changes to `● done` after check-in.
- `isTodayPending` computed property and static function on `HabitStore` for testing pending state
- `toggledCheckIns` static pure function on `HabitStore` for testable toggle logic
- 10 new unit tests covering pending streak logic, `isTodayPending`, and toggle behavior

### Changed
- `calculateStreak` now starts the walk from yesterday when today has no explicit entry (pending state), preventing today from counting before it is confirmed
- `logCheckIn(value:)` now toggles: tapping the same button (✓ or ✗) a second time reverts today back to pending (nil)
- Small and medium widgets suppress "start today" label when today is pending (○ indicator owns that message)
