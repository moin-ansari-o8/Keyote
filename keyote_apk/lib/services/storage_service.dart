import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/server_config.dart';
import '../utils/constants.dart';

class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  Future<ServerConfig?> getServerConfig() async {
    final jsonString = _prefs?.getString(AppConstants.prefKeyServerConfig);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ServerConfig.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveServerConfig(ServerConfig config) async {
    final jsonString = jsonEncode(config.toJson());
    return await _prefs?.setString(
          AppConstants.prefKeyServerConfig,
          jsonString,
        ) ??
        false;
  }

  Future<String?> getThemeMode() async {
    return _prefs?.getString(AppConstants.prefKeyThemeMode);
  }

  Future<bool> saveThemeMode(String mode) async {
    return await _prefs?.setString(AppConstants.prefKeyThemeMode, mode) ??
        false;
  }

  Future<bool> getSoundEnabled() async {
    return _prefs?.getBool(AppConstants.prefKeySoundEnabled) ?? true;
  }

  Future<bool> setSoundEnabled(bool enabled) async {
    return await _prefs?.setBool(AppConstants.prefKeySoundEnabled, enabled) ??
        false;
  }

  Future<String> getSelectedSound() async {
    String sound =
        _prefs?.getString(AppConstants.prefKeySelectedSound) ??
        AppConstants.defaultSound;

    // Migrate old .mp3 preferences to .wav
    if (sound.endsWith('.mp3')) {
      sound = sound.replaceAll('.mp3', '.wav');
      // Save the migrated value
      await setSelectedSound(sound);
    }

    return sound;
  }

  Future<bool> setSelectedSound(String sound) async {
    return await _prefs?.setString(AppConstants.prefKeySelectedSound, sound) ??
        false;
  }

  Future<double> getSoundVolume() async {
    return _prefs?.getDouble(AppConstants.prefKeySoundVolume) ??
        AppConstants.defaultVolume;
  }

  Future<bool> setSoundVolume(double volume) async {
    return await _prefs?.setDouble(AppConstants.prefKeySoundVolume, volume) ??
        false;
  }
}
