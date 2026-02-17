import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  int _prevMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChat();
    });
  }
  
  void _initChat() {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      chatProvider.setActiveChat(widget.chat.id);
      
      if (auth.user != null) {
          chatProvider.fetchMessages(widget.chat.id, auth.user!.token);
      }
  }

  void _scrollToBottom() {
      if (_scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
          });
      }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text;
    _messageController.clear();
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    try {
        await Provider.of<ChatProvider>(context, listen: false).sendMessage(
            content, 
            widget.chat.id, 
            auth.user!.token
        );
        _scrollToBottom();
    } catch (e) {
        print("Send message error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to send message")),
        );
    }
  }

  @override
  void dispose() {
    // We can't access context easily here if the widget is removed from tree, 
    // but we should try to clear active chat id.
    // However, since we use SchedulerBinding in init, let's just leave it or use a proper lifecycle handling.
    // Actually, we can use WidgetsBinding.instance.addPostFrameCallback in initState to set, 
    // but in dispose, we can just assume the next screen (ChatList) won't have this chat active.
    // Better:
    super.dispose();
    _messageController.dispose();
    _scrollController.dispose();
  }
  
  // We need to clear active chat whenever we leave this screen.
  // We can do it in deactivate or pop.
  @override
  void deactivate() {
      Provider.of<ChatProvider>(context, listen: false).setActiveChat(null);
      super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final chatName = widget.chat.getChatName(user!.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
             image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
             fit: BoxFit.cover,
             opacity: 0.05,
          )
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (ctx, chatData, child) {
                    // Auto scroll handling
                    if (chatData.messages.length > _prevMessageCount) {
                        _prevMessageCount = chatData.messages.length;
                        _scrollToBottom();
                    }
                    
                    return chatData.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: chatData.messages.length,
                        padding: const EdgeInsets.all(10),
                        itemBuilder: (ctx, i) {
                          final msg = chatData.messages[i];
                          final isMe = msg.sender.id == user.id;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.teal.shade100 : Colors.white,
                                borderRadius: BorderRadius.circular(12).copyWith(
                                    bottomRight: isMe ? Radius.zero : null,
                                    bottomLeft: !isMe ? Radius.zero : null,
                                ),
                                boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))
                                ]
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   if (!isMe && widget.chat.isGroupChat)
                                     Text(
                                        msg.sender.name,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                     ),
                                   Text(
                                    msg.content,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
