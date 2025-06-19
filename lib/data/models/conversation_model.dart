import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.name,
    required super.lastMessage,
    required super.updatedAt,
    required super.unreadCount,
  });

  factory ConversationModel.fromMap(String id, Map<String, dynamic> data) {
    return ConversationModel(
      id: id,
      name: '', // vacío para asignar dinámicamente
      lastMessage: data['lastMessage'] ?? '',
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] is DateTime
                  ? data['updatedAt']
                  : DateTime.parse(data['updatedAt']))
              : null,
      unreadCount: data['unreadCount'] ?? 0,
    );
  }
}
