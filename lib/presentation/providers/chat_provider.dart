import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nolatech_messenger/presentation/providers/user_provider.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message.dart';

class ChatProvider extends ChangeNotifier {
  final SendUserMessage sendUserMessage;
  final ChatRepository repository;
  final UserProvider userProvider;

  ChatProvider(this.repository, this.userProvider, this.sendUserMessage);

  List<Conversation> conversations = [];
  List<Message> messages = [];
  bool isLoading = false;
  String? errorMessage;

  StreamSubscription<List<Conversation>>? _conversationSub;
  StreamSubscription<List<Message>>? _messageSub;

  void loadConversations() {
    final userId = userProvider.user?.id;
    if (userId == null) return;

    isLoading = true;
    notifyListeners();

    _conversationSub?.cancel();

    _conversationSub = repository
        .getUserConversations(userId)
        .listen(
          (chats) {
            conversations = chats;
            isLoading = false;
            errorMessage = null;
            notifyListeners();
          },
          onError: (e) {
            isLoading = false;
            errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  void listenToMessages(String chatId) {
    _messageSub?.cancel(); // Cancelar escucha anterior si existe

    _messageSub = repository
        .getMessages(chatId)
        .listen(
          (msgs) {
            messages = msgs;
            notifyListeners();
          },
          onError: (e) {
            errorMessage = e.toString();
            notifyListeners();
          },
        );
  }

  Future<void> sendMessage(String chatId, Message message) async {
    try {
      await sendUserMessage(chatId, message);
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    messages = [];
    _messageSub?.cancel();
    notifyListeners();
  }

  Future<void> openChat(String chatId) async {
    await repository.markMessagesAsRead(chatId, userProvider.user!.id);
    listenToMessages(chatId);
  }

  Future<List<User>> fetchAllUsers() async {
    return await repository.fetchAllUsers(); // Que venga del ChatRepository
  }

  Future<String> createOrGetChatWith(
    String otherUserId,
    String myUserId,
  ) async {
    return await repository.createOrGetChat(myUserId, otherUserId);
  }

  @override
  void dispose() {
    _conversationSub?.cancel();
    _messageSub?.cancel();
    super.dispose();
  }
}
