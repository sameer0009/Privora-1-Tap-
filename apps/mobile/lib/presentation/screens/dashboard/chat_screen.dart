import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chat_provider.dart';
import '../../components/chat_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String deviceId;
  final String peerPublicKey;

  const ChatScreen({
    super.key, 
    required this.deviceId, 
    required this.peerPublicKey
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    ref.read(chatProvider.notifier).sendSecureMessage(
      widget.deviceId,
      widget.peerPublicKey,
      _messageController.text.trim(),
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Secure Session', style: TextStyle(fontSize: 16)),
            Text(
              'Encrypted with X25519 + AES-GCM',
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                return ChatBubble(
                  content: msg.content,
                  isMe: msg.isMe,
                  timestamp: msg.timestamp,
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: const Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration.collapsed(hintText: 'Type secure message...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
