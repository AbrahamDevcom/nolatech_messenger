import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../presentation/utils/utils.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final DatabaseReference _dbRef;

  ChatRepositoryImpl() : _dbRef = FirebaseDatabase.instance.ref();

  @override
  Future<String> createOrGetChat(String userAId, String userBId) async {
    final chatId = _generateChatId(userAId, userBId);
    final chatRef = _dbRef.child('chats/$chatId');

    final chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      final now = DateTime.now().toIso8601String();

      final participants = {userAId: true, userBId: true};

      await chatRef.set({
        'participants': participants,
        'createdAt': now,
        'updatedAt': now,
        'lastMessage': '',
      });
    }

    return chatId;
  }

  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final chatRef = _dbRef.child('chats/$chatId');
    final messagesRef = chatRef.child('messages');
    final newMessageRef = messagesRef.push();

    final model = MessageModel(
      id: newMessageRef.key ?? '',
      senderId: message.senderId,
      content: message.content,
      timestamp: message.timestamp,
    );

    final messageData = model.toMap();

    final updates = <String, dynamic>{
      'chats/$chatId/messages/${model.id}': messageData,
      'chats/$chatId/lastMessage': message.content,
      'chats/$chatId/updatedAt': message.timestamp.toIso8601String(),
    };

    await _dbRef.update(updates);
  }

  @override
  Stream<List<Conversation>> getUserConversations(String userId) {
    final chatsRef = _dbRef.child('chats');

    return chatsRef.onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final conversations = <Conversation>[];

      for (final entry in data.entries) {
        final chatId = entry.key;
        final chatData = Map<String, dynamic>.from(entry.value);

        // Validar si el usuario es participante del chat
        final participants = Map<String, dynamic>.from(
          chatData['participants'] ?? {},
        );
        if (!participants.containsKey(userId)) continue;

        final lastMessage = chatData['lastMessage'] ?? '';
        final updatedAtRaw = chatData['updatedAt'];
        final updatedAt =
            DateTime.tryParse(updatedAtRaw ?? '') ?? DateTime.now();

        int unreadCount = 0;

        // Calcular mensajes no leídos
        final messagesSnapshot =
            await _dbRef.child('chats/$chatId/messages').get();
        if (messagesSnapshot.exists) {
          final messagesData = Map<String, dynamic>.from(
            messagesSnapshot.value as Map,
          );
          for (final msgEntry in messagesData.entries) {
            final msg = Map<String, dynamic>.from(msgEntry.value);
            final senderId = msg['senderId'];
            final readBy = Map<String, dynamic>.from(msg['readBy'] ?? {});
            if (senderId != userId && !readBy.containsKey(userId)) {
              unreadCount++;
            }
          }
        }

        // Obtener el nombre del otro usuario
        final otherUserId = extractOtherUserId(chatId, userId);
        final userSnapshot = await _dbRef.child('users/$otherUserId').get();
        final otherName =
            userSnapshot.child('name').value as String? ?? 'Usuario';

        final conversation = ConversationModel(
          id: chatId,
          name: otherName,
          lastMessage: lastMessage,
          updatedAt: updatedAt,
          unreadCount: unreadCount,
        );

        conversations.add(conversation);
      }

      // Ordenar por última actualización
      conversations.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
      return conversations;
    });
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    final messagesRef = _dbRef.child('chats/$chatId/messages');

    return messagesRef.onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      final messages =
          data.entries.map((entry) {
            final value = Map<String, dynamic>.from(entry.value);
            return MessageModel.fromMap(entry.key, value);
          }).toList();

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  @override
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final messagesRef = _dbRef.child('chats/$chatId/messages');
    final snapshot = await messagesRef.get();

    if (snapshot.exists) {
      final updates = <String, dynamic>{};

      final messages = Map<String, dynamic>.from(snapshot.value as Map);

      for (var entry in messages.entries) {
        final msg = Map<String, dynamic>.from(entry.value);
        final senderId = msg['senderId'];

        if (senderId != userId) {
          updates['$chatId/messages/${entry.key}/readBy/$userId'] = true;
        }
      }

      await _dbRef.child('chats').update(updates);
    }
  }

  @override
  Future<void> createChatIfNotExists(
    String chatId,
    List<String> participantIds,
  ) async {
    final chatRef = _dbRef.child('chats/$chatId');

    final snapshot = await chatRef.get();

    if (!snapshot.exists) {
      final now = DateTime.now().millisecondsSinceEpoch;

      // Estructura básica del chat
      final chatData = {
        'lastMessage': '',
        'updatedAt': now,
        'participants': {for (var id in participantIds) id: true},
      };

      await chatRef.set(chatData);

      // Crear referencias en los usuarios
      for (var id in participantIds) {
        await _dbRef.child('users/$id/chats/$chatId').set({
          'lastMessage': '',
          'updatedAt': now,
        });
      }
    }
  }

  @override
  Future<List<User>> fetchAllUsers() async {
    final snapshot = await _dbRef.child('users').get();

    if (!snapshot.exists) return [];

    final usersMap = snapshot.value as Map<dynamic, dynamic>;
    final users =
        usersMap.entries.map((entry) {
          final data = entry.value as Map<dynamic, dynamic>;
          return User(
            id: entry.key,
            email: data['email'] ?? '',
            name: data['name'],
          );
        }).toList();

    return users;
  }

  String _generateChatId(String userAId, String userBId) {
    final sorted = [userAId, userBId]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
