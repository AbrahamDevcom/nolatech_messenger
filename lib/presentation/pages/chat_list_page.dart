import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'chat_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body:
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : ListView.builder(
                itemCount: provider.conversations.length,
                itemBuilder: (context, index) {
                  final chat = provider.conversations[index];
                  return ListTile(
                    title: Text(
                      chat.name.isNotEmpty ? chat.name : 'Cargando...',
                    ),
                    subtitle: Text(chat.lastMessage),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ChatPage(
                                  chatId: chat.id,
                                  recipientName:
                                      chat.name.isNotEmpty
                                          ? chat.name
                                          : 'Cargando...',
                                ),
                          ),
                        ),
                  );
                },
              ),
    );
  }
}
