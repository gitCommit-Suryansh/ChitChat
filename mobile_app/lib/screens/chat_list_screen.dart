import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    
    final isUnread = latestMsg != null && 
                     latestMsg.sender.id != currentUser.id && 
                     !latestMsg.readBy.any((userId) => userId == currentUser.id);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chatPic),
        backgroundColor: Colors.teal.shade100,
      ),
      title: Text(
        chatName,
        style: TextStyle(
          fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
          color: isUnread ? Colors.black : Colors.black87,
        ),
      ),
      subtitle: latestMsg != null
          ? Row(
              children: [
                if (latestMsg.sender.id == currentUser.id)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.done_all,
                      size: 14,
                      color: latestMsg.readBy.isNotEmpty
                          ? Colors.blue
                          : Colors.grey.shade500,
                    ),
                  ),
                Expanded(
                  child: Text(
                    latestMsg.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            )
          : const Text("No messages yet"),
      trailing: latestMsg != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(latestMsg.createdAt.toLocal()),
                  style: TextStyle(
                    fontSize: 12, 
                    color: isUnread ? Colors.green : Colors.grey,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  )
                ]
              ],
            )
          : null,
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
