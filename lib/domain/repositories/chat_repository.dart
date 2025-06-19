import '../entities/conversation.dart';
import '../entities/message.dart';
import '../entities/user.dart';

abstract class ChatRepository {
  Stream<List<Conversation>> getUserConversations(String userId);
  Stream<List<Message>> getMessages(String chatId);
  Future<void> sendMessage(String chatId, Message message);
  Future<void> markMessagesAsRead(String chatId, String userId);
  Future<void> createChatIfNotExists(
    String chatId,
    List<String> participantIds,
  );
  Future<List<User>> fetchAllUsers();
  Future<String> createOrGetChat(String userAId, String userBId);
}
