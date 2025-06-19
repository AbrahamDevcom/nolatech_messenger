import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../router/app_routes.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  List<User> allUsers = [];
  bool isLoading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = context.read<UserProvider>().user?.id;

    final users = await chatProvider.fetchAllUsers();

    // Excluimos al usuario actual
    final filtered = users.where((u) => u.id != currentUserId).toList();

    setState(() {
      allUsers = filtered;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers =
        allUsers.where((user) {
          final name = user.email.toLowerCase(); // O usa user.name si tienes
          return name.contains(search.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo chat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredUsers.isEmpty
              ? const Center(
                child: Text('No se encontraron usuarios disponibles'),
              )
              : allUsers.isEmpty
              ? const Center(
                child: Text(
                  'No hay otros usuarios disponibles para chatear.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.separated(
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(user.email),
                    onTap: () async {
                      final currentUserId =
                          context.read<UserProvider>().user!.id;
                      final chatId = await context
                          .read<ChatProvider>()
                          .createOrGetChatWith(user.id, currentUserId);

                      if (mounted) {
                        context.go('${AppRoutes.chat}/$chatId');
                      }
                    },
                  );
                },
              ),
    );
  }
}
