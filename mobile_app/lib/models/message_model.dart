import 'user_model.dart';
import 'chat_model.dart';

class Message {
  final String id;
  final User sender;
  final String content;
  final Chat? chat;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    this.chat,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      sender: (json['sender'] is Map<String, dynamic>)
          ? User.fromJson(json['sender'])
          : User(id: json['sender'].toString(), name: 'Unknown', email: '', pic: '', token: ''),
      content: json['content'] ?? '',
      chat: (json['chat'] != null && json['chat'] is Map<String, dynamic>)
          ? Chat.fromJson(json['chat'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender.toJson(),
      'content': content,
      'chat': chat?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
