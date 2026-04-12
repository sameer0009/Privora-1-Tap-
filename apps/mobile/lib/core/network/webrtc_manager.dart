import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/foundation.dart';
import 'socket_service.dart';

class WebRTCManager {
  final SocketService _socket;
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  WebRTCManager(this._socket);

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ],
  };

  /// Initialize P2P connection for a specific target device
  Future<void> initConnection(String targetDeviceId, String myDeviceId, Function(String) onMessageReceived) async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      _socket.emit('rtc_ice_candidate', {
        'toDeviceId': targetDeviceId,
        'fromDeviceId': myDeviceId,
        'candidate': candidate.toMap(),
      });
    };

    _dataChannel = await _peerConnection!.createDataChannel('privora_file_transfer', RTCDataChannelInit());
    _setupDataChannel(onMessageReceived);

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _socket.emit('rtc_offer', {
      'toDeviceId': targetDeviceId,
      'fromDeviceId': myDeviceId,
      'offer': offer.toMap(),
    });
  }

  /// Handle incoming offer
  Future<void> handleOffer(String fromDeviceId, String myDeviceId, dynamic offerData) async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      _socket.emit('rtc_ice_candidate', {
        'toDeviceId': fromDeviceId,
        'fromDeviceId': myDeviceId,
        'candidate': candidate.toMap(),
      });
    };

    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel((msg) => debugPrint('Privora: Direct Received: $msg'));
    };

    await _peerConnection!.setRemoteDescription(RTCSessionDescription(offerData['sdp'], offerData['type']));
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _socket.emit('rtc_answer', {
      'toDeviceId': fromDeviceId,
      'fromDeviceId': myDeviceId,
      'answer': answer.toMap(),
    });
  }

  /// Handle incoming answer
  Future<void> handleAnswer(dynamic answerData) async {
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(answerData['sdp'], answerData['type']));
  }

  /// Handle incoming ICE candidate
  Future<void> handleIceCandidate(dynamic candidateData) async {
    await _peerConnection!.addCandidate(RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    ));
  }

  void _setupDataChannel(Function(String) onMessageReceived) {
    _dataChannel?.onMessage = (data) {
      onMessageReceived(data.text);
    };
  }

  Future<void> sendDirectMessage(String message) async {
    if (_dataChannel != null && _dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage(message));
    }
  }

  void dispose() {
    _dataChannel?.close();
    _peerConnection?.close();
  }
}
