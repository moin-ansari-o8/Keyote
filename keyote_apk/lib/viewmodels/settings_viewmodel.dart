import 'package:flutter/material.dart';
import '../models/server_config.dart';
import '../services/keyboard_service.dart';
import '../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final KeyboardService _keyboardService;
  final StorageService _storageService;

  String _ip = '';
  int _port = 5000;
  bool _isConnected = false;
  bool _isTesting = false;
  ThemeMode _themeMode = ThemeMode.system;

  SettingsViewModel(this._keyboardService, this._storageService) {
    _loadSettings();
  }

  String get ip => _ip;
  int get port => _port;
  bool get isConnected => _isConnected;
  bool get isTesting => _isTesting;
  ThemeMode get themeMode => _themeMode;

  Future<void> _loadSettings() async {
    final config = await _storageService.getServerConfig();
    if (config != null) {
      _ip = config.ip;
      _port = config.port;
      _keyboardService.updateConfig(config);
      notifyListeners();
      await testConnection();
    }

    final themeModeString = await _storageService.getThemeMode();
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  void updateIp(String value) {
    _ip = value;
    notifyListeners();
  }

  void updatePort(String value) {
    _port = int.tryParse(value) ?? 5000;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    final config = ServerConfig(ip: _ip, port: _port);
    final success = await _storageService.saveServerConfig(config);
    if (success) {
      _keyboardService.updateConfig(config);
      await testConnection();
    }
    return success;
  }

  Future<void> testConnection() async {
    _isTesting = true;
    notifyListeners();

    _isConnected = await _keyboardService.testConnection();

    _isTesting = false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await _storageService.saveThemeMode(_themeMode.toString());
    notifyListeners();
  }

  void setConnectionState(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }
}
