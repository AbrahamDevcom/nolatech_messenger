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
  Stream<List<Conversation>> getUserConversations(String userId) {
    return _dbRef.child('users/$userId/chats').onValue.asyncMap((event) async {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      final futures = <Future<ConversationModel>>[];

      for (final entry in data.entries) {
        final chatId = entry.key as String;
        final chatData = Map<String, dynamic>.from(entry.value);

        final otherUserId = extractOtherUserId(chatId, userId);

        final future = _dbRef.child('users/$otherUserId').get().then((
          snapshot,
        ) {
          final otherName =
              snapshot.child('name').value as String? ?? 'Usuario';

          final conversation = ConversationModel.fromMap(chatId, chatData);
          conversation.name = otherName;
          return conversation;
        });

        futures.add(future);
      }

      return await Future.wait(futures);
    });
  }

  @override
  Stream<List<Message>> getMessages(String chatId) {
    final messagesRef = _dbRef.child('chats/$chatId/messages');

    return messagesRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final Map<dynamic, dynamic> messagesMap = data as Map<dynamic, dynamic>;

      final messages =
          messagesMap.entries.map((entry) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(
              entry.value,
            );
            return MessageModel.fromMap(entry.key, map);
          }).toList();

      // Ordenar por timestamp ascendente
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    });
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

    final updatedFields = {
      'lastMessage': message.content,
      'updatedAt': message.timestamp.toIso8601String(),
    };

    final updates = <String, dynamic>{};

    // 1. Agregar el mensaje
    updates['chats/$chatId/messages/${model.id}'] = messageData;

    // 2. Actualizar el resumen del chat
    updatedFields.forEach((key, value) {
      updates['chats/$chatId/$key'] = value;
    });

    // 3. Actualizar SOLO el resumen del chat en el nodo del usuario autenticado
    final currentUid = message.senderId;
    updatedFields.forEach((key, value) {
      updates['users/$currentUid/chats/$chatId/$key'] = value;
    });

    // Ejecutar todas las actualizaciones en un solo batch
    await _dbRef.update(updates);
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

  @override
  Future<String> createOrGetChat(String userAId, String userBId) async {
    final chatId = _generateChatId(userAId, userBId);
    final chatRef = _dbRef.child('chats/$chatId');

    final chatSnapshot = await chatRef.get();
    if (!chatSnapshot.exists) {
      // Crear el chat
      final now = DateTime.now().toIso8601String();

      final participants = {userAId: true, userBId: true};

      await chatRef.set({
        'participants': participants,
        'createdAt': now,
        'updatedAt': now,
        'lastMessage': '',
      });

      // Crear referencia para cada usuario
      for (final userId in [userAId, userBId]) {
        await _dbRef.child('users/$userId/chats/$chatId').set({
          'updatedAt': now,
          'lastMessage': '',
        });
      }
    }

    return chatId;
  }

  String _generateChatId(String userAId, String userBId) {
    final sorted = [userAId, userBId]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
