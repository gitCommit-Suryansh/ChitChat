import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'search_user_screen.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';

class ChatListScreen extends StatefulWidget {
  static const routeName = '/chats';

  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChats();
    });
  }

  Future<void> _fetchChats() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.initSocket(auth.user!);
      await chatProvider.fetchChats(auth.user!.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const SearchUserScreen()),
              );
            },
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                Provider.of<AuthProvider>(context, listen: false).logout();
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text('My Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                backgroundImage: NetworkImage(user?.pic ?? ''),
                radius: 16,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (ctx, chatData, child) => chatData.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchChats,
                child: ListView.builder(
                  itemCount: chatData.chats.length,
                  itemBuilder: (ctx, i) {
                    final chat = chatData.chats[i];
                    return ChatTile(chat: chat, currentUser: user!);
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) => const CreateGroupScreen()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final Chat chat;
  final User currentUser;

  const ChatTile({
    super.key,
    required this.chat,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final chatName = chat.getChatName(currentUser.id);
    final chatPic = chat.getChatPic(currentUser.id);
    final latestMsg = chat.latestMessage;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chatPic),
        backgroundColor: Colors.teal.shade100,
      ),
      title: Text(
        chatName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: latestMsg != null
          ? Text(
              "${latestMsg.sender.name}: ${latestMsg.content}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : const Text("No messages yet"),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ChatScreen(chat: chat),
          ),
        );
      },
    );
  }
}
