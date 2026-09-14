import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';

class ControllerHubSocket {
  IOWebSocketChannel? _channel;

  StreamSubscription? _subscription;
  Timer? _heartbeatTimer;

  String? _serverHost;
  int? _serverPort;
  String? _token;
  String? _clientId;

  bool _connected = false;

  bool get isConnected => _connected;

  String? get clientId => _clientId;

  String? get serverHost => _serverHost;

  int? get serverPort => _serverPort;

  final StreamController<Map<String, dynamic>> _messages =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messages.stream;

  Future<void> connect({
    required String serverHost,
    required int serverPort,
    required String token,
    required String clientId,
  }) async {
    await disconnect();

    _serverHost = serverHost;
    _serverPort = serverPort;
    _token = token;
    _clientId = clientId;

    final uri = Uri(
      scheme: 'ws',
      host: serverHost,
      port: serverPort,
      path: '/',
    );

    try {
      final socket = await WebSocket.connect(
        uri.toString(),
      );

      _channel = IOWebSocketChannel(socket);

      _connected = true;

      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: (Object error) {
          _connected = false;
          _stopHeartbeat();

          _messages.add({
            'type': 'connection_error',
            'message': error.toString(),
          });
        },
        onDone: () {
          _connected = false;
          _stopHeartbeat();

          _messages.add({
            'type': 'disconnected',
          });
        },
        cancelOnError: false,
      );

      _sendConnectMessage();

      _startHeartbeat();

      _messages.add({
        'type': 'connected',
      });
    } catch (error) {
      _connected = false;

      _messages.add({
        'type': 'connection_error',
        'message': error.toString(),
      });

      rethrow;
    }
  }

  void _sendConnectMessage() {
    _send({
      'type': 'connect',
      'version': 1,
      'clientId': _clientId,
      'token': _token,
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) {
        if (!_connected) {
          return;
        }

        _send({
          'type': 'heartbeat',
          'version': 1,
          'clientId': _clientId,
        });
      },
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _handleMessage(dynamic rawMessage) {
    try {
      final decoded = jsonDecode(
        rawMessage.toString(),
      );

      if (decoded is Map<String, dynamic>) {
        _messages.add(decoded);
      }
    } catch (_) {
      _messages.add({
        'type': 'invalid_message',
        'message': rawMessage.toString(),
      });
    }
  }

  void sendButton({
    required String button,
    required bool pressed,
  }) {
    _send({
      'type': 'button',
      'version': 1,
      'clientId': _clientId,
      'button': button,
      'pressed': pressed,
    });
  }

  void sendStick({
    required String stick,
    required double x,
    required double y,
  }) {
    _send({
      'type': 'stick',
      'version': 1,
      'clientId': _clientId,
      'stick': stick,
      'x': x,
      'y': y,
    });
  }

  void sendTrigger({
    required String trigger,
    required double value,
  }) {
    _send({
      'type': 'trigger',
      'version': 1,
      'clientId': _clientId,
      'trigger': trigger,
      'value': value,
    });
  }

  void _send(Map<String, dynamic> message) {
    if (!_connected || _channel == null) {
      return;
    }

    _channel!.sink.add(
      jsonEncode(message),
    );
  }

  Future<void> disconnect() async {
    _stopHeartbeat();

    _connected = false;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();

    await _messages.close();
  }
}