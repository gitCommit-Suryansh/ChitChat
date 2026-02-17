import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  final List<User> _selectedUsers = [];
  bool _isLoading = false;
  final ChatService _chatService = ChatService();

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
        setState(() {
            _searchResults = [];
        });
        return;
    }
    
    final token = Provider.of<AuthProvider>(context, listen: false).user!.token;
    try {
      final results = await _chatService.searchUsers(query, token);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      print(e);
    }
  }

  void _toggleUserSelection(User user) {
    setState(() {
      if (_selectedUsers.contains(user)) {
        _selectedUsers.remove(user);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.isEmpty || _selectedUsers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name and select at least 2 users")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).user!.token;
      await Provider.of<ChatProvider>(context, listen: false).createGroupChat(
        _groupNameController.text,
        _selectedUsers,
        token,
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create group")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group Chat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Search Users to add",
                border: OutlineInputBorder(),
              ),
              onChanged: _handleSearch,
            ),
            const SizedBox(height: 10),
            Wrap(
              children: _selectedUsers.map((u) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Chip(
                  label: Text(u.name),
                  onDeleted: () => _toggleUserSelection(u),
                  backgroundColor: Colors.teal.shade100,
                ),
              )).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) {
                  final user = _searchResults[i];
                  final isSelected = _selectedUsers.contains(user);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.pic),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.teal) : null,
                    onTap: () => _toggleUserSelection(user),
                  );
                },
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _createGroup,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                      child: const Text("Create Chat"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
