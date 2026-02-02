import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/key_command.dart';
import '../models/dual_char.dart';
import '../services/keyboard_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class KeyboardViewModel extends ChangeNotifier {
  final KeyboardService _keyboardService;
  final StorageService _storageService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _ctrlPressed = false;
  bool _shiftPressed = false;
  bool _altPressed = false;
  bool _winPressed = false;
  bool _winUsedWithOtherKey = false;
  bool _capsLockActive = false;
  bool _soundEnabled = true;
  String _selectedSound = AppConstants.defaultSound;
  bool _isConnected = false;
  String _inputPreview = '';
  Timer? _debounceTimer;
  Timer? _repeatTimer;
  Timer? _connectionCheckTimer;

  // Dual character map for keys
  final Map<String, DualChar> _keyMap = {
    '1': DualChar(primary: '1', secondary: '!'),
    '2': DualChar(primary: '2', secondary: '@'),
    '3': DualChar(primary: '3', secondary: '#'),
    '4': DualChar(primary: '4', secondary: r'$'),
    '5': DualChar(primary: '5', secondary: '%'),
    '6': DualChar(primary: '6', secondary: '^'),
    '7': DualChar(primary: '7', secondary: '&'),
    '8': DualChar(primary: '8', secondary: '*'),
    '9': DualChar(primary: '9', secondary: '('),
    '0': DualChar(primary: '0', secondary: ')'),
    '-': DualChar(primary: '-', secondary: '_'),
    '=': DualChar(primary: '=', secondary: '+'),
    '[': DualChar(primary: '[', secondary: '{'),
    ']': DualChar(primary: ']', secondary: '}'),
    '\\': DualChar(primary: r'\', secondary: '|'),
    ';': DualChar(primary: ';', secondary: ':'),
    '\'': DualChar(primary: '\'', secondary: '\"'),
    ',': DualChar(primary: ',', secondary: '<'),
    '.': DualChar(primary: '.', secondary: '>'),
    '/': DualChar(primary: '/', secondary: '?'),
    '`': DualChar(primary: '`', secondary: '~'),
  };

  KeyboardViewModel(this._keyboardService, this._storageService) {
    _loadSoundPreferences();
    _startConnectionMonitoring();
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    _debounceTimer?.cancel();
    _repeatTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startConnectionMonitoring() {
    _checkConnection();
    _connectionCheckTimer = Timer.periodic(Duration(seconds: 3), (_) {
      _checkConnection();
    });
  }

  Future<void> _checkConnection() async {
    final wasConnected = _isConnected;
    _isConnected = await _keyboardService.testConnection();

    if (wasConnected != _isConnected) {
      if (!_isConnected) {
        resetModifiers();
        _inputPreview = 'Connect to server first...';
      } else {
        _inputPreview = '';
      }
      notifyListeners();
    }
  }

  bool get ctrlPressed => _ctrlPressed;
  bool get shiftPressed => _shiftPressed;
  bool get altPressed => _altPressed;
  bool get winPressed => _winPressed;
  bool get capsLockActive => _capsLockActive;
  bool get soundEnabled => _soundEnabled;
  String get selectedSound => _selectedSound;
  bool get isConnected => _isConnected;
  String get inputPreview => _inputPreview;

  Future<void> _loadSoundPreferences() async {
    _soundEnabled = await _storageService.getSoundEnabled();
    _selectedSound = await _storageService.getSelectedSound();
    notifyListeners();
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storageService.setSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> updateSelectedSound(String sound) async {
    _selectedSound = sound;
    await _storageService.setSelectedSound(sound);
    notifyListeners();
  }

  void clearInputPreview() {
    _inputPreview = '';
    notifyListeners();
  }

  // Hold-down modifier methods (NOT toggle)
  void setCtrl(bool pressed) {
    _ctrlPressed = pressed;
    notifyListeners();
  }

  void setShift(bool pressed) {
    _shiftPressed = pressed;
    notifyListeners();
  }

  void setAlt(bool pressed) {
    _altPressed = pressed;
    notifyListeners();
  }

  void setWin(bool pressed) {
    // When Win key is released alone (without other keys), send Win key
    if (!pressed && _winPressed && !_winUsedWithOtherKey) {
      sendKey('win');
    }

    if (pressed) {
      _winUsedWithOtherKey = false;
    }

    _winPressed = pressed;
    notifyListeners();
  }

  // Caps Lock is toggle (standard keyboard behavior)
  void toggleCapsLock() {
    _capsLockActive = !_capsLockActive;
    notifyListeners();
  }

  // Legacy toggle methods (deprecated)
  void toggleCtrl() {
    _ctrlPressed = !_ctrlPressed;
    notifyListeners();
  }

  void toggleShift() {
    _shiftPressed = !_shiftPressed;
    notifyListeners();
  }

  void toggleAlt() {
    _altPressed = !_altPressed;
    notifyListeners();
  }

  void resetModifiers() {
    _ctrlPressed = false;
    _shiftPressed = false;
    _altPressed = false;
    notifyListeners();
  }

  void _playSound() {
    if (!_soundEnabled) return;

    // Stop previous sound to prevent overlap and ensure every key press is heard
    _audioPlayer.stop();

    // Play selected sound with low latency mode for instant response
    _audioPlayer
        .play(
          AssetSource('sounds/$_selectedSound'),
          mode: PlayerMode.lowLatency,
          volume: 1.0,
        )
        .catchError((_) {});
  }

  void sendKey(String key, {bool? ctrl, bool? shift, bool? alt, bool? win}) {
    if (!_isConnected) return;

    // Mark Win as used with other key if Win is pressed
    if (_winPressed && key != 'win') {
      _winUsedWithOtherKey = true;
    }

    _playSound();

    // Build modifiers string for Win key support
    String finalKey = key;
    List<String> mods = [];

    final useCtrl = ctrl ?? _ctrlPressed;
    final useShift = shift ?? _shiftPressed;
    final useAlt = alt ?? _altPressed;
    final useWin = win ?? _winPressed;

    // For Win key combinations, send as special format
    if (useWin && key != 'win') {
      mods.add('win');
    }
    if (useCtrl) {
      mods.add('ctrl');
    }
    if (useAlt) {
      mods.add('alt');
    }
    if (useShift) {
      mods.add('shift');
    }

    // Send win+key combinations as composite command
    if (mods.isNotEmpty &&
        key != 'win' &&
        key != 'ctrl' &&
        key != 'alt' &&
        key != 'shift') {
      finalKey = '${mods.join('+')}+$key';
    }

    final command = KeyCommand(
      key: finalKey,
      ctrl: useCtrl && !useWin, // Don't duplicate if already in key string
      shift: useShift && mods.isEmpty,
      alt: useAlt && !useWin,
    );

    _keyboardService.sendKeyAsync(command);

    if (ctrl != null || shift != null || alt != null || win != null) {
      resetModifiers();
    }
  }

  void sendCharacter(String keyId) {
    if (!_isConnected) return;

    String char;

    if (_keyMap.containsKey(keyId)) {
      char = _shiftPressed
          ? _keyMap[keyId]!.secondary
          : _keyMap[keyId]!.primary;
    } else if (_isAlpha(keyId)) {
      char = (_shiftPressed || _capsLockActive)
          ? keyId.toUpperCase()
          : keyId.toLowerCase();
    } else {
      char = keyId;
    }

    // Update input preview without notifying yet
    _inputPreview += char;
    if (_inputPreview.length > 100) {
      _inputPreview = _inputPreview.substring(_inputPreview.length - 100);
    }

    // Send key first, then notify once
    sendKey(char);
    notifyListeners();
  }

  // Send secondary character (for long press on dual-char keys)
  void sendSecondaryChar(String keyId) {
    if (!_isConnected) return;

    String char;

    if (_keyMap.containsKey(keyId)) {
      char = _keyMap[keyId]!.secondary;
    } else {
      char = keyId;
    }

    // Update input preview
    _inputPreview += char;
    if (_inputPreview.length > 100) {
      _inputPreview = _inputPreview.substring(_inputPreview.length - 100);
    }
    notifyListeners();

    sendKey(char);
  }

  void sendSpecialKey(String key) {
    if (!_isConnected) return;

    if (key == 'Backspace' && _inputPreview.isNotEmpty) {
      // If Ctrl is pressed, delete whole word (like Ctrl+Backspace)
      if (_ctrlPressed) {
        // Find last word boundary
        final trimmed = _inputPreview.trimRight();
        final lastSpace = trimmed.lastIndexOf(' ');
        final lastNewline = trimmed.lastIndexOf('\n');
        final lastTab = trimmed.lastIndexOf('\t');
        final boundary = [
          lastSpace,
          lastNewline,
          lastTab,
        ].reduce((a, b) => a > b ? a : b);

        if (boundary >= 0) {
          _inputPreview = _inputPreview.substring(0, boundary + 1);
        } else {
          _inputPreview = '';
        }
      } else {
        _inputPreview = _inputPreview.substring(0, _inputPreview.length - 1);
      }
    } else if (key == 'Return' || key == 'Enter') {
      _inputPreview += '\n';
    } else if (key == 'Tab') {
      // Show key combination text when modifiers are active
      if (_ctrlPressed || _altPressed || _winPressed) {
        List<String> parts = [];
        if (_ctrlPressed) parts.add('Ctrl');
        if (_altPressed) parts.add('Alt');
        if (_winPressed) parts.add('Win');
        parts.add('Tab');
        _inputPreview += ' {${parts.join('+')}} ';
      } else {
        _inputPreview += '\t';
      }
    } else if (key == ' ') {
      _inputPreview += ' ';
    }

    // Notify once after all updates
    notifyListeners();
    sendKey(key);
  }

  bool _isAlpha(String key) {
    return key.length == 1 &&
        key.toLowerCase().compareTo('a') >= 0 &&
        key.toLowerCase().compareTo('z') <= 0;
  }

  void sendKeyDebounced(String key) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      Duration(milliseconds: AppConstants.debounceDelay),
      () => sendKey(key),
    );
  }

  void startKeyRepeat(String key) {
    stopKeyRepeat();
    sendKey(key);
    _repeatTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.keyRepeatInterval),
      (_) => sendKey(key),
    );
  }

  void stopKeyRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }
}
