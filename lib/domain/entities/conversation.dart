class Conversation {
  final String id;
  String name; // nombre del otro usuario, mutable para asignar después
  final String lastMessage;
  final DateTime? updatedAt;
  final int unreadCount;

  Conversation({
    required this.id,
    this.name = '',
    required this.lastMessage,
    required this.updatedAt,
    required this.unreadCount,
  });
}
