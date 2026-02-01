class ServerConfig {
  final String ip;
  final int port;

  const ServerConfig({required this.ip, this.port = 5000});

  String get baseUrl => 'http://$ip:$port';

  Map<String, dynamic> toJson() {
    return {'ip': ip, 'port': port};
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      ip: json['ip'] as String,
      port: json['port'] as int? ?? 5000,
    );
  }

  ServerConfig copyWith({String? ip, int? port}) {
    return ServerConfig(ip: ip ?? this.ip, port: port ?? this.port);
  }
}
