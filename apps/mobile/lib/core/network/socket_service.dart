import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../../core/security/auth_manager.dart';

class SocketService {
  late IO.Socket _socket;
  final String _serverUrl;
  final AuthManager _authManager;

  SocketService(this._serverUrl, this._authManager);

  void connect(String deviceId) async {
    final tokens = await _authManager.getTokens();
    final at = tokens['access_token'];

    _socket = IO.io(_serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': 'Bearer $at'})
      .setQuery({'deviceId': deviceId})
      .enableAutoConnect()
      .build());

    _socket.onConnect((_) => debugPrint('Privora: Connected to Relay Server'));
    _socket.onDisconnect((_) => debugPrint('Privora: Disconnected from Relay Server'));
    _socket.onConnectError((e) => debugPrint('Privora: Connection Error: $e'));
  }

  void onReceiveMessage(Function(dynamic) callback) {
    _socket.on('receive_message', callback);
  }

  void onRtcOffer(Function(dynamic) callback) {
    _socket.on('rtc_offer', callback);
  }

  void onRtcAnswer(Function(dynamic) callback) {
    _socket.on('rtc_answer', callback);
  }

  void onIceCandidate(Function(dynamic) callback) {
    _socket.on('rtc_ice_candidate', callback);
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void disconnect() {
    _socket.disconnect();
  }
}
