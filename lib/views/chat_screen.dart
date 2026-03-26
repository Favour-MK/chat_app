import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/conversations.dart';
import '../models/message.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  bool _isLoadingHistory = true;
  WebSocketChannel? _channel;
  int? _currentUserId; // To figure out if a message is "mine" or "theirs"

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // 1. The Master Setup Function
  Future<void> _initializeChat() async {
    try {
      // Fetch the token and extract our user ID so we can align chat bubbles!
      final token = await _authService.getToken();
      if (token != null) {
        _currentUserId = _getUserIdFromToken(token);
      }

      // Step A: Download the old messages using REST
      final history = await _chatService.getChatHistory(widget.conversation.id);
      setState(() {
        _messages = history;
        _isLoadingHistory = false;
      });
      _scrollToBottom();

      // Step B: Open the live WebSocket door!
      if (token != null) {
        _connectWebSocket(token);
      }
    } catch (e) {
      print("Error initializing chat: $e");
      setState(() => _isLoadingHistory = false);
    }
  }

  // 2. The WebSocket Handshake
  // 2. The WebSocket Handshake (Now with loud error reporting!)
  void _connectWebSocket(String token) {
    // 🚨 DOUBLE CHECK THIS IP ADDRESS! 🚨
    final wsUrl = Uri.parse(
      'ws://192.168.1.69:8000/ws/chat/${widget.conversation.id}?token=$token',
    );

    print("🚀 ATTEMPTING WEBSOCKET CONNECTION: $wsUrl");

    try {
      _channel = WebSocketChannel.connect(wsUrl);

      _channel!.stream.listen(
        (messageData) {
          print("🟢 LIVE MESSAGE RECEIVED: $messageData");
          final decodedData = jsonDecode(messageData);
          final newMessage = Message.fromJson(decodedData);

          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        },
        onError: (error) {
          print("🔴 WEBSOCKET ERROR: $error");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Connection Error: $error')));
        },
        onDone: () {
          print("⚫ WEBSOCKET CLOSED");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Live chat disconnected. Check terminal.'),
            ),
          );
        },
      );
    } catch (e) {
      print("💥 FATAL WEBSOCKET CRASH: $e");
    }
  }

  // 4. Send a message (Now checks if the door is actually open)
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    if (_channel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send: Not connected to server!')),
      );
      return;
    }

    print("📤 SENDING TO SERVER: ${_messageController.text}");
    _channel!.sink.add(_messageController.text.trim());
    _messageController.clear();
  }

  // Helper to decode the JWT token to find out who we are
  int _getUserIdFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return 0;
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final resp = utf8.decode(base64Url.decode(normalized));
    final payloadMap = jsonDecode(resp);
    return int.parse(payloadMap['sub'].toString());
  }

  // Helper to auto-scroll to the newest message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // CRITICAL: Always hang up the phone when the user leaves the screen!
    _channel?.sink.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomName =
        widget.conversation.name ?? 'Room #${widget.conversation.id}';

    return Scaffold(
      appBar: AppBar(title: Text(roomName)),
      body: Column(
        children: [
          // The Chat Log
          Expanded(
            child: _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg.senderId == _currentUserId;

                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // The Input Area
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
