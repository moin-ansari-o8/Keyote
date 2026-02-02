import 'dart:async';
import 'package:flutter/material.dart';
import '../models/key_command.dart';
import '../models/dual_char.dart';
import '../services/keyboard_service.dart';
import '../utils/constants.dart';

class KeyboardViewModel extends ChangeNotifier {
  final KeyboardService _keyboardService;

  bool _ctrlPressed = false;
  bool _shiftPressed = false;
  bool _altPressed = false;
  bool _winPressed = false;
  bool _capsLockActive = false;
  Timer? _debounceTimer;
  Timer? _repeatTimer;

  // Dual character map for keys
  final Map<String, DualChar> _keyMap = {
    '1': DualChar(primary: '1', secondary: '!'),
    '2': DualChar(primary: '2', secondary: '@'),
    '3': DualChar(primary: '3', secondary: '#'),
    '4': DualChar(primary: '4', secondary: '\$'),
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
    '\\': DualChar(primary: '\\', secondary: '|'),
    ';': DualChar(primary: ';', secondary: ':'),
    '\'': DualChar(primary: '\'', secondary: '\"'),
    ',': DualChar(primary: ',', secondary: '<'),
    '.': DualChar(primary: '.', secondary: '>'),
    '/': DualChar(primary: '/', secondary: '?'),
    '`': DualChar(primary: '`', secondary: '~'),
  };

  KeyboardViewModel(this._keyboardService);

  bool get ctrlPressed => _ctrlPressed;
  bool get shiftPressed => _shiftPressed;
  bool get altPressed => _altPressed;
  bool get winPressed => _winPressed;
  bool get capsLockActive => _capsLockActive;

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

  void sendKey(String key, {bool? ctrl, bool? shift, bool? alt}) {
    final command = KeyCommand(
      key: key,
      ctrl: ctrl ?? _ctrlPressed,
      shift: shift ?? _shiftPressed,
      alt: alt ?? _altPressed,
    );

    _keyboardService.sendKeyAsync(command);

    if (ctrl != null || shift != null || alt != null) {
      resetModifiers();
    }
  }

  // Send character with dual-char support
  void sendCharacter(String keyId) {
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

    sendKey(char);
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

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _repeatTimer?.cancel();
    super.dispose();
  }
}
