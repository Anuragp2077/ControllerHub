class PairingInfo {
  final String host;
  final int port;
  final String token;

  const PairingInfo({
    required this.host,
    required this.port,
    required this.token,
  });

  static PairingInfo? parse(String value) {
    try {
      final uri = Uri.parse(value);

      if (uri.scheme != 'http' &&
          uri.scheme != 'https') {
        return null;
      }

      if (uri.host.isEmpty) {
        return null;
      }

      final int port = uri.hasPort
          ? uri.port
          : 80;

      final String? token = uri.queryParameters['token'];

      if (token == null || token.isEmpty) {
        return null;
      }

      return PairingInfo(
        host: uri.host,
        port: port,
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  String get websocketUrl {
    return 'ws://$host:$port/';
  }
}