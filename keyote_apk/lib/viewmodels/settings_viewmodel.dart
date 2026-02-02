import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../models/server_config.dart';
import '../services/keyboard_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class SettingsViewModel extends ChangeNotifier {
  final KeyboardService _keyboardService;
  final StorageService _storageService;
  SoLoud? _previewSoloud;
  final Map<String, AudioSource> _soundCache = {};

  String _ip = '';
  int _port = 5000;
  bool _isConnected = false;
  bool _isTesting = false;
  ThemeMode _themeMode = ThemeMode.system;
  bool _soundEnabled = true;
  String _selectedSound = AppConstants.defaultSound;
  double _soundVolume = AppConstants.defaultVolume;

  SettingsViewModel(this._keyboardService, this._storageService) {
    _initPreviewAudio();
    _loadSettings();
  }

  Future<void> _initPreviewAudio() async {
    try {
      _previewSoloud = SoLoud.instance;
      await _previewSoloud!.init();
    } catch (e) {
      _previewSoloud = null;
    }
  }

  String get ip => _ip;
  int get port => _port;
  bool get isConnected => _isConnected;
  bool get isTesting => _isTesting;
  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  String get selectedSound => _selectedSound;
  double get soundVolume => _soundVolume;

  @override
  void dispose() {
    _previewSoloud?.deinit();
    super.dispose();
  }

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

    _soundEnabled = await _storageService.getSoundEnabled();
    _selectedSound = await _storageService.getSelectedSound();
    _soundVolume = await _storageService.getSoundVolume();
    notifyListeners();
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

  Future<void> updateSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storageService.setSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> updateSoundVolume(double volume) async {
    _soundVolume = volume;
    await _storageService.setSoundVolume(volume);
    notifyListeners();
  }

  Future<void> updateSelectedSound(String sound) async {
    _selectedSound = sound;
    await _storageService.setSelectedSound(sound);
    notifyListeners();
    // Play preview of the selected sound
    playPreview(sound);
  }

  Future<void> playPreview(String sound) async {
    if (_previewSoloud == null) return;

    try {
      // Load sound if not cached
      if (!_soundCache.containsKey(sound)) {
        _soundCache[sound] = await _previewSoloud!.loadAsset(
          'assets/sounds/$sound',
        );
      }

      // Play the cached sound
      final soundSource = _soundCache[sound];
      if (soundSource != null) {
        _previewSoloud!.play(soundSource, volume: _soundVolume);
      }
    } catch (e) {
      // Silently ignore preview errors
    }
  }
}
