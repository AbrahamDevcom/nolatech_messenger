import 'package:flutter/material.dart';
import 'package:nolatech_messenger/presentation/providers/auth_provider.dart';
import 'package:nolatech_messenger/presentation/utils/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadConversations();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final allConversations = chatProvider.conversations;

    final filteredConversations =
        allConversations.where((c) {
          final name = c.name.toLowerCase();
          final lastMsg = c.lastMessage.toLowerCase();
          return name.contains(_searchQuery) || lastMsg.contains(_searchQuery);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              context.go(AppRoutes.login);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar conversación...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body:
          chatProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredConversations.isEmpty
              ? const Center(
                child: Text(
                  'No tienes conversaciones todavía.',
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.separated(
                itemCount: filteredConversations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conv = filteredConversations[index];

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      conv.name.isNotEmpty ? conv.name : 'Cargando...',
                    ),
                    subtitle: Text(
                      conv.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(conv.updatedAt!),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (conv.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${conv.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      context.push(
                        '${AppRoutes.chat}/${conv.id}',
                        extra: conv.name,
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.newChat); // Pantalla para seleccionar usuario
        },
        child: const Icon(Icons.chat),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }
}
