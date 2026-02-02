import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../models/key_command.dart';
import '../models/dual_char.dart';
import '../services/keyboard_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class KeyboardViewModel extends ChangeNotifier {
  final KeyboardService _keyboardService;
  final StorageService _storageService;

  // SoLoud for professional-grade ultra-low latency keyboard sounds
  // Used by games and pro apps - <10ms latency, zero race conditions
  // Architecture: load once, play instantly, zero state machine overhead
  SoLoud? _soloud;
  AudioSource? _soundSource;
  bool _audioInitialized = false;

  bool _ctrlPressed = false;
  bool _shiftPressed = false;
  bool _altPressed = false;
  bool _winPressed = false;
  bool _winUsedWithOtherKey = false;
  bool _capsLockActive = false;
  bool _soundEnabled = true;
  String _selectedSound = AppConstants.defaultSound;
  double _soundVolume = AppConstants.defaultVolume;
  bool _isConnected = false;
  String _inputPreview = '';
  int _cursorPosition = 0;
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
    "'": DualChar(primary: "'", secondary: '"'),
    ',': DualChar(primary: ',', secondary: '<'),
    '.': DualChar(primary: '.', secondary: '>'),
    '/': DualChar(primary: '/', secondary: '?'),
    '`': DualChar(primary: '`', secondary: '~'),
  };

  KeyboardViewModel(this._keyboardService, this._storageService) {
    _init();
  }

  // Proper async initialization sequence to avoid race conditions
  Future<void> _init() async {
    await _initializeAudioPool();
    await _loadSoundPreferences();
    _startConnectionMonitoring();
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    _debounceTimer?.cancel();
    _repeatTimer?.cancel();
    // Release SoLoud resources
    _soloud?.deinit();
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
        _cursorPosition = 0;
      } else {
        _inputPreview = '';
        _cursorPosition = 0;
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
  double get soundVolume => _soundVolume;
  bool get isConnected => _isConnected;
  String get inputPreview => _inputPreview;
  int get cursorPosition => _cursorPosition;

  Future<void> _loadSoundPreferences() async {
    _soundEnabled = await _storageService.getSoundEnabled();
    _selectedSound = await _storageService.getSelectedSound();
    _soundVolume = await _storageService.getSoundVolume();
    notifyListeners();
  }

  // Public method to reload sound settings from storage
  Future<void> reloadSoundSettings() async {
    final newSound = await _storageService.getSelectedSound();
    final newVolume = await _storageService.getSoundVolume();
    
    if (newSound != _selectedSound) {
      _selectedSound = newSound;
      if (_audioInitialized && _soloud != null) {
        _soundSource = await _soloud!.loadAsset('assets/sounds/$_selectedSound');
      }
    }
    
    if (newVolume != _soundVolume) {
      _soundVolume = newVolume;
    }
    
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

    // Reload sound with new selection
    if (_audioInitialized && _soloud != null) {
      _soundSource = await _soloud!.loadAsset('assets/sounds/$_selectedSound');
    }

    notifyListeners();
  }

  void clearInputPreview() {
    _inputPreview = '';
    _cursorPosition = 0;
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

  // Initialize SoLoud engine with pre-loaded sound for instant playback
  Future<void> _initializeAudioPool() async {
    if (_audioInitialized) return;

    try {
      // Initialize SoLoud engine (native C++ audio engine)
      _soloud = SoLoud.instance;
      await _soloud!.init();

      // Load sound asset into memory for zero-latency playback
      _soundSource = await _soloud!.loadAsset('assets/sounds/$_selectedSound');

      _audioInitialized = true;
    } catch (e) {
      // Graceful degradation if audio fails
      _audioInitialized = false;
    }
  }

  void _playSound() {
    if (!_soundEnabled || !_audioInitialized || _soundSource == null) return;

    // Single method call - SoLoud C++ engine handles everything
    // <10ms latency, zero state machine, instant playback
    // Same architecture as professional piano/keyboard apps
    _soloud!.play(_soundSource!, volume: _soundVolume);
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

    // Insert character at cursor position
    _inputPreview =
        _inputPreview.substring(0, _cursorPosition) +
        char +
        _inputPreview.substring(_cursorPosition);
    _cursorPosition++;

    if (_inputPreview.length > 100) {
      final overflow = _inputPreview.length - 100;
      _inputPreview = _inputPreview.substring(overflow);
      _cursorPosition = (_cursorPosition - overflow).clamp(0, 100);
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

    // Insert at cursor position
    _inputPreview =
        _inputPreview.substring(0, _cursorPosition) +
        char +
        _inputPreview.substring(_cursorPosition);
    _cursorPosition++;

    if (_inputPreview.length > 100) {
      final overflow = _inputPreview.length - 100;
      _inputPreview = _inputPreview.substring(overflow);
      _cursorPosition = (_cursorPosition - overflow).clamp(0, 100);
    }
    notifyListeners();

    sendKey(char);
  }

  void sendSpecialKey(String key) {
    if (!_isConnected) return;

    // Handle Left arrow - move cursor left
    if (key == 'Left') {
      if (_ctrlPressed) {
        // Ctrl+Left: jump to previous word start
        _cursorPosition = _findPreviousWordBoundary();
      } else {
        // Simple left movement
        if (_cursorPosition > 0) {
          _cursorPosition--;
        }
      }
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Right arrow - move cursor right
    if (key == 'Right') {
      if (_ctrlPressed) {
        // Ctrl+Right: jump to next word end
        _cursorPosition = _findNextWordBoundary();
      } else {
        // Simple right movement
        if (_cursorPosition < _inputPreview.length) {
          _cursorPosition++;
        }
      }
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Backspace - delete character before cursor
    if (key == 'Backspace') {
      if (_ctrlPressed && _cursorPosition > 0) {
        // Ctrl+Backspace: delete word before cursor
        final prevBoundary = _findPreviousWordBoundary();
        _inputPreview =
            _inputPreview.substring(0, prevBoundary) +
            _inputPreview.substring(_cursorPosition);
        _cursorPosition = prevBoundary;
      } else if (_cursorPosition > 0) {
        // Normal backspace: delete one character before cursor
        _inputPreview =
            _inputPreview.substring(0, _cursorPosition - 1) +
            _inputPreview.substring(_cursorPosition);
        _cursorPosition--;
      }
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Delete key - delete character at cursor
    if (key == 'Delete') {
      if (_cursorPosition < _inputPreview.length) {
        _inputPreview =
            _inputPreview.substring(0, _cursorPosition) +
            _inputPreview.substring(_cursorPosition + 1);
      }
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Home - move cursor to start
    if (key == 'Home') {
      _inputPreview =
          '${_inputPreview.substring(0, _cursorPosition)} {Home} ${_inputPreview.substring(_cursorPosition)}';
      _cursorPosition += 8; // Length of " {Home} "
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle End - move cursor to end
    if (key == 'End') {
      _inputPreview =
          '${_inputPreview.substring(0, _cursorPosition)} {End} ${_inputPreview.substring(_cursorPosition)}';
      _cursorPosition += 7; // Length of " {End} "
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Up/Down arrows - show as special keys
    if (key == 'Up') {
      _inputPreview =
          '${_inputPreview.substring(0, _cursorPosition)} {Up} ${_inputPreview.substring(_cursorPosition)}';
      _cursorPosition += 6; // Length of " {Up} "
      sendKey(key);
      notifyListeners();
      return;
    }

    if (key == 'Down') {
      _inputPreview =
          '${_inputPreview.substring(0, _cursorPosition)} {Down} ${_inputPreview.substring(_cursorPosition)}';
      _cursorPosition += 8; // Length of " {Down} "
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Enter/Return
    if (key == 'Return' || key == 'Enter') {
      _inputPreview =
          '${_inputPreview.substring(0, _cursorPosition)}\n${_inputPreview.substring(_cursorPosition)}';
      _cursorPosition++;
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Tab
    if (key == 'Tab') {
      if (_ctrlPressed || _altPressed || _winPressed) {
        // Show key combination text when modifiers are active
        List<String> parts = [];
        if (_ctrlPressed) parts.add('Ctrl');
        if (_altPressed) parts.add('Alt');
        if (_winPressed) parts.add('Win');
        parts.add('Tab');
        final tabText = ' {${parts.join('+')}} ';
        _inputPreview =
            '${_inputPreview.substring(0, _cursorPosition)}$tabText${_inputPreview.substring(_cursorPosition)}';
        _cursorPosition += tabText.length;
      } else {
        _inputPreview =
            '${_inputPreview.substring(0, _cursorPosition)}\t${_inputPreview.substring(_cursorPosition)}';
        _cursorPosition++;
      }
      sendKey(key);
      notifyListeners();
      return;
    }

    // Handle Space
    if (key == ' ') {
      _inputPreview =
          '${_inputPreview.substring(0, _cursorPosition)} ${_inputPreview.substring(_cursorPosition)}';
      _cursorPosition++;
      sendKey(key);
      notifyListeners();
      return;
    }

    // For any other special key, just send it
    notifyListeners();
    sendKey(key);
  }

  // Helper: Find previous word boundary for Ctrl+Left/Ctrl+Backspace
  int _findPreviousWordBoundary() {
    if (_cursorPosition == 0) return 0;

    int pos = _cursorPosition - 1;

    // Skip whitespace before cursor
    while (pos > 0 && _isWhitespace(_inputPreview[pos])) {
      pos--;
    }

    // Find start of word
    while (pos > 0 && !_isWhitespace(_inputPreview[pos - 1])) {
      pos--;
    }

    return pos;
  }

  // Helper: Find next word boundary for Ctrl+Right
  int _findNextWordBoundary() {
    if (_cursorPosition >= _inputPreview.length) return _inputPreview.length;

    int pos = _cursorPosition;

    // Skip whitespace after cursor
    while (pos < _inputPreview.length && _isWhitespace(_inputPreview[pos])) {
      pos++;
    }

    // Find end of word
    while (pos < _inputPreview.length && !_isWhitespace(_inputPreview[pos])) {
      pos++;
    }

    return pos;
  }

  // Helper: Check if character is whitespace
  bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n';
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
