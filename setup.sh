#!/bin/bash
set -e

echo "→ Installing xcodegen..."
brew install xcodegen 2>/dev/null || brew upgrade xcodegen 2>/dev/null || true

echo "→ Generating HabitTracker.xcodeproj..."
cd "$(dirname "$0")"
xcodegen generate

echo ""
echo "✓ Done! HabitTracker.xcodeproj is ready."
echo ""
echo "Next steps:"
echo "  1. open HabitTracker.xcodeproj"
echo "  2. Select the HabitTracker target → Signing & Capabilities"
echo "     • Set your Development Team (Apple ID or paid account)"
echo "     • Verify App Group 'group.com.ananth.habittracker' is ON"
echo "  3. Repeat step 2 for the HabitTrackerWidget target"
echo "  4. Plug in your iPhone → Product → Run"
echo ""
echo "  ⚠️  Free Apple ID = 7-day cert. Set up SideStore for auto-refresh:"
echo "      https://sidestore.io"
