import '../entities/message.dart';
import '../repositories/chat_repository.dart';

class SendUserMessage {
  final ChatRepository repository;

  SendUserMessage(this.repository);

  Future<void> call(String chatId, Message message) {
    return repository.sendMessage(chatId, message);
  }
}
