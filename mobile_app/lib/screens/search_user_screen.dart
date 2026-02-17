import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isLoading = false;
  final ChatService _chatService = ChatService();

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
        setState(() {
            _searchResults = [];
        });
        return;
    }
    
    setState(() {
        _isLoading = true;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).user!.token;
    try {
      final results = await _chatService.searchUsers(query, token);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to search users")),
      );
    } finally {
        setState(() {
            _isLoading = false;
        });
    }
  }
  
  Future<void> _accessChat(String userId) async {
    setState(() {
      _isLoading = true;
    });
    
    final token = Provider.of<AuthProvider>(context, listen: false).user!.token;
    try {
      Chat chat = await Provider.of<ChatProvider>(context, listen: false).accessChat(userId, token);
      
      if (!mounted) return;
      
      // Navigate to chat screen and remove search screen from stack so back button goes to chat list
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => ChatScreen(chat: chat)),
      );
    } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to access chat")),
        );
    } finally {
        if (mounted) {
            setState(() {
               _isLoading = false;
            });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: const InputDecoration(
            hintText: "Search users...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onSubmitted: _handleSearch,
        ),
        actions: [
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _handleSearch(_searchController.text),
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (ctx, i) {
                final user = _searchResults[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.pic),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () => _accessChat(user.id),
                );
              },
            ),
    );
  }
}
