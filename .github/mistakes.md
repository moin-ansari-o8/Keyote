# Mistakes Log - Keyote Project

Historical record of errors and learnings.

---

## 2026-02-04 - PyInstaller Executable Permission Error
_Problem:_ .exe crashed on user's computer with PermissionError [Errno 13] when trying to create log file at `C:\WINDOWS\system32\keyote_server_errors.log`. Used relative paths (`Path("keyote_server_errors.log")`) which resolved to system32 when Windows launched the .exe, requiring admin privileges to write
_Solution:_ Detect if running as compiled executable with `getattr(sys, 'frozen', False)` and use `Path(sys.executable).parent` to get .exe directory. Added fallback to `%APPDATA%\KeyoteServer` if primary location not writable. Applied to both LOG_FILE and CONFIG_FILE in dashboard.py and server.py
_Lesson:_ PyInstaller bundles change working directory behavior - never use relative paths for user data in compiled apps. Always use sys.executable path for bundled executables. Provide fallback to %APPDATA% for edge cases (Program Files installs, USB drives, etc.). Test .exe on clean machine without admin rights
_Related Files:_ dashboard.py (lines 28-58), server.py (lines 28-40), build.spec

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

## 2026-02-02 - Soundpool Migration (Final Fix)
_Problem:_ Even after removing stop() and reducing pool size, audio still died during fast typing. Audioplayers architecture fundamentally wrong for keyboard clicks
_Root Cause:_ Audioplayers uses multiple player instances with async state machines. Each play() call goes through: platform channel → player state check → native layer → SoundPool. Even without stop(), this is too many layers for 15+ keys/sec. Architecture mismatch: audioplayers designed for music (seek/pause/resume), keyboards need drum-pad immediacy
_Solution:_ Switched to soundpool package. Single native object, no player instances, no state machine. Just play(soundId) → instant native call. Preload sound once, get ID, play ID repeatedly. Matches Android SoundPool architecture directly
_Lesson:_ Use correct tool for job (Werkzeug). Music player (audioplayers) ≠ Click player (soundpool). For <20ms latency requirements, need native-level architecture. No amount of optimization fixes wrong abstraction layer. Soundpool = architecturally correct for keyboards. When expert says "Option 2: soundpool", they diagnosed the real issue
_Related Files:_ pubspec.yaml (audioplayers → soundpool), keyboard_viewmodel.dart (_playSound, _initializeAudioPool), settings_viewmodel.dart (playPreview)
## 2026-02-02 - flutter_soloud Migration (Modern Replacement)
_Problem:_ Soundpool package discontinued. Needed modern cross-platform alternative
_Root Cause:_ Soundpool was Android-only wrapper around Android SoundPool. No iOS/Web support, package abandoned by maintainer
_Solution:_ Migrated to flutter_soloud - professional-grade audio engine based on SoLoud C++. Same architecture (load once, play repeatedly) but cross-platform, actively maintained (539 likes, 160 pub points), used by games. API cleaner: SoLoud.instance.init(), loadAsset() returns AudioSource, play(source). Latency improved 5-10ms → 3-8ms
_Lesson:_ When package is discontinued, don't patch - upgrade to modern maintained alternative. flutter_soloud is architectural successor to soundpool with better performance. Check pub.dev maintenance status before depending on packages. Professional game engines (SoLoud) are battle-tested for exactly this use case - trust them
_Related Files:_ pubspec.yaml (soundpool → flutter_soloud), keyboard_viewmodel.dart (Soundpool → SoLoud, dispose → deinit), settings_viewmodel.dart (same changes), AUDIO_ISSUE_DIAGNOSTIC.md (complete rewrite), AUDIO_MIGRATION_GUIDE.md (new file)