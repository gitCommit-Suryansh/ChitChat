import 'user_model.dart';
import 'message_model.dart';

class Chat {
  final String id;
  final String chatName;
  final bool isGroupChat;
  final List<User> users;
  final Message? latestMessage;
  final User? groupAdmin;

  Chat({
    required this.id,
    required this.chatName,
    required this.isGroupChat,
    required this.users,
    this.latestMessage,
    this.groupAdmin,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    var usersList = (json['users'] as List?) ?? [];
    List<User> users = usersList
        .where((i) => i != null && i is Map<String, dynamic>)
        .map((i) => User.fromJson(i))
        .toList();

    return Chat(
      id: json['_id'] ?? '',
      chatName: json['chatName'] ?? 'Chat',
      isGroupChat: json['isGroupChat'] ?? false,
      users: users,
      latestMessage: (json['latestMessage'] != null && json['latestMessage'] is Map<String, dynamic>)
          ? Message.fromJson(json['latestMessage'])
          : null,
      groupAdmin: (json['groupAdmin'] != null && json['groupAdmin'] is Map<String, dynamic>)
          ? User.fromJson(json['groupAdmin'])
          : null,
    );
  }
  
  String getChatName(String currentUserId) {
    if (isGroupChat) {
      return chatName;
    } else {
      // Find the other user
      final otherUser = users.firstWhere(
        (u) => u.id != currentUserId, 
        orElse: () => User(id: '', name: 'Deleted User', email: '', pic: '', token: '')
      );
      return otherUser.name;
    }
  }
  
  String getChatPic(String currentUserId) {
    if (isGroupChat) {
      return "https://icon-library.com/images/group-icon-png/group-icon-png-10.jpg"; 
    } else {
       final otherUser = users.firstWhere(
        (u) => u.id != currentUserId, 
        orElse: () => User(id: '', name: 'Deleted User', email: '', pic: 'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg', token: '')
      );
      return otherUser.pic;
    }
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'chatName': chatName,
      'isGroupChat': isGroupChat,
      'users': users.map((u) => u.toJson()).toList(),
      // 'latestMessage': latestMessage?.toJson(), // Avoid circular dependency
      'groupAdmin': groupAdmin?.toJson(),
    };
  }
}
