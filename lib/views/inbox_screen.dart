import 'package:flutter/material.dart';
import '../models/conversations.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    // Kick off the network request the exact moment the screen loads
    _conversationsFuture = _chatService.getConversations();
  }

  void _logout() async {
    await _authService.logout(); // Destroys the saved token
    if (!mounted) return;

    // Kick the user back to the login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          // 1. Still waiting for the Python server
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Python threw an error (or the network dropped)
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading chats:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // 3. Success, but the database table is empty
          final conversations = snapshot.data;
          if (conversations == null || conversations.isEmpty) {
            return const Center(child: Text('No chats yet. Create one!'));
          }

          // 4. Success! We have rooms. Build the list.
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              // If the room name is null, give it a default fallback name
              final roomName = conv.name ?? 'Room #${conv.id}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(roomName.substring(0, 1).toUpperCase()),
                  ),
                  title: Text(
                    roomName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Tap to enter Room ${conv.id}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to the Live Chat Screen, passing the selected room!
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(conversation: conv),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      // A placeholder button for creating new rooms later
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create room coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
