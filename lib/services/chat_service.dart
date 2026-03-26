import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/conversations.dart';
import '../models/message.dart';
import 'auth_service.dart';

class ChatService {
  static const String baseUrl = 'http://192.168.1.69:8000/api';
  final AuthService _authService = AuthService();

  Future<List<Conversation>> getConversations() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception("No token found. User must login");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/conversations'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Conversation.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load conversation: ${response.statusCode}');
    }
  }

  Future<List<Message>> getChatHistory(int conversationId) async {
    final token = await _authService.getToken();
    
    if (token == null) throw Exception('No token found.');

    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Message.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load history: ${response.statusCode}');
    }
  }
}
