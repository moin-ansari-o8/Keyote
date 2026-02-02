import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/key_command.dart';
import '../models/server_config.dart';
import '../utils/constants.dart';

class KeyboardService {
  ServerConfig? _config;
  final Queue<KeyCommand> _keyQueue = Queue();
  bool _isProcessing = false;
  static const int _maxQueueSize = 100;

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
    // Prevent queue overflow
    if (_keyQueue.length >= _maxQueueSize) {
      _keyQueue.removeFirst();
    }
    
    _keyQueue.add(command);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _keyQueue.isEmpty || _config == null) return;
    
    _isProcessing = true;
    
    while (_keyQueue.isNotEmpty) {
      final command = _keyQueue.removeFirst();
      
      try {
        await sendKey(command);
        // Reduced delay for faster typing
        if (_keyQueue.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 2));
        }
      } catch (e) {
        // Continue processing even if one key fails
      }
    }
    
    _isProcessing = false;
  }

  void clearQueue() {
    _keyQueue.clear();
    _isProcessing = false;
  }
}
