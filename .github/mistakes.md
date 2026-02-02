# Mistakes Log - Keyote Project

Historical record of errors and learnings.

---

## 2026-02-02 - Flutter Widget API Changes
_Problem:_ Used deprecated `withOpacity()` method and incorrect InkWell parameter `onLongPressUp`
_Solution:_ Replaced `withOpacity()` with `withValues(alpha: 0.2)` and switched from InkWell to GestureDetector for proper long-press support
_Lesson:_ Always check Flutter API documentation for latest method signatures; GestureDetector provides more granular control for gestures than InkWell
_Related Files:_ connection_indicator.dart, key_button.dart

## 2026-02-02 - Dependency Configuration
_Problem:_ Initially placed provider, http, and shared_preferences in dev_dependencies
_Solution:_ Moved runtime dependencies to dependencies section of pubspec.yaml
_Lesson:_ dev_dependencies are for development tools only; runtime packages must be in dependencies
_Related Files:_ pubspec.yaml

## 2026-02-02 - AudioPlayer State Management for Rapid Key Presses
_Problem:_ Only first key press produced sound, subsequent rapid key presses were silent. Tried using single AudioPlayer with stop() + play() but stop() is async and creates state conflicts
_Root Cause:_ AudioPlayer is stateful - calling stop() returns a Future but we called play() immediately without awaiting, causing the player to be in a "stopping" state when play() was called. This made the second and subsequent plays fail silently
_Solution:_ Create a NEW AudioPlayer instance for each sound effect and auto-dispose after playing. This is the recommended pattern for sound effects (vs reusing players for background music)
_Lesson:_ For sound effects with rapid/overlapping playback, create fresh AudioPlayer instances rather than reusing one. Single player reuse works for background music but not for sound effects. Never call async methods without awaiting when their completion affects subsequent calls
_Related Files:_ keyboard_viewmodel.dart (_playSound method)
