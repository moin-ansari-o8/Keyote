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
_Problem:_ Only first key press produced sound, subsequent rapid key presses were silent. Tried using single AudioPlayer with stop() + play() but stop() is async and creates state conflicts. Second attempt: creating new AudioPlayer per sound worked but had significant delay/latency
_Root Cause:_ Creating new AudioPlayer() for each key press has initialization overhead. Loading AssetSource each time adds I/O latency. Not suitable for rapid sound effects like keyboard typing or instrument apps
_Solution:_ Implemented audio pool pattern (used by games/instrument apps): Pre-initialize 5 AudioPlayer instances, pre-load sound source into all players using setSource(), use round-robin pattern with resume() for instant playback, zero initialization/loading overhead
_Lesson:_ For low-latency sound effects: (1) Pre-initialize player pool on app start, (2) Pre-load audio sources, (3) Use resume() not play(), (4) Round-robin through pool for overlapping sounds. Never create AudioPlayer on-demand for time-critical audio. Study existing instrument/game apps for sound effect patterns
_Related Files:_ keyboard_viewmodel.dart (_initializeAudioPool, _preloadSound, _playSound methods)
