class Validators {
  static final RegExp _ipv4Regex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );

  static String? validateIp(String? value) {
    if (value == null || value.isEmpty) {
      return 'IP address is required';
    }
    if (!_ipv4Regex.hasMatch(value)) {
      return 'Invalid IPv4 address';
    }
    return null;
  }

  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port is required';
    }
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return 'Port must be between 1 and 65535';
    }
    return null;
  }
}
