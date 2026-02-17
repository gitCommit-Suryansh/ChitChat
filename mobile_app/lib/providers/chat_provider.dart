import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Chat> _chats = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  IO.Socket? _socket;
  String? _activeChatId;

  List<Chat> get chats => _chats;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  IO.Socket? get socket => _socket;

  void setActiveChat(String? chatId) {
    _activeChatId = chatId;
  }

  void initSocket(User user) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io('http://10.62.60.169:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket!.connect();
    
    _socket!.onConnect((_) {
      print('Socket connected: ${_socket!.id}');
      _socket!.emit("setup", user.toJson());
    });

    _socket!.on('message received', (newMessageReceived) {
      print("Global Message received: $newMessageReceived");
      
      // Update Chats List (Latest Message)
      try {
         // Find if chat exists in list
         final chatIndex = _chats.indexWhere((c) => c.id == newMessageReceived['chat']['_id']);
         final message = Message.fromJson(newMessageReceived);
         
         if (chatIndex != -1) {
             // Move chat to top and update latest message
             final chat = _chats.removeAt(chatIndex);
             final updatedChat = Chat(
                 id: chat.id,
                 chatName: chat.chatName,
                 isGroupChat: chat.isGroupChat,
                 users: chat.users,
                 groupAdmin: chat.groupAdmin,
                 latestMessage: message
             );
             _chats.insert(0, updatedChat);
         } else {
             // New chat received via socket
             var chatMap = newMessageReceived['chat'];
             if (chatMap != null && chatMap is Map<String, dynamic>) {
                  Chat newChat = Chat.fromJson(chatMap);
                  // Force update latest message
                  newChat = Chat(
                      id: newChat.id,
                      chatName: newChat.chatName,
                      isGroupChat: newChat.isGroupChat,
                      users: newChat.users,
                      groupAdmin: newChat.groupAdmin,
                      latestMessage: message
                  );
                  _chats.insert(0, newChat);
             }
         }

         // Update Active Chat Messages if open
         if (_activeChatId == newMessageReceived['chat']['_id']) {
            _messages.add(message);
         }
         
         notifyListeners();
      } catch (e) {
          print("Error processing message received: $e");
      }
    });
  }
  
  void disconnectSocket() {
      if (_socket != null) {
          _socket!.disconnect();
          _socket = null;
      }
  }

  Future<void> fetchChats(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      _chats = await _chatService.fetchChats(token);
    } catch (e) {
      print(e);
      // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMessages(String chatId, String token) async {
    _isLoading = true;
    notifyListeners(); 
    try {
      _messages = await _chatService.fetchMessages(chatId, token);
      if (_socket != null) {
          _socket!.emit("join chat", chatId);
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Message> sendMessage(String content, String chatId, String token) async {
    try {
      Message newMessage = await _chatService.sendMessage(content, chatId, token);
      _messages.add(newMessage);
      
      // Update latest message in chat list
       final chatIndex = _chats.indexWhere((c) => c.id == chatId);
       if (chatIndex != -1) {
           final chat = _chats.removeAt(chatIndex);
            final updatedChat = Chat(
                 id: chat.id,
                 chatName: chat.chatName,
                 isGroupChat: chat.isGroupChat,
                 users: chat.users,
                 groupAdmin: chat.groupAdmin,
                 latestMessage: newMessage
             );
           _chats.insert(0, updatedChat);
       }
       
      notifyListeners();
      
      if (_socket != null) {
          _socket!.emit("new message", newMessage.toJson());
      }
      
      return newMessage;
    } catch (e) {
      print(e);
      throw e;
    }
  }
  
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  Future<void> createGroupChat(String name, List<User> users, String token) async {
    try {
      Chat groupChat = await _chatService.createGroupChat(name, users, token);
      _chats.insert(0, groupChat);
      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Chat> accessChat(String userId, String token) async {
    try {
      Chat chat = await _chatService.accessChat(userId, token);
      if (!_chats.any((c) => c.id == chat.id)) {
        _chats.insert(0, chat);
        notifyListeners();
      }
      return chat;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
