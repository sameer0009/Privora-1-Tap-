import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/socket_service.dart';
import '../../core/network/webrtc_manager.dart';
import '../../core/network/connectivity_service.dart';
import 'base_providers.dart';
import 'auth_provider.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isMe;
  final bool isDirect; // WebRTC P2P status

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMe,
    this.isDirect = false,
  });
}

class ChatNotifier extends Notifier<List<ChatMessage>> {
  late SocketService _socket;
  late WebRTCManager _webrtc;

  @override
  List<ChatMessage> build() {
    _socket = ref.read(socketServiceProvider);
    _webrtc = ref.read(webrtcManagerProvider);

    // Listen for incoming relay messages
    _socket.onReceiveMessage((data) {
      receiveMessage(data['fromDeviceId'], data['content']);
    });

    // Listen for WebRTC signaling
    _socket.onRtcOffer((data) {
      final myDeviceId = ref.read(authProvider).deviceId;
      _webrtc.handleOffer(data['fromDeviceId'], myDeviceId, data['offer']);
    });

    return [];
  }

  Future<void> sendSecureMessage(String deviceId, String pubKey, String text) async {
    final myMsg = ChatMessage(
      id: DateTime.now().toString(),
      senderId: 'me',
      content: text,
      timestamp: DateTime.now(),
      isMe: true,
    );
    
    state = [...state, myMsg];

    // Adaptive Routing Logic
    final connectivity = ref.read(connectivityServiceProvider.notifier);
    
    try {
      if (connectivity.isOnWifi) {
        // Prefer WebRTC P2P on Local Network
        debugPrint('Privora: Attempting P2P delivery...');
        await _webrtc.sendDirectMessage(text);
        // Note: In this MVP, we fallback to Socket if Send fails or isn't open yet.
      }
    } catch (e) {
       debugPrint('Privora: Direct P2P failed, falling back to Relay...');
    }

    // Always ensure relay delivery for reliability in this build
    final repository = ref.read(chatRepositoryProvider);
    await repository.sendMessage(
      peerDeviceId: deviceId,
      peerPublicKey: pubKey,
      message: text,
    );
  }

  void receiveMessage(String senderId, String content) {
    final msg = ChatMessage(
      id: DateTime.now().toString(),
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      isMe: false,
    );
    state = [...state, msg];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

// Added providers for new services
final socketServiceProvider = Provider<SocketService>((ref) {
  // Use PC local IP for Physical Android devices
  return SocketService('http://192.168.100.32:3001', ref.read(authManagerProvider));
});

final webrtcManagerProvider = Provider<WebRTCManager>((ref) {
  return WebRTCManager(ref.read(socketServiceProvider));
});
