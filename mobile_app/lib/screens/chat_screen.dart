import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Added this import
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
  bool _isTypingLocally = false;
  Timer? _typingTimer;

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
          chatProvider.fetchMessages(widget.chat.id, auth.user!.token, auth.user!);
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
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    // Stop typing immediately when message is sent
    chatProvider.emitStopTyping(widget.chat.id);
    setState(() {
      _isTypingLocally = false;
    });
    _typingTimer?.cancel();
    
    try {
        await chatProvider.sendMessage(
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
    _typingTimer?.cancel();
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              msg.content,
                                              style: const TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8, bottom: 0),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                    Text(
                                                        DateFormat('HH:mm').format(msg.createdAt.toLocal()),
                                                        style: const TextStyle(fontSize: 10, color: Colors.black54),
                                                    ),
                                                    if (isMe) ...[
                                                        const SizedBox(width: 4),
                                                        Icon(
                                                            Icons.done_all,
                                                            size: 14,
                                                            color: msg.readBy.isNotEmpty ? Colors.blue : Colors.grey.shade400,
                                                        ),
                                                    ]
                                                ],
                                            ),
                                          ),
                                        ],
                                      ),
                                   ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (ctx, chatData, child) {
                if (chatData.isTyping && !_isTypingLocally) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "Someone is typing...",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (text) {
                        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
                        if (!_isTypingLocally) {
                          setState(() {
                            _isTypingLocally = true;
                          });
                          chatProvider.emitTyping(widget.chat.id);
                        }
                        
                        _typingTimer?.cancel();
                        _typingTimer = Timer(const Duration(seconds: 3), () {
                          if (_isTypingLocally) {
                            setState(() {
                              _isTypingLocally = false;
                            });
                            chatProvider.emitStopTyping(widget.chat.id);
                          }
                        });
                      },
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
