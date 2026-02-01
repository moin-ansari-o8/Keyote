import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/key_command.dart';
import '../models/server_config.dart';
import '../utils/constants.dart';

class KeyboardService {
  ServerConfig? _config;

  void updateConfig(ServerConfig config) {
    _config = config;
  }

  Future<bool> testConnection() async {
    if (_config == null) return false;

    try {
      final response = await http
          .get(Uri.parse('${_config!.baseUrl}${AppConstants.healthEndpoint}'))
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendKey(KeyCommand command) async {
    if (_config == null) return false;

    try {
      final response = await http
          .post(
            Uri.parse('${_config!.baseUrl}${AppConstants.keyEndpoint}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(command.toJson()),
          )
          .timeout(Duration(seconds: AppConstants.requestTimeout));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void sendKeyAsync(KeyCommand command) {
    sendKey(command).catchError((_) => false);
  }
}
