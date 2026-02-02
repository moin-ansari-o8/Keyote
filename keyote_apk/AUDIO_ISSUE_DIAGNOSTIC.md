# Keyboard Sound Issue - Diagnostic Report

## Problem Description

**Issue:** Keyboard sound stops working after fast typing or after some time of usage.

**Behavior:**
- Sound works initially when app starts
- After typing fast or after some time, sound completely stops
- Happens with backspace, space, and regular character keys
- App doesn't crash, just silently stops playing sound

**Environment:**
- Flutter app on Android
- `audioplayers: ^6.1.0` package
- Audio files: WAV format (Mono, 48kHz, 16-bit PCM)
  - `click.wav` (2.63 KB)
  - `key-press1.wav` (166.61 KB)
  - `key-press2.wav` (29.33 KB)

---

## Current Implementation

### Audio Pool Architecture

```dart
// From keyboard_viewmodel.dart
static const int _audioPoolSize = 15; // Pool of 15 pre-loaded players for rapid typing
final List<AudioPlayer> _audioPool = [];
int _currentPlayerIndex = 0;
bool _audioPoolInitialized = false;

// Initialization
Future<void> _initializeAudioPool() async {
  if (_audioPoolInitialized) return;

  for (int i = 0; i < _audioPoolSize; i++) {
    final player = AudioPlayer();
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setReleaseMode(ReleaseMode.stop);
    _audioPool.add(player);
  }

  _audioPoolInitialized = true;
}

// Playback (called on every key press)
void _playSound() {
  if (!_soundEnabled || !_audioPoolInitialized) return;

  final player = _audioPool[_currentPlayerIndex];

  try {
    player.stop();
    player.play(
      AssetSource('sounds/$_selectedSound'),
      mode: PlayerMode.lowLatency,
    );
  } catch (e) {
    // Silently ignore audio errors
  }

  _currentPlayerIndex = (_currentPlayerIndex + 1) % _audioPoolSize;
}
```

### Key Press Flow

**Regular Characters:**
```dart
void sendCharacter(String keyId) {
  // ... update preview logic ...
  sendKey(char);        // ← Calls _playSound()
  notifyListeners();    // ← UI update after sound
}
```

**Special Keys (Space, Backspace, etc.):**
```dart
void sendSpecialKey(String key) {
  if (key == 'Backspace') {
    // ... update preview logic ...
    sendKey(key);       // ← Calls _playSound()
    notifyListeners();  // ← UI update after sound
    return;
  }
  // Similar pattern for all special keys
}
```

---

## Fixes Attempted (All Failed)

### Fix #1: Order of Execution
**Problem:** Special keys called `notifyListeners()` before `sendKey()`, causing widget rebuild to interrupt sound
**Solution:** Swapped order - `sendKey()` before `notifyListeners()`
**Result:** ❌ Issue persists

### Fix #2: MP3 → WAV Conversion
**Problem:** MP3 codec adds 10-50ms latency
**Solution:** Converted audio to WAV (raw PCM, zero codec delay)
**Result:** ✓ Latency fixed, but ❌ sound still stops after fast typing

### Fix #3: Error Handling
**Problem:** Crashes due to missing assets
**Solution:** Added try-catch, migration logic for .mp3 → .wav preferences
**Result:** ✓ No crashes, but ❌ sound still stops

### Fix #4: Increased Pool Size
**Problem:** 5-player pool exhausted during fast typing
**Solution:** Increased to 15 players
**Result:** ❌ Issue persists

### Fix #5: Explicit Stop Before Play
**Problem:** Players in "busy" state when cycling back in pool
**Solution:** Added `player.stop()` before `player.play()`
**Result:** ❌ Issue persists

---

## Technical Details

### AudioPlayer States
From `audioplayers` package documentation:
- **STOPPED**: Ready to play
- **PLAYING**: Currently playing audio
- **PAUSED**: Paused mid-playback
- **COMPLETED**: Finished playing

### ReleaseMode.stop Behavior
According to docs: "When audio completes, player automatically returns to STOPPED state and resets to beginning"

### PlayerMode.lowLatency
- Optimized for low-latency playback
- May cache small assets in memory
- Supposed to reduce initialization overhead

---

## Potential Root Causes to Investigate

### 1. Audio Player State Corruption
**Hypothesis:** Players get stuck in invalid state after repeated use
**Evidence:** Sound works initially but fails after some time/fast typing
**To Check:**
- Are players actually returning to STOPPED state?
- Does `stop()` complete before `play()` is called?
- Are there hidden async state transitions?

### 2. Asset Loading Failure
**Hypothesis:** AssetSource fails to reload after first few plays
**Evidence:** Using `AssetSource('sounds/$_selectedSound')` on every play call
**To Check:**
- Does asset cache get corrupted?
- Should we use `setSource()` once and call `resume()` instead?
- Is there a memory leak in asset loading?

### 3. Android Audio Focus Issues
**Hypothesis:** App loses audio focus to system
**Evidence:** Issue happens after some time of usage
**To Check:**
- Does Android reclaim audio focus?
- Should we implement AudioFocus management?
- Are there system-level audio interruptions?

### 4. Async Race Conditions
**Hypothesis:** `stop()` + `play()` creates race condition
**Evidence:** Calling async methods synchronously without await
**To Check:**
- Should we `await player.stop()` before `play()`?
- Does fire-and-forget async break player state?
- Is there a better pattern for rapid sequential calls?

### 5. Pool Index Overflow/Corruption
**Hypothesis:** `_currentPlayerIndex` gets corrupted in rapid succession
**Evidence:** Round-robin % operation in high-frequency scenario
**To Check:**
- Is modulo operation thread-safe in Dart?
- Could `_currentPlayerIndex` skip players or loop incorrectly?
- Should we use atomic operations?

### 6. Memory/Resource Exhaustion
**Hypothesis:** 15 AudioPlayers consume too much memory over time
**Evidence:** Issue appears after "some time" of usage
**To Check:**
- Does Android kill AudioPlayers silently?
- Are we hitting memory limits?
- Should we reduce pool size or use different architecture?

---

## Alternative Architectures to Consider

### Option A: Single Player with Queue
```dart
// Instead of pool, use 1 player with rapid stop+play
final AudioPlayer _player = AudioPlayer();

void _playSound() {
  _player.stop();
  _player.play(AssetSource('sounds/$_selectedSound'));
}
```
**Pros:** Simple, no pool management
**Cons:** Already tried, didn't work for first implementation

### Option B: Pre-set Source, Use Resume
```dart
// Set source once, use resume() for playback
await _player.setSource(AssetSource('sounds/$_selectedSound'));

void _playSound() {
  _player.stop();
  _player.resume();
}
```
**Pros:** No asset reloading overhead
**Cons:** External AI said resume() has playhead bug with ReleaseMode.stop

### Option C: Native Platform Channel
```dart
// Use MethodChannel to call native Android MediaPlayer
static const platform = MethodChannel('keyote/audio');

void _playSound() {
  platform.invokeMethod('playSound', {'file': _selectedSound});
}
```
**Pros:** Direct Android API, more control
**Cons:** Complex implementation, need native code

### Option D: soundpool Package
```dart
// Use soundpool package instead of audioplayers
// Designed specifically for low-latency sound effects
Soundpool pool = Soundpool.fromOptions();
int soundId = await pool.load(await rootBundle.load('assets/sounds/click.wav'));

void _playSound() {
  pool.play(soundId);
}
```
**Pros:** Built for game sound effects (this exact use case)
**Cons:** Different package, need migration

---

## Code Location Reference

**Main Files:**
- `lib/viewmodels/keyboard_viewmodel.dart` - Lines 14-240 (audio pool logic)
- `lib/viewmodels/settings_viewmodel.dart` - Lines 124-133 (preview player)
- `lib/services/storage_service.dart` - Lines 60-71 (migration logic)
- `lib/utils/constants.dart` - Lines 17-20 (sound file constants)
- `pubspec.yaml` - Lines 59-61 (asset registration)
- `assets/sounds/` - WAV audio files

**Key Methods:**
- `_initializeAudioPool()` - Creates 15 AudioPlayer instances
- `_playSound()` - Called on every key press
- `sendKey()` - Triggers _playSound() then sends key to server
- `sendCharacter()` - Handles regular characters
- `sendSpecialKey()` - Handles backspace, space, arrows, etc.

---

## Questions for Investigation

1. **State Verification:**
   - What is the actual state of AudioPlayers when sound stops?
   - Can we log player states to see pattern?

2. **Async Behavior:**
   - Should `stop()` be awaited before `play()`?
   - What happens when `play()` is called while previous `play()` is still loading?

3. **Package Alternatives:**
   - Would `soundpool` package work better for this use case?
   - Are there known issues with `audioplayers` for rapid playback?

4. **Platform-Specific:**
   - Are there Android-specific audio limitations?
   - Does this happen on all Android versions?
   - Should we test on iOS to isolate Android issues?

5. **Resource Management:**
   - Should players be recreated periodically?
   - Is there a "refresh pool" pattern we should implement?
   - Do we need to manually release resources?

---

## Testing Suggestions

### Test 1: Add Logging
```dart
void _playSound() {
  print('Sound attempt: idx=$_currentPlayerIndex, enabled=$_soundEnabled, init=$_audioPoolInitialized');
  final player = _audioPool[_currentPlayerIndex];
  print('Player state before stop: ${player.state}');
  
  player.stop();
  print('Player state after stop: ${player.state}');
  
  player.play(AssetSource('sounds/$_selectedSound'), mode: PlayerMode.lowLatency);
  print('Play called');
  
  _currentPlayerIndex = (_currentPlayerIndex + 1) % _audioPoolSize;
}
```

### Test 2: Await Stop
```dart
Future<void> _playSound() async {
  final player = _audioPool[_currentPlayerIndex];
  await player.stop();  // Wait for stop to complete
  await player.play(AssetSource('sounds/$_selectedSound'));
  _currentPlayerIndex = (_currentPlayerIndex + 1) % _audioPoolSize;
}
```

### Test 3: Smaller Pool
```dart
static const int _audioPoolSize = 3; // Test if 15 is too many
```

### Test 4: Single Player
```dart
// Remove pool entirely, test with 1 player
final AudioPlayer _soloPlayer = AudioPlayer();

void _playSound() {
  _soloPlayer.stop();
  _soloPlayer.play(AssetSource('sounds/$_selectedSound'));
}
```

---

## External Resources

**Packages:**
- `audioplayers` docs: https://pub.dev/packages/audioplayers
- `soundpool` alternative: https://pub.dev/packages/soundpool
- Flutter audio guide: https://docs.flutter.dev/cookbook/plugins/play-audio

**Similar Issues:**
- GitHub audioplayers issues: Check for "stop working" or "silent after time"
- Stack Overflow: Search "flutter audioplayers stops working fast playback"
- Reddit r/FlutterDev: Sound effect pooling discussions

**Android Audio:**
- AudioFocus management: https://developer.android.com/guide/topics/media-apps/audio-focus
- Low-latency audio: https://developer.android.com/ndk/guides/audio/audio-latency

---

## Current Status Summary

✅ **Working:**
- Sound plays on first few key presses
- No crashes or errors in logs (except initial asset not found which was fixed)
- UI responds correctly
- Settings toggle works

❌ **Broken:**
- Sound stops completely after fast typing or after some time
- No error messages or exceptions thrown
- Silent failure - very hard to debug

🤔 **Unknown:**
- Exact trigger condition (fast typing? time-based? pool exhaustion?)
- AudioPlayer internal state when failure occurs
- Whether it's package bug or our implementation
- If Android system is interfering

---

## Recommendation for External Analysis

When consulting external AI/experts, ask specifically:

1. "Is there a known issue with `audioplayers` package stopping playback after repeated rapid calls?"

2. "What's the correct pattern for low-latency sound effects in Flutter - pool of players vs single player?"

3. "Should `player.stop()` be awaited before calling `player.play()` in rapid succession?"

4. "Is `soundpool` package better than `audioplayers` for keyboard click sounds?"

5. "Could Android AudioFocus be causing sound to stop? How to prevent?"

6. "Is there a maximum number of AudioPlayer instances that can be active?"

7. "What diagnostic logging can reveal AudioPlayer state corruption?"

---

**Generated:** February 2, 2026  
**Flutter Version:** Latest stable  
**Package:** audioplayers ^6.1.0  
**Platform:** Android
