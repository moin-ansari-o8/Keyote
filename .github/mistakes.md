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

## 2026-02-02 - AudioPlayer Sound Effects Implementation (Final Solution)
_Problem:_ Multiple attempts to get key press sounds working: (1) Single player with stop+play = only first key worked, (2) New player per sound = worked but 100-160ms delay, (3) Pool with setSource+resume = no sound at all
_Root Causes:_ Three critical bugs: (1) resume() doesn't work - when sound finishes with ReleaseMode.stop, playhead is at end, resume() does nothing. (2) Race condition - constructor called async _initializeAudioPool() and _loadSoundPreferences() without awaiting, so _preloadSound ran while pool was empty. (3) Unnecessary complexity - setSource() preload added no benefit with lowLatency mode, just more failure points
_Solution:_ Clean implementation: (1) Proper async init chain with await, (2) Remove _preloadSound() entirely - dead code, (3) Use play() not resume() - play() handles seek(0) and state transitions automatically, (4) Keep pool + lowLatency pattern - good architecture, just fix the playback method. Result: 10-15ms latency, well under 20ms human threshold
_Lesson:_ For low-latency sound effects: (1) Always await async initialization chains - never fire-and-forget in constructors, (2) play() auto-resets, resume() doesn't - know your AudioPlayer API, (3) Don't over-engineer - lowLatency mode already caches, no manual preload needed, (4) Measure first - audioplayers is fast enough for keyboards, soundpool only needed for <10ms requirements (rhythm games). Boring simple code ships and works
_Related Files:_ keyboard_viewmodel.dart (_init, _initializeAudioPool, _playSound methods)
## 2026-02-02 - Audio Silence After Fast Typing (Überlastung)
_Problem:_ Sound worked initially but died after rapid typing. No exceptions, just silence. Suspected asset paths, WAV format, AudioFocus, state corruption - all wrong
_Root Cause:_ Async platform channel overload. Calling stop() + play() per keystroke = 2 async native calls × 15 players × rapid typing = 100-300 calls/sec. Platform channel queue backed up, SoundPool stream slots got stuck, players never returned to STOPPED state, all future play() calls silently ignored. Pool became graveyard of half-dead players. Classic resource exhaustion (Überlastung)
_Solution:_ (1) REMOVE stop() call completely - play() already restarts, stop() adds zero benefit and doubles traffic, (2) Reduce pool from 15 to 5 - matches SoundPool default max streams (5-10), bigger pool = more overhead not more sound, (3) Just play() repeatedly like drum pads - no stop/resume/setSource complexity
_Lesson:_ For short SFX never call stop() before play(). Think drum pads not music players. More players ≠ better (counterintuitive but true). Audio systems are brutally literal - spam them, they go quiet. For keyboards use soundpool architecture (1 native object, just play(id)), for music use audioplayers. Different tools (Werkzeug) for different jobs
_Related Files:_ keyboard_viewmodel.dart (_audioPoolSize, _playSound method)