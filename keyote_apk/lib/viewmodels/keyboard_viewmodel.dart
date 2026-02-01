import 'dart:async';
import 'package:flutter/material.dart';
import '../models/key_command.dart';
import '../services/keyboard_service.dart';
import '../utils/constants.dart';

class KeyboardViewModel extends ChangeNotifier {
  final KeyboardService _keyboardService;

  bool _ctrlPressed = false;
  bool _shiftPressed = false;
  bool _altPressed = false;
  Timer? _debounceTimer;
  Timer? _repeatTimer;

  KeyboardViewModel(this._keyboardService);

  bool get ctrlPressed => _ctrlPressed;
  bool get shiftPressed => _shiftPressed;
  bool get altPressed => _altPressed;

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
