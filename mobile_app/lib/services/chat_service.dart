import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class ChatService {

  static const String baseUrl = AppConstants.baseUrl;

  Future<List<Chat>> fetchChats(String token) async {
    print("Fetching chats from $baseUrl/chat");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10)); // 10s timeout

      print("Fetch chats response: ${response.statusCode}");
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        print("Chats loaded: ${body.length}");
        List<Chat> chats = body.map((dynamic item) => Chat.fromJson(item)).toList();
        return chats;
      } else {
        print("Fetch chats failed: ${response.body}");
        throw Exception("Failed to load chats: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch chats error: $e");
      throw Exception("Error fetching chats: $e");
    }
  }

  Future<List<Message>> fetchMessages(String chatId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/message/$chatId'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Message> messages = body.map((dynamic item) => Message.fromJson(item)).toList();
      return messages;
    } else {
      throw Exception("Failed to load messages");
    }
  }

  Future<Chat> accessChat(String userId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to access chat");
    }
  }

  Future<Message> sendMessage(String content, String chatId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/message'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "content": content,
        "chatId": chatId,
      }),
    );

    if (response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to send message");
    }
  }

  Future<List<User>> searchUsers(String query, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user?search=$query'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => User.fromJson(item)).toList();
    } else {
      throw Exception("Failed to search users");
    }
  }

  Future<Chat> createGroupChat(String name, List<User> users, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/group'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "users": jsonEncode(users.map((u) => u.id).toList()),
      }),
    );

    if (response.statusCode == 200) {
      return Chat.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create group chat");
    }
  }
}
